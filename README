# Publication MATLAB code

This repository contains analysis code accompanying the paper "Fluid transport properties dominate blastocyst expansion over mechanics".

It contains three related workflows. The scripts are organized by experiment and by analysis stage.

## Usage

Choose the workflow matching the data you want to analyze:

```bash
Blastocyst_physiologic_growth_brightfield/
  1_image_segmentation_ClementCode/
    segmentation-BF-imaging/README.md  # 2-D yapic segmentation of brightfield imaging and instructions
  2_sample_analysis/1_extract_embryo_parameters_fromMasks/
    zp_seg_postprocessing.m            # segmentation post-processing
  2_sample_analysis/2_extract_growth_curve_parameters/
    collapses.m                        # per-embryo physiological growth and collapse parameters
  3_experiment_analysis_fromMatrix/
    growth_curves_alignment_pub.m      # condition-level analysis and plots
```

```bash
Fast_osmotic_shocks_onChip/
  1_folder_organization/organize_your_folder.m # folder organization of microscopy images
  2_sample_analysis_MaxProj/1_extract_embryo_parameters_fromMasks/
    ellipse_maxproj561.m # 2-D max-projection segmentation of mTmG imaging and ellipse fitting
  2_sample_analysis_MaxProj/2_extract_growth_curve_parameters/
    find_slopes.m # per-embryo forced inflation and deflation parameters - dynamic Osmotic shocks on microfluidic chip
  3_experiment_analysis_fromMatrix/OS_onChip_common_publi.m # condition-level analysis and plots
```

```bash
Static_osmotic_shocks_onDish/
  1_1_image_segmentation_AurelienCode # 3-D mask segmentation of mTmG imaging
  2_Analysis_3D/OS_volumes_equilibrium_contributions_final.m # 3-D mask analysis, volumes counting, and condition-level analysis - Static osmotic shocks on dish
```

Run each script in MATLAB after editing its configuration block and loading or creating the workspace variables described in the file header. The scripts are interactive in places: several require polygon selections, clicks, or manual outlier review. Run the stages in order when starting from raw image data.

## Workflows

You can find for each workflow a script header describing the expected inputs, outputs, and configuration. 

### Blastocyst physiological growth

1. Prepare embryo (and, when used, zona pellucida) segmentation TIFF stacks.
2. Use yapic segmentation code to create labeled probability maps.
3. Run `zp_seg_postprocessing.m` to create `zp_results` and saved final masks.# Publication MATLAB code

This repository contains analysis code accompanying the paper "Fluid transport properties dominate blastocyst expansion over mechanics".

It contains three related workflows. The scripts are organized by experiment and by analysis stage.

## Usage

Choose the workflow matching the data you want to analyze:

```bash
Blastocyst_physiologic_growth_brightfield/
  1_image_segmentation_ClementCode/
    segmentation-BF-imaging/README.md  # 2-D yapic segmentation of brightfield imaging and instructions
  2_sample_analysis/1_extract_embryo_parameters_fromMasks/
    zp_seg_postprocessing.m            # segmentation post-processing
  2_sample_analysis/2_extract_growth_curve_parameters/
    collapses.m                        # per-embryo physiological growth and collapse parameters
  3_experiment_analysis_fromMatrix/
    growth_curves_alignment_pub.m      # condition-level analysis and plots
```

```bash
Fast_osmotic_shocks_onChip/
  1_folder_organization/organize_your_folder.m # folder organization of microscopy images
  2_sample_analysis_MaxProj/1_extract_embryo_parameters_fromMasks/
    ellipse_maxproj561.m # 2-D max-projection segmentation of mTmG imaging and ellipse fitting
  2_sample_analysis_MaxProj/2_extract_growth_curve_parameters/
    find_slopes.m # per-embryo forced inflation and deflation parameters - dynamic Osmotic shocks on microfluidic chip
  3_experiment_analysis_fromMatrix/OS_onChip_common_publi.m # condition-level analysis and plots
```

```bash
Static_osmotic_shocks_onDish/
  1_1_image_segmentation_AurelienCode # 3-D mask segmentation of mTmG imaging
  2_Analysis_3D/OS_volumes_equilibrium_contributions_final.m # 3-D mask analysis, volumes counting, and condition-level analysis - Static osmotic shocks on dish
```

