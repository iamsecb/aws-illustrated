#!/bin/bash
# Export all drawio diagrams into PNG files. PNG files will have "sanitized" diagram names

export diagram_file_name=cloudfront # No extension
export diagram_file_path=./cloudfront/diagrams
export png_target_path=./cloudfront/diagrams/png

# Get diagram info. No need for --uncompressed : care only about <diagram name="..." ...> part.
/Applications/draw.io.app/Contents/MacOS/draw.io --export --format xml --output $diagram_file_path/$diagram_file_name.xml --page-index 0 $diagram_file_path/$diagram_file_name.drawio

# grep -Eo "name=\"[^\"]*": get name="... tokens/matches from xml
# cut -c7-: get diagram name (everything but starting 'name="'')
# sed -e 's/[^a-zA-Z0-9_]/_/: replace all possible unsafe charactecter for file names with underscore (_) 
# tr '[:upper:]' '[:lower:]': make all lower case
# awk '{print NR,$1}': add sequence number (NR) to output to indicate index of diagram
# xargs -n2 sh -c: get 2 arguments (index and sanitized driagram name) and pass to shell command
# drawio --export...: export diagram at specified index (0-based) to PNG
cat $diagram_file_path/$diagram_file_name.xml \
    | grep -Eo "name=\"[^\"]*" \
    | cut -c7- \
    | sed -e 's/[^a-zA-Z0-9_]/_/g' \
    | tr '[:upper:]' '[:lower:]' \
    | awk '{print NR,$1}' \
    | xargs -n2 sh -c \
    '/Applications/draw.io.app/Contents/MacOS/draw.io --export --format png --output $png_target_path/$1.png --page-index $(expr $0 - 1) $diagram_file_path/$diagram_file_name.drawio'


rm $diagram_file_path/$diagram_file_name.xml
