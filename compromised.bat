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

echo %mm%/%dd%/%yyyy1%

::Clears out old working CSV files
cls
del /f /s /q C:\Temp\logins.csv
del /f /s /q C:\Temp\logins2.csv
del /f /s /q C:\Temp\logins3.csv
del /f /s /q C:\Temp\logins4.csv
del /f /s /q C:\Temp\logins5.csv
del /f /s /q C:\Temp\logins6.csv
del /f /s /q C:\Temp\logins6.html
::Create headers for final CSV
echo login_result,email_address,email_address2,time,IP_Address,suspicious,type,password_set,city,countryname,google-map>C:\Temp\logins6.csv

cls
::Use GAM to query Google for all accounts they have reported compromised since the end of the last school year
gam config csv_output_row_filter "name:regex:account_disabled_password_leak" redirect csv C:\Temp\logins.csv report logins start %yyyy%-06-01

::This report will have the email addresses duplicated multiple times. Use PowerShell to remove duplicates
powershell "Import-Csv C:\Temp\logins.csv | sort affected_email_address -Unique | export-csv C:\Temp\logins2.csv" -notype

::Read through CSV to grab information for variables for next step
for /f "tokens=6 delims=, skip=1" %%a in (C:\Temp\logins2.csv) do call :next %%a

::Use Powershell to filter out any duplicate information again
powershell "Import-Csv C:\Temp\logins3.csv | sort name,actor.callerType,actor.email,actor.key,actor.profileId,affected_email_address,id.applicationName,id.customerId,id.time,id.uniqueQualifier,ipAddress,is_second_factor,is_suspicious,login_challenge_method,login_challenge_status,login_type,type -Unique | export-csv C:\Temp\logins4.csv"
call :filter

::Update Google Sheet
gam user <GAM account> update drivefile id "<Sheet ID>" newfilename "Sheet Name" localfile C:\Temp\logins6.csv csvsheet id:<Tab ID>
exit /b

:next
::Use GAM to grab all login information for the compromised accounts since the end of prior school year
set email=%1
set email=%email:"=%
gam config csv_output_row_filter "actor.email:regex:%email%" report logins start %yyyy%-06-01>>C:\Temp\logins3.csv
exit /b

:filter
::Read through CSV to grab information for variables for next step
for /f "tokens=1,3,6,9,11,13,16 delims=, skip=1" %%a in (C:\Temp\logins4.csv) do call :next1 %%a %%b %%c %%d %%e %%f %%g
exit /b

:next1
::echo Step 4
set name=
set email1=
set email2=
set time=
set ipaddress=
set suspicious=
set login_type=
set city=
set country=
set google=

set name=%1
set email1=%2
set email2=%3
set time=%4
set ipaddress=%5
set suspicious=%6
set login_type=%7

::Filter out our internet IP Address and CSV header since it is now out of place
if %ipaddress% EQU "Your external IP address" goto :eof
if /i %name% EQU "name" goto :eof

::Use GAM to get last password change information for compromised accounts
gam report useraccounts user %email1% event password_edit>C:\Temp\password-audit.csv

:psfile
::Use Powershell to take the IP addresses in the CSV and use it in an API to grab the login location
powershell -File "<Path to >\Test.ps1" %ipaddress%
::Create the final variables to put into CSV
for /f "tokens=1-3 skip=1 delims=;" %%a in (C:\Temp\temp.csv) do set city=%%c && set country=%%a && set google=%%b
for /f "tokens=7 skip=1 delims=," %%g in (C:\Temp\password-audit.csv) do set password_set=%%g

echo %name%,%email1%,%email2%,%time%,%ipaddress%,%suspicious%,%login_type%,%password_set%,%city%,%country%,%google%>>C:\Temp\logins6.csv
