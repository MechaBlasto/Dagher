import numpy as np
import tifffile
import glob
import sys
import os
from pathlib import Path

folder_regex = Path(sys.argv[1])

output_folder = Path(sys.argv[2])

for file in glob.glob(str(folder_regex / "*.tif")):
    print(file)
    img = tifffile.imread(file) * 255
    file_name = file.split(os.sep)[-1]
    
    tifffile.imwrite(str(output_folder/file_name), img.astype("uint8"))
