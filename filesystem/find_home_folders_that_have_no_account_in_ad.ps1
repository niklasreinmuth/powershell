$fileshare = '\\server\share' 

foreach($share in $fileshare) 
{ 
    foreach ($folder in (Get-ChildItem -Directory "$share")) 
    { 
        $userExists = $null 
        try  
        {  
            $userExists = Get-ADUser $folder.Name | Where-Object {$_.Enabled}  
        }  
        catch {}

        if ($userExists -eq $null) 
        { 
            $arrInvalidFolder += $folder 

            try  
            { 
                $size = (Get-ChildItem -Recurse $folder.FullName -ErrorAction Stop | Measure-Object -property length -sum -ErrorAction SilentlyContinue) 
                $size = "{0:N2}" -f ($size.sum / 1MB) + " MB" 
            }  
            catch [System.IO.PathTooLongException]  
            {  
                Write-Output "Folder `"$($folder.Name)`" Path too long!"  
            } 

            Write-Output Folder `"$($folder.Name)`" `($size`) is invalid or the user is disabled / deleted. | Out-File $env:userprofile\desktop\list.csv
        } 
    } 
} 
