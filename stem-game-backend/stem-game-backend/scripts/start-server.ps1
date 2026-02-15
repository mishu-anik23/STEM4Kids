<#
  start-server.ps1
  - Stops any process listening on port 3000
  - Starts the backend server (`node src/server.js`) in a detached process
  - If `pm2` is installed and desired, prefer using PM2 by running `npm run pm2:start`
#>

param(
  [int]$Port = 3000
)

Write-Host "Checking for processes listening on port $Port..."

try {
  $listeners = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
} catch {
  $listeners = $null
}

if ($listeners) {
  $pids = $listeners | Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($pid in $pids) {
    Write-Host "Killing process $pid that is listening on port $Port..."
    try {
      Stop-Process -Id $pid -Force -ErrorAction Stop
      Write-Host "Stopped process $pid"
    } catch {
      Write-Host "Failed to stop $pid: $($_.Exception.Message)"
      Write-Host "Attempting taskkill /F $pid"
      cmd /c "taskkill /PID $pid /F" | Out-Null
    }
  }
} else {
  Write-Host "No listeners on port $Port"
}

Write-Host "Starting backend server (detached)..."

$cwd = Get-Location

Start-Process -FilePath "${env:ProgramFiles}\nodejs\node.exe" -ArgumentList "src/server.js" -WorkingDirectory $cwd -WindowStyle Hidden
Write-Host "Backend start requested. Check logs or hit /health to verify."
