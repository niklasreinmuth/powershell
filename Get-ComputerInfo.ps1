function Get-ComputerInfo
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromPipeline = $true
				   )]
		[string[]]$ComputerName = $env:COMPUTERNAME
	)

	Begin
	{
		$Table = New-Object System.Data.DataTable
		$Table.Columns.AddRange(@("ComputerName", "Windows Edition", "Version", "CPU", "CPU Clock", "RAM", "Disk Type", "Disk Size"))
	}
	Process
	{
		Foreach ($Computer in $ComputerName)
		{
			$Code = {
				$ProductName = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName).ProductName
				Try
				{
					$Version = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseID -ErrorAction Stop).ReleaseID
                    $CPU = Get-CimInstance -ComputerName $computer -ClassName Win32_Processor
                    $CPUName = $CPU.Name
                    $CPUClock = $CPU.MaxClockSpeed
                    $RAM = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))}
                    $DiskID = ((Get-Partition -DriveLetter C).UniqueId).split('}')[-1]
                    $Disk = Get-PhysicalDisk -UniqueId $DiskID
                    $DiskType = $Disk.MediaType
                    $DiskSize = ([math]::round(($Disk.Size / 1GB),2))
				}
				Catch
				{
					$Version = "N/A"
                    $CPUName  = "N/A"
                    $CPUClock = "N/A"
                    $RAM = "N/A"
                    $DiskType = "N/A"
                    $DiskSize = "N/A"
				}

				$TempTable = New-Object System.Data.DataTable
				$TempTable.Columns.AddRange(@("ComputerName", "Windows Edition", "Version", "CPU", "CPU Clock", "RAM", "Disk Type", "Disk Size"))
				[void]$TempTable.Rows.Add($env:COMPUTERNAME, $ProductName, $Version, $OSVersion, $CPUName, $CPUClock, $RAM, $DiskType, $DiskSize)

				Return $TempTable
			}

			If ($Computer -eq $env:COMPUTERNAME)
			{
				$Result = Invoke-Command -ScriptBlock $Code
				[void]$Table.Rows.Add($Result.Computername, $Result.'Windows Edition', $Result.Version, $Result.'CPU', $Result.'CPU Clock', $Result.'RAM', $Result.'Disk Type', $Result.'Disk Size')
			}
			Else
			{
				Try
				{
					$Result = Invoke-Command -ComputerName $Computer -ScriptBlock $Code -ErrorAction Stop
					[void]$Table.Rows.Add($Result.Computername, $Result.'Windows Edition', $Result.Version, $Result.'CPU', $Result.'CPU Clock', $Result.'RAM', $Result.'Disk Type', $Result.'Disk Size')
				}
				Catch
				{
					$_
				}
			}
		}
	}
	End
	{
		Return $Table
	}
}
