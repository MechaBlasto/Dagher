% ORGANIZE_YOUR_FOLDER Organize acquired microscopy files.
%
% Purpose:
%   Create sample and wavelength subfolders and move matching files into them.
% Inputs:
%   folder_path, nb_samples, and used_wavelengths configured below. The input
%   directory is expected to contain the acquired files directly.
% Outputs:
%   A reorganized directory tree on disk. No MATLAB variables are saved.
% Overview:
%   Lists files, groups names containing a sample suffix, then groups the
%   remaining names by wavelength and moves them into the corresponding folders.
% Dependencies:
%   MATLAB file-system functions (dir, mkdir, movefile, fullfile).
%
% This is an optional preprocessing script for the fast on-chip workflow.

%clear all
% original folder of imaging
folder_path = '/path/to/data/fast_osmotic_shocks_onChip/2025-04-01_VH_static_mtmg_noZP_E3-5/Water_dil_50%';
cd(folder_path)

% list all tif filesmu
S = dir(fullfile(folder_path,'*'));
N = {S.name};
N = string(N);

%% If you want to create folder per sample

nb_samples = 2;

for sample = 1 : nb_samples
    sample_folder = string(sample);
    mkdir(sample_folder)
    suffixe = strcat('-',string(sample),'.');
    % find matching names indexes
    X = ~cellfun('isempty',strfind(N,suffixe));
    % create an array of the names
    SAMPLE = N(X);
    % move the files to the corresponding folder
    for i = 1 : length(SAMPLE)
        movefile(SAMPLE(i),sample_folder)
    end
    N(X) = "";

end

%% If you want to create folder par wavelength channel

% possible wavelengths
wavelengths = ["thumb";"BF";"561";"nd";"488";"642";"405"];

% for your experiment
used_wavelengths = [wavelengths(2:4)];


for wl = 1 : length(used_wavelengths) % for each channel colour
    new_folder = string(used_wavelengths(wl)); %give a name
    mkdir(new_folder) %create a folder
    % find matching names indexes
    X = ~cellfun('isempty',strfind(N,new_folder));
    % create an array of the names
    WL = N(X);
    % move the files to the corresponding folder
    for i = 1 : length(WL)
        movefile(WL(i),new_folder)
    end
    N(X) = "";
end
