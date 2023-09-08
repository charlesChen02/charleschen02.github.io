#!/bin/bash

# Default values
EDITOR="subl"

# Function to show usage
function usage() {
    echo "Usage: $0 [--editor editor_name] title"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --editor)
    EDITOR="$2"
    shift # past argument
    shift # past value
    ;;
    *)
    TITLE="$@"
    break
    ;;
esac
done

if [[ -z "$TITLE" ]]; then
    usage
fi

# Replace spaces with dashes and convert to lowercase
TITLE_URL=$(echo "$TITLE" | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]')

DATE=$(date +"%Y-%m-%d")
FILENAME="_posts/$DATE-$TITLE_URL.markdown"

# Check if file already exists
if [[ -e $FILENAME ]]; then
    echo "$FILENAME already exists!"
    exit 1
fi

# Create the post file
echo "Creating new post: $FILENAME"
cat << EOF > $FILENAME
---
layout: post
title: "$TITLE"
tags:
 -
---
EOF

# Open the post file in the specified editor
# $EDITOR $FILENAME
