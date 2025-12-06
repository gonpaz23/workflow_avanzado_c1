# scripts/windows-automation.ps1
Write-Host "=== AUTOMATIZACIÓN WINDOWS ===" -ForegroundColor Green

# Crear directorios
Write-Host "Creando directorios..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path output, logs, backups | Out-Null

# Gestionar permisos (ejemplo simplificado)
Write-Host "Configurando permisos..." -ForegroundColor Yellow
$acl = Get-Acl output
Set-Acl output $acl

# Variables de entorno
Write-Host "Mostrando información del sistema..." -ForegroundColor Yellow
Write-Host "Usuario: $env:USERNAME"
Write-Host "Computadora: $env:COMPUTERNAME"
Write-Host "Sistema Operativo: $env:OS"
Write-Host "Directorio actual: $(Get-Location)"

# Crear archivo de reporte
Write-Host "Generando archivos de reporte..." -ForegroundColor Yellow
$reportPath = "output\windows-report.txt"
"=== REPORTE DEL SISTEMA ===" | Out-File -FilePath $reportPath
"Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $reportPath -Append
"Usuario: $env:USERNAME" | Out-File -FilePath $reportPath -Append
"Computadora: $env:COMPUTERNAME" | Out-File -FilePath $reportPath -Append
"Sistema: $env:OS" | Out-File -FilePath $reportPath -Append
"Directorio: $(Get-Location)" | Out-File -FilePath $reportPath -Append

Write-Host "Reporte generado en $reportPath" -ForegroundColor Green

# Generar JSON
Write-Host "Generando configuración JSON..." -ForegroundColor Yellow
$configData = @{
    timestamp = Get-Date -Format o
    system = @{
        os = "$env:OS"
        computer = "$env:COMPUTERNAME"
        username = "$env:USERNAME"
    }
    directories = @{
        current = "$(Get-Location)"
        output = "output"
        logs = "logs"
        backups = "backups"
    }
    github = @{
        workflow = "$env:GITHUB_WORKFLOW"
        run_id = "$env:GITHUB_RUN_ID"
    }
}

$configData | ConvertTo-Json | Out-File -FilePath "output\config.json"
Write-Host "Configuración guardada en output\config.json" -ForegroundColor Green

# Crear proceso en segundo plano (ejemplo simplificado)
Write-Host "Iniciando proceso en segundo plano..." -ForegroundColor Yellow
Start-Job -Name "BackgroundMonitor" -ScriptBlock {
    $logPath = "logs\background-process.log"
    for ($i = 1; $i -le 5; $i++) {
        "[$(Get-Date -Format 'HH:mm:ss')] Iteración $i - Proceso en segundo plano funcionando" | Out-File -FilePath $logPath -Append
        Start-Sleep -Seconds 2
    }
} | Out-Null

# Esperar un momento para que el proceso background haga algo
Write-Host "Esperando procesos en segundo plano..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Mostrar contenido del log de background
Write-Host "Contenido del log de background:" -ForegroundColor Cyan
if (Test-Path "logs\background-process.log") {
    Get-Content "logs\background-process.log"
}

# Limpiar el job
Get-Job -Name "BackgroundMonitor" | Remove-Job -Force

# Listar archivos generados
Write-Host "`n=== ARCHIVOS GENERADOS ===" -ForegroundColor Magenta
Get-ChildItem -Recurse output, logs | Format-Table Name, Length, LastWriteTime

Write-Host "`n=== AUTOMATIZACIÓN COMPLETADA EXITOSAMENTE ===" -ForegroundColor Green