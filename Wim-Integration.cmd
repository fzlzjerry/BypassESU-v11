@setlocal DisableDelayedExpansion
@echo off
set "_cmdf=%~f0"
if exist "%SystemRoot%\Sysnative\cmd.exe" (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %*"
exit /b
)
set "SysPath=%SystemRoot%\System32"
if exist "%SystemRoot%\Sysnative\reg.exe" (set "SysPath=%SystemRoot%\Sysnative")
set "Path=%SysPath%;%SystemRoot%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\"
set "_err===== ERROR ===="
set "RDLL=HKLM\wSYSTEM\ControlSet001\Services\wuauserv\Parameters"
set "IFEO=HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
set "_SxS=HKLM\wSOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide"
set "_Cmp=HKLM\wCOMPONENTS\DerivedData\Components"
set "_OurVer=6.1.7603.25000"
set "_EsuX64=amd64_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_6.1.7603.25000_none_caceb5163345f228"
set "_EsuX86=x86_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_6.1.7603.25000_none_6eb019927ae880f2"
set "xSU=superUser64.exe"
if /i %PROCESSOR_ARCHITECTURE%==x86 (if not defined PROCESSOR_ARCHITEW6432 (
  set "xSU=superUser32.exe"
  )
)
set "_bat=%~f0"
set "_arg=%~1"
set "_elv="
if defined _arg if /i "%_arg%"=="-su" set _elv=1

reg query HKU\S-1-5-19 1>nul 2>nul || goto :E_Admin

set "_work=%~dp0"
set "_work=%_work:~0,-1%"
setlocal EnableDelayedExpansion
pushd "!_work!"
if not exist "bin\" goto :E_DLL
for %%# in (
%xSU% bbe64.exe bbe32.exe sle64.dll sle32.dll x64\msislc.dll x86\msislc.dll
PatchWU.cmd PatchWU.xml
%_EsuX64%.manifest
%_EsuX86%.manifest
) do (
if not exist "bin\%%~#" (set "_file=%%~nx#"&goto :E_DLL)
)

call :TIcmd 1>nul 2>nul
whoami /USER | find /i "S-1-5-18" 1>nul && (
goto :Begin
) || (
if defined _elv goto :E_TI
net start TrustedInstaller 1>nul 2>nul
1>nul 2>nul bin\%xSU% /c cmd.exe /c ""!_bat!" -su" &exit /b
)
whoami /USER | find /i "S-1-5-18" 1>nul || goto :E_TI