Run each script in MATLAB after editing its configuration block and loading or creating the workspace variables described in the file header. The scripts are interactive in places: several require polygon selections, clicks, or manual outlier review. Run the stages in order when starting from raw image data.

## Workflows

You can find for each workflow a script header describing the expected inputs, outputs, and configuration. 

### Blastocyst physiological growth

1. Prepare embryo (and, when used, zona pellucida) segmentation TIFF stacks.
2. Use yapic segmentation code to create labeled probability maps.
3. Run `zp_seg_postprocessing.m` to create `zp_results` and saved final masks.
4. Load the resulting `zp_results` MAT file and run `collapses.m` for one embryo at a time.
5. Load the completed `zp_results` structure and run `growth_curves_alignment_pub.m` for condition-level alignment, plots, and exported statistics. It aligns the growth curves of the samples at a specific volume (300 pL, when the embryo reaches the zona pellucida). It thus enables the study of the average behaviour of the embryo’s volume and the thickness of its zona pellucida during blastocyst development. It enables the temporal analysis of parameters related to the growth and collapse phases: speed, frequency, amplitude, duration and the associated osmotic gradient.
This pipeline is used primarily to understand physiological behaviour and is reused for experiments disrupting fluid transport using drugs.


### Fast osmotic shocks on chip

1. Use `organize_your_folder.m` to make sample and wavelength folders after acquisition.
2. Use `ellipse_maxproj561.m` on max-projection TIFF stacks to create `maxproj_results` files.
3. Prepare the `all_data` structure from the upstream mask/intensity analysis, then run `find_slopes.m` for the selected embryo index.
4. Combine the resulting `microflu_data` records and run `OS_onChip_common_publi.m` for group-level figures and statistics. It compares the slopes of forced inflation and deflation for different strengths of hypo- and hyper- osmotic shocks. It enables the embryos behaviour as a perfect semi-permeable membrane to be verified using the Boyle–Van’t Hoff equation.

### Static osmotic shocks on dish

1. Prepare 3-D TIFF stacks and run `1_image_segmentation_AurelienCode` to create 3D labeled masks. Prepare 2-D TIFF stacks of max-projection images if you want to compare 3-D- and 2-D-image-based analysis.
2. Run `Static_osmotic_shocks_onDish/2_Analysis_3D/OS_volumes_equilibrium_contributions_final.m`
after preparing the 3-D mask and max-projection directories. It counts cell, lumen, and embryo voxels, performs interactive 2-D ellipse segmentation, pairs corresponding files, and exports comparisons and summary statistics.

## MATLAB and dependencies

MATLAB version: <R2023a>.
with the following toolboxes:
- Image Processing Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

Other required toolboxes and external code: `imcart2pol`, `customcolormap`, `slanCM`, `linspecer`, `daviolinplot`.

The scripts use descriptive example paths such as `/path/to/external_tools/`
and `/path/to/data/`. Replace these placeholders with local directories before
running the code. External tools are not included here and must be obtained
separately and added to the MATLAB path.

## Citation

If you use this code in your research, please cite the following publication:

Dagher L. et al., Fluid transport properties dominate blastocyst expansion over mechanics, <todo: journal name>, 2026.

@article{dagher2026,
  title     = {Fluid transport properties dominate blastocyst expansion over mechanics},
  author    = {Dagher, Louise and Bassanini, Matteo and de Plater, Ludmilla and Gropplero, Giacomo and Caporal, Clément and Maillot, Aurélien and Kastas, Ozan and Duclut, Charlie and Descroix, Stéphanie and Maître, Jean-Léon},
  journal   = {<todo: journal name>},
  year      = {2026},
}
4. Load the resulting `zp_results` MAT file and run `collapses.m` for one embryo at a time.
5. Load the completed `zp_results` structure and run `growth_curves_alignment_pub.m` for condition-level alignment, plots, and exported statistics. It aligns the growth curves of the samples at a specific volume (300 pL, when the embryo reaches the zona pellucida). It thus enables the study of the average behaviour of the embryo’s volume and the thickness of its zona pellucida during blastocyst development. It enables the temporal analysis of parameters related to the growth and collapse phases: speed, frequency, amplitude, duration and the associated osmotic gradient.
This pipeline is used primarily to unde# Publication MATLAB code

