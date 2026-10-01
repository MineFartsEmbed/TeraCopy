param ($source, $target, [int64] $size, $time, [int64] $failed, [int64] $skipped)

write-host "Transfer completed:"
write-host "  Source: $source"
write-host "  Target: $target"
write-host "  Failed: $failed, skipped: $skipped"

$fsize = "{0:N0}" -f $size
write-host "  Size: $fsize"
write-host "  Time: $time"
write-host ""

write-host "Sending notification..."

$topic = 'YOUR_TOPIC'

if ($topic -eq 'YOUR_TOPIC') {
    write-host "Please subscribe to a topic in the Ntfy mobile app or at https://ntfy.sh/app and modify this script."
    write-host "Press any key to locate this file..."

    [void][System.Console]::ReadKey($true)
    Invoke-Expression "explorer /select,$PSCommandPath"
    exit
}

$url = "https://ntfy.sh/$topic"

$headers = @{
    "Title" = "Transfer completed"
    "Priority" = "default"
    "Tags" = "heavy_check_mark"
}

$body = @"
Source: $source
Target: $target
$size bytes, $time
Failed: $failed, skipped: $skipped
"@

$response = Invoke-WebRequest -Method Post -Uri $url -Headers $headers -Body $body

write-host $response

Start-Sleep -Seconds 5
