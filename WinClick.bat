:Start
@echo off
	cls
	Title WinClick by MartyFiles
	Color 0f
	chcp 866 >nul
	echo "%~dp0\Work" | findstr /r "[()!]" >nul && echo Путь до .bat содержит недопустимые символы. && timeout /t 7 >nul && exit
	SetLocal EnableDelayedExpansion
	cd /d "%~dp0\Work"
	reg query "HKU\S-1-5-19" >nul 2>&1 || nircmd elevate "%~f0" && exit

Rem Установка переменных
	set "ch=cecho.exe"
	set "TI=NSudoLG -U:T -P:E -ShowWindowMode:Hide -Wait cmd.exe /c"
	mode 55,10 >nul
	nircmd win min ititle "WinClick by MartyFiles"
	set msgFile=%~dp0Work\message.txt
	

Rem Фикс, если запущено из Terminal UWP
	tasklist /fi "imagename eq WindowsTerminal.exe" 2>nul | find /i "WindowsTerminal" >nul && (
		for %%p in (DelegationConsole DelegationTerminal) do reg add "HKCU\Console\%%%%Startup" /v "%%p" /t REG_SZ /d "{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" /f >nul
		echo. && echo  Restarting with cmd .. && timeout /t 3 /nobreak >nul && start "" "%~f0" && exit
	)

Rem Проверка версии
	call :WinVer && exit /b
	start "" PowerShell -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -NoExit -File "%~dp0Work\Overlay.ps1"
	echo Скоро Windows 11 станет лучше > "%msgFile%"
	timeout /t 4 /nobreak >nul 2>&1

echo Удаление мусора... [1/13]  > "%msgFile%"
	sc query wuauserv | find /i "RUNNING" >nul 2>&1 && (
		net stop wuauserv >nul 2>&1
		timeout /t 1 /nobreak >nul 2>&1
		sc query wuauserv | find /i "RUNNING" >nul 2>&1 && %TI% net stop wuauserv
	)	
	del /q /f /s "%SystemRoot%\SoftwareDistribution\Download\*.*" >nul 2>&1
	rd /q /s "%SystemRoot%\SoftwareDistribution\Download\" >nul 2>&1
	del /q /f /s "%SystemRoot%\SoftwareDistribution\Download" >nul 2>&1
	del /q /f /s "%ProgramFiles(x86)%\Microsoft\EdgeUpdate\Download\*.*" >nul 2>&1
	rd /q /s "%ProgramFiles(x86)%\Microsoft\EdgeUpdate\Download\" >nul 2>&1
	del /q /f /s "%userprofile%\AppData\Local\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalCache\*.*" >nul 2>&1
	rd /q /s "%userprofile%\AppData\Local\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalCache\" >nul 2>&1
	pushd "%LocalAppData%\Microsoft\Windows\Explorer" >nul 2>&1
	del /s /q /a:h "IconCache*" "thumbcache*" >nul 2>&1
	del /s /q /f "IconCache*" "thumbcache*" >nul 2>&1
	popd
	pushd "%LocalAppData%" >nul 2>&1
	if exist IconCache.db del /a /q IconCache.db >nul 2>&1
	if exist IconCache.db-wal del /a /q IconCache.db-wal >nul 2>&1
	del /s /q /a:h "IconCache*" "thumbcache*" >nul 2>&1
	popd
Rem Очистка WinSxS
	Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
