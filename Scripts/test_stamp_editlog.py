#!/usr/bin/env python3
"""Regression suite for stamp_editlog.py. 9 base groups (census shapes/edges) +
4 adversarial cases from the S303 Round 2 code review (CR1-CR4). Run: python3 test_stamp_editlog.py"""
import subprocess, os, sys
HERE=os.path.dirname(os.path.abspath(__file__)); SCRIPT=os.path.join(HERE,"stamp_editlog.py")
try: import yaml; HAVE_YAML=True
except ImportError: HAVE_YAML=False
os.makedirs("t", exist_ok=True)
def run(args, rc=0):
    r=subprocess.run([sys.executable,SCRIPT]+args,capture_output=True,text=True)
    assert r.returncode==rc,"rc=%d want %d\n%s\n%s"%(r.returncode,rc,r.stdout,r.stderr)
    return r
def write(n,s): open("t/"+n,"w",newline="").write(s)
def raw(n): return open("t/"+n,encoding="utf-8",newline="").read()
def fm(n):
    assert HAVE_YAML; import yaml
    return yaml.safe_load(raw(n).split("---",2)[1])
P=[]
def ok(m): P.append(m); print("  PASS:",m)

# ---- base groups (condensed from the S70 build suite) ----
print("== base: F2 wrapped-tail, F3 flow+empty, F5 dedupe+quote, F4, missing-key, BOM ==")
write("wrap.md","---\ntitle: X\nedit_log:\n  - DW-S1 short\n"
 '  - "DW-S2 - long entry wrapped\n    onto a continuation line"\ntags:\n  - a\n---\nbody\n')
run(["--file","t/wrap.md","--entry","RW-S70 new"])
if HAVE_YAML:
    d=fm("wrap.md"); assert len(d["edit_log"])==3 and d["edit_log"][-1]=="RW-S70 new"
    assert "continuation line" in d["edit_log"][1] and d["tags"]==["a"]
ok("F2 wrapped-tail insert, tags untouched")
write("flow.md","---\ntags: [design, yaml]\n---\nb\n"); run(["--file","t/flow.md","--entry","new","--key","tags"])
if HAVE_YAML: assert fm("flow.md")["tags"]==["design","yaml","new"]
ok("F3 flow normalize+append")
write("ef.md","---\nedit_log: []\nt: z\n---\nb\n"); run(["--file","t/ef.md","--entry","first"])
if HAVE_YAML: assert fm("ef.md")["edit_log"]==["first"]
ok("F3 empty [] gets first item")
r=run(["--file","t/wrap.md","--entry","RW-S70 new"]); assert "duplicate-noop" in r.stdout
ok("F5 dedupe no-op")
write("q.md","---\nedit_log:\n  - a\n---\nb\n"); run(["--file","t/q.md","--entry","DW-S9 - v4.6.4: rule"])
if HAVE_YAML: assert fm("q.md")["edit_log"][-1]=="DW-S9 - v4.6.4: rule"
assert '"DW-S9 - v4.6.4: rule"' in raw("q.md"); ok("F5 colon-space quoted + round-trips")
write("u.md","---\nedit_log:\n  - a\nupdated: '2020-01-01'\n---\nb\n"); run(["--file","t/u.md","--entry","b"])
if HAVE_YAML: assert str(fm("u.md")["updated"])=="2020-01-01"
run(["--file","t/u.md","--entry","c","--updated","2026-08-30"])
if HAVE_YAML: assert str(fm("u.md")["updated"])=="2026-08-30"
ok("F4 updated untouched unless --updated")
write("mk.md","---\ntitle: only\n---\nb\n"); run(["--file","t/mk.md","--entry","x"],rc=1)
run(["--file","t/mk.md","--entry","x","--create-key"]); ok("missing key refuse / --create-key")
write("bom.md","﻿---\r\nedit_log:\r\n  - a\r\n---\r\nb\r\n"); b=raw("bom.md")
run(["--file","t/bom.md","--entry","z"]); a=raw("bom.md")
assert a.startswith("﻿") and "  - z\r\n" in a and a.count("\r\n")==b.count("\r\n")+1
ok("BOM+CRLF byte-faithful")

# ---- S303 Round 2 adversarial cases ----
print("== Round 2: CR1 scalar, CR2 block-scalar + nested-map, CR3 zero-indent, CR4 nested flow ==")
write("cr1.md","---\nedit_log: DW-S1 2026-01-01\n---\nb\n"); snap=raw("cr1.md")
r=run(["--file","t/cr1.md","--entry","NEW"],rc=1); assert "not-an-array" in r.stdout
assert raw("cr1.md")==snap, "CR1: scalar file must be untouched"
ok("CR1 scalar edit_log REFUSED, file unchanged")
write("cr2a.md","---\nnotes: >-\n  folded line one\n  folded line two\n---\nb\n"); snap=raw("cr2a.md")
r=run(["--file","t/cr2a.md","--entry","NEW","--key","notes"],rc=1); assert "not-an-array" in r.stdout
assert raw("cr2a.md")==snap; ok("CR2 block scalar (>-) REFUSED, file unchanged")
write("cr2b.md","---\nmeta:\n  sub: val\n---\nb\n"); snap=raw("cr2b.md")
r=run(["--file","t/cr2b.md","--entry","NEW","--key","meta"],rc=1); assert "not-an-array" in r.stdout
assert raw("cr2b.md")==snap; ok("CR2 nested mapping under empty key REFUSED, file unchanged")
write("cr3.md","---\nedit_log:\n- old one\n- old two\n---\nb\n")
run(["--file","t/cr3.md","--entry","new three"])
if HAVE_YAML:
    d=fm("cr3.md"); assert d["edit_log"]==["old one","old two","new three"], d["edit_log"]
assert "\n- new three\n" in raw("cr3.md"), "CR3: new item must be at column 0 to match existing"
r=run(["--file","t/cr3.md","--entry","old two"]); assert "duplicate-noop" in r.stdout, "CR3 dedupe must see zero-indent items"
ok("CR3 zero-indent items: new item matches indent, dedupe sees them")
# CR4 nested flow: must NOT split at the inner comma
import importlib.util
spec=importlib.util.spec_from_file_location("se",SCRIPT); se=importlib.util.module_from_spec(spec); spec.loader.exec_module(se)
items=se.parse_flow("a, [b, c], d")
assert items==["a","[b, c]","d"], "CR4 parse_flow nested: %r"%items
ok("CR4 nested flow [a, [b, c], d] -> 3 items (no split at inner comma)")

print("\n== ALL %d GROUPS PASSED%s ==" % (len(P), "" if HAVE_YAML else " (structural; pyyaml absent)"))
