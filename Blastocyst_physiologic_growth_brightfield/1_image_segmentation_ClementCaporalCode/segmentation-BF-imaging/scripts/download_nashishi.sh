mkdir -p ../data/nashishi_3D_annotated_pair/label/
mkdir -p ../data/nashishi_3D_annotated_pair/raw/
gdown --folder https://drive.google.com/drive/folders/1uyPtLlD1pqtrv5JYs1TfPzX6ojlI9QTb -O ../data/nashishi_3D_annotated_pair/
mv ../data/nashishi_3D_annotated_pair/nashishi_model/*label.tif ../data/nashishi_3D_annotated_pair/label/
mv ../data/nashishi_3D_annotated_pair/nashishi_model/*.tif ../data/nashishi_3D_annotated_pair/raw/