Rem Удаления старых драйверов
PowerShell -encodedCommand JABkAGkAcwBtAE8AdQB0ACAAPQAgAGQAaQBzAG0AIAAvAG8AbgBsAGkAbgBlACAALwBnAGUAdAAtAGQAcgBpAHYAZQByAHMADQAKACQATABpAG4AZQBzACAAPQAgACQAZABpAHMAbQBPAHUAdAAgAHwAIABzAGUAbABlAGMAdAAgAC0AUwBrAGkAcAAgADEAMAANAAoAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAiAHQAaABlAE4AYQBtAGUAIgANAAoAJABEAHIAaQB2AGUAcgBzACAAPQAgAEAAKAApAA0ACgBmAG8AcgBlAGEAYwBoACAAKAAgACQATABpAG4AZQAgAGkAbgAgACQATABpAG4AZQBzACAAKQAgAHsADQAKACAAIAAgACAAJAB0AG0AcAAgAD0AIAAkAEwAaQBuAGUADQAKACAAIAAgACAAJAB0AHgAdAAgAD0AIAAkACgAJAB0AG0AcAAuAFMAcABsAGkAdAAoACAAJwA6ACcAIAApACkAWwAxAF0ADQAKACAAIAAgACAAcwB3AGkAdABjAGgAIAAoACQATwBwAGUAcgBhAHQAaQBvAG4AKQAgAHsADQAKACAAIAAgACAAIAAgACAAIAAnAHQAaABlAE4AYQBtAGUAJwAgAHsAIAAkAE4AYQBtAGUAIAA9ACAAJAB0AHgAdAANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAnAHQAaABlAEYAaQBsAGUATgBhAG0AZQAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABiAHIAZQBhAGsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUARgBpAGwAZQBOAGEAbQBlACcAIAB7ACAAJABGAGkAbABlAE4AYQBtAGUAIAA9ACAAJAB0AHgAdAAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQATwBwAGUAcgBhAHQAaQBvAG4AIAA9ACAAJwB0AGgAZQBFAG4AdAByACcADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYgByAGUAYQBrAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUARQBuAHQAcgAnACAAewAgACQARQBuAHQAcgAgAD0AIAAkAHQAeAB0AC4AVAByAGkAbQAoACkADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQATwBwAGUAcgBhAHQAaQBvAG4AIAA9ACAAJwB0AGgAZQBDAGwAYQBzAHMATgBhAG0AZQAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABiAHIAZQBhAGsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUAQwBsAGEAcwBzAE4AYQBtAGUAJwAgAHsAIAAkAEMAbABhAHMAcwBOAGEAbQBlACAAPQAgACQAdAB4AHQALgBUAHIAaQBtACgAKQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQATwBwAGUAcgBhAHQAaQBvAG4AIAA9ACAAJwB0AGgAZQBWAGUAbgBkAG8AcgAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYgByAGUAYQBrAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAB9AA0ACgAgACAAIAAgACAAIAAgACAAJwB0AGgAZQBWAGUAbgBkAG8AcgAnACAAewAgACQAVgBlAG4AZABvAHIAIAA9ACAAJAB0AHgAdAAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAnAHQAaABlAEQAYQB0AGUAJwANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGIAcgBlAGEAawANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUARABhAHQAZQAnACAAewAgACAAJAB0AG0AcAAgAD0AIAAkAHQAeAB0AC4AcwBwAGwAaQB0ACgAIAAnAC4AJwAgACkADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAdAB4AHQAIAA9ACAAIgAkACgAJAB0AG0AcABbADIAXQApAC4AJAAoACQAdABtAHAAWwAxAF0AKQAuACQAKAAkAHQAbQBwAFsAMABdAC4AVAByAGkAbQAoACkAKQAiAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAEQAYQB0AGUAIAA9ACAAJAB0AHgAdAANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAnAHQAaABlAFYAZQByAHMAaQBvAG4AJwANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYgByAGUAYQBrAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAH0ADQAKACAAIAAgACAAIAAgACAAIAAnAHQAaABlAFYAZQByAHMAaQBvAG4AJwAgAHsAIAAkAFYAZQByAHMAaQBvAG4AIAA9ACAAJAB0AHgAdAAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAE8AcABlAHIAYQB0AGkAbwBuACAAPQAgACcAdABoAGUATgB1AGwAbAAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAHAAYQByAGEAbQBzACAAPQAgAFsAbwByAGQAZQByAGUAZABdAEAAewAgACcARgBpAGwAZQBOAGEAbQBlACcAIAA9ACAAJABGAGkAbABlAE4AYQBtAGUADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJwBWAGUAbgBkAG8AcgAnACAAPQAgACQAVgBlAG4AZABvAHIADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJwBEAGEAdABlACcAIAA9ACAAJABEAGEAdABlAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACcATgBhAG0AZQAnACAAPQAgACQATgBhAG0AZQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAnAEMAbABhAHMAcwBOAGEAbQBlACcAIAA9ACAAJABDAGwAYQBzAHMATgBhAG0AZQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAnAFYAZQByAHMAaQBvAG4AJwAgAD0AIAAkAFYAZQByAHMAaQBvAG4ADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJwBFAG4AdAByACcAIAA9ACAAJABFAG4AdAByAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABvAGIAagAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAALQBUAHkAcABlAE4AYQBtAGUAIABQAFMATwBiAGoAZQBjAHQAIAAtAFAAcgBvAHAAZQByAHQAeQAgACQAcABhAHIAYQBtAHMADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQARAByAGkAdgBlAHIAcwAgACsAPQAgACQAbwBiAGoADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGIAcgBlAGEAawANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAB9AA0ACgAgACAAIAAgACAAIAAgACAAIAAnAHQAaABlAE4AdQBsAGwAJwAgAHsAIAAkAE8AcABlAHIAYQB0AGkAbwBuACAAPQAgACcAdABoAGUATgBhAG0AZQAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGIAcgBlAGEAawANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAB9AA0ACgB9AA0ACgAkAGwAYQBzAHQAIAA9ACAAJwAnAA0ACgAkAE4AbwB0AFUAbgBpAHEAdQBlACAAPQAgAEAAKAApAA0ACgBmAG8AcgBlAGEAYwBoACAAKAAgACQARAByACAAaQBuACAAJAAoACQARAByAGkAdgBlAHIAcwAgAHwAIABzAG8AcgB0ACAARgBpAGwAZQBuAGEAbQBlACkAIAApACAAewANAAoAIAAgACAAIABpAGYAIAAoACQARAByAC4ARgBpAGwAZQBOAGEAbQBlACAALQBlAHEAIAAkAGwAYQBzAHQAIAAgACkAIAB7ACAAIAAkAE4AbwB0AFUAbgBpAHEAdQBlACAAKwA9ACAAJABEAHIAIAAgAH0ADQAKACAAIAAgACAAJABsAGEAcwB0ACAAPQAgACQARAByAC4ARgBpAGwAZQBOAGEAbQBlAA0ACgB9AA0ACgAkAE4AbwB0AFUAbgBpAHEAdQBlACAAfAAgAHMAbwByAHQAIABGAGkAbABlAE4AYQBtAGUAIAB8ACAAZgB0AA0ACgAjAFMAZQBhAHIAYwBoAGkAbgBnACAAZgBvAHIAIABkAHUAcABsAGkAYwBhAHQAZQAgAGQAcgBpAHYAZQByAHMAIAANAAoAJABsAGkAcwB0ACAAPQAgACQATgBvAHQAVQBuAGkAcQB1AGUAIAB8ACAAcwBlAGwAZQBjAHQAIAAtAEUAeABwAGEAbgBkAFAAcgBvAHAAZQByAHQAeQAgAEYAaQBsAGUATgBhAG0AZQAgAC0AVQBuAGkAcQB1AGUADQAKACQAVABvAEQAZQBsACAAPQAgAEAAKAApAA0ACgBmAG8AcgBlAGEAYwBoACAAKAAgACQARAByACAAaQBuACAAJABsAGkAcwB0ACAAKQAgAHsADQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIARAB1AHAAbABpAGMAYQB0AGUAIABkAHIAaQB2AGUAcgAgAGYAbwB1AG4AZAAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFkAZQBsAGwAbwB3AA0ACgAgACAAIAAgACQAcwBlAGwAIAA9ACAAJABEAHIAaQB2AGUAcgBzACAAfAAgAHcAaABlAHIAZQAgAHsAIAAkAF8ALgBGAGkAbABlAE4AYQBtAGUAIAAtAGUAcQAgACQARAByACAAfQAgAHwAIABzAG8AcgB0ACAAZABhAHQAZQAgAC0ARABlAHMAYwBlAG4AZABpAG4AZwAgAHwAIABzAGUAbABlAGMAdAAgAC0AUwBrAGkAcAAgADEADQAKACAAIAAgACAAJABzAGUAbAAgAHwAIABmAHQADQAKACAAIAAgACAAJABUAG8ARABlAGwAIAArAD0AIAAkAHMAZQBsAA0ACgB9AA0ACgAjAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAEwAaQBzAHQAIABvAGYAIABkAHIAaQB2AGUAcgAgAHYAZQByAHMAaQBvAG4AIAAgAHQAbwAgAHIAZQBtAG8AdgBlACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAUgBlAGQADQAKACQAVABvAEQAZQBsACAAfAAgAGYAdAANAAoAIwBEAGUAbABlAHQAaQBuAGcAIABvAGwAZAAgAGQAcgBpAHYAZQByAHMADQAKAGYAbwByAGUAYQBjAGgAIAAoACAAJABpAHQAZQBtACAAaQBuACAAJABUAG8ARABlAGwAIAApACAAewANAAoAIAAgACAAIAAkAE4AYQBtAGUAIAA9ACAAJAAoACQAaQB0AGUAbQAuAE4AYQBtAGUAKQAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAGQAZQBsAGUAdABpAG4AZwAgACQATgBhAG0AZQAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFkAZQBsAGwAbwB3AA0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAHAAbgBwAHUAdABpAGwALgBlAHgAZQAgAC8AZABlAGwAZQB0AGUALQBkAHIAaQB2AGUAcgAgACAAJABOAGEAbQBlACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAWQBlAGwAbABvAHcADQAKACAAIAAgACAASQBuAHYAbwBrAGUALQBFAHgAcAByAGUAcwBzAGkAbwBuACAALQBDAG8AbQBtAGEAbgBkACAAIgBwAG4AcAB1AHQAaQBsAC4AZQB4AGUAIAAvAGQAZQBsAGUAdABlAC0AZAByAGkAdgBlAHIAIAAkAE4AYQBtAGUAIgANAAoAfQA= >nul 2>&1


echo Удаление всех UWP-приложений... [2/13] > "%msgFile%"
	PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage | Where-Object { $_.NonRemovable -eq $false } | ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue }" >nul 2>&1
	taskkill /f /im OneDrive.exe >nul 2>&1
	%SystemRoot%\System32\OneDriveSetup.exe /uninstall >nul 2>&1
	rd "%UserProfile%\OneDrive" /Q /S >nul 2>&1
	rd "%LocalAppData%\Microsoft\OneDrive" /Q /S >nul 2>&1
	rd "%ProgramData%\Microsoft OneDrive" /Q /S >nul 2>&1
	reg delete "HKCU\Software\Microsoft\OneDrive" /f >nul 2>&1
	reg delete "HKLM\Software\Microsoft\OneDrive" /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f >nul 2>&1
	rd "%AppData%\Microsoft\Windows\Start Menu\Programs\Accessibility" /Q /S >nul 2>&1
	rd "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Accessories\System Tools" /Q /S >nul 2>&1
	PowerShell "Start-Process mstsc.exe -ArgumentList '/uninstall' -WindowStyle Hidden -ErrorAction SilentlyContinue"
	timeout /t 5 /nobreak >nul 2>&1
	taskkill /f /im mstsc.exe >nul 2>&1

	
echo Удаление браузера Edge... [3/13] > "%msgFile%"
	taskkill /f /im MicrosoftEdge.exe >nul 2>&1
	taskkill /f /im MicrosoftEdgeUpdate.exe >nul 2>&1
	start /wait "" "%~dp0\Work\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall --msedge >nul 2>&1
	start /wait "" "%~dp0\Work\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall --msedgewebview >nul 2>&1

echo Удаление Защитника... [4/13] > "%msgFile%"
	reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" | find /i "0x0" >nul 2>&1 && set "ArgNsudo=C" || set "ArgNsudo=E"
	set "ListWDServ=WinDefend MDCoreSvc WdNisSvc Sense wscsvc SgrmBroker SecurityHealthService webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdFilter SgrmAgent MsSecWfp MsSecFlt MsSecCore"
	goto StartProcessRemove

