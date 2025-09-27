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
Rem Удаление файлов обновлений
	del /q /f /s "%SystemRoot%\SoftwareDistribution\Download\*.*" >nul 2>&1
	rd /q /s "%SystemRoot%\SoftwareDistribution\Download\" >nul 2>&1
	del /q /f /s "%SystemRoot%\SoftwareDistribution\Download" >nul 2>&1
	del /q /f /s "%ProgramFiles(x86)%\Microsoft\EdgeUpdate\Download\*.*" >nul 2>&1
	rd /q /s "%ProgramFiles(x86)%\Microsoft\EdgeUpdate\Download\" >nul 2>&1
Rem Удаление кэша Windows Store
	del /q /f /s "%userprofile%\AppData\Local\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalCache\*.*" >nul 2>&1
	rd /q /s "%userprofile%\AppData\Local\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalCache\" >nul 2>&1
Rem Удаление кэша Проводника
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
Rem Удаление ShellBags
for %%k in (Bags BagMRU BagsMRU) do (
    reg delete "HKCU\Software\Microsoft\Windows\Shell\%%k" /f >nul 2>&1
    reg delete "HKCU\Software\Microsoft\Windows\ShellNoRoam\%%k" /f >nul 2>&1
    reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\%%k" /f >nul 2>&1
)


echo Удаление всех UWP-приложений... [2/13] > "%msgFile%"
	PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage | Where-Object { $_.NonRemovable -eq $false } | ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue }" >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f >nul 2>&1
Rem Удаление OneDrive
	taskkill /f /im OneDrive.exe >nul 2>&1
	%SystemRoot%\System32\OneDriveSetup.exe /uninstall >nul 2>&1
	rd "%UserProfile%\OneDrive" /Q /S >nul 2>&1
	rd "%LocalAppData%\Microsoft\OneDrive" /Q /S >nul 2>&1
	rd "%ProgramData%\Microsoft OneDrive" /Q /S >nul 2>&1
	reg delete "HKCU\Software\Microsoft\OneDrive" /f >nul 2>&1
	reg delete "HKLM\Software\Microsoft\OneDrive" /f >nul 2>&1
Rem Удаление лишних папок с приложениями в Пуске
	rd "%AppData%\Microsoft\Windows\Start Menu\Programs\Accessibility" /Q /S >nul 2>&1
	rd "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Accessories\System Tools" /Q /S >nul 2>&1
Rem Удаление Помощника по удаленному подключению
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

	%TI% ren "%SystemRoot%\System32\SecurityHealthService.exe" "SecurityHealthService.exe_fuck"
	%TI% ren "%SystemRoot%\System32\smartscreenps.dll" smartscreenps.dll_fuck
	%TI% ren "%SystemRoot%\System32\wscapi.dll" wscapi.dll_fuck
	%TI% ren "%SystemRoot%\System32\smartscreen.exe" "smartscreen.exedel"

	%TI% del /f /q "%SystemRoot%\Containers\WindowsDefenderApplicationGuard.wim"
	%TI% del /f /q "%SystemRoot%\Containers\serviced\WindowsDefenderApplicationGuard.wim"

	for %%f in (
		SecurityHealthService.exe SecurityHealthSystray.exe SecurityHealthHost.exe
		SecurityHealthAgent.dll SecurityHealthSSO.dll SecurityHealthProxyStub.dll smartscreen.dll wscisvif.dll
		wscproxystub.dll smartscreenps.dll wscapi.dll windowsdefenderapplicationguardcsp.dll wscsvc.dll SecurityHealthCore.dll
		SecurityHealthSsoUdk.dll SecurityHealthUdk.dll smartscreen.exe

		SecurityHealthService.exe_fuck smartscreenps.dll_fuck wscapi.dll_fuck smartscreen.exedel
	) do %TI% del /f /q "%SystemRoot%\System32\%%f" "%SystemRoot%\SysWOW64\%%f"

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
reg query "HKLM\System\CurrentControlset\Services\WdFilter" >nul 2>&1 && (
		call :CreateRunOnceDelReg
		goto RemoveApps
	)

	reg delete "HKU\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /f >nul 2>&1
	goto RemoveApps
 
 :CreateRunOnceDelReg
	set "RegKey=HKLM\System\CurrentControlSet\Services"
	for %%p in (RegClean RegClean1) do %TI% reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "%%p" /t reg_sz /f /d "\"%~dp0Work\NSudoLG.exe\" -U:T -P:E -ShowWindowMode:Hide -Wait cmd.exe /c \"timeout /t 3 /nobreak ^& reg delete %RegKey%\WdFilter /f ^& reg delete %RegKey%\WinDefend /f ^& reg delete %RegKey%\WdNisDrv /f ^& reg delete %RegKey%\MDCoreSvc /f ^& reg delete %RegKey%\WdNisSvc /f ^& reg delete %RegKey%\WdBoot /f\"" >nul
	exit /b
	