:Begin
set _wim=0
if exist "*.wim" (for /f "tokens=* delims=" %%# in ('dir /b /a:-d "*.wim"') do (call set /a _wim+=1))
if %_wim% equ 1 (
for /f "tokens=* delims=" %%# in ('dir /b /a:-d "*.wim"') do set "target=!_work!\%%~nx#"
goto :CheckWIM
)
cd bin\
set _wim=0
set _img=0
@cls
echo.
echo Enter the target path:
echo - WIM file ^(not mounted^)
echo - Mounted directory, offline image drive letter
echo.
set /p target=
if not defined target exit /b
set "target=%target:"=%"
if "%target:~-1%"=="\" set "target=%target:~0,-1%"
if /i "%target%"=="%SystemDrive%" exit /b

if /i "%target:~-4%"==".wim" (
if exist "%target%" set _wim=1
) else (
if exist "%target%\Windows\regedit.exe" set _img=1
)

if %_wim% equ 0 if %_img% equ 0 (
echo.
echo %_err%
echo Specified location is not valid
goto :TheEnd
)

if %_wim% equ 1 goto :CheckWIM

dir /b "%target%\Windows\Servicing\Version\6.1.*" 1>nul 2>nul || (
echo.
echo %_err%
echo Specified offline image is not Windows NT 6.1
goto :TheEnd
)
@cls
echo.
echo ____________________________________________________________
echo.
echo Checking . . .
echo.

set "WinPath=%target%\Windows"
set "SysPath=%WinPath%\System32"
set "SysWow=%WinPath%\SysWOW64"
if exist "%WinPath%\Servicing\Packages\*amd64*.mum" (
set "xOS=x64"
set "xBT=amd64"
set "xBE=bbe64.exe"
set "xSL=sle64.dll"
set "_EsuKey=%_SxS%\Winners\amd64_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_none_0e8b36cfce2fb332"
set "_EsuCom=%_EsuX64%"
set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E312E373630332E32353030302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D616D6436342C2076657273696F6E53636F70653D4E6F6E537853"
set "_EsuHsh=45D0AE442FD92CE32EE1DDC38EA3B875EAD9A53D6A17155A10FA9D9E16BEDEB2"
) else (
set "xOS=x86"
set "xBT=x86"
set "xBE=bbe32.exe"
set "xSL=sle32.dll"
set "_EsuKey=%_SxS%\Winners\x86_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_none_b26c9b4c15d241fc"
set "_EsuCom=%_EsuX86%"
set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E312E373630332E32353030302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D7838362C2076657273696F6E53636F70653D4E6F6E537853"
set "_EsuHsh=343B7E8DE2FE932E2FA1DB0CDFE69BB648BEE8E834B41728F1C83A12C1766ECB"
)

set _SrvrC=0
if exist "%WinPath%\WinSxS\Manifests\%xBT%_windowsserverfoundation_*.manifest" set _SrvrC=1

set _Embed=0
if exist "%WinPath%\Servicing\Packages\*Winemb-*.mum" set _Embed=1

set _WinPE=0
if exist "%WinPath%\Servicing\Packages\*WinPE-LanguagePack*.mum" set _WinPE=1

set _WuEsu=0
if exist "%WinPath%\WuEsu\bbe.exe" set _WuEsu=1

set _WiEsu=0
if %xOS%==x86 if exist "%SysPath%\msislc.dll" if exist "%SysPath%\msiexec.exe.manifest" if exist "%SysPath%\ActionCenter.dll.3.Manifest" if exist "%SysPath%\timedate.cpl.3.Manifest" set _WiEsu=1
if %xOS%==x64 if exist "%SysPath%\msislc.dll" if exist "%SysPath%\msiexec.exe.manifest" if exist "%SysPath%\ActionCenter.dll.3.Manifest" if exist "%SysPath%\timedate.cpl.3.Manifest" if exist "%SysWow%\msislc.dll" if exist "%SysWow%\msiexec.exe.manifest" if exist "%SysWow%\ActionCenter.dll.3.Manifest" if exist "%SysWow%\timedate.cpl.3.Manifest" set _WiEsu=1

reg load HKLM\wSOFTWARE "%SysPath%\Config\SOFTWARE" 1>nul 2>nul
set _EsuPkg=0
if exist "%WinPath%\WinSxS\Manifests\%_EsuCom%.manifest" (
reg query "%_EsuKey%" /ve 2>nul | find /i "%_OurVer:~0,3%" 1>nul && (
  reg query "%_EsuKey%\%_OurVer:~0,3%" /ve 2>nul | find /i "%_OurVer%" 1>nul && set _EsuPkg=1
  )
)

set _EsuUpdt=0
set "_EsuMajor="
set "_EsuWinner="
if not exist "%WinPath%\WinSxS\Manifests\%xBT%_microsoft-windows-s..edsecurityupdatesai*.manifest" goto :proceed
reg query "%_EsuKey%" 1>nul 2>nul || goto :proceed
reg load HKLM\wCOMPONENTS "%SysPath%\config\COMPONENTS" 1>nul 2>nul
reg query "%_Cmp%" /f "%xBT%_microsoft-windows-s..edsecurityupdatesai_*" /k 2>nul | find /i "edsecurityupdatesai" 1>nul || goto :proceed
for /f "tokens=4 delims=_" %%# in ('dir /b "%WinPath%\WinSxS\Manifests\%xBT%_microsoft-windows-s..edsecurityupdatesai*.manifest"') do (
set "_ChkVer=%%#"&call :checkver
)
goto :proceed