:AddExclusionDef
	sc query WinDefend | find /i "RUNNING" >nul 2>&1 && (
			NSudoLG -U:%ArgNsudo% -ShowWindowMode:Hide -Wait PowerShell "foreach ($drive in [System.IO.DriveInfo]::GetDrives()) { Add-MpPreference -ExclusionPath $drive.Name }; Start-Sleep -Milliseconds 1500" >nul 2>&1
			reg query "HKLM\Software\Microsoft\Windows Defender\Exclusions\Paths" | find /i "%SystemDrive%\" >nul 2>&1 || goto ErrorAddExclusion
	)
	exit /b

:StartProcessRemove
rem Если раздел драйвера filter и раздел wd от defender существуют (оба) и если не найден в исключениях системный диск - добавляем в исключения.
	reg query HKLM\System\CurrentControlset\Services\WdFilter >nul 2>&1 && reg query "HKLM\Software\Microsoft\Windows Defender" >nul 2>&1 && (
		reg query "HKLM\Software\Microsoft\Windows Defender\Exclusions\Paths" | find /i "%SystemDrive%\" >nul 2>&1 || (
			call :AddExclusionDef
		)
	)

	if not exist "%AllUsersProfile%\Microsoft\Windows Defender" (
		if not exist "%SystemDrive%\Program Files\Windows Defender" (
			goto SkipUnlockerAndExclAndBackup
		)
	)

rem Пропускаем создание копии. Если нет веток. Если нет файла. Множественная проверка на то, выполнялось ли удаление хотя бы 1 раз.
	set "flag=0"
	reg query "HKLM\Software\Microsoft\Windows Advanced Threat Protection" >nul 2>&1 && set "flag=1"
	reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender/WHC" >nul 2>&1 && set "flag=1"
	reg query "HKCR\Directory\shellex\ContextMenuHandlers\EPP" >nul 2>&1 && set "flag=1"
	if exist "%SystemRoot%\System32\SecurityHealthService.exe" set "flag=1"
	if not %flag%==1 goto StartUnlockerAndSkipBackup

:StartUnlockerAndSkipBackup
	Unlocker /DеlWD
	start "" PowerShell -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -NoExit -File "%~dp0Work\Overlay.ps1"
	taskkill /f /im explorer.exe
	start explorer
	for %%d in ("%AllUsersProfile%\Microsoft\Windows Security Health", "%AllUsersProfile%\Microsoft\Windows Defender", "%AllUsersProfile%\Microsoft\Windows Defender", "%AllUsersProfile%\Microsoft\Windows Defender") do (
		if exist %%d (
			timeout /t 2 /nobreak >nul
			Unlocker /DеlWD
			start "" PowerShell -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -NoExit -File "%~dp0Work\Overlay.ps1"
			taskkill /f /im explorer.exe
			start explorer
		)
	)

:SkipUnlockerAndExclAndBackup
(
for %%x in (%ListWDServ%) do (
    %TI% sc config "%%~x" start=disabled
    %TI% sc stop "%%~x"
    %TI% sc delete "%%~x"
    %TI% reg delete "HKLM\System\CurrentControlSet\Services\%%~x" /f
	)

	for %%d in ("Windows Defender" "Windows Defender Advanced Threat Protection" "Windows Security Health" "Storage Health") do (
		%TI% rd /s /q "%AllUsersProfile%\Microsoft\%%~d")

	for %%d in ("Windows Defender" "Windows Defender Sleep" "Windows Defender Advanced Threat Protection" "Windows Security" "PCHealthCheck" "Microsoft Update Health Tools") do (
		%TI% rd /s /q "%SystemDrive%\Program Files\%%~d")

	for %%d in ("Windows Defender" "Windows Defender Advanced Threat Protection") do (
		%TI% rd /s /q "%SystemDrive%\Program Files (x86)\%%~d")

	for %%d in ("HealthAttestationClient" "SecurityHealth" "WebThreatDefSvc" "Sgrm") do (
		%TI% rd /s /q "%SystemRoot%\System32\%%~d")

	%TI% rd /s /q "%SystemRoot%\security\database"
	%TI% rd /s /q "%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\Defender"
	%TI% rd /s /q "%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\DefenderPerformance"
	%TI% rd /s /q "%SystemRoot%\System32\Tasks_Migrated\Microsoft\Windows\Windows Defender"
	%TI% rd /s /q "%SystemRoot%\System32\Tasks\Microsoft\Windows\Windows Defender"
	%TI% rd /s /q "%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\Modules\Defender"
	%TI% rd /s /q "%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\Modules\DefenderPerformance"

rem Переименование 4 файлов
	%TI% ren "%SystemRoot%\System32\SecurityHealthService.exe" "SecurityHealthService.exe_fuck"
	%TI% ren "%SystemRoot%\System32\smartscreenps.dll" smartscreenps.dll_fuck
	%TI% ren "%SystemRoot%\System32\wscapi.dll" wscapi.dll_fuck
	%TI% ren "%SystemRoot%\System32\smartscreen.exe" "smartscreen.exedel"

	%TI% del /f /q "%SystemRoot%\Containers\WindowsDefenderApplicationGuard.wim"
	%TI% del /f /q "%SystemRoot%\Containers\serviced\WindowsDefenderApplicationGuard.wim"

rem Удаление файлов от Defender / Центра Безопасности и SmartScreen + 4 файла переименованных
	for %%f in (
		SecurityHealthService.exe SecurityHealthSystray.exe SecurityHealthHost.exe
		SecurityHealthAgent.dll SecurityHealthSSO.dll SecurityHealthProxyStub.dll smartscreen.dll wscisvif.dll
		wscproxystub.dll smartscreenps.dll wscapi.dll windowsdefenderapplicationguardcsp.dll wscsvc.dll SecurityHealthCore.dll
		SecurityHealthSsoUdk.dll SecurityHealthUdk.dll smartscreen.exe

		SecurityHealthService.exe_fuck smartscreenps.dll_fuck wscapi.dll_fuck smartscreen.exedel
	) do %TI% del /f /q "%SystemRoot%\System32\%%f" "%SystemRoot%\SysWOW64\%%f"

rem Планировщик / Реестр
	for %%s in ("Windows Defender Cache Maintenance" "Windows Defender Cleanup" "Windows Defender Scheduled Scan" "Windows Defender Verification"
	) do %TI% schtasks /Delete /TN "Microsoft\Windows\Windows Defender\%%~s" /f
	%TI% schtasks /Delete /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /f

	%TI% reg delete "HKLM\Software\Microsoft\Windows Defender" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows Defender Security Center" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows Advanced Threat Protection" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows Security Health" /f

	%TI% reg delete "HKLM\System\CurrentControlset\Control\WMI\Autologger\DefenderApiLogger" /f
	%TI% reg delete "HKLM\System\CurrentControlset\Control\WMI\Autologger\DefenderAuditLogger" /f

	%TI% reg delete "HKCR\*\shellex\ContextMenuHandlers\EPP" /f
	%TI% reg delete "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /f
	%TI% reg delete "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /f
	%TI% reg delete "HKLM\Software\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f

	%TI% reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender" /f

	%TI% reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender/WHC" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\NIS-Driver-WFP/Diagnostic" /f
	%TI% reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender/Operational" /f
	
	%TI% reg delete "HKLM\System\CurrentControlSet\Services\WdFilter" /f
	%TI% reg delete "HKLM\System\CurrentControlSet\Services\WinDefend" /f
	%TI% reg delete "HKLM\System\CurrentControlSet\Services\WdNisDrv" /f
	%TI% reg delete "HKLM\System\CurrentControlSet\Services\MDCoreSvc" /f
	%TI% reg delete "HKLM\System\CurrentControlSet\Services\WdNisSvc" /f
	%TI% reg delete "HKLM\System\CurrentControlSet\Services\WdBoot" /f	
) >nul 2>&1
	sc start VMTools >nul 2>&1
