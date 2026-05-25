@echo off
REM Shared settings — edit COM_PORT if Device Manager shows a different port
set "COM_PORT=COM12"
set "TUYA_OPEN=C:\Users\shivr\TuyaOpen"
set "TUYA_OPEN_ROOT=%TUYA_OPEN%"
set "PY=C:\Users\shivr\AppData\Local\Programs\Python\Python312\python.exe"
set "PYTHONIOENCODING=utf-8"
set "PYTHONUTF8=1"
set "PATH=C:\Users\shivr\AppData\Local\Programs\Python\Python312;C:\Users\shivr\AppData\Local\Programs\Python\Python312\Scripts;C:\Program Files (x86)\GnuWin32\bin;%TUYA_OPEN%\platform\T5AI\tools\bash\bin;%PATH%"
