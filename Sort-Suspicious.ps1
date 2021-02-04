$prop1 = @{Expression='time'; Descending=$true }
$prop2 = @{Expression='email_address'; Ascending=$true }
(Import-Csv C:\Temp\logins26.csv) |
    Sort-Object $prop2, $prop1 |
    Export-Csv C:\Temp\logins26.csv -NoType