rem Создание в автозапуск самоисчезающих [разовых] команд для подчистки служб после ребута ПК
	reg query "HKLM\System\CurrentControlset\Services\WdFilter" >nul 2>&1 && (
		call :CreateRunOnceDelReg
		goto RemoveApps
	)
rem Возвращаем цвет заголовка по-умолчанию для TI программ. Нет в чистой Windows.
	reg delete "HKU\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /f >nul 2>&1
	goto RemoveApps
 
 :CreateRunOnceDelReg
	set "RegKey=HKLM\System\CurrentControlSet\Services"
rem Подчистка реестра с помощью RunOnce после ребута ПК
	for %%p in (RegClean RegClean1) do %TI% reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "%%p" /t reg_sz /f /d "\"%~dp0Work\NSudoLG.exe\" -U:T -P:E -ShowWindowMode:Hide -Wait cmd.exe /c \"timeout /t 3 /nobreak ^& reg delete %RegKey%\WdFilter /f ^& reg delete %RegKey%\WinDefend /f ^& reg delete %RegKey%\WdNisDrv /f ^& reg delete %RegKey%\MDCoreSvc /f ^& reg delete %RegKey%\WdNisSvc /f ^& reg delete %RegKey%\WdBoot /f\"" >nul
	exit /b
	
:RemoveApps
	set "KeyAPPX=SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore"
rem Удалить из InboxApplications. Чтоб не установился заново. For SystemApps.
	for %%p in (SecHealthUI Apprep.ChxApp) do (
		for /f "usebackq delims=" %%n In (`2^>nul reg query "HKLM\%KeyAPPX%\InboxApplications" /f "*%%p*" /k^|findstr ^H`) do %TI% reg delete "HKLM\%KeyAPPX%\InboxApplications\%%~nxn" /f >nul 2>&1
	)
rem Удалить из Applications для Store + EOL + Remove для -Allusers + SYS Remove для S-1-5-18
	NSudoLG -U:%ArgNsudo% -ShowWindowMode:Hide -Wait PowerShell "$usrsid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value; $filters = @('*SecHealthUI*', '*Apprep.ChxApp*'); foreach ($filter in $filters) { $packages = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like $filter } | Select-Object -ExpandProperty PackageFullName; foreach ($app in $packages) { Remove-Item -Path \"HKLM:\%KeyAPPX%\Applications\$($app)\" -Force -Recurse -ErrorAction SilentlyContinue; $endOfLifePaths = @(\"HKLM:\%KeyAPPX%\EndOfLife\$usrsid\$($app)\", \"HKLM:\%KeyAPPX%\EndOfLife\S-1-5-18\$($app)\"); $endOfLifePaths | ForEach-Object { New-Item -Path $_ -Force | Out-Null }; Remove-AppxPackage -Package $app -AllUsers -ErrorAction SilentlyContinue }}"

	for %%p in (SecHealthUI Apprep.ChxApp) do (
		NSudoLG -U:S -P:E -ShowWindowMode:Hide -Wait PowerShell "Get-AppxPackage -AllUsers *%%p* | Remove-AppxPackage -User 'S-1-5-18' -ErrorAction SilentlyContinue"
	)
	%TI% reg delete "HKLM\%KeyAPPX%\EndOfLife" /f >nul 2>&1
	%TI% reg add "HKLM\%KeyAPPX%\EndOfLife" /f >nul 2>&1
rem Эти папки можно удалять. Восстанавливаются сами, если восстановить приложение.
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%ProgramData%\Microsoft\Windows\AppRepository\Packages\*SecHealth*" /S /B /A:D`) do %TI% rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%ProgramData%\Microsoft\Windows\AppRepository\Packages\*Apprep.ChxApp*" /S /B /A:D`) do %TI% rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%LocalAppData%\Packages\*SecHealth*" /S /B /A:D`) do %TI% rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%LocalAppData%\Packages\*Apprep.ChxApp*" /S /B /A:D`) do %TI% rd /s /q "%%d"	
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "SettingsPageVisibility" /t REG_SZ /d "hide:home;windowsdefender" /f >nul

rem Удаление папок из хранилища WinSxS с большей вероятностью сломает установку некоторых обновлений.
rem 	for %%i in (windows-defender, windows-senseclient-service, windows-dynamic-image) do (
rem 			for /f "usebackq delims=" %%d In (`2^>nul dir "%SystemRoot%\WinSxS\*%%i*" /S /B /A:D`) do rd /s /q "%%d" >nul 2>&1
rem 	)

echo Удаление дополнительных компонентов... [5/13]> "%msgFile%"
for %%C in (
    Microsoft.Windows.Notepad.System
	Microsoft.Windows.PowerShell.ISE
	Print.Management.Console
    VBSCRIPT
    OpenSSH.Client
    Hello.Face
    MathRecognizer
    InternetExplorer
    StepsRecorder
    Media.WindowsMediaPlayer
	Microsoft.Wallpapers.Extended
) do (
    for /f "tokens=2 delims=:" %%A in ('dism /Online /Get-Capabilities ^| findstr /I "%%C"') do (
        set "cap=%%A"
        set "cap=!cap:~1!"
        dism /Online /Remove-Capability /CapabilityName:!cap! /NoRestart
    )
) >nul 2>&1


echo Отключение лишнего в Планировщике задач... [6/13] > "%msgFile%"
schtasks /Change /TN "\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Automated)" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\AppID\EDP Policy Manager" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\AppID\PolicyConverter" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\MareBackup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\PcaPatchDbTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\SdbinstMergeDbTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramInventoryUpdater" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ApplicationData\appuriverifierdaily" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ApplicationData\appuriverifierinstall" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ApplicationData\DsSvcCleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\AppxDeploymentClient\UCPD velocity" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Autochk\Proxy" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\AutoLogger\AutoLogger-Diagtrack-Listener" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\AutoLogger\AutoLogger-FileSizeTracking" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\BrokerInfrastructure\BgTaskRegistrationMaintenanceTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CEIP\Uploader" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CertificateServicesClient\AikCertEnrollTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CertificateServicesClient\CryptoPolicyTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CertificateServicesClient\KeyPreGenTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CertificateServicesClient\SystemTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Cleanup\UpdateCleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Clip\License Validation" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Clip\LicenseImdsIntegration" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CloudExperienceHost\SyncHost" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CloudRestore\Backup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\CloudRestore\Restore" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ContactSupport\Scheduled" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Uploader" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Device Information\Device" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Device Information\Device User" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Device Setup\Driver Recovery on Reboot" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Device Setup\Metadata Refresh" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\HandleCommand" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceProtectionStateChanged" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnosis\RecommendedTroubleshootingScanner" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnosis\Scheduled" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnosis\UnexpectedCodepath" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskCleanup\SilentCleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\DiagnosticResolver" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\DiskDiagnostic" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskFootprint\Diagnostics" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskFootprint\StorageSense" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DUSM\dusmtask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ErrorReporting\QueueReporting" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ErrorReporting\KernelCeipTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClient" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioUpload" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioRun" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnUserSignIn" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\File Classification Infrastructure\Property Definition Sync" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Help\OEMSupport" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Help\WindowsHelpUpdateTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\HelloFace\FODCleanupTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\HelloFace\FeatureCleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\InputSettingsRestoreDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\LocalUserSyncDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\MouseSyncDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\PenSyncDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\RemoteMouseSyncDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\RemotePenSyncDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\RemoteTouchpadSyncDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\input\TouchpadSyncDataAvailable" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\InstallService\WakeUpAndContinueUpdates" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\InstallService\WakeUpAndScanForUpdates" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\International\Synchronize Language Settings" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\LanguageComponentsInstaller\Installation" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\LanguageComponentsInstaller\Uninstallation" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\License Manager\TempSignedLicenseExchange" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Location\WindowsActionDialog" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsUpdateTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\MemoryDiagnostic\AutomaticOfflineMemoryDiagnostic" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\NlaSvc\WiFiTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Offline Files\Background Synchronization" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Offline Files\Logon Synchronization" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PCRPF\PCR Prediction Framework Firmware Update Task" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PerformanceTrace\WhesvcToast" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PI\Secure-Boot-Update" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PI\Sqm-Tasks" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Pluton\Pluton-Ksp-Provisioning" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Printing\EduPrintProv" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Printing\PrintJobCleanupTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PushToInstall\LoginCheck" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PushToInstall\Registration" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Ras\MobilityManager" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\ReFsDedupSvc\Initialization" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Registry\RegIdleBackup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\RetailDemo\CleanupOfflineContent" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Search\IndexerDiagnosticsTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Search\SearchIndexerMaintenance" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Setup\SetupCleanupTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\SharedPC\Account Cleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Shell\FamilySafetyRefreshTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Shell\IndexerAutomaticMaintenance" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Shell\ThemeAssetTask_SyncFODState" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Shell\ThemesSyncedImageDownload" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Shell\UndockedFlightingUpdate" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Shell\UpdateUserPictureTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Storage Tiers Management\Storage Tiers Optimization" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Subscription\EnableLicenseAcquisition" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Subscription\LicenseAcquisition" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Sysmain\WsSwapAssessmentTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Sysmain\HybridDriveCacheRebalance" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Sysmain\HybridDriveCachePrepopulate" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UPnP\UPnPHostConfig" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\CleanupUpdateTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\User Profile Service\HiveUploadTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WaaSMedic\PerformRemediation" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WaaSMedic\ScanForUpdates" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WaaSMedic\WsusScan" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Error Reporting\ReportQueue" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WindowsAI\Recall\InitialConfiguration" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WindowsAI\Recall\PolicyConfiguration" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WindowsAI\Settings\InitialConfiguration" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WindowsAI\Copilot\CopilotDataCollectionTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WindowsAI\Insights\InsightsDataCollectionTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\Refresh Group Policy Cache" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WlanSvc\CDSSync" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WOF\WIM-Hash-Management" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WOF\WIM-Hash-Validation" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Workplace Join\Device-Sync" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Workplace Join\Recovery-Check" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UNP\RunCampaignManager" /Disable >nul 2>&1
schtasks /Change /TN "\MicrosoftEdgeUpdateTaskMachineCore" /Disable >nul 2>&1
schtasks /Change /TN "\MicrosoftEdgeUpdateTaskMachineUA" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\Schedule Scan" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToDownload" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_StartDownload" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\XblGameSave\XblGameSaveTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\OneDrive\OneDrive Standalone Update Task" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnostics\RecommendedTroubleshootingScanner" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnostics\Scheduled" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnostics\UnexpectedCodepath" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\EdgeUpdate\Microsoft Edge Update Task Machine Core" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\EdgeUpdate\Microsoft Edge Update Task Machine UA" /Disable >nul 2>&1


