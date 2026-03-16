@echo off
cd %~dp0
setlocal ENABLEDELAYEDEXPANSION

for %%s in ( *.src ) do (
	set src=%%s
	set dst=%%~ns
	@rem echo src=!src!
	@rem echo dst=!dst!
	echo create !dst!
	echo on
	type !src! > !dst!
	@echo off
	del !src!
)

echo on
copy chrome-profmgr_MakeShotcut.vbs chrome-profmgr_MakeShotcut-Hidden.vbs
copy chrome-profmgr_MakeShotcut.vbs chrome-profmgr_MakeShotcut-Hidden-v7.vbs
@echo off

echo PRE-INST DONE
pause
