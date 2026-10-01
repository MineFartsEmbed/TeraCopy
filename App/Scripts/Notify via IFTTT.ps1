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

$key = 'YOUR_WEBHOOKS_KEY'

if ($key -eq 'YOUR_WEBHOOKS_KEY') {
    write-host "Please get your own key here: https://ifttt.com/maker_webhooks/settings"
    write-host "Press any key to locate this file..."

    [void][System.Console]::ReadKey($true)
    Invoke-Expression "explorer /select,$PSCommandPath"
    exit
}

$url = "https://maker.ifttt.com/trigger/teracopy/with/key/$key"

$JSON = @{
    "value1" = "Source: $source"
    "value2" = "Target: $target"
    "value3" = "$size bytes, $time `nFailed: $failed, skipped: $skipped"
} | ConvertTo-Json

$response = Invoke-WebRequest -UseBasicParsing -Method Post -Headers @{'Content-Type'='application/json'} -Body $JSON -Uri $url

write-host $response

Start-Sleep -Seconds 3
