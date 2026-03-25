
protocol: 1.7
project_instructions: 2.8

## If your Project Instructions version doesn't match
Your version is in the header of your pasted instructions
(e.g., "v2.8" or "v2.8-local"). If it doesn't match the
project_instructions value above (ignore "-local" suffix),
tell the user:
  "Your Project Instructions are v[yours] but the current
  version is v[current]. Want me to fetch the latest so
  you can update?"
If yes → fetch the full file from:
  https://raw.githubusercontent.com/andrewalan11/DataWizard/main/COPY%20INTO%20CLAUDE%20PROJECT.md
Print the paste block (between the ``` fences) in full so
the user can copy it into Settings → Project Instructions.
Remind them to keep their Home folder line.
If no → continue with current instructions.
