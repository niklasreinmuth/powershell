$accounts = Get-Content "C:\accounts.txt" #includes samaccountnames

foreach($account in $accounts) 
{ 
    $homefolders = "d:\home" 
    $homepath   = "d:\home\$account" 

    New-Item -Path $homefolders -Name $account -ItemType Directory 
    New-SmbShare -Name $account -Path $homepath -FullAccess Administrator, Everyone      

    $acl = Get-Acl $homepath 
    $inheritance = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit 
    $propagation = [System.Security.AccessControl.PropagationFlags]::None 
    $ar = New-Object System.Security.AccessControl.FileSystemAccessRule($account,"Modify",$inheritance,$propagation,"Allow") 
    $acl.SetAccessRule($ar) 

    Set-Acl $homepath $acl 
} 
