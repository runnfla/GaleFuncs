@echo off
SET THEFILE=G:\Projects\RunFormula\GitHub\ElmoFire\Source\elmofire.dll
echo Linking %THEFILE%
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ld.exe -b pei-x86-64  --gc-sections  -s --dll  --entry _DLLMainCRTStartup   --base-file base.$$$ -o G:\Projects\RunFormula\GitHub\ElmoFire\Source\elmofire.dll G:\Projects\RunFormula\GitHub\ElmoFire\Source\link2532.res
if errorlevel 1 goto linkend
dlltool.exe -S C:\lazarus\fpc\3.2.2\bin\x86_64-win64\as.exe -D G:\Projects\RunFormula\GitHub\ElmoFire\Source\elmofire.dll -e exp.$$$ --base-file base.$$$ 
if errorlevel 1 goto linkend
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ld.exe -b pei-x86-64  -s --dll  --entry _DLLMainCRTStartup   -o G:\Projects\RunFormula\GitHub\ElmoFire\Source\elmofire.dll G:\Projects\RunFormula\GitHub\ElmoFire\Source\link2532.res exp.$$$
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occurred while assembling %THEFILE%
goto end
:linkend
echo An error occurred while linking %THEFILE%
:end
