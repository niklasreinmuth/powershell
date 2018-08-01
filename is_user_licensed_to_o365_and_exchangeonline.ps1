Install-Module MSOnline -Force -AllowClobber 
Connect-MsolService 

$users = Get-MsolUser -UsageLocation "US" | ?{$_.isLicensed -eq $true} 
$correctly_licensed_user = New-Object System.Collections.ArrayList 

foreach($user in $users) 
{ 
    try 
    { 
        $arr = $user.Licenses.AccountSkuId 
        $ind = [array]::IndexOf($arr,"company:ENTERPRISEPREMIUM")  

        if($user.Licenses[$ind].ServiceStatus[21].Provisioningstatus -eq "Success" -and $user.Licenses[$ind].ServiceStatus[23].Provisioningstatus -eq "Success") 
        { 
            [void] $correctly_licensed_user.Add($user) 
        } 
    } 
    catch 
    { 
        Write-Output "$($user.UserPrincipalName) is not licensed to company:ENTERPRISEPREMIUM" 
    } 
} 

Compare-Object -ReferenceObject (($users).UserPrincipalName) -DifferenceObject (($correctly_licensed_user).UserPrincipalName) 
