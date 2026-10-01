% FIND_SLOPES Extract medium-transition and embryo-response parameters.
%
% Purpose:
%   Analyze one entry of the all_data structure from a fast on-chip shock
%   experiment and store transition timing and embryo volume parameters.
% Inputs:
%   It should be imported in the workspace : the structure (matrix) 'all_data' with time_minutes, legend642, file, medium_intensity_642,
%   medium_intensity_488, x_emb, and y_emb fields. Configure i, os, date,
%   folder_save, and matrix_filename below.
% Outputs:
%   microflu_data(i) in a MAT file, containing medium transition and embryo
%   response measurements, plus diagnostic figures.
% Overview:
%   Converts embryo radius to volume, detects slope-change regions in the two
%   medium channels and optionally the embryo trace, then saves the result.
% Dependencies:
%   Image Processing Toolbox for bwlabel; MATLAB functions filloutliers,
%   rmmissing, gradient, and plotting functions. The local findslopes helper
%   is defined at the end of this file.

% ----- SAVING
% Create a folder with today time, in the folding of saving
folder_save = '/path/to/results/fast_osmotic_shocks_onChip';
date = string(datetime("now"));
mkdir(fullfile(folder_save,date))

matrix_filename = 'data_OS_onChip.mat'

%% Sample input
i = 41 %Embryo index, to modify
t = all_data(i).time_minutes';
legend = all_data(i).legend642
os = 0; %Not to compute slopes on controls
%% Slope changes for Dextran 10kDa-Alexa647nm
intensity_647 = all_data(i).medium_intensity_642;
[change_start_647,change_stop_647] = findslopes(t,intensity_647,0)

%% Compute parameters
change_start_times_647 = t(change_start_647);
change_stop_times_647 = t(change_stop_647);
duration_medium_change_647 = change_stop_times_647 - change_start_times_647

%% Slope changes for Dextran 10kDa-Alexa488nm
intensity_488 = all_data(i).medium_intensity_488;
[change_start_488,change_stop_488] = findslopes(t,intensity_488,0)

%% Compute parameters
change_start_times_488 = t(change_start_488);
change_stop_times_488 = t(change_stop_488);
duration_medium_change_488 = change_stop_times_488 - change_start_times_488

%% Slope changes for the embryo
x_emb = all_data(i).x_emb;
y_emb = (4 .* pi./3 .*(all_data(i).y_emb./2).^3) .* (10^-3); % convert to volume and to pL

if os == 1 
[change_start_emb,change_stop_emb] = findslopes(x_emb,y_emb,1)
else
    figure
    plot(x_emb,y_emb)
end

%% Compute parameters
if os == 1
change_start_times_emb = x_emb(change_start_emb);
change_stop_times_emb = x_emb(change_stop_emb);

change_start_volumes_emb = y_emb(change_start_emb);
change_stop_volumes_emb = y_emb(change_stop_emb);

duration_volume_change_emb = change_stop_times_emb - change_start_times_emb;
amplitude_volume_change_emb = change_stop_volumes_emb - change_start_volumes_emb;

disp('duration')
disp(duration_volume_change_emb)
disp('amplitude')
disp(amplitude_volume_change_emb)

slope_OS = amplitude_volume_change_emb(1) / duration_volume_change_emb(1);
slope_recovery = amplitude_volume_change_emb(2) / duration_volume_change_emb(2);
end

%% Adding new results to matrix
microflu_data(i).file = all_data(i).file;
microflu_data(i).legend = all_data(i).legend642;
microflu_data(i).time_minutes = t;

% Dextran 647nm
microflu_data(i).medium_intensity_647nm = intensity_647;
microflu_data(i).medium_change_start_indexes_647 = change_start_647;
microflu_data(i).medium_change_start_times_647 = change_start_times_647;
microflu_data(i).medium_change_stop_indexes_647 = change_stop_647;
microflu_data(i).medium_change_stop_times_647 = change_stop_times_647;
microflu_data(i).duration_medium_change_647= duration_medium_change_647;

% Dextran 488nm
microflu_data(i).medium_intensity_488nm = intensity_488;
microflu_data(i).medium_change_start_indexes_488 = change_start_488;
microflu_data(i).medium_change_start_times_488 = change_start_times_488;
microflu_data(i).medium_change_stop_indexes_488 = change_stop_488;
microflu_data(i).medium_change_stop_times_488 = change_stop_times_488;
microflu_data(i).duration_medium_change_488= duration_medium_change_488;

% Embryo volume
microflu_data(i).embryo_time_min = x_emb;
microflu_data(i).embryo_radius_microns = all_data(i).y_emb;
microflu_data(i).embryo_volume_pL = y_emb;

if os == 1
microflu_data(i).embryo_change_start_indexes = change_start_emb;
microflu_data(i).embryo_change_start_volumes = change_start_volumes_emb;
microflu_data(i).embryo_change_stop_indexes = change_stop_emb;
microflu_data(i).embryo_change_stop_volumes = change_stop_volumes_emb;
microflu_data(i).duration_volume_change_emb_min = duration_volume_change_emb;
microflu_data(i).amplitude_volume_change_emb_pL = amplitude_volume_change_emb;
microflu_data(i).slope_OS_pLperMin = slope_OS;
microflu_data(i).slope_recovery_pLperMin = slope_recovery;
microflu_data(i).delay_answer_embryo = change_start_times_emb' - change_start_times_647;

else
microflu_data(i).embryo_change_start_indexes = NaN;
microflu_data(i).embryo_change_start_volumes = NaN;
microflu_data(i).embryo_change_stop_indexes = NaN;
microflu_data(i).embryo_change_stop_volumes = NaN;
microflu_data(i).duration_volume_change_emb_min = NaN;
microflu_data(i).amplitude_volume_change_emb_pL = NaN;
microflu_data(i).slope_OS_pLperMin = NaN;
microflu_data(i).slope_recovery_pLperMin = NaN;
microflu_data(i).delay_answer_embryo = NaN;
end
disp('ok')
%% Save matrix
save(fullfile(folder_save,date,matrix_filename),'microflu_data','-mat')
disp("save")
close all


%% Function to find start and stop of change

% FINDSLOPES Detect contiguous regions whose smoothed slope exceeds a threshold.
function [change_start,change_stop] = findslopes(time,intensity,emb)

dt = gradient(time);  % Time step
slope = gradient(intensity) ./ dt;



if emb == 0
    slope_smooth = movmean(slope, 3);  % 5-point moving average
    threshold = 0.1 * max(abs(slope_smooth));  % Customize threshold as needed
else
    slope_smooth = movmean(slope, 5);  % 5-point moving average
    threshold = 0.4 * max(abs(slope_smooth));
end

change_mask = abs(slope_smooth) > threshold;

% Find continuous chunks of "change" using bwlabel
change_regions = bwlabel(change_mask);  % Needs Image Processing Toolbox

n_regions = max(change_regions);
change_start = zeros(1, n_regions);
change_stop = zeros(1, n_regions);

for s = 1:n_regions
    region_idx = find(change_regions == s);
    change_start(s) = region_idx(1);
    change_stop(s) = region_idx(end);
end

change_start_times = time(change_start);
change_stop_times = time(change_stop);


figure;
plot(time, intensity, 'b'); hold on;

scatter(time, intensity)
hold off


% Highlight change region
xline(change_start_times, '--g', 'Start');
xline(change_stop_times, '--r', 'Stop');

xlabel('Time'); ylabel('Intensity');
title('Transition Detection');
legend('Signal', 'Start of Change', 'End of Change');

end