# scripts/windows-automation.ps1
Write-Host "=== WINDOWS SYSTEM AUTOMATION ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)"
Write-Host "User: $env:USERNAME"
Write-Host "Computer: $env:COMPUTERNAME"
Write-Host ""

# Create directories
Write-Host "1. Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path output, logs, backups | Out-Null

# File operations
Write-Host "`n2. File operations..." -ForegroundColor Yellow

# Create system info file
$systemInfo = @"
System Information
==================
Date: $(Get-Date)
User: $env:USERNAME
Computer: $env:COMPUTERNAME
OS: $([Environment]::OSVersion.VersionString)
PowerShell: $($PSVersionTable.PSVersion)
Memory: $([math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)) GB
"@

$systemInfo | Out-File -FilePath "output\system-info.txt" -Encoding UTF8

# Create CSV file
$csvData = @()
for ($i = 1; $i -le 5; $i++) {
    $csvData += [PSCustomObject]@{
        Id = $i
        Name = "item_$i"
        Value = Get-Random -Minimum 1 -Maximum 100
        Timestamp = Get-Date -Format "o"
    }
}
$csvData | Export-Csv -Path "output\data.csv" -NoTypeInformation -Encoding UTF8

# Create JSON file
$jsonConfig = @{
    environment = $env:NODE_ENV
    timestamp = Get-Date -Format "o"
    system = @{
        computerName = $env:COMPUTERNAME
        userName = $env:USERNAME
    }
}
$jsonConfig | ConvertTo-Json | Out-File -FilePath "output\config.json" -Encoding UTF8

Write-Host "Files created in output\ directory" -ForegroundColor Green

# File permissions management (icacls)
Write-Host "`n3. Managing file permissions..." -ForegroundColor Yellow

# Create files
"Public content" | Out-File -FilePath "output\public.txt" -Encoding UTF8
"Private content" | Out-File -FilePath "output\private.txt" -Encoding UTF8
"Backup data" | Out-File -FilePath "backups\data.bak" -Encoding UTF8

# Apply permissions using icacls
try {
    # Public file - Read for everyone
    icacls "output\public.txt" /inheritance:r /grant:r "Everyone:(R)" 2>&1 | Out-Null
    
    # Private file - Read only for current user
    icacls "output\private.txt" /inheritance:r /grant:r "$env:USERNAME:(R)" 2>&1 | Out-Null
    
    # Backup file - No inheritance, restricted
    icacls "backups\data.bak" /inheritance:r 2>&1 | Out-Null
    
    Write-Host "Permissions applied successfully" -ForegroundColor Green
    Write-Host "Current permissions:" -ForegroundColor Gray
    Get-ChildItem output\, backups\ -File | ForEach-Object {
        $perm = icacls $_.FullName 2>&1 | Select-String $env:USERNAME, "Everyone"
        Write-Host "  $($_.Name): $perm"
    }
}
catch {
    Write-Host "Error applying permissions: $_" -ForegroundColor Red
}

# Background processes (Jobs)
Write-Host "`n4. Creating background processes..." -ForegroundColor Yellow

# Job 1: System monitor
$job1 = Start-Job -Name "SystemMonitor" -ScriptBlock {
    "Starting system monitor at $(Get-Date)" | Out-File -FilePath "logs\monitor.log" -Encoding UTF8
    for ($i = 1; $i -le 3; $i++) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        "[$timestamp] Monitor iteration $i" | Out-File -FilePath "logs\monitor.log" -Append -Encoding UTF8
        "[$timestamp] CPU: $(Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue)" | Out-File -FilePath "logs\monitor.log" -Append -Encoding UTF8
        Start-Sleep -Seconds 2
    }
}

# Job 2: Data processor
$job2 = Start-Job -Name "DataProcessor" -ScriptBlock {
    for ($i = 1; $i -le 5; $i++) {
        "Processing data $i at $(Get-Date)" | Out-File -FilePath "logs\processor.log" -Append -Encoding UTF8
        Start-Sleep -Seconds 1
    }
}

Write-Host "Background jobs started:" -ForegroundColor Green
Get-Job | Select-Object Id, Name, State | Format-Table -AutoSize

# Wait for jobs to work
Write-Host "Waiting for jobs to work..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Get job results and clean up
$job1 | Receive-Job -AutoRemoveJob -Wait
$job2 | Receive-Job -AutoRemoveJob -Wait

Write-Host "Background jobs completed" -ForegroundColor Green

# Environment variables and secrets
Write-Host "`n5. Environment variables and secrets..." -ForegroundColor Yellow

# Environment variables
$envVars = @"
Environment Variables
====================
NODE_ENV: $env:NODE_ENV
USERNAME: $env:USERNAME
COMPUTERNAME: $env:COMPUTERNAME
"@

$envVars | Out-File -FilePath "output\env-vars.txt" -Encoding UTF8

# Handle secret (without exposing it)
if (-not [string]::IsNullOrEmpty($env:SECRET_MESSAGE)) {
    "Secret is configured (value hidden)" | Out-File -FilePath "output\secrets.txt" -Encoding UTF8
    "Operation using secret completed" | Out-File -FilePath "output\secret-operation.txt" -Encoding UTF8
}
else {
    "No secret configured" | Out-File -FilePath "output\secrets.txt" -Encoding UTF8
}

Write-Host "Environment info saved to output\env-vars.txt" -ForegroundColor Green

# Generate artifacts
Write-Host "`n6. Generating artifacts..." -ForegroundColor Yellow

# Create summary file
$summary = @"
# Windows Automation Execution Summary

## Execution Details
- Date: $(Get-Date)
- Script: windows-automation.ps1
- Status: Completed successfully
- Exit Code: 0

## Files Generated
$(
    $files = Get-ChildItem -Recurse output, logs, backups -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        "- ``$($file.Name)`` ($($file.Length) bytes)"
    }
)

## System Info
- OS: $([Environment]::OSVersion.VersionString)
- PowerShell: $($PSVersionTable.PSVersion)
- Architecture: $env:PROCESSOR_ARCHITECTURE

## Background Processes
- Started: 2 jobs
- Duration: ~3 seconds
"@

$summary | Out-File -FilePath "output\execution-summary.md" -Encoding UTF8

# List generated files
Write-Host "`n=== GENERATED FILES ===" -ForegroundColor Magenta
Get-ChildItem -Recurse output, logs, backups -File -ErrorAction SilentlyContinue | 
    Select-Object Directory, Name, Length | 
    Format-Table -AutoSize

Write-Host "`n=== WINDOWS AUTOMATION COMPLETED SUCCESSFULLY ===" -ForegroundColor Green
Write-Host "Exit code: 0" -ForegroundColor Green

exit 0