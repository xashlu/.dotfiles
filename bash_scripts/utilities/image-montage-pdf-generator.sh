#!/bin/bash

# Define the main directories
PDF_CREATOR_DIR="$HOME/pdf-creator"
IMAGE_SOURCE_DIR="$PDF_CREATOR_DIR/images-source"
IMAGE_DIR="$PDF_CREATOR_DIR/images"
PDF_DIR="$PDF_CREATOR_DIR/pdf"

# Check how many of the four directories are missing
missing=0
for dir in "$PDF_CREATOR_DIR" "$IMAGE_SOURCE_DIR" "$IMAGE_DIR" "$PDF_DIR"; do
    if [ ! -d "$dir" ]; then
        missing=$((missing + 1))
    fi
done

if [ "$missing" -eq 4 ]; then
    echo "All four directories are missing. Creating them and exiting..."
    mkdir -p "$PDF_CREATOR_DIR" "$IMAGE_SOURCE_DIR" "$IMAGE_DIR" "$PDF_DIR"
    exit 0
fi

# Create missing directories (if any)
mkdir -p "$PDF_CREATOR_DIR" "$IMAGE_SOURCE_DIR" "$IMAGE_DIR" "$PDF_DIR"

prepare_directories() {
    echo "Preparing directories..."
    rm -rf "$IMAGE_DIR"/*
    rm -rf "$PDF_DIR"/*
}

# Copy images from source to image directory
copy_images() {
    echo "Copying images from '$IMAGE_SOURCE_DIR' to '$IMAGE_DIR'..."
    cp "$IMAGE_SOURCE_DIR"/* "$IMAGE_DIR/"
}

convert_images() {
    echo "Converting and resizing images in '$IMAGE_DIR'..."

    # Iterate over the files in the image directory
    for file in "$IMAGE_DIR"/*; do
        if [[ $file != *.png ]]; then
            # Convert non-PNG files to PNG
            magick "$file" "$IMAGE_DIR/$(basename "$file" .${file##*.}).png"
            rm -f "$file"
        fi
    done
}

# Combine images horizontally by their base names
combine_images() {
    echo "Combining images in '$IMAGE_DIR'..."
    cd "$IMAGE_DIR"
    
    # Find images with similar base names and combine them horizontally
    for base in $(ls | sed -E 's/-[0-9]+\.png$//' | sort | uniq); do
        files=$(ls "$base"-*.png | sort)
        if [ -n "$files" ]; then
            magick $files +append "$base.png"
            rm -rf $files
        fi
    done
}

create_pdf() {
    echo "Creating PDF from combined images..."
    # Create a montage of all combined images
    montage *.png -tile 1x -geometry +0+0 -background black _.png
    magick _.png "$PDF_DIR/_.pdf"  # Convert to PDF and save in the PDF directory
}

view_pdf() {
    PDF_FILE="$PDF_DIR/_.pdf"
    if [ -f "$PDF_FILE" ]; then
        echo "Opening the generated PDF..."
        zathura "$PDF_FILE"
    else
        echo "No PDF generated; nothing to open."
    fi
}

main() {
    prepare_directories
    copy_images
    convert_images
    combine_images
    create_pdf
    view_pdf
}

# Execute the main function
main

