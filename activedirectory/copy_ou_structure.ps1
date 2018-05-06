$source_ou = "OU=OUNAME,DC=CONTOSO,DC=COM" 
$destination_ou = "OU=OUNAMENEW,DC=CONTOSO,DC=COM" 
$ad_path= "LDAP://" + $destination_ou 

$obj_domain=New-Object System.DirectoryServices.DirectoryEntry($ad_path) 
$obj_search=New-Object System.DirectoryServices.DirectorySearcher($obj_domain) 

[array] $ous = @() 
$ous = dsquery * $source_ou -Filter "(objectCategory=organizationalUnit)" -limit 0 
$ou_sorted = $ous | sort-object {$_.Length} 

for ($k=0; $k -le $ou_sorted.Count -1; $k++) 
{ 
    $ou_to_create = ($ou_sorted[$k] -replace $source_ou,$destination_ou).ToString() 
    $ou_search = ($ou_to_create -replace '"',"").ToString() 
    $obj_search.Filter = "(&(objectCategory=organizationalUnit)(distinguishedName="+ $ou_search + "))" 
    $results = $obj_search.FindAll() 

    if ($results.Count -eq 1) 
    { 
        "No changes were done on = " + $ou_to_create 
    } 
    else 
    { 
        dsadd ou $ou_to_create 
        "OU Creation = " + $ou_to_create 
    } 
} 