:checkver
if "%_ChkVer%"=="%_OurVer%" exit /b
reg query "%_Cmp%" /f "%xBT%_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_%_ChkVer%_*" /k 2>nul | find /i "%_ChkVer%" 1>nul || exit /b
reg query "%_EsuKey%\%_ChkVer:~0,3%" /t REG_BINARY 2>nul | find /i "%_ChkVer%" 1>nul || exit /b
if "%_ChkVer:~4,4%" equ "7601" if "%_ChkVer:~9,5%" geq "24548" set _EsuUpdt=1
if "%_ChkVer:~4,4%" equ "7602" if "%_ChkVer:~9,5%" geq "20587" set _EsuUpdt=1
if "%_ChkVer:~4,4%" geq "7603" set _EsuUpdt=1
set "_EsuMajor=%_ChkVer:~0,3%"
set "_EsuWinner=%_ChkVer%"
exit /b

:proceed
reg unload HKLM\wSOFTWARE 1>nul 2>nul
reg unload HKLM\wCOMPONENTS 1>nul 2>nul
set _wufile=wuaueng.dll
if exist "%SysPath%\wuaueng2.dll" set _wufile=wuaueng2.dll
@title BypassESU v11

:MainMenu
set _elr=0
set _dowu=0
@cls
echo ____________________________________________________________
echo.
if %_WuEsu% equ 0 if %_WiEsu% equ 0 if %_WinPE% equ 0 (
echo [1] Full Integration {ESU Suppressor + WU ESU Patcher + .NET 4 ESU Bypass}
echo.
)
if %_EsuPkg% equ 0 (
echo [2] Integrate ESU Suppressor
echo.
)
if %_WuEsu% equ 0 if %_WinPE% equ 0 (
echo [3] Integrate WU ESU Patcher
echo.
)
if %_WuEsu% equ 1 (
echo [4] Remove WU ESU Patcher
echo.
)
if %_EsuPkg% equ 1 if %_EsuUpdt% equ 0 (
echo [5] Remove ESU Suppressor
echo.
)
if %_WiEsu% equ 1 (
echo [6] Remove .NET 4 ESU Bypass
echo.
)
if %_WiEsu% equ 0 if %_WinPE% equ 0 (
echo [7] Integrate .NET 4 ESU Bypass
echo.
)
echo [9] Exit
echo.
echo ____________________________________________________________
echo.
choice /C 12345679 /N /M "Choose a menu option: "
set _elr=%errorlevel%
if %_elr%==8 goto :eof
if %_elr%==7 if %_WiEsu% equ 0 if %_WinPE% equ 0 (goto :imgWI)
if %_elr%==6 if %_WiEsu% equ 1 (goto :UnHookWI)
if %_elr%==5 if %_EsuPkg% equ 1 if %_EsuUpdt% equ 0 (goto :Uninstall)
if %_elr%==4 if %_WuEsu% equ 1 (goto :UnPatchWU)
if %_elr%==3 if %_WuEsu% equ 0 if %_WinPE% equ 0 (goto :imgWU)
if %_elr%==2 if %_EsuPkg% equ 0 (goto :imgESU)
if %_elr%==1 if %_WuEsu% equ 0 if %_WiEsu% equ 0 if %_WinPE% equ 0 (set _dowu=1&goto :imgESU)
goto :MainMenu

:imgESU
@cls
if %_EsuPkg% equ 1 goto :imgWU
echo.
echo ____________________________________________________________
echo.
echo Integrating ESU Suppressor . . .
echo.
if exist "%WinPath%\servicing\slc.dll" del /f /q "%WinPath%\servicing\slc.dll" 1>nul 2>nul
call :IMGt 1>nul 2>nul
if %_dowu% equ 1 goto :imgWU
echo.
echo Done.
goto :TheEnd

