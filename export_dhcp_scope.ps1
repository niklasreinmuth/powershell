Get-DhcpServerv4Lease -ComputerName demusdhcp01 -ScopeId $scope | select @{
    expression = {$_.hostname -replace "suffix"}; Label = "Name"
}, @{
    expression = {($_.clientid).ToString().ToUpper() -replace '-', ':'}; Label = "MAC"
}, @{
    expression = {$_.ipaddress}; Label = "IP"
} | Export-Csv -Path $path -NoTypeInformation