echo Оптимизация параметров... [7/13] > "%msgFile%"
Rem Гибернация
    powercfg -h off >nul 2>&1
	reg add "HKLM\System\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d 0x0 /f >nul 2>&1
Rem Зарезервированное хранилище
	Dism /Online /Set-ReservedStorageState /State:Disabled >nul 2>&1
Rem Точки восстановления
	vssadmin resize shadowstorage /on=c: /for=c: /maxsize=1%% >nul 2>&1
	PowerShell -Command "Disable-ComputerRestore -Drive '%SystemDrive%\'" >nul 2>&1
	vssadmin delete shadows /all /quiet >nul 2>&1
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "RPSessionInterval" /f >nul 2>&1
Rem Отложенный запуск служб
	for %%p in (EventSystem NlaSvc) do reg add "HKLM\System\CurrentControlSet\Services\%%p" /v "DelayedAutostart" /t reg_dword /d 1 /f >nul 2>&1
	)
Rem Системные отчеты
	"%~dp0\Work\Eventlog" >nul 2>&1
Rem Кэш иконок
	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MaxCachedIcons" /t REG_SZ /d 4096 /f >nul
Rem Порог разделения SVC
    PowerShell "$key = 'HKLM:\SYSTEM\CurrentControlSet\Control'; if (-not (Get-ItemProperty -Path $key -Name 'SvcHostSplitThresholdInKB' -ErrorAction SilentlyContinue)) { Write-Output ' Параметра SvcHostSplitThresholdInKB нет, отмена действий'; Pause; Exit } elseif (-not (Get-ItemProperty -Path $key -Name 'SvcHostSplitThresholdInKB_orig' -ErrorAction SilentlyContinue)) { Rename-ItemProperty -Path $key -Name 'SvcHostSplitThresholdInKB' -NewName 'SvcHostSplitThresholdInKB_orig'; $mem = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize + 1024000; Set-ItemProperty -Path $key -Name 'SvcHostSplitThresholdInKB' -Value $mem -Type DWord }
Rem Ускорить открытие папок
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d NotSpecified /f >nul 2>&1
	for %%k in (Directory.Audio Directory.Image Directory.Video) do (for %%c in (Enqueue Play) do (reg add "HKCR\SystemFileAssociations\%%k\shell\%%c" /v "LegacyDisable" /t REG_SZ /d "" /f >nul)) >nul 2>&1
Rem Отключить VBS
    bcdedit /set hypervisorlaunchtype off >nul
    for %%p in (
        HypervisorEnforcedCodeIntegrity
        LsaCfgFlags
        RequirePlatformSecurityFeatures
        ConfigureSystemGuardLaunch
        ConfigureKernelShadowStacksLaunch
    ) do reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "%%p" /f >nul 2>&1
    for %%p in (
        EnableVirtualizationBasedSecurity
        HVCIMATRequired
    ) do reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
    for %%p in (
        WasEnabledBy
        WasEnabledBySysprep
    ) do reg delete "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%%p" /f >nul 2>&1
    for %%p in (
        Enabled
        HVCIMATRequired
        Locked
    ) do reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
    for %%p in (
        EnableVirtualizationBasedSecurity
        RequirePlatformSecurityFeatures
        Locked
    ) do reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
    for %%p in (
        Enabled
        AuditModeEnabled
        WasEnabledBy
    ) do reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
Rem Отключить DVR 
    reg add "HKCR\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 
    reg add "HKCR\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul
	reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul
	reg add "HKLM\Software\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "Value" /t REG_DWORD /d 0 /f >nul
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul
Rem Максимальная производительность
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
    for /f "tokens=4" %%a in ('powercfg /l ^| findstr /i "Максимальная Ultimate"') do set "guid=%%a"
    powercfg /setactive !guid!
