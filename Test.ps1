$ip = $args[0]
$apidata     = Invoke-RestMethod "http://api.geoiplookup.net/?query=$ip"
$city        = $apidata.ip.results.result.city
$countryname = $apidata.ip.results.result.countryname
$maplat      = $apidata.ip.results.result.latitude
$maplon      = $apidata.ip.results.result.longitude
$maploc      = "https://www.google.com/maps/@" + $maplat + "," + $maplon + ",13z"

New-Object -TypeName PSCustomObject -Property @{
city = $city
countryname = $countryname
maploc = $maploc
} | Export-Csv -Path C:\Temp\temp.csv -NoTypeInformation -delimiter ';'
