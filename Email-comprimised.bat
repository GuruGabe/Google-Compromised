@echo on
cls

::Grabs current date and converts it to Google fomat. For those systems that has the day of week in the short date, makes the correct adjustment.

set rundate1=
set rundate1=%date%
echo %rundate1%
echo %rundate1%|findstr /i [a-z] > nul
echo %errorlevel%
if %errorlevel% NEQ 0 set rundate1=%date:~-4%-%date:~0,2%-%date:~3,2%
if %errorlevel% EQU 0 set rundate1=%date:~-4%-%date:~4,2%-%date:~7,2%

set yyyy=%rundate1:~0,4%
set mm=%rundate1:~5,2%
set dd=%rundate1:~-2,2%

if %mm% EQU 01 set /a yyyy=%yyyy%-1
if %mm% EQU 02 set /a yyyy=%yyyy%-1
if %mm% EQU 03 set /a yyyy=%yyyy%-1
if %mm% EQU 04 set /a yyyy=%yyyy%-1
if %mm% EQU 05 set /a yyyy=%yyyy%-1

set rundate1=%yyyy%-06-01
echo %rundate1%

::cls
del /f /s /q C:\Temp\logins11.csv
del /f /s /q C:\Temp\logins12.csv
del /f /s /q C:\Temp\logins13.csv
del /f /s /q C:\Temp\logins14.csv
del /f /s /q C:\Temp\logins15.csv
del /f /s /q C:\Temp\logins16.csv
del /f /s /q C:\Temp\compromised.html
echo email_address,time,password_set,last_login>C:\Temp\logins16.csv

::cls
::echo Step 1
gam config csv_output_row_filter "name:regex:account_disabled_password_leak" redirect csv C:\Temp\logins11.csv report logins start %rundate1%
powershell "Import-Csv C:\Temp\logins11.csv | sort affected_email_address -Unique | export-csv C:\Temp\logins12.csv"

::for /f "tokens=6 delims=, skip=1" %%a in (C:\Temp\logins12.csv) do call :next %%a
::powershell "Import-Csv C:\Temp\logins13.csv | sort name,actor.callerType,actor.email,actor.key,actor.profileId,affected_email_address,id.applicationName,id.customerId,id.time,id.uniqueQualifier,ipAddress,is_second_factor,is_suspicious,login_challenge_method,login_challenge_status,login_type,type -Unique | export-csv C:\Temp\logins14.csv"
call :filter

echo Update Google Sheet and Email
::gam user <GAM account> update drivefile id "Sheet ID" newfilename "Sheet name" localfile C:\Temp\logins16.csv csvsheet id:<Tab ID>
for /f %%i in ("C:\Temp\logins16.csv") do set size=%%~zi
if %size% gtr 0 powershell -file "<Path to >\email-compromised.ps1"
exit /b

:next
::echo Step 2
set email=%1
set email=%email:"=%
gam config csv_output_row_filter "actor.email:regex:%email%" report logins start %rundate1%>>C:\Temp\logins13.csv
exit /b

:filter
::Step 3
for /f "tokens=6,9 delims=, skip=2" %%a in (C:\Temp\logins12.csv) do call :next1 %%a %%b
exit /b

:next1
::echo Step 4
set email1=
set time=

set email1=%1
set time=%2

::call :psfile
::Filter out our IP Address and header since it is out of place
::if %ipaddress% EQU "Your external IP address" goto :eof
::if /i %name% EQU "name" goto :eof
:psfile
::powershell -File "<Path to >\Test.ps1" %ipaddress%
::for /f "tokens=1-3 skip=1 delims=;" %%a in (C:\Temp\temp2.csv) do set city=%%c && set country=%%a && set google=%%b

gam report useraccounts user %email1% event password_edit>C:\Temp\password-audit2.csv
for /f "tokens=7 skip=1 delims=," %%g in (C:\Temp\password-audit2.csv) do set password_set=%%g
gam info user %email1% lastLoginTime | findstr "Last login time:">C:\Temp\last-login.csv
for /f "tokens=4 delims= " %%m in (C:\Temp\last-login.csv) do set last-login=%%m
echo %email1%,%time%,%password_set%,%last-login: =%>>C:\Temp\logins16.csv
::echo %name:"=%,%email1:"=%,%email2:"=%,%time:"=%,%ipaddress:"=%,%suspicious:"=%,%login_type:"=%,%city:"=%,%country:"=%,%google:"=%>>C:\Temp\logins6.csv
::exit /b
