#!/bin/bash
set -e

declare currentFolder=$(pwd)
declare publicFolder="$currentFolder/public"

# Creates static html files for openapi.yaml file in the current directory
loadStaticHtmlToFolder() {
    local folder="$1"
    echo "Creating folder $publicFolder/$folder"
    mkdir -p $publicFolder/$folder
    npx @redocly/cli bundle $currentFolder/$folder/openapi.yaml -o $publicFolder/$folder/index.html
}

# Selects all folders in the current directory
selectAllFoldersInDirectory() {
    local -n folders=$1
    echo "Selecting all folders in $currentFolder"
    
    # Use glob pattern to get all directories
    for dir in "$currentFolder"/*/; do
        # Check if it's a directory
        if [ -d "$dir" ] && [[ "$dir" != */images/ ]] && [[ "$dir" != */public/ ]]; then
            folders+=("$dir")
        fi
    done

    # Stripping the path and getting only the folder name
    folders=("${folders[@]%/}")
    folders=("${folders[@]##*/}")
}

# Initializes the public folder
initializePublicFolder() {
    echo "Initializing public folder"
    mkdir -p $publicFolder
    cp -r $currentFolder/images $publicFolder
}

# Creates index.html file
createIndexHtml() {
    local -n folders=$1
    echo "Creating index.html"
    local indexHtml="$publicFolder/index.html"
    echo "<html><head><title>SSC</title></head><body><h1>SSC</h1><ul>" > $indexHtml
    for folder in "${folders[@]}"; do
        echo "<li><a href=\"$folder/index.html\">$folder</a></li>" >> $indexHtml
    done
    echo "</ul></body></html>" >> $indexHtml
}

declare allFolders
selectAllFoldersInDirectory allFolders
initializePublicFolder
createIndexHtml allFolders

for directory in "${allFolders[@]}"; do
    loadStaticHtmlToFolder $directory
done