This repository contains analysis code accompanying the paper "Fluid transport properties dominate blastocyst expansion over mechanics".

It contains three related workflows. The scripts are organized by experiment and by analysis stage.

## Usage

Choose the workflow matching the data you want to analyze:

```bash
Blastocyst_physiologic_growth_brightfield/
  1_image_segmentation_ClementCode/
    segmentation-BF-imaging/README.md  # 2-D yapic segmentation of brightfield imaging and instructions
  2_sample_analysis/1_extract_embryo_parameters_fromMasks/
    zp_seg_postprocessing.m            # segmentation post-processing
  2_sample_analysis/2_extract_growth_curve_parameters/
    collapses.m                        # per-embryo physiological growth and collapse parameters
  3_experiment_analysis_fromMatrix/
    growth_curves_alignment_pub.m      # condition-level analysis and plots
```

```bash
Fast_osmotic_shocks_onChip/
  1_folder_organization/organize_your_folder.m # folder organization of microscopy images
  2_sample_analysis_MaxProj/1_extract_embryo_parameters_fromMasks/
    ellipse_maxproj561.m # 2-D max-projection segmentation of mTmG imaging and ellipse fitting
  2_sample_analysis_MaxProj/2_extract_growth_curve_parameters/
    find_slopes.m # per-embryo forced inflation and deflation parameters - dynamic Osmotic shocks on microfluidic chip
  3_experiment_analysis_fromMatrix/OS_onChip_common_publi.m # condition-level analysis and plots
```

```bash
Static_osmotic_shocks_onDish/
  1_1_image_segmentation_AurelienCode # 3-D mask segmentation of mTmG imaging
  2_Analysis_3D/OS_volumes_equilibrium_contributions_final.m # 3-D mask analysis, volumes counting, and condition-level analysis - Static osmotic shocks on dish
```

Run each script in MATLAB after editing its configuration block and loading or creating the workspace variables described in the file header. The scripts are interactive in places: several require polygon selections, clicks, or manual outlier review. Run the stages in order when starting from raw image data.

## Workflows

You can find for each workflow a script header describing the expected inputs, outputs, and configuration. 

### Blastocyst physiological growth

1. Prepare embryo (and, when used, zona pellucida) segmentation TIFF stacks.
2. Use yapic segmentation code to create labeled probability maps.
3. Run `zp_seg_postprocessing.m` to create `zp_results` and saved final masks.
4. Load the resulting `zp_results` MAT file and run `collapses.m` for one embryo at a time.
5. Load the completed `zp_results` structure and run `growth_curves_alignment_pub.m` for condition-level alignment, plots, and exported statistics. It aligns the growth curves of the samples at a specific volume (300 pL, when the embryo reaches the zona pellucida). It thus enables the study of the average behaviour of the embryo’s volume and the thickness of its zona pellucida during blastocyst development. It enables the temporal analysis of parameters related to the growth and collapse phases: speed, frequency, amplitude, duration and the associated osmotic gradient.
This pipeline is used primarily to understand physiological behaviour and is reused for experiments disrupting fluid transport using drugs.


### Fast osmotic shocks on chip

1. Use `organize_your_folder.m` to make sample and wavelength folders after acquisition.
2. Use `ellipse_maxproj561.m` on max-projection TIFF stacks to create `maxproj_results` files.
3. Prepare the `all_data` structure from the upstream mask/intensity analysis, then run `find_slopes.m` for the selected embryo index.
4. Combine the resulting `microflu_data` records and run `OS_onChip_common_publi.m` for group-level figures and statistics. It compares the slopes of forced inflation and deflation for different strengths of hypo- and hyper- osmotic shocks. It enables the embryos behaviour as a perfect semi-permeable membrane to be verified using the Boyle–Van’t Hoff equation.

### Static osmotic shocks on dish

