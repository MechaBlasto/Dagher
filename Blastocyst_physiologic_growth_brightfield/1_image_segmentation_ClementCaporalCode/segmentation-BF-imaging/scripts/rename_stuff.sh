for file in *.tif; do mv -- "$file" "${file%.tif}_new.tif"; done
