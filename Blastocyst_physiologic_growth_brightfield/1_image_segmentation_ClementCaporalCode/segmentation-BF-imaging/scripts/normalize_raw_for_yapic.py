# used to be sure that all the raw dataset is readable by yapic
# It should be 8bits and in "ZYXC" order and the file extension should be ".tif"

import os
import numpy as np
import glob
from pathlib import Path
from tifffile import imread, imwrite
import sys


# retrieve input path from bash command line
input_path = sys.argv[1]

if len(sys.argv) < 3:
    # create a folder next to the input folder
    output_path = Path(input_path).parent / (Path(input_path).name + "_normalized")
    print("Output path not specified. Using default path: ", output_path)
else:
    output_path = sys.argv[2]

if not os.path.exists(output_path):
    os.makedirs(output_path)

folder_path_raw = Path(input_path)
folder_path_normalized = Path(output_path)

path_imgs = glob.glob(str(folder_path_raw / "*"))

for path in path_imgs:
    print(path)
    img = imread(path)
    print("input shape: ", img.shape)
    img = (img - np.min(img)) / (np.max(img) - np.min(img)) * 255 # normalize to match the 8-bit format
    img = img.astype(np.uint8)
    # check if img has 4 dimensions
    if len(img.shape) != 4:
        img = np.expand_dims(img, axis=-1) # assume that the last dimension is the channel
    print("output shape: ", img.shape, "for order ZYXC")
    imwrite(folder_path_normalized / Path(path).name.replace(".tiff", ".tif"), img, dtype=np.uint8, metadata={'axes': 'ZYXS'}) # S is Channel