:IMGt
set "_EsuFnd=windowsfoundation_31bf3856ad364e35_6.1.7601.17514_615fdfe2a739474c"
if %_WinPE% equ 1 set "_EsuFnd=winpe_31bf3856ad364e35_6.1.7601.17514_b103c6caf44fb2e9"
if %_Embed% equ 1 set "_EsuFnd=windowsembe..dfoundation_31bf3856ad364e35_6.1.7601.17514_b791db78a3ca92ca"
if %_SrvrC% equ 1 set "_EsuFnd=windowsserverfoundation_31bf3856ad364e35_6.1.7601.17514_1767904420c89fad"
if /i "%xBT%"=="x86" (
set "_EsuFnd=windowsfoundation_31bf3856ad364e35_6.1.7601.17514_0541445eeedbd616"
if %_WinPE% equ 1 set "_EsuFnd=winpe_31bf3856ad364e35_6.1.7601.17514_54e52b473bf241b3"
if %_Embed% equ 1 set "_EsuFnd=windowsembe..dfoundation_31bf3856ad364e35_6.1.7601.17514_5b733ff4eb6d2194"
)
copy /y %_EsuCom%.manifest "%WinPath%\WinSxS\Manifests\"
reg load HKLM\wCOMPONENTS "%SysPath%\config\COMPONENTS"
reg load HKLM\wSOFTWARE "%SysPath%\config\SOFTWARE"
reg delete "%_Cmp%\%_EsuCom%" /f
reg add "%_Cmp%\%_EsuCom%" /f /v "c^!%_EsuFnd%" /t REG_BINARY /d ""
reg add "%_Cmp%\%_EsuCom%" /f /v identity /t REG_BINARY /d "%_EsuIdn%"
reg add "%_Cmp%\%_EsuCom%" /f /v S256H /t REG_BINARY /d "%_EsuHsh%"
reg add "%_EsuKey%" /f /ve /d %_OurVer:~0,3%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /ve /d %_OurVer%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /v %_OurVer% /t REG_BINARY /d 01
reg unload HKLM\wCOMPONENTS
reg unload HKLM\wSOFTWARE
exit /b

:Uninstall
@cls
echo.
echo ____________________________________________________________
echo.
echo Removing ESU Suppressor . . .
echo.
call :RemoveManual 1>nul 2>nul
echo.
echo Done.
goto :TheEnd

:RemoveManual
reg load HKLM\wCOMPONENTS "%SysPath%\Config\COMPONENTS"
reg load HKLM\wSOFTWARE "%SysPath%\Config\SOFTWARE"
reg delete "%_Cmp%\%_EsuCom%" /f
reg delete "%_EsuKey%\%_OurVer:~0,3%" /f /v %_OurVer%
del /f /q "%WinPath%\WinSxS\Manifests\%_EsuCom%.manifest"
if not exist "%WinPath%\WinSxS\Manifests\*_microsoft-windows-s..edsecurityupdatesai*.manifest" (
reg delete "%_EsuKey%" /f
) else (
if defined _EsuWinner (
  reg add "%_EsuKey%" /f /ve /d "%_EsuMajor%"
  reg add "%_EsuKey%\%_EsuMajor%" /f /ve /d "%_EsuWinner%"
  ) else (
  reg delete "%_EsuKey%" /f
  )
)
for /f "tokens=* delims=" %%# in ('reg query HKLM\wCOMPONENTS\DerivedData\VersionedIndex 2^>nul ^| findstr /i VersionedIndex') do reg delete "%%#" /f
reg unload HKLM\wCOMPONENTS
reg unload HKLM\wSOFTWARE
exit /b