1. Prepare 3-D TIFF stacks and run `1_image_segmentation_AurelienCode` to create 3D labeled masks. Prepare 2-D TIFF stacks of max-projection images if you want to compare 3-D- and 2-D-image-based analysis.
2. Run `Static_osmotic_shocks_onDish/2_Analysis_3D/OS_volumes_equilibrium_contributions_final.m`
after preparing the 3-D mask and max-projection directories. It counts cell, lumen, and embryo voxels, performs interactive 2-D ellipse segmentation, pairs corresponding files, and exports comparisons and summary statistics.

## MATLAB and dependencies

MATLAB version: <R2023a>.
with the following toolboxes:
- Image Processing Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

Other required toolboxes and external code: `imcart2pol`, `customcolormap`, `slanCM`, `linspecer`, `daviolinplot`.

The scripts use descriptive example paths such as `/path/to/external_tools/`
and `/path/to/data/`. Replace these placeholders with local directories before
running the code. External tools are not included here and must be obtained
separately and added to the MATLAB path.

## Citation

If you use this code in your research, please cite the following publication:

Dagher L. et al., Fluid transport properties dominate blastocyst expansion over mechanics, <todo: journal name>, 2026.

@article{dagher2026,
  title     = {Fluid transport properties dominate blastocyst expansion over mechanics},
  author    = {Dagher, Louise and Bassanini, Matteo and de Plater, Ludmilla and Gropplero, Giacomo and Caporal, Clément and Maillot, Aurélien and Kastas, Ozan and Duclut, Charlie and Descroix, Stéphanie and Maître, Jean-Léon},
  journal   = {<todo: journal name>},
  year      = {2026},
}rstand physiological behaviour and is reused for experiments disrupting fluid transport using drugs.


### Fast osmotic shocks on chip

1. Use `organize_your_folder.m` to make sample and wavelength folders after acquisition.
2. Use `ellipse_maxproj561.m` on max-projection TIFF stacks to create `maxproj_results` files.
3. Prepare the `all_data` structure from the upstream mask/intensity analysis, then run `find_slopes.m` for the selected embryo index.
4. Combine the resulting `microflu_data` records and run `OS_onChip_common_publi.m` for group-level figures and statistics. It compares the slopes of forced inflation and deflation for different strengths of hypo- and hyper- osmotic shocks. It enables the embryos behaviour as a perfect semi-permeable membrane to be verified using the Boyle–Van’t Hoff equation.

### Static osmotic shocks on dish

1. Prepare 3-D TIFF stacks and run `1_image_segmentation_AurelienCode` to create 3D labeled masks. Prepare 2-D TIFF stacks of max-projection images if you want to compare 3-D- and 2-D-image-based analysis.
2. Run `Static_osmotic_shocks_onDish/2_Analysis_3D/OS_volumes_equilibrium_contributions_final.m`
after preparing the 3-D mask and max-projection directories. It counts cell, lumen, and embryo voxels, performs interactive 2-D ellipse segmentation, pairs corresponding files, and exports comparisons and summary statistics.

## MATLAB and dependencies

MATLAB version: <R2023a>.
with the following toolboxes:
- Image Processing Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

Other required toolboxes and external code: `imcart2pol`, `customcolormap`, `slanCM`, `linspecer`, `daviolinplot`.

The scripts use descriptive example paths such as `/path/to/external_tools/`
and `/path/to/data/`. Replace these placeholders with local directories before
running the code. External tools are not included here and must be obtained
separately and added to the MATLAB path.

## Citation

If you use this code in your research, please cite the following publication:

Dagher L. et al., Fluid transport properties dominate blastocyst expansion over mechanics, <todo: journal name>, 2026.

@article{dagher2026,
  title     = {Fluid transport properties dominate blastocyst expansion over mechanics},
  author    = {Dagher, Louise and Bassanini, Matteo and de Plater, Ludmilla and Gropplero, Giacomo and Caporal, Clément and Maillot, Aurélien and Kastas, Ozan and Duclut, Charlie and Descroix, Stéphanie and Maître, Jean-Léon},
  journal   = {<todo: journal name>},
  year      = {2026},
}