Rem Функция Возобновить
	"%~dp0\Work\vivetool.exe" /disable /id:56517033 >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CrossDeviceResume\Configuration" /v "IsResumeAllowed" /t REG_DWORD /d 0 /f >nul 
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CrossDeviceResume\Configuration" /v "IsOneDriveResumeAllowed" /t REG_DWORD /d 0 /f >nul
Rem Удаления старых драйверов
PowerShell -encodedCommand JABkAGkAcwBtAE8AdQB0ACAAPQAgAGQAaQBzAG0AIAAvAG8AbgBsAGkAbgBlACAALwBnAGUAdAAtAGQAcgBpAHYAZQByAHMADQAKACQATABpAG4AZQBzACAAPQAgACQAZABpAHMAbQBPAHUAdAAgAHwAIABzAGUAbABlAGMAdAAgAC0AUwBrAGkAcAAgADEAMAANAAoAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAiAHQAaABlAE4AYQBtAGUAIgANAAoAJABEAHIAaQB2AGUAcgBzACAAPQAgAEAAKAApAA0ACgBmAG8AcgBlAGEAYwBoACAAKAAgACQATABpAG4AZQAgAGkAbgAgACQATABpAG4AZQBzACAAKQAgAHsADQAKACAAIAAgACAAJAB0AG0AcAAgAD0AIAAkAEwAaQBuAGUADQAKACAAIAAgACAAJAB0AHgAdAAgAD0AIAAkACgAJAB0AG0AcAAuAFMAcABsAGkAdAAoACAAJwA6ACcAIAApACkAWwAxAF0ADQAKACAAIAAgACAAcwB3AGkAdABjAGgAIAAoACQATwBwAGUAcgBhAHQAaQBvAG4AKQAgAHsADQAKACAAIAAgACAAIAAgACAAIAAnAHQAaABlAE4AYQBtAGUAJwAgAHsAIAAkAE4AYQBtAGUAIAA9ACAAJAB0AHgAdAANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAnAHQAaABlAEYAaQBsAGUATgBhAG0AZQAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABiAHIAZQBhAGsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUARgBpAGwAZQBOAGEAbQBlACcAIAB7ACAAJABGAGkAbABlAE4AYQBtAGUAIAA9ACAAJAB0AHgAdAAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQATwBwAGUAcgBhAHQAaQBvAG4AIAA9ACAAJwB0AGgAZQBFAG4AdAByACcADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYgByAGUAYQBrAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUARQBuAHQAcgAnACAAewAgACQARQBuAHQAcgAgAD0AIAAkAHQAeAB0AC4AVAByAGkAbQAoACkADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQATwBwAGUAcgBhAHQAaQBvAG4AIAA9ACAAJwB0AGgAZQBDAGwAYQBzAHMATgBhAG0AZQAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABiAHIAZQBhAGsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUAQwBsAGEAcwBzAE4AYQBtAGUAJwAgAHsAIAAkAEMAbABhAHMAcwBOAGEAbQBlACAAPQAgACQAdAB4AHQALgBUAHIAaQBtACgAKQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQATwBwAGUAcgBhAHQAaQBvAG4AIAA9ACAAJwB0AGgAZQBWAGUAbgBkAG8AcgAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYgByAGUAYQBrAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAB9AA0ACgAgACAAIAAgACAAIAAgACAAJwB0AGgAZQBWAGUAbgBkAG8AcgAnACAAewAgACQAVgBlAG4AZABvAHIAIAA9ACAAJAB0AHgAdAAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAnAHQAaABlAEQAYQB0AGUAJwANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGIAcgBlAGEAawANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACcAdABoAGUARABhAHQAZQAnACAAewAgACAAJAB0AG0AcAAgAD0AIAAkAHQAeAB0AC4AcwBwAGwAaQB0ACgAIAAnAC4AJwAgACkADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAdAB4AHQAIAA9ACAAIgAkACgAJAB0AG0AcABbADIAXQApAC4AJAAoACQAdABtAHAAWwAxAF0AKQAuACQAKAAkAHQAbQBwAFsAMABdAC4AVAByAGkAbQAoACkAKQAiAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAEQAYQB0AGUAIAA9ACAAJAB0AHgAdAANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABPAHAAZQByAGEAdABpAG8AbgAgAD0AIAAnAHQAaABlAFYAZQByAHMAaQBvAG4AJwANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYgByAGUAYQBrAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAH0ADQAKACAAIAAgACAAIAAgACAAIAAnAHQAaABlAFYAZQByAHMAaQBvAG4AJwAgAHsAIAAkAFYAZQByAHMAaQBvAG4AIAA9ACAAJAB0AHgAdAAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAE8AcABlAHIAYQB0AGkAbwBuACAAPQAgACcAdABoAGUATgB1AGwAbAAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAHAAYQByAGEAbQBzACAAPQAgAFsAbwByAGQAZQByAGUAZABdAEAAewAgACcARgBpAGwAZQBOAGEAbQBlACcAIAA9ACAAJABGAGkAbABlAE4AYQBtAGUADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJwBWAGUAbgBkAG8AcgAnACAAPQAgACQAVgBlAG4AZABvAHIADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJwBEAGEAdABlACcAIAA9ACAAJABEAGEAdABlAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACcATgBhAG0AZQAnACAAPQAgACQATgBhAG0AZQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAnAEMAbABhAHMAcwBOAGEAbQBlACcAIAA9ACAAJABDAGwAYQBzAHMATgBhAG0AZQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAnAFYAZQByAHMAaQBvAG4AJwAgAD0AIAAkAFYAZQByAHMAaQBvAG4ADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJwBFAG4AdAByACcAIAA9ACAAJABFAG4AdAByAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABvAGIAagAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAALQBUAHkAcABlAE4AYQBtAGUAIABQAFMATwBiAGoAZQBjAHQAIAAtAFAAcgBvAHAAZQByAHQAeQAgACQAcABhAHIAYQBtAHMADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQARAByAGkAdgBlAHIAcwAgACsAPQAgACQAbwBiAGoADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGIAcgBlAGEAawANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAB9AA0ACgAgACAAIAAgACAAIAAgACAAIAAnAHQAaABlAE4AdQBsAGwAJwAgAHsAIAAkAE8AcABlAHIAYQB0AGkAbwBuACAAPQAgACcAdABoAGUATgBhAG0AZQAnAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGIAcgBlAGEAawANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAB9AA0ACgB9AA0ACgAkAGwAYQBzAHQAIAA9ACAAJwAnAA0ACgAkAE4AbwB0AFUAbgBpAHEAdQBlACAAPQAgAEAAKAApAA0ACgBmAG8AcgBlAGEAYwBoACAAKAAgACQARAByACAAaQBuACAAJAAoACQARAByAGkAdgBlAHIAcwAgAHwAIABzAG8AcgB0ACAARgBpAGwAZQBuAGEAbQBlACkAIAApACAAewANAAoAIAAgACAAIABpAGYAIAAoACQARAByAC4ARgBpAGwAZQBOAGEAbQBlACAALQBlAHEAIAAkAGwAYQBzAHQAIAAgACkAIAB7ACAAIAAkAE4AbwB0AFUAbgBpAHEAdQBlACAAKwA9ACAAJABEAHIAIAAgAH0ADQAKACAAIAAgACAAJABsAGEAcwB0ACAAPQAgACQARAByAC4ARgBpAGwAZQBOAGEAbQBlAA0ACgB9AA0ACgAkAE4AbwB0AFUAbgBpAHEAdQBlACAAfAAgAHMAbwByAHQAIABGAGkAbABlAE4AYQBtAGUAIAB8ACAAZgB0AA0ACgAjAFMAZQBhAHIAYwBoAGkAbgBnACAAZgBvAHIAIABkAHUAcABsAGkAYwBhAHQAZQAgAGQAcgBpAHYAZQByAHMAIAANAAoAJABsAGkAcwB0ACAAPQAgACQATgBvAHQAVQBuAGkAcQB1AGUAIAB8ACAAcwBlAGwAZQBjAHQAIAAtAEUAeABwAGEAbgBkAFAAcgBvAHAAZQByAHQAeQAgAEYAaQBsAGUATgBhAG0AZQAgAC0AVQBuAGkAcQB1AGUADQAKACQAVABvAEQAZQBsACAAPQAgAEAAKAApAA0ACgBmAG8AcgBlAGEAYwBoACAAKAAgACQARAByACAAaQBuACAAJABsAGkAcwB0ACAAKQAgAHsADQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIARAB1AHAAbABpAGMAYQB0AGUAIABkAHIAaQB2AGUAcgAgAGYAbwB1AG4AZAAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFkAZQBsAGwAbwB3AA0ACgAgACAAIAAgACQAcwBlAGwAIAA9ACAAJABEAHIAaQB2AGUAcgBzACAAfAAgAHcAaABlAHIAZQAgAHsAIAAkAF8ALgBGAGkAbABlAE4AYQBtAGUAIAAtAGUAcQAgACQARAByACAAfQAgAHwAIABzAG8AcgB0ACAAZABhAHQAZQAgAC0ARABlAHMAYwBlAG4AZABpAG4AZwAgAHwAIABzAGUAbABlAGMAdAAgAC0AUwBrAGkAcAAgADEADQAKACAAIAAgACAAJABzAGUAbAAgAHwAIABmAHQADQAKACAAIAAgACAAJABUAG8ARABlAGwAIAArAD0AIAAkAHMAZQBsAA0ACgB9AA0ACgAjAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAEwAaQBzAHQAIABvAGYAIABkAHIAaQB2AGUAcgAgAHYAZQByAHMAaQBvAG4AIAAgAHQAbwAgAHIAZQBtAG8AdgBlACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAUgBlAGQADQAKACQAVABvAEQAZQBsACAAfAAgAGYAdAANAAoAIwBEAGUAbABlAHQAaQBuAGcAIABvAGwAZAAgAGQAcgBpAHYAZQByAHMADQAKAGYAbwByAGUAYQBjAGgAIAAoACAAJABpAHQAZQBtACAAaQBuACAAJABUAG8ARABlAGwAIAApACAAewANAAoAIAAgACAAIAAkAE4AYQBtAGUAIAA9ACAAJAAoACQAaQB0AGUAbQAuAE4AYQBtAGUAKQAuAFQAcgBpAG0AKAApAA0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAGQAZQBsAGUAdABpAG4AZwAgACQATgBhAG0AZQAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFkAZQBsAGwAbwB3AA0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAHAAbgBwAHUAdABpAGwALgBlAHgAZQAgAC8AZABlAGwAZQB0AGUALQBkAHIAaQB2AGUAcgAgACAAJABOAGEAbQBlACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAWQBlAGwAbABvAHcADQAKACAAIAAgACAASQBuAHYAbwBrAGUALQBFAHgAcAByAGUAcwBzAGkAbwBuACAALQBDAG8AbQBtAGEAbgBkACAAIgBwAG4AcAB1AHQAaQBsAC4AZQB4AGUAIAAvAGQAZQBsAGUAdABlAC0AZAByAGkAdgBlAHIAIAAkAE4AYQBtAGUAIgANAAoAfQA= >nul 2>&1
	
	
echo Настройка Центра обновления Windows... [8/13] > "%msgFile%"
	timeout /t 5 /nobreak >nul 2>&1
