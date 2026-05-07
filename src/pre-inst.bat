@echo off
cd %~dp0

rem setlocal ENABLEDELAYEDEXPANSION
rem for %%s in ( *.src ) do (
rem 	set src=%%s
rem 	set dst=%%~ns
rem 	@rem echo src=!src!
rem 	@rem echo dst=!dst!
rem 	echo create !dst!
rem 	echo on
rem 	type !src! > !dst!
rem 	@echo off
rem 	del !src!
rem )

if not exist chrome-profmgr.ps1.src (
	echo "ERROR: chrome-profmgr.ps1.src not found!"
	pause
	exit /b 1
)
if not exist xxxx_MakeShotcut.vbs.src (
	echo "ERROR: xxxx_MakeShotcut.vbs.src not found!"
	pause
	exit /b 1
)

echo on
type chrome-profmgr.ps1.src > chrome-profmgr.ps1
type xxxx_MakeShotcut.vbs.src > chrome-profmgr_MakeShotcut.vbs
del chrome-profmgr.ps1.src
del xxxx_MakeShotcut.vbs.src
copy chrome-profmgr_MakeShotcut.vbs chrome-profmgr_MakeShotcut-Hidden.vbs
copy chrome-profmgr_MakeShotcut.vbs chrome-profmgr_MakeShotcut-Hidden-v7.vbs
@echo off

echo "****  PRE-INST DONE  ****"
pause
