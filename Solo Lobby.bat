@echo off 
set pathtoGTAexe=""
Rem without ""


:checkPrivileges
 NET FILE 1>NUL 2>NUL
 if '%errorlevel%' == '0' ( goto main ) else ( goto getPrivileges )
 
 :getPrivileges
 if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
 
 setlocal DisableDelayedExpansion
 set "batchPath=%~0"
 setlocal EnableDelayedExpansion
 echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
 echo args = "ELEV " >> "%temp%\OEgetPrivileges.vbs"
 echo For Each strArg in WScript.Arguments >> "%temp%\OEgetPrivileges.vbs"
 echo args = args ^& strArg ^& " "  >> "%temp%\OEgetPrivileges.vbs"
 echo Next >> "%temp%\OEgetPrivileges.vbs"
 echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
 "%SystemRoot%\System32\WScript.exe" "%temp%\OEgetPrivileges.vbs" %*
 exit /B
 
:information
cls
echo Information:
echo ------------
echo.
echo This tool will create Windows Firewall rules to block GTAV from staying connected to other players.
echo This will result in you being able to create a solo public session and block other players from joining you.
echo.
echo Requirements:
echo -------------
echo.
echo 1. Admin permissions
echo 2. Windows Firewall as active Firewall
echo.
echo.
echo Note: When you search for a GTA Path, the Platform is not correct every time and also might result in multiple Platforms.
echo.
pause

:main

set "deb="
set "choice="
set "launcher="
set "spaces=                    "

