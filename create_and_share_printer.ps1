#csv columns: printer name | ip
$pathToCsv = "C:\printers.csv" 
$driver = "PRINTERDRIVER"

$csv = Import-Csv -Path $pathToCsv -Delimiter ";" 
$printers = @{} 

foreach($line in $csv) 
{ 
    $printers[$line.name] = $line.ip 
} 

$printers.Keys | % { 
    Add-PrinterPort -Name $printers.$_ -PrinterHostAddress $printers.$_ -Verbose 
    Add-Printer -Name $_ -DriverName $driver -PortName $printers.$_ -Verbose 
    Set-Printer -Name $_ -Shared $true -ShareName $_ -Verbose 
}    
