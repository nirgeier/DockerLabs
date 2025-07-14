#!/bin/bash
# Generate a table of contents for the documentation.
# This script is run by the Makefile.

# Load the script from the specified path using process substitution
# Download the script locally first
#curl -fsSL "https://raw.githubusercontent.com/nirgeier/labs-assets/main/scripts/generate_readme_toc.sh" -o ./generate_readme_toc.sh

# Source the local file
source ./generate_readme_toc.sh

# Add all the methods from the script to the current shell
# This allows us to use the functions defined in the script directly
# Loop over the functions and expose them on the main shell
for func in $(declare -F | awk '{print $3}'); 
do
  export -f "$func"
done

# Check if the directory argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi  

# Generate the TOC file in the specified directory
generate_toc_file "$1"  