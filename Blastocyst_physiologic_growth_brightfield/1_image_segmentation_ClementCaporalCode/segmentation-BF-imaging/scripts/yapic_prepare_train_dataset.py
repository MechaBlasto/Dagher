import os
import numpy as np
import glob
from pathlib import Path
from tifffile import imread, imwrite
import sys

# retrieve input path from bash command line
input_path = sys.argv[1]
output_path = sys.argv[2]

folder_path_3D_annotated_pair = Path(input_path)
folder_path_yapic_training_dataset = Path(output_path)

path_imgs = glob.glob(str(folder_path_3D_annotated_pair / "raw/*"))
path_labels = glob.glob(str(folder_path_3D_annotated_pair / "label/*"))

# create empty folder if it doesn't exist to save the data
if not os.path.isdir(folder_path_yapic_training_dataset):
    os.mkdir(folder_path_yapic_training_dataset)
    os.mkdir(folder_path_yapic_training_dataset/"input")
    os.mkdir(folder_path_yapic_training_dataset/"target")

for k in range(len(path_imgs)):
    path_img = path_imgs[k]
    path_label = path_labels[k]
    print(path_img, path_label, "to", folder_path_yapic_training_dataset)
    im = imread(path_img)
    im = (im - np.min(im)) / (np.max(im) - np.min(im)) * 255 # normalize to match the 8-bit format
    labels = imread(path_label)
    # populate the folders
    for i, t in enumerate(labels):
        if 1 in t: # if this slide has labels
            # save the pair
            imwrite(folder_path_yapic_training_dataset/"input"/(str(k)+"-"+str(i)+".tif"), [im[i].astype(np.uint8)], dtype=np.uint8)
            imwrite(folder_path_yapic_training_dataset/"target"/(str(k)+"-"+str(i)+".tif"), [t.astype(np.uint8)], dtype=np.uint8)
