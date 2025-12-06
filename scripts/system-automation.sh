#!/bin/bash
# scripts/system-automation.sh

set -e  # Salir en error

echo "=== SCRIPT DE AUTOMATIZACIÓN DEL SISTEMA ==="
echo "Usuario: $(whoami)"
echo "Directorio actual: $(pwd)"
echo ""

# 1. Crear estructura de directorios
echo "1. Creando estructura de directorios..."
mkdir -p logs backups output
echo "   Directorios creados: logs/, backups/, output/"

# 2. Gestionar permisos de archivos
echo ""
echo "2. Gestionando permisos..."
touch logs/app.log
chmod 644 logs/app.log  # rw-r--r--
touch output/report.txt
chmod 755 output/report.txt  # rwxr-xr-x
touch backups/config.backup
chmod 600 backups/config.backup  # rw-------

echo "   Permisos configurados:"
ls -la logs/app.log
ls -la output/report.txt
ls -la backups/config.backup

# 3. Leer/escribir archivos
echo ""
echo "3. Leyendo y escribiendo archivos..."
echo "Contenido generado en: $(date)" > output/report.txt
echo "Usuario: $USER" >> output/report.txt
echo "Sistema: $(uname -a)" >> output/report.txt
echo "Variables de entorno recibidas:" >> output/report.txt
echo "  SECRET_MESSAGE: $SECRET_MESSAGE" >> output/report.txt

echo "   Reporte creado en output/report.txt"

# 4. Crear proceso en segundo plano
echo ""
echo "4. Creando proceso en segundo plano..."
echo "Monitoreo iniciado: $(date)" > logs/monitor.log
(
    while true; do
        echo "[$(date)] CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')" >> logs/monitor.log
        sleep 10
    done
) &
MONITOR_PID=$!
echo "   Proceso monitor iniciado con PID: $MONITOR_PID"

# 5. Mostrar variables de entorno
echo ""
echo "5. Variables de entorno:"
echo "   NODE_ENV: $NODE_ENV"
echo "   GITHUB_ACTIONS: $GITHUB_ACTIONS"
echo "   SECRET_MESSAGE: [OCULTO POR SEGURIDAD]"

# 6. Generar archivo de configuración
echo ""
echo "6. Generando configuración..."
cat > output/config.json << EOF
{
  "timestamp": "$(date -Iseconds)",
  "system": {
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "hostname": "$(hostname)"
  },
  "environment": {
    "node_env": "$NODE_ENV",
    "user": "$USER"
  },
  "directories": {
    "current": "$(pwd)",
    "logs": "$(pwd)/logs",
    "output": "$(pwd)/output"
  }
}
EOF
echo "   Configuración guardada en output/config.json"

# 7. Simular trabajo
echo ""
echo "7. Simulando trabajo..."
for i in {1..3}; do
    echo "   Iteración $i completada"
    sleep 1
done

# 8. Finalizar proceso en segundo plano
echo ""
echo "8. Finalizando procesos..."
kill $MONITOR_PID 2>/dev/null || true
echo "   Proceso monitor terminado"

echo ""
echo "=== SCRIPT COMPLETADO CON ÉXITO ==="