:imgWU
if %_dowu% equ 0 (
@cls
)
echo.
echo ____________________________________________________________
echo.
echo Integrating WU ESU Patcher . . .
echo.
if exist "%SysPath%\wuaueng3.dll" del /f /q "%SysPath%\wuaueng3.dll"
if exist "%WinPath%\WuEsu\" rmdir /s /q "%WinPath%\WuEsu\"
echo.
echo adding "%WinPath%\WuEsu"
mkdir "%WinPath%\WuEsu"
copy /y PatchWU.cmd "%WinPath%\WuEsu" 1>nul 2>nul
copy /y %xBE% "%WinPath%\WuEsu\bbe.exe" 1>nul 2>nul
echo.
echo adding "%SysPath%\sle.dll"
copy /y %xSL% "%SysPath%\sle.dll" 1>nul 2>nul
echo.
echo adding schedule task "Patch WU ESU"
1>nul 2>nul copy /y PatchWU.xml "%SysPath%\Tasks\Patch WU ESU"
1>nul 2>nul icacls "%SysPath%\Tasks\" /restore PatchWU.txt
1>nul 2>nul reg load HKLM\wSOFTWARE "%SysPath%\Config\SOFTWARE"
1>nul 2>nul reg import PatchWU.reg
1>nul 2>nul reg unload HKLM\wSOFTWARE
if %_dowu% equ 1 goto :imgWI
echo.
echo Done.
goto :TheEnd

:UnPatchWU
@cls
echo.
echo ____________________________________________________________
echo.
echo Removing WU ESU Patcher . . .
echo.
if exist "%WinPath%\WuEsu\" (echo removing "%WinPath%\WuEsu\"&rmdir /s /q "%WinPath%\WuEsu\")
if exist "%SysPath%\wuaueng3.dll" (echo removing "%SysPath%\wuaueng3.dll"&del /f /q "%SysPath%\wuaueng3.dll")
if exist "%SysPath%\sle.dll" (echo removing "%SysPath%\sle.dll"&del /f /q "%SysPath%\sle.dll")
echo.
echo restoring registry value "ServiceDll" to "%_wufile%"
1>nul 2>nul reg load HKLM\wSYSTEM "%SysPath%\Config\SYSTEM"
1>nul 2>nul reg add "%RDLL%" /f /v ServiceDll /t REG_EXPAND_SZ /d ^%%SystemRoot^%%\System32\%_wufile%
1>nul 2>nul reg unload HKLM\wSYSTEM
echo.
echo removing schedule task "Patch WU ESU"
set "_tsk=HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache"
1>nul 2>nul reg load HKLM\wSOFTWARE "%SysPath%\Config\SOFTWARE"
1>nul 2>nul reg delete "%_tsk%\Tree\Patch WU ESU" /f
1>nul 2>nul reg delete "%_tsk%\Boot\{7132FCA0-A3F0-431E-9945-C2B58D3DFCAF}" /f
1>nul 2>nul reg delete "%_tsk%\Tasks\{7132FCA0-A3F0-431E-9945-C2B58D3DFCAF}" /f
echo.
set "_ebak="
reg query "HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID_bak 1>nul 2>nul && for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID_bak 2^>nul') do set "_ebak=%%b"
if defined _ebak (
echo restoring registry value "EditionID" to "%_ebak%"
echo.
1>nul 2>nul reg add "HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion" /f /v EditionID /d %_ebak%
1>nul 2>nul reg delete "HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion" /f /v EditionID_bak
)
1>nul 2>nul reg unload HKLM\wSOFTWARE
echo.
echo Done.
goto :TheEnd

