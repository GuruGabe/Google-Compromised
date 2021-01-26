$smtp = "smtp.gmail.com" # This is your SMTP Server
$to1 = "gabriel.clifton@fsisd.net" # This is the recipient smtp address 1
$to2 = "chris.terry@fsisd.net" # This is the recipient smtp address 2
$to3 = "debra.ezell@fsisd.net" # This is the recipient smtp address 3

$smtpUsername = "server.reports@fsisd.net"  
$smtpPassword = "S8<R&RrQ"  
$credentials = new-object Management.Automation.PSCredential $smtpUsername, ($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)
$from = "<Alert@fsisd.net>" # This will be the sender's address
$subject = "Accounts Google reported compromised"

Import-Csv C:\Temp\logins16.csv | Select -Skip 1 | % {$_.time = ([datetime]($_.time)).ToString('MM/dd/yyyy');$_} | % {$_.password_set = ([datetime]($_.password_set)).ToString('MM/dd/yyyy');$_} | % {$_."last_login" = ([datetime]($_."last_login")).ToString('MM/dd/yyyy');$_} | Sort-Object { $_."email_address" } | Sort-Object { $_."time" } | Sort-Object { $_."password_set" } | Sort-Object { $_."last_login" } -Descending | Export-Csv C:\Temp\logins17.csv -NoTypeInformation
<#
$prop1 = @{Expression='email_address'; Ascending=$false }
$prop2 = @{Expression='time'; Descending=$true }
(Import-Csv C:\Temp\logins16.csv) |
    Sort-Object $prop2, $prop1 |
    Export-Csv C:\Temp\logins16.csv -NoType
#>
$csv = import-csv "C:\Temp\logins17.csv"
$report = 
foreach($row in $csv){

    [pscustomobject]@{
       "email address" = $row.email_address
       "Date Google reported compromised" = $row.time.Split("T")[0]
       "Date Google password last changed" = $row.password_set.Split("T")[0]
       "Last login date" = $row.last_login.Split("T")[0]
    }
}


$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    
    
   table {
		font-size: 12px;
		border: 1px solid black;
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 1px solid black;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #d8d8d9;
    }

        #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }
    



</style>
"@

$report | 
ConvertTo-Html -Head $header | 
Out-File C:\Temp\compromised.html

$body1 = '<a href="https://docs.google.com/spreadsheets/d/1IaGdVQNRxjiSzfylCB_2UOF0PiUgs4pFQUF7IvTrQyU/edit#gid=2123204598">Link to Google Sheet with full details</a>'
#$body1 = $ExecutionContext.InvokeCommand.ExpandString($body1)
$body2 = "<br /><br />"
$body3 = Get-Content C:\Temp\compromised.html | Out-String
$body = "$body1 $body2 $body3"

send-MailMessage -SmtpServer $smtp -Port 587 -UseSsl -Credential $credentials -To $to1 -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high
#, $to2, $to3