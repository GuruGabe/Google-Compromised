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

if %mm% EQU 1 set mm=01
if %mm% EQU 2 set mm=02
if %mm% EQU 3 set mm=03
if %mm% EQU 4 set mm=04
if %mm% EQU 5 set mm=05
if %mm% EQU 6 set mm=06
if %mm% EQU 7 set mm=07
if %mm% EQU 8 set mm=08
if %mm% EQU 9 set mm=09

if %mm% EQU 01 set /a yyyy=%yyyy%-1
if %mm% EQU 02 set /a yyyy=%yyyy%-1
if %mm% EQU 03 set /a yyyy=%yyyy%-1
if %mm% EQU 04 set /a yyyy=%yyyy%-1
if %mm% EQU 05 set /a yyyy=%yyyy%-1

::if %mm% EQU 01 set mm2=01 && goto :first
set /a dd2=dd-1
set /a mm2=mm-1
echo %dd2%
if %dd2% EQU 1 set dd2=01
if %dd2% EQU 2 set dd2=02
if %dd2% EQU 3 set dd2=03
if %dd2% EQU 4 set dd2=04
if %dd2% EQU 5 set dd2=05
if %dd2% EQU 6 set dd2=06
if %dd2% EQU 7 set dd2=07
if %dd2% EQU 8 set dd2=08
if %dd2% EQU 9 set dd2=09

echo %mm%/%dd%/%yyyy%
echo %mm%/%dd2%/%yyyy%

if %mm2% EQU 01 set LastDay=31
if %mm2% EQU 1 set LastDay=31
if %mm2% EQU 02 set LastDay=28
if %mm2% EQU 2 set LastDay=28
if %mm2% EQU 03 set LastDay=31
if %mm2% EQU 3 set LastDay=31
if %mm2% EQU 04 set LastDay=30
if %mm2% EQU 4 set LastDay=30
if %mm2% EQU 05 set LastDay=31
if %mm2% EQU 5 set LastDay=31
if %mm2% EQU 06 set LastDay=30
if %mm2% EQU 6 set LastDay=30
if %mm2% EQU 07 set LastDay=31
if %mm2% EQU 7 set LastDay=31
if %mm2% EQU 08 set LastDay=31
if %mm2% EQU 8 set LastDay=31
if %mm2% EQU 09 set LastDay=30
if %mm2% EQU 9 set LastDay=30
if %mm2% EQU 10 set LastDay=31
if %mm2% EQU 11 set LastDay=30
if %mm2% EQU 12 set LastDay=31

if %dd2% EQU 1 set dd=01
if %dd2% EQU 2 set dd=02
if %dd2% EQU 3 set dd=03
if %dd2% EQU 4 set dd=04
if %dd2% EQU 5 set dd=05
if %dd2% EQU 6 set dd=06
if %dd2% EQU 7 set dd=07
if %dd2% EQU 8 set dd=08
if %dd2% EQU 9 set dd=09

if %dd% EQU 01 set mm=%mm2% && set dd2=%LastDay%
if %mm% EQU 01 if %dd% EQU 01 set mm=12 && set dd2=31

::if %dd% EQU %LastDay% call :archive

:first
echo %mm%/%dd%/%yyyy%

cls
del /f /s /q C:\Temp\All_logins.csv
del /f /s /q C:\Temp\All_logins2.csv
del /f /s /q C:\Temp\All_logins3.csv
del /f /s /q C:\Temp\All_logins4.csv
del /f /s /q C:\Temp\All_logins4.csv.old
::del /f /s /q C:\Temp\logins4.csv
::del /f /s /q C:\Temp\logins5.csv
::del /f /s /q C:\Temp\logins6.csv
::del /f /s /q C:\Temp\logins6.html
echo login_result,email_address,time,IP_Address,suspicious,type,city,countryname>C:\Temp\All_logins3.csv

cls
gam report logins start %yyyy%-%mm%-%dd2%>C:\Temp\All_logins.csv
::for /f "tokens=6 delims=, skip=1" %%a in (C:\Temp\All_logins.csv) do call :next %%a
call :next
call :filter
powershell -File "C:\Users\Administrator.FSISD\Desktop\Compromised Accounts\all_accounts.ps1"
powershell "Rename-Item C:\Temp\All_logins4.csv C:\Temp\All_logins4.csv.old"
powershell "Import-CSV C:\Temp\All_logins4.csv.old | Sort-Object email_address,time,IP_Address -Unique | Export-Csv -Path C:\Temp\All_logins4.csv -NoTypeInformation"
gam user fsisd.gam@fsisd.net update drivefile id "<Google Sheet>" newfilename "Account location logs" localfile C:\Temp\All_logins4.csv csvsheet id:<Sheet Tab ID>
exit /b

:next
powershell "Import-Csv C:\Temp\All_logins.csv | sort name,actor.callerType,actor.email,actor.key,actor.profileId,affected_email_address,id.applicationName,id.customerId,id.time,id.uniqueQualifier,ipAddress,is_second_factor,is_suspicious,login_challenge_method,login_challenge_status,login_type,type -Unique | export-csv C:\Temp\All_logins2.csv"
exit /b

:filter
::Step 3
for /f "tokens=1,2,6,8,10,13 delims=, skip=1" %%a in (C:\Temp\All_logins2.csv) do call :next1 %%a %%b %%c %%d %%e %%f %%g
exit /b

:next1
::echo Step 4
set name=
set email1=
set time=
set ipaddress=
set suspicious=
set login_type=

set name=%1
set email1=%2
set time=%3
set ipaddress=%4
set suspicious=%5
set login_type=%6

set name=%name:"=%
set email1=%email1:"=%
set time=%time:"=%
set ipaddress=%ipaddress:"=%
set suspicious=%suspicious:"=%
set login_type=%login_type:"=%

::Filter out our IP Address and header since it is out of place
if %ipaddress% EQU "69.94.180.21" exit /b
if /i %name% EQU "name" goto exit /b
if /i %name% EQU "account_disabled_password_leak" exit /b

echo %name%,%email1%,%time%,%ipaddress%,%suspicious%,%login_type%>>C:\Temp\All_logins3.csv
exit /b

:archive
#Copy data from prior month's file to a new file labled with prior month year as name
    gam user fsisd.gam copy drivefile <Google Sheet> newfilename "%mm2%-%yyyy% Account logs" parentid <Parent Folder ID>
exit /b
