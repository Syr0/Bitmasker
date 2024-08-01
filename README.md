This is a project in German compiled in Purebasic.
The Tool is GUI-only and is used to color documents / technical descriptions to visually describe protocols and other stuff.
You can use 5 ways to identify the position you want to highlight. Once highlighted, the data on this position can be extracted with one click.
The tool builds "masks" that can be applied on any new file with this mask.
These are the five ways to mask the data fields:
- absolute Position (Position and Length needed)
- Regex (multiple or just one catching group)
- Pointer + Offset (Read any number out of the data, go to that position and paint that position. The Pointer can be varied in length, a offset can be added and it can be multipülied with any constant)
- Valuetable (Table of Values to be searched for)
- Relative positions(specify any other alrady defined Datafield, e.g. a regex, then add any offset to that position and read 'length' chars from there)



![image](https://github.com/user-attachments/assets/cb58097e-1a89-4dd7-b250-8867de44a1c8)

Optionale Orientierung:

![image](https://github.com/user-attachments/assets/f731c591-6894-4f93-a7ab-3ccd0c967ca3)
