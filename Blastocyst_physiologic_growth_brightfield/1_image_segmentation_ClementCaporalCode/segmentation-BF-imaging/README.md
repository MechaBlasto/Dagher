# segmentation-BF-imaging
Project for automatically segmenting bright-field images of preimplantations embryos

Link towards the drive with all files: 
https://drive.google.com/drive/folders/1xVX-8GpPe_J5bqARcgoSp0SJXLvS5uON?usp=sharing

## installation
1. Clone the repository

```
git clone git@github.com:Mechanics-of-Mammalian-Development/segmentation-BF-imaging.git
```

2. Create new environment and install dependencies

```
conda create -n segmentation-BF-imaging python=3.6
conda activate segmentation-BF-imaging
pip install tensorflow-gpu==1.15 --ignore-installed certifi
pip install yapic_io==0.2.7 yapic==1.3.2 ipykernel gdown
```

## Usage example

### How to create a new yapic model from scratch for nashishi
1. upload your images on a drive for example: https://drive.google.com/drive/folders/1uyPtLlD1pqtrv5JYs1TfPzX6ojlI9QTb
  Note that all labels are depicted by a {name_of_the_image}label.tif. This is used in the scripts so be sure the labels have this regex
2. In the `scripts/` folder you will find script to automatically run the following steps:
   1. download the dataset (`scripts/download_nashishi.sh`): This will download everything in a `data/nashishi_3D_annotated_pair` and will sort the `raw` from their `label` in two folders
   2. create yapic compatible dataset (`scripts/prepare_nashishi.sh`): This will open each 3D label and create individual plane where you actually labelled the images. Everything will be saved inside a new folder `data/yapic_training_dataset_nashishi` with two folders `input` and `target`.
   3. train the model (`scripts/train_nashishi.sh`): start the yapic model training. The model will be saved in `data/yapic_training_dataset_nashishi/model_nashishi.h5`
 3. The model is now ready to be used 


## Run a trained model on images
Protocol:
1)	Inside data folder / Create a folder named by today date
2)	Transfer data to this new folder
3)	Normalize tiff files for YAPIC (normalize_raw_for_yapic.py)
4)	Create folder for predicted output like data/[date]_predict
5)	Give 3 paths for yapic prediction (model path; normalized data; prediction folder)

Command lines to run:
```
from [folder name with dataset inside]
conda activate segmentation-BF-imaging
python ../scripts/normalize_raw_for_yapic.py today/ [or give true pathway of scripts folder]
mkdir [date]_predict
yapic predict [models/model_cell_discoverer.h5] [[date]_normalized/] [[date]_predict/]
```

