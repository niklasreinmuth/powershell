$registryPath = "HKLM:/System/CurrentControlSet/Control/Terminal Server/" 
$values = @{ 
    "AllowTSConnections" = 1 
    "fDenyTSConnections" = 0 
    "fAllowToGetHelp" = 1 
} 

Foreach($value in $values.GetEnumerator())  
{ 
    New-ItemProperty -Path $registryPath -Name $($value.Name) -Value $($value.Value) -PropertyType DWORD -Force | Out-Null 
} 
