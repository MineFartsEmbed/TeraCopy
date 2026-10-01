param ($source, $target, [int64] $size, $time, [int64] $failed, [int64] $skipped)

write-host "Transfer completed:"
write-host "  Source: $source"
write-host "  Target: $target"
write-host "  Failed: $failed, skipped: $skipped"

$fsize = "{0:N0}" -f $size
write-host "  Size: $fsize"
write-host "  Time: $time"
write-host ""

# get removable drives
$drives = gwmi win32_volume | 
	where{$_.DriveType -eq '2'} |
		select -ExpandProperty DriveLetter

# eject drives
foreach ($drive in $drives) {
	if ($target.StartsWith($drive) -or $source.StartsWith($drive) ) {
		write-host "Ejecting drive $drive..."

		$shell = New-Object -comObject Shell.Application
		$shell.Namespace(17).ParseName($drive).InvokeVerb("Eject")
	}
}