:RemoveApps
	set "KeyAPPX=SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore"
	for %%p in (SecHealthUI Apprep.ChxApp) do (
		for /f "usebackq delims=" %%n In (`2^>nul reg query "HKLM\%KeyAPPX%\InboxApplications" /f "*%%p*" /k^|findstr ^H`) do %TI% reg delete "HKLM\%KeyAPPX%\InboxApplications\%%~nxn" /f >nul 2>&1
	)
	NSudoLG -U:%ArgNsudo% -ShowWindowMode:Hide -Wait PowerShell "$usrsid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value; $filters = @('*SecHealthUI*', '*Apprep.ChxApp*'); foreach ($filter in $filters) { $packages = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like $filter } | Select-Object -ExpandProperty PackageFullName; foreach ($app in $packages) { Remove-Item -Path \"HKLM:\%KeyAPPX%\Applications\$($app)\" -Force -Recurse -ErrorAction SilentlyContinue; $endOfLifePaths = @(\"HKLM:\%KeyAPPX%\EndOfLife\$usrsid\$($app)\", \"HKLM:\%KeyAPPX%\EndOfLife\S-1-5-18\$($app)\"); $endOfLifePaths | ForEach-Object { New-Item -Path $_ -Force | Out-Null }; Remove-AppxPackage -Package $app -AllUsers -ErrorAction SilentlyContinue }}"

	for %%p in (SecHealthUI Apprep.ChxApp) do (
		NSudoLG -U:S -P:E -ShowWindowMode:Hide -Wait PowerShell "Get-AppxPackage -AllUsers *%%p* | Remove-AppxPackage -User 'S-1-5-18' -ErrorAction SilentlyContinue"
	)
	%TI% reg delete "HKLM\%KeyAPPX%\EndOfLife" /f >nul 2>&1
	%TI% reg add "HKLM\%KeyAPPX%\EndOfLife" /f >nul 2>&1
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%ProgramData%\Microsoft\Windows\AppRepository\Packages\*SecHealth*" /S /B /A:D`) do %TI% rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%ProgramData%\Microsoft\Windows\AppRepository\Packages\*Apprep.ChxApp*" /S /B /A:D`) do %TI% rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%LocalAppData%\Packages\*SecHealth*" /S /B /A:D`) do %TI% rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul Dir "%LocalAppData%\Packages\*Apprep.ChxApp*" /S /B /A:D`) do %TI% rd /s /q "%%d"	
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "SettingsPageVisibility" /t REG_SZ /d "hide:home;windowsdefender" /f >nul

Rem Удаление папок Защитника из хранилища WinSxS (с большей вероятностью сломает установку некоторых обновлений)
Rem 	for %%i in (windows-defender, windows-senseclient-service, windows-dynamic-image) do (
Rem 			for /f "usebackq delims=" %%d In (`2^>nul dir "%SystemRoot%\WinSxS\*%%i*" /S /B /A:D`) do rd /s /q "%%d" >nul 2>&1
Rem 	)


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
timeout /t 3 /nobreak >nul 2>&1
for %%T in (
    "\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Automated)"
    "\Microsoft\Windows\AppID\EDP Policy Manager"
    "\Microsoft\Windows\AppID\PolicyConverter"
    "\Microsoft\Windows\Application Experience\MareBackup"
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp"
    "\Microsoft\Windows\Application Experience\PcaPatchDbTask"
    "\Microsoft\Windows\Application Experience\SdbinstMergeDbTask"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\ProgramInventoryUpdater"
    "\Microsoft\Windows\ApplicationData\appuriverifierdaily"
    "\Microsoft\Windows\ApplicationData\appuriverifierinstall"
    "\Microsoft\Windows\ApplicationData\DsSvcCleanup"
    "\Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup"
    "\Microsoft\Windows\AppxDeploymentClient\UCPD velocity"
    "\Microsoft\Windows\Autochk\Proxy"
    "\Microsoft\Windows\AutoLogger\AutoLogger-Diagtrack-Listener"
    "\Microsoft\Windows\AutoLogger\AutoLogger-FileSizeTracking"
    "\Microsoft\Windows\BrokerInfrastructure\BgTaskRegistrationMaintenanceTask"
    "\Microsoft\Windows\CEIP\Uploader"
    "\Microsoft\Windows\CertificateServicesClient\AikCertEnrollTask"
    "\Microsoft\Windows\CertificateServicesClient\CryptoPolicyTask"
    "\Microsoft\Windows\CertificateServicesClient\KeyPreGenTask"
    "\Microsoft\Windows\CertificateServicesClient\SystemTask"
    "\Microsoft\Windows\Cleanup\UpdateCleanup"
    "\Microsoft\Windows\Clip\License Validation"
    "\Microsoft\Windows\Clip\LicenseImdsIntegration"
    "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
    "\Microsoft\Windows\CloudExperienceHost\SyncHost"
    "\Microsoft\Windows\CloudRestore\Backup"
    "\Microsoft\Windows\CloudRestore\Restore"
    "\Microsoft\Windows\ContactSupport\Scheduled"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM"
    "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
    "\Microsoft\Windows\Device Information\Device"
    "\Microsoft\Windows\Device Information\Device User"
    "\Microsoft\Windows\Device Setup\Driver Recovery on Reboot"
    "\Microsoft\Windows\Device Setup\Metadata Refresh"
    "\Microsoft\Windows\DeviceDirectoryClient\HandleCommand"
    "\Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand"
    "\Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck"
    "\Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession"
    "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange"
    "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange"
    "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24"
    "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange"
    "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceProtectionStateChanged"
    "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange"
    "\Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice"
    "\Microsoft\Windows\Diagnosis\RecommendedTroubleshootingScanner"
    "\Microsoft\Windows\Diagnosis\Scheduled"
    "\Microsoft\Windows\Diagnosis\UnexpectedCodepath"
    "\Microsoft\Windows\DiskCleanup\SilentCleanup"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"
    "\Microsoft\Windows\DiskDiagnostic\DiagnosticResolver"
    "\Microsoft\Windows\DiskDiagnostic\DiskDiagnostic"
    "\Microsoft\Windows\DiskFootprint\Diagnostics"
    "\Microsoft\Windows\DiskFootprint\StorageSense"
    "\Microsoft\Windows\DUSM\dusmtask"
    "\Microsoft\Windows\ErrorReporting\QueueReporting"
    "\Microsoft\Windows\ErrorReporting\KernelCeipTask"
    "\Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioUpload"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioRun"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnUserSignIn"
    "\Microsoft\Windows\File Classification Infrastructure\Property Definition Sync"
    "\Microsoft\Windows\FileHistory\File History (maintenance mode)"
    "\Microsoft\Windows\Help\OEMSupport"
    "\Microsoft\Windows\Help\WindowsHelpUpdateTask"
    "\Microsoft\Windows\HelloFace\FODCleanupTask"
    "\Microsoft\Windows\HelloFace\FeatureCleanup"
    "\Microsoft\Windows\input\InputSettingsRestoreDataAvailable"
    "\Microsoft\Windows\input\LocalUserSyncDataAvailable"
    "\Microsoft\Windows\input\MouseSyncDataAvailable"
    "\Microsoft\Windows\input\PenSyncDataAvailable"
    "\Microsoft\Windows\input\RemoteMouseSyncDataAvailable"
    "\Microsoft\Windows\input\RemotePenSyncDataAvailable"
    "\Microsoft\Windows\input\RemoteTouchpadSyncDataAvailable"
    "\Microsoft\Windows\input\TouchpadSyncDataAvailable"
    "\Microsoft\Windows\InstallService\WakeUpAndContinueUpdates"
    "\Microsoft\Windows\InstallService\WakeUpAndScanForUpdates"
    "\Microsoft\Windows\International\Synchronize Language Settings"
    "\Microsoft\Windows\LanguageComponentsInstaller\Installation"
    "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources"
    "\Microsoft\Windows\LanguageComponentsInstaller\Uninstallation"
    "\Microsoft\Windows\License Manager\TempSignedLicenseExchange"
    "\Microsoft\Windows\Location\WindowsActionDialog"
    "\Microsoft\Windows\Maintenance\WinSAT"
    "\Microsoft\Windows\Maps\MapsToastTask"
    "\Microsoft\Windows\Maps\MapsUpdateTask"
    "\Microsoft\Windows\MemoryDiagnostic\AutomaticOfflineMemoryDiagnostic"
    "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic"
    "\Microsoft\Windows\NlaSvc\WiFiTask"
    "\Microsoft\Windows\Offline Files\Background Synchronization"
    "\Microsoft\Windows\Offline Files\Logon Synchronization"
    "\Microsoft\Windows\PCRPF\PCR Prediction Framework Firmware Update Task"
    "\Microsoft\Windows\PerformanceTrace\WhesvcToast"
    "\Microsoft\Windows\PI\Secure-Boot-Update"
    "\Microsoft\Windows\PI\Sqm-Tasks"
    "\Microsoft\Windows\Pluton\Pluton-Ksp-Provisioning"
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
    "\Microsoft\Windows\Printing\EduPrintProv"
    "\Microsoft\Windows\Printing\PrintJobCleanupTask"
    "\Microsoft\Windows\PushToInstall\LoginCheck"
    "\Microsoft\Windows\PushToInstall\Registration"
    "\Microsoft\Windows\Ras\MobilityManager"
    "\Microsoft\Windows\ReFsDedupSvc\Initialization"
    "\Microsoft\Windows\Registry\RegIdleBackup"
    "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask"
    "\Microsoft\Windows\RetailDemo\CleanupOfflineContent"
    "\Microsoft\Windows\Search\IndexerDiagnosticsTask"
    "\Microsoft\Windows\Search\SearchIndexerMaintenance"
    "\Microsoft\Windows\Setup\SetupCleanupTask"
    "\Microsoft\Windows\SharedPC\Account Cleanup"
    "\Microsoft\Windows\Shell\FamilySafetyMonitor"
    "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
    "\Microsoft\Windows\Shell\IndexerAutomaticMaintenance"
    "\Microsoft\Windows\Shell\ThemeAssetTask_SyncFODState"
    "\Microsoft\Windows\Shell\ThemesSyncedImageDownload"
    "\Microsoft\Windows\Shell\UndockedFlightingUpdate"
    "\Microsoft\Windows\Shell\UpdateUserPictureTask"
    "\Microsoft\Windows\Storage Tiers Management\Storage Tiers Optimization"
    "\Microsoft\Windows\Subscription\EnableLicenseAcquisition"
    "\Microsoft\Windows\Subscription\LicenseAcquisition"
    "\Microsoft\Windows\Sysmain\WsSwapAssessmentTask"
    "\Microsoft\Windows\Sysmain\HybridDriveCacheRebalance"
    "\Microsoft\Windows\Sysmain\HybridDriveCachePrepopulate"
    "\Microsoft\Windows\UPnP\UPnPHostConfig"
    "\Microsoft\Windows\UpdateOrchestrator\CleanupUpdateTask"
    "\Microsoft\Windows\User Profile Service\HiveUploadTask"
    "\Microsoft\Windows\WaaSMedic\PerformRemediation"
    "\Microsoft\Windows\WaaSMedic\ScanForUpdates"
    "\Microsoft\Windows\WaaSMedic\WsusScan"
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
    "\Microsoft\Windows\Windows Error Reporting\ReportQueue"
    "\Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange"
    "\Microsoft\Windows\WindowsAI\Recall\InitialConfiguration"
    "\Microsoft\Windows\WindowsAI\Recall\PolicyConfiguration"
    "\Microsoft\Windows\WindowsAI\Settings\InitialConfiguration"
    "\Microsoft\Windows\WindowsAI\Copilot\CopilotDataCollectionTask"
    "\Microsoft\Windows\WindowsAI\Insights\InsightsDataCollectionTask"
    "\Microsoft\Windows\WindowsUpdate\Refresh Group Policy Cache"
    "\Microsoft\Windows\WlanSvc\CDSSync"
    "\Microsoft\Windows\WOF\WIM-Hash-Management"
    "\Microsoft\Windows\WOF\WIM-Hash-Validation"
    "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
    "\Microsoft\Windows\Workplace Join\Device-Sync"
    "\Microsoft\Windows\Workplace Join\Recovery-Check"
    "\Microsoft\Windows\UNP\RunCampaignManager"
    "\MicrosoftEdgeUpdateTaskMachineCore"
    "\MicrosoftEdgeUpdateTaskMachineUA"
    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
    "\Microsoft\Windows\Windows Defender Cleanup"
    "\Microsoft\Windows\Windows Defender Scheduled Scan"
    "\Microsoft\Windows\Windows Defender Verification"
) do (
    schtasks /Change /TN %%T /Disable >nul 2>&1
)


echo Оптимизация параметров... [7/13] > "%msgFile%"
Rem Отключение гибернации
    powercfg -h off >nul 2>&1
	reg add "HKLM\System\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d 0x0 /f >nul 2>&1
Rem Отключение зарезервированного хранилища
	Dism /Online /Set-ReservedStorageState /State:Disabled >nul 2>&1
Rem Отключение точек восстановления
	vssadmin resize shadowstorage /on=c: /for=c: /maxsize=1%% >nul 2>&1
	PowerShell -Command "Disable-ComputerRestore -Drive '%SystemDrive%\'" >nul 2>&1
	vssadmin delete shadows /all /quiet >nul 2>&1
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "RPSessionInterval" /f >nul 2>&1
Rem Отложенный запуск автоматических служб
	for %%p in (EventSystem NlaSvc) do reg add "HKLM\System\CurrentControlSet\Services\%%p" /v "DelayedAutostart" /t reg_dword /d 1 /f >nul 2>&1
	)
Rem Минимизация системных отчетов
	"%~dp0\Work\Eventlog" >nul 2>&1
Rem Кэш иконок
	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MaxCachedIcons" /t REG_SZ /d 4096 /f >nul
Rem Увеличение порога разделения SVC
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
Rem Пауза обновлений до 07.07.77
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
Rem Принудительное завершение программ при зависании
reg add "HKCR\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d 1 /f >nul
Rem Отключение Удаленного помощника
	reg add "HKLM\System\ControlSet001\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f >nul
	reg add "HKLM\System\ControlSet001\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d 0 /f >nul
	reg add "HKLM\System\ControlSet001\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 1 /f >nul
	reg add "HKLM\System\ControlSet001\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t REG_DWORD /d 0 /f >nul
Rem Отключение залипания клавиш
	reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d 506 /f >nul
Rem Скрытие реального TTL
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
Rem Если есть папка Drivers на Рабочем столе
if exist "%USERPROFILE%\Desktop\Drivers" (
    pnputil /add-driver "%USERPROFILE%\Desktop\Drivers\*.inf" /subdirs /install >nul 2>&1
    timeout /t 3 /nobreak >nul 2>&1
) else (
Rem Если нет папки Driver на Рабочем столе
    echo Папка с драйверами не обнаружена. Пропускаю установку драйверов. [10/13] > "%msgFile%"
	timeout /t 3 /nobreak >nul 2>&1
)


echo Установка Visual C++ и DirectX... [11/13] > "%msgFile%"
	start "" /wait "%~dp0\Work\VisualCppRedist_AIO_x86_x64.exe" /aiA /gm2
	start "" /wait "%~dp0\Work\DirectX.exe"
	

echo Установка визуальных твиков... [12/13] > "%msgFile%"
    timeout /t 5 /nobreak >nul 2>&1
Rem Удаление Главная из Проводника 
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "HubMode" /t REG_DWORD /d 1 /f >nul
    reg add "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul
    reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul
Rem Удаление Галерея из Проводника 
    reg add "HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f >nul 2>&1
Rem Удаление Сеть из Проводника 
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

Rem Установка дополнительных эскизов через Icaros
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
	compact /c /s:%SystemDrive%\ /exe:LZX /i /a /f >nul 2>&1
echo Готово. Перезагружаюсь...> "%msgFile%"
	timeout /t 5 /nobreak >nul 2>&1
	del /q /f /s "%~dp0Work\message.txt" >nul 2>&1
Rem Перезагрузка
	shutdown /r /t 2
	Exit

Rem Проверка версии Windows
:WinVer
    for /f "skip=2 tokens=3" %%a in ('2^>nul reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') do set /a build=%%a
    if !build! LSS 22000 %ch%  {0c}Эта утилита работает только на Windows 11{\n#} && timeout /t 3 /nobreak >nul && exit /b
