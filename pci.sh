#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo " This script must be run as ROOT."
  exit 1
fi
file="/pci_cleanup_test.txt"

echo "Creating test file: $file"
echo "Linux" > $file

chmod 777 $file
echo "Applied rwxrwxrwx permissions to $file"
echo ""

# ---------------------------
#  Step 2: Ask for log directory
# ---------------------------
echo "Enter the directory that contains Apache logs:"
read log_dir

# Verify directory exists
if [ ! -d "$log_dir" ]; then
  echo "Directory does not exist."
  exit 1
fi

echo ""
echo "Searching for files containing 'Linux' (case-insensitive)..."
echo ""

# Find all files containing "Linux"
results=$(grep -irl "Linux" "$log_dir")

if [ -z "$results" ]; then
  echo "No files containing 'Linux' found."
  exit 0
fi

echo "Matching Files:"
echo "$results"
echo ""


echo " WARNING: The following regular files will be deleted:"
find "$log_dir" -type f -exec grep -il "Linux" {} \;

echo ""
read -p "Do you want to delete these files? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Operation cancelled."
  exit 0
fi


echo ""
echo "Deleting files..."
find "$log_dir" -type f -exec grep -il "Linux" {} \; -delete

echo " Cleanup completed safely according to PCI-DSS requirements."