if "%pathtoGTAexe%"=="""" call :changepath nopath
if not exist "%pathtoGTAexe%" call :changepath invalidpath
cd %pathtoGTAexe% 2>nul >nul
if errorlevel 1 (echo.) else (call :changepath invalidpath)

title GTA5:O Solo Lobby Tool [Loading...]
for /f %%i in ('netsh advfirewall firewall show rule "GTASoloLobby" ^| findstr "GTASoloLobby"') do set deb=%%i
if "%deb%"=="" (set status=Off) else (set status=On)
title GTA5:O Solo Lobby Tool [%status%]
cls
for /F "tokens=*" %%f in ("%pathtoGTAexe%") do set "pathtoGTAfolder=%%~dpf"
echo [DIRECTORY] %pathtoGTAfolder%
echo [STATUS] %status%
echo.
echo wscript.sleep 50 > %tmp%\sleeptmp.vbs
cscript //Nologo %tmp%\sleeptmp.vbs > nul
del %tmp%\sleeptmp.vbs
echo [1] Activate
echo [2] Deactivate
echo [3] Change GTA Path
echo [I] Information
echo.
echo wscript.sleep 50 > %tmp%\sleeptmp.vbs
cscript //Nologo %tmp%\sleeptmp.vbs > nul
del %tmp%\sleeptmp.vbs
set /p choice=Action: 

if "%choice%"=="1" (
netsh advfirewall firewall add rule name=GTASoloLobby dir=out action=block protocol=UDP localport=6672 enable=yes program="%pathtoGTAexe:~0,-1%"
netsh advfirewall firewall add rule name=GTASoloLobby dir=in action=block protocol=UDP localport=6672 enable=yes program="%pathtoGTAexe:~0,-1%"
)

if "%choice%"=="2" netsh advfirewall firewall delete rule name=GTASoloLobby
if "%choice%"=="3" goto changepath
if "%choice%"=="i" goto information
if "%choice%"=="I" goto information
cls
goto main

:changepath
cls
if "%1"=="nopath" echo [!] You have no current path. & echo.
if "%1"=="invalidpath" echo [!] Path is invalid. & echo.
echo Do you want to search for the path?:
echo.
echo [1] Preconfigured (fastest but not good for custom installations, mostly obsolete)
echo [2] Search (known directories, slower)
echo [3] Search intensively (should get every directory, slow)
echo.
echo Or:
echo.
echo [4] Input Path manually
echo.
set "mode="
set /p mode=Mode: 
cls
echo Found installations:
echo.
echo      Platform(s)     ^|      Directory      
echo -------------------------------------------
if "%mode%"=="1" goto searchpre
if "%mode%"=="2" goto searchknown
if "%mode%"=="3" goto intensive
if "%mode%"=="4" cls & goto setpath
if "%mode%"=="exit" goto main
goto changepath

:searchpre
if exist "%systemdrive%\Program Files\Epic Games\GTAV\GTA5.exe" call :getlauncher "%systemdrive%\Program Files\Epic Games\GTAV\"
if exist "%systemdrive%\Program Files\Epic Games\GTA5\GTA5.exe" call :getlauncher "%systemdrive%\Program Files\Epic Games\GTA5\"
if exist "%systemdrive%\Program Files\Epic Games\Grand Theft Auto V\GTA5.exe" call :getlauncher "%systemdrive%\Program Files\Epic Games\Grand Theft Auto V\"
if exist "%systemdrive%\Program Files\Rockstar Games\Grand Theft Auto V\GTA5.exe" call :getlauncher "%systemdrive%\Program Files\Rockstar Games\Grand Theft Auto V\"
if exist "%ProgramFiles(x86)%\Steam\steamapps\common\Grand Theft Auto V\GTA5.exe" call :getlauncher "%systemdrive%\C:\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\"
if exist "%ProgramFiles(x86)%\Steam\steamapps\common\GTAV\GTA5.exe" call :getlauncher "%systemdrive%\C:\Program Files (x86)\Steam\steamapps\common\GTAV\"
if exist "%ProgramFiles(x86)%\Steam\steamapps\common\GTA5\GTA5.exe" call :getlauncher "%systemdrive%\C:\Program Files (x86)\Steam\steamapps\common\GTA5\"
goto setpath

:searchknown
for /f "tokens=2*" %%f in ('robocopy /l "%systemdrive%\Program Files\Epic Games" null GTA5.exe /bytes /njh /njs /np /nc /ndl /xjd /mt /s') do (
	for /f "delims=" %%l in ("%%f %%g") do (
		if exist "%%~dpld3dcsx_46.dll" if exist "%%~dplx64c.rpf" call :getlauncher "%%~dpl"
	)
)
for /f "tokens=2*" %%f in ('robocopy /l "%systemdrive%\Program Files (x86)\Steam\steamapps\common" null GTA5.exe /bytes /njh /njs /np /nc /ndl /xjd /mt /s') do (
	for /f "delims=" %%l in ("%%f %%g") do (
		if exist "%%~dpld3dcsx_46.dll" if exist "%%~dplx64c.rpf" call :getlauncher "%%~dpl"
	)
)
for /f "tokens=2*" %%f in ('robocopy /l "%systemdrive%\Program Files\Rockstar Games" null GTA5.exe /bytes /njh /njs /np /nc /ndl /xjd /mt /s') do (
	for /f "delims=" %%l in ("%%f %%g") do (
		if exist "%%~dpld3dcsx_46.dll" if exist "%%~dplx64c.rpf" call :getlauncher "%%~dpl"
	)
)
goto setpath

:intensive
setlocal enabledelayedexpansion
for /f "skip=1" %%L in ('wmic logicaldisk get name') do for /f %%M in ("%%L") do (
	REM echo %%M\
	REM echo ----
	for /f "tokens=2*" %%f in ('robocopy /l %%M\ null GTA5.exe /bytes /njh /njs /np /nc /ndl /xjd /mt /s') do (
		for /f "delims=" %%l in ("%%f %%g") do (
			if exist "%%~dpld3dcsx_46.dll" if exist "%%~dplx64c.rpf" call :getlauncher "%%~dpl"
		)
	)
)
setlocal disabledelayedexpansion
goto setpath

:getlauncher
set pathtoGTAfolder=%~1
set launcher=Unknown
echo %pathtoGTAfolder% | findstr /i "Epic" > nul
if not errorlevel 1 set launcher=Epic
echo %pathtoGTAfolder% | findstr /i "Rockstar" > nul
if not errorlevel 1 (
	if %launcher%==Unknown (set "launcher=Rockstar") else (set "launcher=%launcher%/Rockstar")
)
echo %pathtoGTAfolder% | findstr /i "Steam" > nul
if not errorlevel 1 (
	if %launcher%==Unknown (set "launcher=Steam") else (set "launcher=%launcher%/Steam")
)
set "preformat=%launcher%%spaces%"
echo %preformat:~0,20% ^|  %pathtoGTAfolder%
goto :eof

:setpath
setlocal disabledelayedexpansion
echo.
set /p setpathtogtafolder=Please enter the path to the GTA directory: 
for /f "tokens=*" %%f in ("%setpathtogtafolder%") do set setpathtogtafolder=%%~f
if not exist "%setpathtogtafolder%\GTA5.exe" echo [!] Please enter a valid path. & goto setpath
set setpathtogtaexe=%setpathtogtafolder%\GTA5.exe
set setpathtoGTAexe=%setpathtoGTAexe:\\=\%
echo "%setpathtogtaexe%"
cd %~dp0
echo cd "%~dp0"; Get-Content 'Solo Lobby.bat' ^| Select-String -pattern 'se^t patht^ogtaexe' -notmatch ^| Set-Content temp.txt > temp.ps1
powershell .\temp.ps1
echo cd "%~dp0"; (Get-Content 'temp.txt' ^| Out-String) -replace ^"@ec^ho of^f^", ^"@ec^ho of^f `r`nse^t patht^oGTAexe=%setpathtogtaexe%^" ^| Out-File 'temp.txt' > temp.ps1
powershell .\temp.ps1
echo cd "%~dp0" > temp.ps1
echo $AllLines = Get-Content "temp.txt" >> temp.ps1
echo $LastLine = Get-Content "temp.txt" -Tail 1 >> temp.ps1
echo while ($LastLine -eq "") { >> temp.ps1
echo	$AllLines = $AllLines[0..($AllLines.count - 2)] >> temp.ps1
echo	echo $AllLines ^| Out-File "temp.txt" -Encoding ascii >> temp.ps1
echo	$LastLine = Get-Content "temp.txt" -Tail 1 >> temp.ps1
echo } >> temp.ps1
powershell .\temp.ps1
del temp.ps1 >nul 2>nul
echo. & echo [*] To apply the new directory press any key, then do nothing until the script reopens.
echo. & pause
start "" /min cmd /c timeout /t 1 /nobreak ^>nul ^& title 1 ^& del "Solo Lobby.bat"
start "" /min cmd /c timeout /t 3 /nobreak ^>nul ^& title 2 ^& rename temp.txt "Solo Lobby.bat"
cmd /k timeout /t 5 /nobreak ^>nul ^& "Solo Lobby.bat"
exit /b
