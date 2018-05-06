$SRV1 = "Windows Server 2016"  
$SRAM = 8GB               
$SRV1VHD = 30GB                 
$VMLOC = "C:\HyperV"            
$NetworkSwitch1 = "External Virtual Network"  
$WSISO = "C:\14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO"      

if ((Test-Path $VMLOC) -eq $False) 
{ 
    New-Item -ItemType Directory -Path $VMLOC 
} 

$TestSwitch = Get-VMSwitch -Name $NetworkSwitch1  
if ($TestSwitch.Count -eq 0) 
{ 
    New-VMSwitch -Name $NetworkSwitch1 -SwitchType External 
} 

New-VM -Name $SRV1 -Path $VMLOC -MemoryStartupBytes $SRAM -NewVHDPath $VMLOC\$SRV1.vhdx -NewVHDSizeBytes $SRV1VHD -SwitchName $NetworkSwitch1 
Set-VMDvdDrive -VMName $SRV1 -Path $WSISO 
Set-VMFloppyDiskDrive -VMName $SRV1 -Path $WSVFD 
Start-VM $SRV1 
