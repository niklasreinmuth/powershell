$cred = Get-Credential admin

$servers = @("server1",
    "server2"
) 

foreach($server in $servers)  
{ 
    try  
    { 
        $osinfo = Get-WmiObject win32_operatingsystem -ComputerName $server -Credential $cred -ErrorAction SilentlyContinue 

        $properties = @{ 
            ComputerName = $osinfo.csname 
            BootTime     = $osinfo.converttodatetime($osinfo.lastbootuptime) 
        } 
    }  
    catch  
    {  
        $properties = @{ 
            ComputerName = $server 
            BootTime     = 'Offline?' 
        } 
    } 
    finally 
    { 
        $obj = New-Object -TypeName psobject -Property $properties 
        Write-Output -InputObject $obj 
    } 
}  