Rem Запрет на установку драйверов
	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul
	reg add "HKLM\Software\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul
	reg add "HKLM\Software\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f >nul
	reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f >nul
Rem Запрет на обновление баз Защитника
	reg add "HKLM\Software\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f >nul
Rem Пауза обновлений
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseUpdatesStartTime" /t REG_SZ /d 2024-09-13T00:00:00Z /f >nul
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseUpdatesExpiryTime" /t REG_SZ /d 2077-07-07T00:00:00Z /f >nul

	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseFeatureUpdatesStartTime" /t REG_SZ /d 2024-09-13T00:00:00Z /f >nul
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseFeatureUpdatesExpiryTime" /t REG_SZ /d 2077-07-07T00:00:00Z /f >nul

	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseQualityUpdatesStartTime" /t REG_SZ /d 2024-09-13T00:00:00Z /f >nul
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseQualityUpdatesExpiryTime" /t REG_SZ /d 2077-07-07T00:00:00Z /f >nul
	
	reg add "HKLM\Software\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedFeatureStatus" /t REG_DWORD /d 1 /f >nul
	reg add "HKLM\Software\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedQualityStatus" /t REG_DWORD /d 1 /f >nul
	reg add "HKLM\Software\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedQualityDate" /t REG_SZ /d "2077-07-07 13:00:00" /f >nul
	reg add "HKLM\Software\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedFeatureDate" /t REG_SZ /d "2077-07-07 13:00:00" /f >nul


echo Применение полезных твиков... [9/13] > "%msgFile%"
	timeout /t 3 /nobreak >nul 2>&1
Rem Отключение UAC
    for %%a in (EnableLUA PromptOnSecureDesktop EnableVirtualization ConsentPromptBehaviorAdmin) do reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "%%a" /t REG_DWORD /d 0 /f >nul
    for %%b in (batfile cmdfile exefile cplfile mscfile) do reg add "HKLM\Software\Classes\%%b\shell\runas" /v "ProgrammaticAccessOnly" /t REG_SZ /d "" /f >nul
    reg add "HKLM\Software\Classes\exefile\shell\runas2" /v "ProgrammaticAccessOnly" /t REG_SZ /d "" /f >nul
Rem Административная учетная запись
   net user "%UserName%" /active:yes >nul
Rem Снятие региональных ограничений
	sc start TrustedInstaller >nul
	%TI% ren "%SystemRoot%\System32\IntegratedServicesRegionPolicySet.json" IntegratedServicesRegionPolicySet.json_bak
	%TI% copy "%~dp0\Work\IntegratedServicesRegionPolicySet.json" "%SystemRoot%\System32"
Rem Принудительное завершение программ
reg add "HKCR\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d 1 /f >nul
Rem Отключение Удаленного помощника
	reg add "HKLM\System\ControlSet001\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f >nul
	reg add "HKLM\System\ControlSet001\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d 0 /f >nul
	reg add "HKLM\System\ControlSet001\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 1 /f >nul
	reg add "HKLM\System\ControlSet001\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t REG_DWORD /d 0 /f >nul
Rem Отключение залипания клавиш
	reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d 506 /f >nul
Rem Скрытие TTL
	reg add "HKLM\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 0x41 /f >nul
	reg add "HKLM\SYSTEM\ControlSet001\Services\Tcpip6\Parameters" /v DefaultTTL /t REG_DWORD /d 0x41 /f >nul
Rem Отключение уведомлений и рекомендаций в Система > Уведомления
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f >nul
Rem Отключение уведомлений и рекомендаций в Персонализация > Пуск
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Start" /v "ShowRecentList" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Start" /v "ShowFrequentList" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_AccountNotifications" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_Layout" /t REG_DWORD /d 1 /f >nul
Rem Отключение рекомендаций в Проводнике
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowCloudFilesInQuickAccess" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecommendations" /t REG_DWORD /d 0 /f >nul
Rem Отключение других рекомендаций и предложений
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul
Rem Установка DNS
set adapters=Ethernet "Беспроводная сеть" "Бездротова мережа" "Wireless network"
for %%a in (!adapters!) do (
	netsh interface ipv4 set dns name=%%a static 1.1.1.1 >nul
	netsh interface ip add dns name=%%a address=1.0.0.1 index=2 >nul
)


echo Установка драйверов... [10/13] > "%msgFile%"
	timeout /t 3 /nobreak >nul 2>&1
if exist "%USERPROFILE%\Desktop\Drivers" (
    pnputil /add-driver "%USERPROFILE%\Desktop\Drivers\*.inf" /subdirs /install >nul 2>&1
    timeout /t 3 /nobreak >nul 2>&1
) else (
    echo Папка с драйверами не обнаружена. Пропускаю установку драйверов. [10/13] > "%msgFile%"
)


echo Установка Visual C++ и DirectX... [11/13] > "%msgFile%"
	start "" /wait "%~dp0\Work\DirectX.exe"
	start "" /wait "%~dp0\Work\VisualCppRedist_AIO_x86_x64.exe" /aiA /gm2
	

echo Установка визуальных твиков... [12/13] > "%msgFile%"
Rem Удаление Главная
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "HubMode" /t REG_DWORD /d 1 /f >nul
    reg add "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul
    reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul
Rem Удаление Галерея
    reg add "HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f >nul 2>&1
Rem Удаление Сеть
	reg add "HKCU\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
Rem Темная тема
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f >nul 2>&1
Rem Установка обоев
	copy "%~dp0\Work\1.jpg" "%SystemRoot%\Web\Wallpaper\Windows" >nul 2>&1
	reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%SystemRoot%\Web\Wallpaper\Windows\1.jpg" /f >nul 2>&1
