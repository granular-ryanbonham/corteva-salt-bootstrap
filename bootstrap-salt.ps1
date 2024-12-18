# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define the URL of the script to download
$scriptUrl = "https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.ps1"

# Download the script
Write-Host "Downloading Bootstrap Script"
$scriptContent = Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing

# Save the script to a temporary file
$tempScriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
Set-Content -Path $tempScriptPath -Value $scriptContent.Content

Write-Host "Executing Bootstrap Script"
# Execute the downloaded script with the same parameters
Start-Process powershell -ArgumentList "-File `"$tempScriptPath`" $($args -join ' ')" -Verb RunAs -Wait

Write-Host "Clean up the temporary file"
# Clean up the temporary file
Remove-Item -Path $tempScriptPath

# Check For Salt Pip and Innstall Credstash
$path = "C:\Program Files\Salt Project\Salt\salt-pip.exe"
$timeout = 300  # Timeout in seconds
$interval = 5   # Interval between checks in seconds
$elapsed = 0

while (-not (Test-Path $path) -and ($elapsed -lt $timeout)) {
    Write-Host "Waiting for $path to become valid..."  -ForegroundColor Yellow
    Start-Sleep -Seconds $interval
    $elapsed += $interval
}

if (Test-Path $path) {
    Write-Host "$path is now valid."
    # Proceed with your command
    $saltPipInstall = Start-Process -FilePath $path -WorkingDirectory "C:\Program Files\Salt Project\Salt" -ArgumentList "install credstash" -NoNewWindow -Wait -PassThru
    if ($saltPipInstall.ExitCode -ne 0) {
        Write-Host "Credstash install failed with exit code $($saltPipInstall.ExitCode)" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "Credstash install succeeded" -ForegroundColor Green
        Write-Host "===============================================================================" -ForegroundColor Yellow
    }
} else {
    Write-Host "Timeout reached. $path is still not valid."  -ForegroundColor Red
    exit 1
}
exit 0
