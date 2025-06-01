#!/bin/bash
desktop="$HOME/Desktop"
alias_map="$HOME/Desktop/.alias_map"

> "$alias_map"  # Clear existing file

for dir in "$desktop"/[0-9]*; do
    [ -d "$dir" ] || continue
    for alias_file in "$dir"/*-aliases.txt; do
        keyword=$(basename "$alias_file" | sed 's/-aliases\.txt$//')
        echo "$keyword:$dir" >> "$alias_map"
    done
done
