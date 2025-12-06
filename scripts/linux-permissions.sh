#!/bin/bash
# scripts/linux-permissions.sh - Demo adicional de permisos

echo "=== LINUX PERMISSIONS DEMO ==="

# Create demo files
echo "Creating demo files..."
echo "File 1: Read only for owner" > demo1.txt
echo "File 2: Read for everyone" > demo2.txt
echo "File 3: Executable script" > demo3.sh

# Show original permissions
echo "Original permissions:"
ls -l demo*.txt demo*.sh 2>/dev/null

# Apply different permissions
echo ""
echo "Applying permissions:"
chmod 400 demo1.txt && echo "  demo1.txt -> 400 (r--------)"
chmod 644 demo2.txt && echo "  demo2.txt -> 644 (rw-r--r--)"
chmod 755 demo3.sh && echo "  demo3.sh  -> 755 (rwxr-xr-x)"

# Show final permissions
echo ""
echo "Final permissions:"
ls -l demo*.txt demo*.sh 2>/dev/null

# Clean up
rm -f demo*.txt demo*.sh

echo ""
echo "=== PERMISSIONS DEMO COMPLETED ==="