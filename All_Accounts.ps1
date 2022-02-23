#Name the file All_Accounts.ps1
$csv = import-csv "C:\Temp\All_logins3.csv"

$report = 
foreach($row in $csv){
    $apidata     = Invoke-RestMethod "http://api.geoiplookup.net/?query=$($row.IP_Address)"
    $city        = $apidata.ip.results.result.city
    $countryname = $apidata.ip.results.result.countryname
    
    [pscustomobject]@{
       "Login Result" = $row.login_result
       "email address" = $row.email_address
       Time = $row.time
       "IP Address" = $row.IP_Address
       Suspicious = $row.suspicious
       Type = $row.type
       City = $city
       "Country Name" = $countryname
    }
}
$report | Export-Csv "C:\Temp\All_logins4.csv" -NoTypeInformation -Encoding:UTF8


$data = foreach($line in Get-Content "C:\Temp\All_logins4.csv")
{
    if($line -like '*Fort Stockton*')
    {

    }
    else
    {
        $line
    }

}
$data | Set-Content "C:\Temp\All_logins4.csv" -Force