:imgWI
if %_dowu% equ 0 (
@cls
)
echo.
echo ____________________________________________________________
echo.
echo Integrating .NET 4 ESU Bypass . . .
echo.
for %%# in (msiesu.dll msislc.dll slcmsi.dll msiexec.exe.manifest) do (
if exist "%SysPath%\%%#" del /f /q "%SysPath%\%%#" 1>nul 2>nul
if exist "%SysWow%\%%#" del /f /q "%SysWow%\%%#" 1>nul 2>nul
)
if exist "%SysPath%\msiexec.exe.local\" rmdir /s /q "%SysPath%\msiexec.exe.local\"
if exist "%SysWow%\msiexec.exe.local\" rmdir /s /q "%SysWow%\msiexec.exe.local\"
echo.
echo adding files...
echo.
echo "%SysPath%\"
echo ActionCenter.dll.3.Manifest
echo perfmon.exe.3.Manifest
echo pnidui.dll.3.Manifest
echo timedate.cpl.3.Manifest
echo msiexec.exe.manifest
echo msislc.dll
echo slcmsi.dll
xcopy /cryq %xOS% "%SysPath%\" 1>nul 2>nul
copy /y "%SysPath%\slc.dll" "%SysPath%\slcmsi.dll" 1>nul 2>nul
if %xOS%==x64 (
echo.
echo "%SysWow%\"
echo ActionCenter.dll.3.Manifest
echo perfmon.exe.3.Manifest
echo pnidui.dll.3.Manifest
echo timedate.cpl.3.Manifest
echo msiexec.exe.manifest
echo msislc.dll
echo slcmsi.dll
xcopy /cryq x86 "%SysWow%\" 1>nul 2>nul
copy /y "%SysWow%\slc.dll" "%SysWow%\slcmsi.dll" 1>nul 2>nul
)
echo.
echo adding PreferExternalManifest registry...
reg load HKLM\wSOFTWARE "%SysPath%\Config\SOFTWARE" 1>nul 2>nul
reg delete "%IFEO%" /v DevOverrideEnable /f 1>nul 2>nul
reg delete "%IFEO%\msiexec.exe" /f 1>nul 2>nul
reg add "%_SxS%" /v PreferExternalManifest /t REG_DWORD /d 1 /f 1>nul 2>nul
reg unload HKLM\wSOFTWARE 1>nul 2>nul
echo.
echo Done.
goto :TheEnd

:UnHookWI
@cls
echo.
echo ____________________________________________________________
echo.
echo Removing .NET 4 ESU Bypass . . .
echo.
for %%# in (msiesu.dll msislc.dll slcmsi.dll msiexec.exe.manifest) do (
if exist "%SysPath%\%%#" del /f /q "%SysPath%\%%#" 1>nul 2>nul
if exist "%SysWow%\%%#" del /f /q "%SysWow%\%%#" 1>nul 2>nul
)
if exist "%SysPath%\msiexec.exe.local\" rmdir /s /q "%SysPath%\msiexec.exe.local\"
if exist "%SysWow%\msiexec.exe.local\" rmdir /s /q "%SysWow%\msiexec.exe.local\"
reg load HKLM\wSOFTWARE "%SysPath%\Config\SOFTWARE" 1>nul 2>nul
reg delete "%IFEO%" /v DevOverrideEnable /f 1>nul 2>nul
reg delete "%IFEO%\msiexec.exe" /f 1>nul 2>nul
reg delete "%_SxS%" /v PreferExternalManifest /f 1>nul 2>nul
reg unload HKLM\wSOFTWARE 1>nul 2>nul
echo.
echo Done.
goto :TheEnd

:CheckWIM
cd bin\
call wimfile.cmd "%target%"
goto :TheEnd

:TIcmd
reg add HKU\.DEFAULT\Console /f /v FaceName /t REG_SZ /d Consolas
reg add HKU\.DEFAULT\Console /f /v FontFamily /t REG_DWORD /d 0x36
reg add HKU\.DEFAULT\Console /f /v FontSize /t REG_DWORD /d 0x100000
reg add HKU\.DEFAULT\Console /f /v FontWeight /t REG_DWORD /d 0x190
reg add HKU\.DEFAULT\Console /f /v ScreenBufferSize /t REG_DWORD /d 0x12c0050
exit /b

:E_TI
echo %_err%
echo Failed running the script with TrustedInstaller privileges.
goto :TheEnd

:E_Admin
echo %_err%
echo This script requires administrator privileges.
goto :TheEnd

:E_DLL
echo %_err%
echo Required file bin\%_file% is missing.

:TheEnd
echo.
echo Press any key to exit.
pause >nul
goto :eof
