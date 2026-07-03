# push_metrics_to_graphite.ps1
#
# Collects CPU, memory, disk, network and website-availability metrics and
# sends them to Graphite's Carbon plaintext receiver, so they can be
# visualised in the Grafana dashboard.
#
# Run from PowerShell (not Git Bash):
#   cd monitoring\scripts
#   powershell -ExecutionPolicy Bypass -File push_metrics_to_graphite.ps1

$GraphiteHost    = "localhost"
$GraphitePort    = 2003
$MetricPrefix    = "college_event_site"

# NodePort URL of the deployed app. If localhost:30081 isn't reachable on your
# machine (see README troubleshooting section), temporarily run:
#   kubectl port-forward svc/techfest-backend 8081:8081
# in another window and change the line below to "http://localhost:8081/healthz".
$AppUrl          = "http://localhost:8081/healthz"

$IntervalSeconds = 30

function Send-Metric {
    param(
        [string]$Path,
        [double]$Value
    )
    $epoch = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $message = "$MetricPrefix.$Path $Value $epoch`n"

    try {
        $client = New-Object System.Net.Sockets.TcpClient($GraphiteHost, $GraphitePort)
        $stream = $client.GetStream()
        $bytes  = [System.Text.Encoding]::ASCII.GetBytes($message)
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush()
        $client.Close()
    } catch {
        Write-Host "Could not send metric '$Path' to Graphite: $_"
    }
}

Write-Host "Pushing metrics to Graphite at $($GraphiteHost):$($GraphitePort) every $($IntervalSeconds)s. Ctrl+C to stop."

while ($true) {

    # ---- CPU usage (%) ----
    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        Send-Metric -Path "system.cpu_usage_percent" -Value $cpu
    } catch { Write-Host "CPU metric failed: $_" }

    # ---- Memory usage (%) ----
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalMB = $os.TotalVisibleMemorySize / 1KB
        $freeMB  = $os.FreePhysicalMemory / 1KB
        $memPercent = [math]::Round((($totalMB - $freeMB) / $totalMB) * 100, 2)
        Send-Metric -Path "system.memory_usage_percent" -Value $memPercent
    } catch { Write-Host "Memory metric failed: $_" }

    # ---- Disk usage (%) on C: ----
    try {
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $diskPercent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 2)
        Send-Metric -Path "system.disk_usage_percent" -Value $diskPercent
    } catch { Write-Host "Disk metric failed: $_" }

    # ---- Network traffic (bytes total, all adapters) ----
    try {
        $rx = (Get-NetAdapterStatistics | Measure-Object -Property ReceivedBytes -Sum).Sum
        $tx = (Get-NetAdapterStatistics | Measure-Object -Property SentBytes -Sum).Sum
        Send-Metric -Path "system.network_rx_bytes" -Value $rx
        Send-Metric -Path "system.network_tx_bytes" -Value $tx
    } catch { Write-Host "Network metric failed: $_" }

    # ---- Uptime (seconds) ----
    try {
        $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        Send-Metric -Path "system.uptime_seconds" -Value ([int]$uptime.TotalSeconds)
    } catch { Write-Host "Uptime metric failed: $_" }

    # ---- HTTP availability of the website (1 = up, 0 = down) ----
    try {
        $response = Invoke-WebRequest -Uri $AppUrl -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Send-Metric -Path "app.http_availability" -Value 1
        } else {
            Send-Metric -Path "app.http_availability" -Value 0
        }
    } catch {
        Send-Metric -Path "app.http_availability" -Value 0
    }

    Start-Sleep -Seconds $IntervalSeconds
}
