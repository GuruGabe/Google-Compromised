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

if mm EQU 01 set /a yyyy=%yyyy%-1
if mm EQU 02 set /a yyyy=%yyyy%-1
if mm EQU 03 set /a yyyy=%yyyy%-1
if mm EQU 04 set /a yyyy=%yyyy%-1
if mm EQU 05 set /a yyyy=%yyyy%-1

echo %mm%/%dd%/%yyyy%

cls
del /f /s /q C:\Temp\logins21.csv
del /f /s /q C:\Temp\logins22.csv
del /f /s /q C:\Temp\logins23.csv
del /f /s /q C:\Temp\logins24.csv
del /f /s /q C:\Temp\logins25.csv
del /f /s /q C:\Temp\logins26.csv
del /f /s /q C:\Temp\logins26.html
echo login_result,email_address,email_address2,time,IP_Address,suspicious,type,city,countryname>C:\Temp\logins26.csv

cls
::echo Step 1
gam config csv_output_row_filter "name:regex:suspicious_login" redirect csv C:\Temp\logins21.csv report logins start %yyyy%-06-01
powershell "Import-Csv C:\Temp\logins21.csv | sort affected_email_address -Unique | export-csv C:\Temp\logins22.csv"

for /f "tokens=6 delims=, skip=1" %%a in (C:\Temp\logins22.csv) do call :next %%a
powershell "Import-Csv C:\Temp\logins23.csv | sort name,actor.callerType,actor.email,actor.key,actor.profileId,affected_email_address,id.applicationName,id.customerId,id.time,id.uniqueQualifier,ipAddress,is_second_factor,is_suspicious,login_challenge_method,login_challenge_status,login_type,type -Unique | export-csv C:\Temp\logins24.csv"
call :filter

:: Sort Sheet
powreshell.exe -File "C:\Users\Administrator.FSISD\Desktop\Compromised Accounts\Sort-Suspicious.ps1"

echo Update Google Sheet and Email
gam user <GAM Email Account> update drivefile id "<Google Shee ID> newfilename "Sheet Name" localfile C:\Temp\logins26.csv csvsheet id:<Sheet Tab ID>
exit /b

:next
::echo Step 2
set email=%1
set email=%email:"=%
gam config csv_output_row_filter "actor.email:regex:%email%" report logins start %yyyy%-06-01>>C:\Temp\logins23.csv
exit /b

:filter
::Step 3
for /f "tokens=1,3,6,9,11,13,16 delims=, skip=1" %%a in (C:\Temp\logins24.csv) do call :next1 %%a %%b %%c %%d %%e %%f %%g
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

set name=%1
set email1=%2
set email2=%3
set time=%4
set ipaddress=%5
set suspicious=%6
set login_type=%7

::Filter out our IP Address and header since it is out of place
if %ipaddress% EQU "<Our external IP Address>" goto :eof
if /i %name% EQU "name" goto :eof

echo %name:"=%,%email1:"=%,%email2:"=%,%time:"=%,%ipaddress:"=%,%suspicious:"=%,%login_type:"=%>>C:\Temp\logins26.csv
