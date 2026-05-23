@echo off
set PY=C:\Users\shivr\AppData\Local\Programs\Python\Python312\python.exe
set CLI=C:\Users\shivr\TuyaOpen\tools\tyutool\tyutool_cli.py

set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
set PATH=C:\Users\shivr\AppData\Local\Programs\Python\Python312;C:\Users\shivr\AppData\Local\Programs\Python\Python312\Scripts;%PATH%

echo Make sure the T5 AI board is plugged into COM11.
pause

"%PY%" "%CLI%" write -d T5AI -p COM12 -b 115200 -f C:\Users\shivr\TuyaOpen\examples\freshrfridge\.build\bin\freshrfridge_QIO_1.0.0.bin
pause