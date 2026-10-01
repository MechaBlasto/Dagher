mkdir -p ../data/cell_discoverer_3D_annotated_pair/label/
mkdir -p ../data/cell_discoverer_3D_annotated_pair/raw/
gdown --folder https://drive.google.com/drive/folders/1MVUiDLNJqPPBfXV5nbmeib5GoGs3qdsD -O ../data/cell_discoverer_3D_annotated_pair/
mv ../data/cell_discoverer_3D_annotated_pair/cell_discoverer_model/*label.tif ../data/cell_discoverer_3D_annotated_pair/label/
mv ../data/cell_discoverer_3D_annotated_pair/cell_discoverer_model/*.tif ../data/cell_discoverer_3D_annotated_pair/raw/