Rem Установка синих папок
	%TI% ren "%SystemRoot%\SystemResources\imageres.dll.mun" imageres.dll.mun_bak
	%TI% copy "%~dp0\Work\BlueIcon\imageres.dll.mun" "%SystemRoot%\SystemResources"
	for %%f in ("File Explorer.lnk" Проводник.lnk) do del /q "%AppData%\Microsoft\Windows\Start Menu\Programs\%%~f" "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\%%~f" >nul 2>&1
	
	copy "%~dp0\Work\BlueIcon\File Explorer.lnk" "%AppData%\Microsoft\Windows\Start Menu\Programs" /y >nul
	copy "%~dp0\Work\BlueIcon\File Explorer.lnk" "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar" /y >nul
	copy "%~dp0\Work\BlueIcon\Blank.ico" "%SystemRoot%" /y >nul

	xcopy "%~dp0\Work\BlueIcon\windows" "%SystemRoot%" /E /I /Y /H /K /C /R /F >nul
	xcopy "%~dp0\Work\BlueIcon\x64" "%ProgramFiles%" /E /I /Y /H /K /C /R /F >nul
	xcopy "%~dp0\Work\BlueIcon\x86" "%ProgramFiles(x86)%" /E /I /Y /H /K /C /R /F >nul
	xcopy "%~dp0\Work\BlueIcon\users" "%SystemDrive%\Users" /E /I /Y /H /K /C /R /F >nul

	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "179" /t REG_EXPAND_SZ /d "%SystemRoot%\Blank.ico,0" /f >nul

	reg add "HKCR\CompressedFolder\DefaultIcon" /v "" /t REG_EXPAND_SZ /d "%SystemRoot%\System32\imageres.dll,165" /f >nul
	reg add "HKCR\ArchiveFolder\DefaultIcon" /v "" /t REG_EXPAND_SZ /d "%SystemRoot%\System32\imageres.dll,165" /f >nul
	
	pushd "%ProgramFiles%"
	for %%p in (x64.ico desktop.ini) do attrib +h %%p >nul 2>&1
	popd
	pushd "%ProgramFiles(x86)%"
	for %%p in (x86.ico desktop.ini) do attrib +h %%p >nul 2>&1
	popd
	pushd "%SystemDrive%\Users"
	for %%p in (users.ico desktop.ini) do attrib +h %%p >nul 2>&1
	popd
	pushd "%SystemRoot%"
	for %%p in (windows.ico desktop.ini) do attrib +h %%p >nul 2>&1
	popd
	for %%f in ("%ProgramFiles(x86)%" "%ProgramFiles%" "%SystemDrive%\Users" "%SystemRoot%") do ATTRIB +R "%%~f" >nul 2>&1

Rem Установка Icaros
	if not exist "%ProgramFiles%\WinClean\Preview" mkdir "%ProgramFiles%\WinClean\Preview" >nul 2>&1
    for %%F in (avcodec-ics-61.dll avformat-ics-61.dll avutil-ics-59.dll IcarosCache.dll IcarosPropertyHandler.dll IcarosThumbnailProvider.dll libunarr-ics.dll swscale-ics-8.dll) do (
	copy "%~dp0\Work\Icaros\%%F" "%ProgramFiles%\WinClean\Preview" >nul 2>&1) 

    reg add "HKLM\SOFTWARE\Classes\CLSID\{c5aec3ec-e812-4677-a9a7-4fee1f9aa000}" /ve /t REG_SZ /d "Icaros Thumbnail Provider" /f >nul
    reg add "HKLM\SOFTWARE\Classes\CLSID\{c5aec3ec-e812-4677-a9a7-4fee1f9aa000}\InProcServer32" /ve /t REG_SZ /d "%ProgramFiles%\WinClean\Preview\IcarosThumbnailProvider.dll" /f >nul
    reg add "HKLM\SOFTWARE\Classes\CLSID\{c5aec3ec-e812-4677-a9a7-4fee1f9aa000}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{c5aec3ec-e812-4677-a9a7-4fee1f9aa000}" /t REG_SZ /d "Icaros Thumbnail Provider" /f >nul
	
	reg add "HKCU\Software\Icaros" /v "Cache" /t REG_DWORD /d 2 /f >nul 
	reg add "HKCU\Software\Icaros" /v "FrameThresh" /t REG_DWORD /d 20 /f >nul 
	reg add "HKCU\Software\Icaros" /v "UseCoverArt" /t REG_DWORD /d 2 /f >nul 
	reg add "HKCU\Software\Icaros\Cache" /v "Location" /t REG_SZ /d "%ProgramFiles%\WinClean\Preview" /f >nul
	reg add "HKCU\Software\Icaros\Cache\Locations" /v "%ProgramFiles%\WinClean\Preview" /t REG_DWORD /d 33554453 /f >nul

    for %%E in (.3g2 .3gp .3gp2 .3gpp .ai .aiff .amv .ape .asf .avi .avif .bik .bmp .cb7 .cbr .cbz .cur .dds .divx .dpg .dv .dvr-ms .eps .epub .evo .exr .f4v .flac .flv .gif .hdmov .hdr .heic .heif .indd .jpg .k3g .m1v .m2t .m2ts .m2v .m4b .m4p .m4v .mk3d .mka .mkv .mov .mp2v .mp3 .mp4 .mp4v .mpc .mpe .mpeg .mpg .mpv2 .mpv4 .mqv .mts .mxf .nsv .odp .ods .odt .ofr .ofs .ogg .ogm .ogv .opus .png .psd .psxprj .px .qt .ram .rm .rmvb .skm .spx .swf .tak .tga .tif .tiff .tp .tpr .trp .ts .tta .vob .wav .webm .webp .wm .wmv .wv .xvid
    ) do (
        reg add "HKLM\Software\Classes\%%E\ShellEx\{e357fccd-a995-4576-b01f-234630154e96}" /ve /t REG_SZ /d "{c5aec3ec-e812-4677-a9a7-4fee1f9aa000}" /f >nul 
        reg add "HKLM\Software\Classes\%%E\ShellEx\{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}" /ve /t REG_SZ /d "{c5aec3ec-e812-4677-a9a7-4fee1f9aa000}" /f >nul 
    )

Rem Установка секунд в трее
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSecondsInSystemClock /t REG_DWORD /d 1 /f >nul
Rem Установка даты в трее
    reg add "HKCU\Control Panel\International" /v sShortDate /t REG_SZ /d "ddd, dd.MM.yy" /f >nul 2>&1
Rem Установка Завершить задачу
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /t REG_DWORD /d 1 /f >nul
Rem Удаление лишних значков
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >nul
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul 
Rem Скрытие Рекомендуем
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "HideRecommendedSection" /t REG_DWORD /d 1 /f >nul
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Education" /v "IsEducationEnvironment" /t REG_DWORD /d 1 /f >nul
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d 1 /f >nul
Rem Установка значка Настройки в Пуске
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Start" /v "VisiblePlaces" /t REG_BINARY /d 86087352AA5143429F7B2776584659D4 /f >nul
Rem Удаления сжатия обоев
	reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d 0x64 /f >nul
Rem Удаление экрана блокировки
	reg add "HKLM\Software\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f >nul
	reg add "HKLM\Software\Policies\Microsoft\Windows\Personalization" /v NoLockScreenCamera /t REG_DWORD /d 1 /f >nul
Rem Удаление тени на значках Рабочего стола
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 0 /f >nul
Rem Открывать Проводник в Этот компьютер
	reg add  "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 0 /f >nul


echo Сжатие системы... [13/13] > "%msgFile%"
rem compact /c /s:%SystemDrive%\ /exe:LZX /i /a /f >nul 2>&1
	pushd "%LocalAppData%\Microsoft\Windows\Explorer" >nul 2>&1
	del /s /q /a:h "IconCache*" "thumbcache*" >nul 2>&1
	del /s /q /f "IconCache*" "thumbcache*" >nul 2>&1
	popd >nul 2>&1
	pushd "%LocalAppData%" >nul 2>&1	if exist IconCache.db del /a /q IconCache.db >nul 2>&1
	if exist IconCache.db-wal del /a /q IconCache.db-wal >nul 2>&1
	del /s /q /a:h "IconCache*" "thumbcache*" >nul 2>&1
	popd >nul 2>&1


echo Готово. Перезагружаюсь...> "%msgFile%"
	timeout /t 5 /nobreak >nul 2>&1
	del /q /f /s "%~dp0Work\message.txt" >nul 2>&1
	shutdown /r /t 2
	Exit

:WinVer
    for /f "skip=2 tokens=3" %%a in ('2^>nul reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') do set /a build=%%a
    if !build! LSS 22000 %ch%  {0c}Эта утилита работает только на Windows 11{\n#} && timeout /t 3 /nobreak >nul && exit /b
