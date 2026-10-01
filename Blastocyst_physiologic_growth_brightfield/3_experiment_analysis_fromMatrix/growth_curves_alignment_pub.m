% GROWTH_CURVES_ALIGNMENT_PUB Align and compare embryo growth curves.
%
% Purpose:
%   Align growth curves from multiple conditions, extract collapse and growth
%   phases parameters, and generate the comparative figures and statistical outputs.
% Inputs:
%   A workspace variable zp_results produced by the blastocyst sample-analysis
%   scripts. Configure folder_save, conditions, x_common, binning, and related
%   plotting parameters below.
% Outputs:
%   Aligned curve MAT/CSV files, correlation and regression result files, and
%   figures/tables written below folder_save.
% Overview:
%   Initializes condition-specific containers, aligns curves to common time
%   coordinates, bins event parameters, compares conditions, and exports the
%   resulting plots and summary statistics.
% Dependencies:
%   External imcart2pol, customcolormap, slanCM, and generic_codes directories
%   added in the script; additional helper functions in those directories may
%   be required. Requires a populated zp_results structure.

%% Plotting growth
%---- You need to open corresponding zp_results matrix before running the
%cell

%---- Path to the folder where you want to save figures

folder_save = '/path/to/results/blastocyst_growth/20-Oct-2025/pLperMin';

%--- Modules to download before running the code and to import
addpath('/path/to/external_tools/imcart2pol')
addpath('/path/to/external_tools/customcolormap')
addpath('/path/to/external_tools/slanCM')


% Embryo volume limits
% ylim_embryo_1 = 0;
% ylim_embryo_2 = 2000; %pL

%---- Set colors required for you conditions
% Manual color setting
colors = [0, 0, 0 ; 1 0 0]%ZPnoZP;[0,0,0; [122, 115, 209] ./ 255 ;[255, 201, 0]./ 255]%%AQP3 [0,0,0; [51, 150, 211] ./ 255];%Oubain,eipa[0,0,0; [122, 115, 209] ./ 255 ;[255, 201, 0]./ 255] [255, 201, 0]./ 255];% %AQP3 0,0.74,1 %Ouabain experiment colors, shades of brown

% Colorbar axis limits
cblim_1 = 0;
cblim_2 = 10; %pL/h

conditions = [];
index_conditions_p1 = [];
index_conditions_p2 = [];
index_conditions_p3 = [];
index_conditions_p4 = [];
uniques_conditions = [];

% Initialize variables to store interpolated y-values
x_common = linspace(-20, 50, 210);%linspace(0, 40, 240); %linspace(0, 30, 180)% %linspace(0, 30, 180) linspace(0, 30, 180); % Define common x-axis (time range) 720,360

%-- Choose binning for the analysis of growth curve parameters
binning = 2;%h %Analysis binning
bins = -20:binning:50; %Analysis range
counts_collapse_categories_condition_1 = nan(length(zp_results), length(bins)-1);
counts_collapse_categories_condition_2 = nan(length(zp_results), length(bins)-1);
counts_collapse_categories_condition_3 = nan(length(zp_results), length(bins)-1);

% To extract the time steps at the start and end of a collapse
X_minima_shifted_condition_1 = {};
X_maxima_shifted_condition_1 = {};
X_minima_shifted_condition_2 = {};
X_maxima_shifted_condition_2 = {};
X_minima_shifted_condition_3 = {};
X_maxima_shifted_condition_3 = {};

%Growth curve parameters
Influx_condition_1 = {};
Influx_condition_2 = {};
Influx_condition_3 = {};

deltaOsm_condition_1 = {};
deltaOsm_condition_2 = {};
deltaOsm_condition_3 = {};

deltaVolumeGrowth_condition_1 =  {};
deltaVolumeGrowth_condition_2 =  {};
deltaVolumeGrowth_condition_3 =  {};

deltaTGrowth_condition_1 = {};
deltaTGrowth_condition_2 = {};
deltaTGrowth_condition_3 = {};

Outflux_condition_1 = {};
Outflux_condition_2 = {};
Outflux_condition_3 = {};

deltaVolumeCollapses_condition_1 = {};
deltaVolumeCollapses_condition_2 = {};
deltaVolumeCollapses_condition_3 = {};

deltaTCollapses_condition_1 = {};
deltaTCollapses_condition_2 = {};
deltaTCollapses_condition_3 = {};

t_ZP_hatch_shifted = [];

X_ZP_minima_shifted_condition_1 = {};
X_ZP_maxima_shifted_condition_1 = {};
X_ZP_minima_shifted_condition_2 = {};
X_ZP_maxima_shifted_condition_2 = {};
X_ZP_minima_shifted_condition_3 = {};
X_ZP_maxima_shifted_condition_3 = {};

stretching_rate_condition_1 = {};
stretching_rate_condition_2 = {};
stretching_rate_condition_3 = {};

relaxation_rate_condition_1 = {};
relaxation_rate_condition_2 = {};
relaxation_rate_condition_3 = {};

hatching_duration_condition_1 = {};
hatching_duration_condition_2 = {};
hatching_duration_condition_3 = {};

% ---- Define conditions manually (or based on the data)
% condition_1 = 'NED9-KO'; % Replace with your actual condition
% condition_2 = 'AQP3-KO'; % Replace with your actual condition

% condition_1 = 'Control_DMSO'; % Replace with your actual condition
% condition_2 = 'Ouabain 500μM'; % Replace with your actual condition
% condition_3 = 'EIPA 15μM'; % Replace with your actual condition

condition_1 = 'Natural stretching ZP'; % Replace with your actual condition
condition_2 = 'Natural stretching no ZP'; % Replace with your actual condition


c1 = 0;
c2 = 0;
c3 = 0;

% Store all aligned curves for each condition
aligned_volumes_condition_1 = NaN(length(zp_results), length(x_common)); % Rows for each sample, columns for time steps
aligned_volumes_condition_2 = NaN(length(zp_results), length(x_common)); % Rows for each sample, columns for time steps
aligned_volumes_condition_3 = NaN(length(zp_results), length(x_common)); % Rows for each sample, columns for time steps      

aligned_ZP_hatching_period_condition_1 = NaN(length(zp_results), length(x_common));
aligned_ZP_hatching_period_condition_2 = NaN(length(zp_results), length(x_common));
aligned_ZP_hatching_period_condition_3 = NaN(length(zp_results), length(x_common));

aligned_ZP_thickness_condition_1 = NaN(length(zp_results), length(x_common));
aligned_ZP_thickness_condition_2 = NaN(length(zp_results), length(x_common));
aligned_ZP_thickness_condition_3 = NaN(length(zp_results), length(x_common));


tot_hatching = 0;
hatching_start_all = [];

for i_1 = 1 : size(zp_results,2) % for each sample
    hatching_start = zp_results(i_1).hatching_start;
    hatching_stop = zp_results(i_1).hatching_stop;

    if ischar(hatching_start) || isstring(hatching_start)
        hatching_start = str2double(hatching_start);
        hatching_stop = str2double(hatching_stop);
    end

    time = zp_results(i_1).time_hours; %retrieve time array
    embryo_volumes = zp_results(i_1).embryo_volumes; %retrieve embryo volume array
        
    %/!\ if you want the radius unstead of the inferred volume. To convert from volume to radius without changing variables' names.
    % embryo_volumes = (3.* embryo_volumes .* (10^3) ./ (4*pi)) .^(1/3);

    %retrieve ZP dynamics
        if isnan(hatching_start) == 0
            zp_thickness= zp_thickness(1:hatching_start); %retrieve ZP thickness before hatching
            time_zp = time(1:hatching_start); %retrieve corresponding time
            tot_hatching = tot_hatching + 1; %count how many embryos hatched in this experiment
        end
    
    embryo_volume_i = embryo_volumes(1); %retrieve initial embryo volume
    minima_time_hours = zp_results(i_1).minima_time_hours; %retrieve starts of growths
    maxima_time_hours = zp_results(i_1).maxima_time_hours; %retrieve ends of growths
    influx_slopes_pLperh = zp_results(i_1).slopes_influx_pL; % in pL/h
    influx_slopes = influx_slopes_pLperh ./ 60; %in pL/min
    
    
    % Osmotic pressure - From volume relationship
    %based on my previous work (osmotic shocks with microfluidic chip), we have the linear relationship between water transport rate and osmotic gradient applied
    embryo_intern_osm = - (influx_slopes - 139.05) ./ 0.55;
    Delta_osm = influx_slopes ./ 0.544684938254721;

    delta_volume_pL = zp_results(i).detla_volume_pL;
    delta_t_growth_h = zp_results(i).delta_t_growth_h;
    delta_t_collapses_h = zp_results(i).delta_t_collapses_h;
    slopes_outflux_pLperh = zp_results(i_1).slopes_outflux_pL; % in pL/h
    slopes_outflux = slopes_outflux_pLperh ./ 60; %in pL/min
    maxima_volumes = zp_results(i_1).maxima_volumes;
    minima_volumes = zp_results(i_1).minima_volumes;

    % /!\ Conversion to radius if needed
    % maxima_volumes = (3.* maxima_volumes .* (10^3) ./ (4*pi)) .^(1/3); %microns, radius
    % minima_volumes = (3.* minima_volumes .* (10^3) ./ (4*pi)) .^(1/3); %microns, radius
    % influx_slopes = zp_results(i_1).slopes_influx_micronsperh; %micronsperh
    % slopes_outflux = zp_results(i_1).slopes_outflux_micronsperh;%micronsperh

    % Osmotic pressure - from radius relationship
    % influx_slopes_micronperH = ((influx_slopes_pLperh.* (10^3)) .*3 ./ (4*pi) ) .^(1/3); %in microns/h
    % slopes_outflux_micronperH = ((slopes_outflux_pLperh.* (10^3)) .*3 ./ (4*pi) ) .^(1/3); %in microns/h

    % Osmotic pumping - From radius calculation (to remove the surface variation term):
    % maxima_radius_microns = (3.* maxima_volumes .* (10^3) ./ (4*pi)) .^(1/3); %microns, radius
    % minima_radius_microns = (3.* minima_volumes .* (10^3) ./ (4*pi)) .^(1/3); %microns, radius
    
    influx_slopes_micronperH = zp_results(i_1).slopes_influx_micronsperh;
    % embryo_intern_osm = - (influx_slopes_micronperH - 531.508076153438) ./ 2.194477869638676; %
    % Delta_osm = influx_slopes_micronperH ./ 2.570398410613197;

    % Delta_osm = abs(control_medium_osm - embryo_intern_osm);

    delta_volume_deflation_pL = [];
    delta_t_collapses_h = [];
    delta_volume_pL = [];
    delta_t_growth_h = [];

    for c = 1:(length(minima_volumes)-1) %retrieve collapses phases characterisation
        amplitude_collapse = maxima_volumes(c) - minima_volumes(c+1);
        duration_collapse = abs(maxima_time_hours(c) - minima_time_hours(c+1));
        delta_volume_deflation_pL = [delta_volume_deflation_pL;amplitude_collapse];
        delta_t_collapses_h = [delta_t_collapses_h;duration_collapse];
    end
    zp_results(i_1).delta_volume_deflation_pL = delta_volume_deflation_pL;
    zp_results(i_1).duration_collapse_h = delta_t_collapses_h;

    
    for c = 1:length(minima_volumes) %retrieve growth phases characterisation
        amplitude_growth =  maxima_volumes(c) - minima_volumes(c);
        duration_growth = maxima_time_hours(c) - minima_time_hours(c);
        delta_volume_pL = [delta_volume_pL;amplitude_growth];
        delta_t_growth_h = [delta_t_growth_h;duration_growth];
    end

    zp_results(i_1).delta_volume_inflation_pL = delta_volume_pL;
    zp_results(i_1).duration_inflation_h = delta_t_growth_h;

    % Recompute instantaneous growth rate
    growth_rate = zeros(1,length(embryo_volumes)) ; %initialisation matrix
    for j = 2:length(embryo_volumes)-1
        growth_rate(j) = (embryo_volumes(j+1)-embryo_volumes(j))/(time(j+1)-time(j)) ;
    end
    growth_rate(1) = growth_rate(2);
    growth_rate = growth_rate ./ 60; %to convert in pL/min

    %retrieve current condition information
    current_condition = string(zp_results(i_1).Osmlegend);
    previous_conditions_detected = size(uniques_conditions,1); %for the graph legend plotting
    conditions = [conditions; current_condition]; % gather conditions the loop is going through 
    uniques_conditions = unique(conditions, 'stable'); %filter to identify single conditions and to assign a specific color
    index_color = find(uniques_conditions == current_condition);
    
    % Lumen growth alignment
    % Alignement at 300pL
    align_y_value = 300;

    % Find the corresponding X-values where Y is closest to the align_y_value
    smallest_values = mink(abs(embryo_volumes - align_y_value), 3);
    indices = find(ismember(abs(embryo_volumes - align_y_value), smallest_values));
    [sorted_indices, order] = sort(indices);
    smallest_values_in_order = embryo_volumes(sorted_indices(1));

    x_align = time(sorted_indices(1));

    % Adjust x-data
    x_shifted = time - x_align;
    % Interpolate the aligned samples volume onto the common x-axis (x_common)
    aligned_y = interp1(x_shifted, embryo_volumes, x_common, 'linear', NaN);%'extrap');

    hatching_start_all = [hatching_start_all; (hatching_start- x_align)];
   
    % % ZP dynamics before hatching ------------------------------
    slopes_stretching_zp = zp_results(i_1).slopes_stretching_micromperh;
    maxima_time_hours_zp = zp_results(i_1).maxima_time_hours_zp;

    slopes_relaxation_zp = zp_results(i_1).slopes_relaxation_micromperh;
    minima_time_hours_zp = zp_results(i_1).minima_time_hours_zp;

    minima_shifted_zp = minima_time_hours_zp - x_align;
    maxima_shifted_zp = maxima_time_hours_zp - x_align;
    
    
    % ZP Hatching period characterisation ---------------------
    if isnan(hatching_start) == 0
        start_hatch_shifted = time(hatching_start) - x_align;
        time_zp_shift = time_zp - x_align;
        if hatching_stop < size(time,2) %for cropped movies, where the end is removed
            stop_hatch_shifted = time(hatching_stop) - x_align;
        else
            stop_hatch_shifted = time(end) - x_align;
            hatching_stop = size(time,2);
        end
    
        t_ZP_hatch_shifted = [t_ZP_hatch_shifted ; start_hatch_shifted, stop_hatch_shifted];
       

        deltaT_hatching = stop_hatch_shifted - start_hatch_shifted;

        ZP_hatching = zeros(1,size(time,2));
        ZP_hatching(hatching_start:hatching_stop) = 1;
    
        aligned_ZP_hatching = interp1(x_shifted, ZP_hatching, x_common, 'nearest', NaN);
        aligned_ZP_thickness = interp1(time_zp_shift, zp_thickness, x_common, 'nearest', NaN);
    else
        aligned_ZP_hatching = NaN(1,size(x_common,2));
        aligned_ZP_thickness = NaN(1,size(x_common,2));
    end

    % ZP theoretical volume -----
    if isnan(hatching_start) == 0
    idx = find(embryo_volumes >= align_y_value, 1); %threshold when the embryo is touching the ZP
    embryo_volumes_converted = embryo_volumes(idx:hatching_start)' ./ (10^-3);
    embryo_radius = ((3/4).*(embryo_volumes_converted./pi)).^(1/3);
    zp_thickness_beforehatch = zp_thickness(idx:hatching_start);
    zp_volume = 4.*pi/3 .*(zp_thickness_beforehatch).*((zp_thickness_beforehatch + embryo_radius).^2 .* ((zp_thickness_beforehatch + embryo_radius).*embryo_radius) .* (embryo_radius.^2));
    end

    % Embryo volume dynamics -----------------------------
    minima_shifted = minima_time_hours - x_align;
    maxima_shifted = maxima_time_hours - x_align;
    times = maxima_shifted(~isnan(maxima_shifted));  % remove NaNs
    

    % Indexing all data ------------------------------------------------
    % Store the aligned y-values based on the condition
    if current_condition == condition_1
        c1 = c1 + 1;
        aligned_volumes_condition_1(i_1,1:length(aligned_y)) = aligned_y;
        counts_collapse_categories_condition_1(i_1, :) = histcounts(times, bins);
        
        X_minima_shifted_condition_1{c1} = minima_shifted;
        deltaOsm_condition_1{c1} = Delta_osm;
        Influx_condition_1{c1} = influx_slopes';
        deltaVolumeGrowth_condition_1{c1} =  delta_volume_pL;
        deltaTGrowth_condition_1{c1} = delta_t_growth_h;
        
        X_maxima_shifted_condition_1{c1} = maxima_shifted;
        Outflux_condition_1{c1} = slopes_outflux';
        deltaVolumeCollapses_condition_1{c1} = delta_volume_deflation_pL;
        deltaTCollapses_condition_1{c1} = delta_t_collapses_h;

        aligned_ZP_hatching_period_condition_1(i_1,:) = aligned_ZP_hatching;
        aligned_ZP_thickness_condition_1(i_1,:) = aligned_ZP_thickness;
        % X_ZP_minima_shifted_condition_1{c1} = minima_shifted_zp;
        % X_ZP_maxima_shifted_condition_1{c1} = maxima_shifted_zp;
        % stretching_rate_condition_1{c1} = slopes_stretching_zp;
        % relaxation_rate_condition_1{c1} = slopes_relaxation_zp;
        % hatching_duration_condition_1{c1} = deltaT_hatching;

    elseif current_condition == condition_2
        c2 = c2 + 1;
        aligned_volumes_condition_2(i_1,1:length(aligned_y)) = aligned_y;
       counts_collapse_categories_condition_2(i_1, :) = histcounts(times, bins);

        X_minima_shifted_condition_2{c2} = minima_shifted;
        deltaOsm_condition_2{c2} = Delta_osm;
        Influx_condition_2{c2} = influx_slopes';
        deltaVolumeGrowth_condition_2{c2} =  delta_volume_pL;
        deltaTGrowth_condition_2{c2} = delta_t_growth_h;
        
        X_maxima_shifted_condition_2{c2} = maxima_shifted;
        Outflux_condition_2{c2} = slopes_outflux';
        deltaVolumeCollapses_condition_2{c2} = delta_volume_deflation_pL;
        deltaTCollapses_condition_2{c2} = delta_t_collapses_h;

        aligned_ZP_hatching_period_condition_2(i_1,:) = aligned_ZP_hatching;
        aligned_ZP_thickness_condition_2(i_1,:) = aligned_ZP_thickness;
        % X_ZP_minima_shifted_condition_2{c2} = minima_shifted_zp;
        % X_ZP_maxima_shifted_condition_2{c2} = maxima_shifted_zp;
        % stretching_rate_condition_2{c2} = slopes_stretching_zp;
        % relaxation_rate_condition_2{c2} = slopes_relaxation_zp;
        % hatching_duration_condition_2{c2} = deltaT_hatching;

       elseif current_condition == condition_3
        c3 = c3 + 1;
        aligned_volumes_condition_3(i_1, 1:length(aligned_y)) = aligned_y;
        counts_collapse_categories_condition_3(i_1, :) = histcounts(times, bins);

        X_minima_shifted_condition_3{c3} = minima_shifted;
        deltaOsm_condition_3{c3} = Delta_osm;
        Influx_condition_3{c3} = influx_slopes';
        deltaVolumeGrowth_condition_3{c3} =  delta_volume_pL;
        deltaTGrowth_condition_3{c3} = delta_t_growth_h;
        
        X_maxima_shifted_condition_3{c3} = maxima_shifted;
        Outflux_condition_3{c3} = slopes_outflux';
        deltaVolumeCollapses_condition_3{c3} = delta_volume_deflation_pL;
        deltaTCollapses_condition_3{c3} = delta_t_collapses_h;

        aligned_ZP_hatching_period_condition_3(i_1,:) = aligned_ZP_hatching;
        aligned_ZP_thickness_condition_3(i_1,:) = aligned_ZP_thickness;
        % X_ZP_minima_shifted_condition_2{c3} = minima_shifted_zp;
        % X_ZP_maxima_shifted_condition_2{c3} = maxima_shifted_zp;
        % stretching_rate_condition_2{c3} = slopes_stretching_zp;
        % relaxation_rate_condition_2{c3} = slopes_relaxation_zp;
        % hatching_duration_condition_2{c3} = deltaT_hatching;
    end

 end 

%% Saving aligned curves
save(fullfile(folder_save,['aligned_y_' condition_1 '.mat']),'aligned_volumes_condition_1','-mat')
save(fullfile(folder_save,['aligned_y_' condition_2 '.mat']),'aligned_volumes_condition_2','-mat')
save(fullfile(folder_save,'aligned_common_x.mat'),'x_common','-mat')
writematrix(aligned_volumes_condition_1, fullfile(folder_save,['aligned_embryos_volumes_' strrep(condition_1, ' ', '') '.csv']));
writematrix(aligned_volumes_condition_2, fullfile(folder_save,['aligned_embryos_volumes_' strrep(condition_2, ' ', '') '.csv']));
writematrix(x_common, fullfile(folder_save,'aligned_common_x.csv'));

disp('saved')

%% Plotting average behavior - Initiate gradient background highlighting ZP hatching dynamics
% Sample data - Here only embryos with ZP

backgroundVal = sum(round(aligned_ZP_hatching_period_condition_1),1,'omitnan') * 100 ./ tot_hatching;         % Background variable (for gradient)

% Create figure and axes
figure;
hold on;
y_limits = [0, 2000]; % y-axis limits
imagesc(x_common, y_limits, repmat(backgroundVal, 2, 1)); % 2-row image stretched vertically

% Set colormap
caxis([min(backgroundVal), max(backgroundVal)]);
mycolormap = customcolormap([0 0.2 0.4 0.6 0.8 1],{'#bdb2ff', '#ffadad', '#ffd6a5','#fdffb6','#caffbf','#cdecff'});
colormap(mycolormap);      

% Adjust axes
set(gca, 'YDir', 'normal'); % Reset YDir (imagesc inverts it)
ylim(y_limits);
xlabel('x');
ylabel('y');

%% Plotting average behavior - Mean and std from aligned curves 
% ///////// Embryo volume
% Compute the mean and standard deviation for each condition
mean_volume_condition_1 = nanmean(aligned_volumes_condition_1, 1);
std_volume_condition_1 = nanstd(aligned_volumes_condition_1, 0, 1);
sem_volume_condition_1 = std_volume_condition_1 / sqrt(size(aligned_volumes_condition_1, 1)); % SEM

mean_volume_condition_2 = nanmean(aligned_volumes_condition_2, 1);
std_volume_condition_2 = nanstd(aligned_volumes_condition_2, 0, 1);
sem_volume_condition_2 = std_volume_condition_2 / sqrt(size(aligned_volumes_condition_2, 1)); % SEM

% uncomment if required
% mean_volume_condition_3 = nanmean(aligned_volumes_condition_3, 1);
% std_volume_condition_3 = nanstd(aligned_volumes_condition_3, 0, 1);
% sem_volume_condition_3 = std_volume_condition_3 / sqrt(size(aligned_volumes_condition_3, 1)); % SEM

lgd = findobj(gcf, 'Type', 'Legend');
% Plot the mean curves with error bars for both conditions
f14 = figure(1); % Post-loop processing
hold on;

% Plot Condition 1
errorbar(x_common(:), mean_volume_condition_1(:), sem_volume_condition_1(:), 'Color', [colors(1, :)], 'LineWidth', 0.6,'DisplayName','');
h1 = plot(x_common(:), mean_volume_condition_1(:),'Color', [colors(1, :)],'LineWidth', 3, 'DisplayName', 'Control DMSO', 'LineStyle', '-')
% % Plot Condition 2
errorbar(x_common(:), mean_volume_condition_2(:), sem_volume_condition_2(:), 'Color', [colors(2, :)], 'LineWidth', 0.6,'DisplayName','');
h2 = plot(x_common(:), mean_volume_condition_2(:),'Color', [colors(2, :)],'LineWidth', 3, 'DisplayName', condition_2)
% % Plot Condition 3
% errorbar(x_common(:), mean_volume_condition_3(:), sem_volume_condition_3(:), 'Color', [colors(3, :)], 'LineWidth', 0.6,'DisplayName','');
% h3 = plot(x_common(:), mean_volume_condition_3(:),'Color', [colors(3, :)],'LineWidth', 3, 'DisplayName', condition_3)

% Customize the plot
xlabel('Time after reaching 300 pL (h)');
ylabel('Embryo volume (pL)');%('Embryo radius (μm)') %

% ////// ZP - % uncomment if required
% % Compute the mean and standard deviation for each condition
% mean_ZP_condition_1 = nanmean(aligned_ZP_thickness_condition_1, 1);
% std_ZP_condition_1 = nanstd(aligned_ZP_thickness_condition_1, 0, 1);
% sem_ZP_condition_1 = std_ZP_condition_1 / sqrt(size(aligned_ZP_thickness_condition_1, 1)); % SEM

% % Plot the mean curves with error bars for both conditions
% hold on;
% yyaxis right
% Plot Condition 1
% ti = 100; %% n > 5
% t_hatched = 193; %% n < 50%
% errorbar(x_common(ti:t_hatched), mean_ZP_condition_1(ti:t_hatched), sem_ZP_condition_1(ti:t_hatched), 'Color', '#219B9D', 'LineWidth', 0.6, 'DisplayName', condition_1);
% plot(x_common(ti:t_hatched), mean_ZP_condition_1(ti:t_hatched),'Color', '#219B9D','LineWidth', 3, 'DisplayName', 'Mean', 'LineStyle', '-')


% ylim([0 10])
% hYLabel = ylabel('Zona pellucida thickness (μm)');
% ax = gca;
% ax.YAxis(2).Color = 'k';
% hYLabel.Color = '#219B9D';
% hold off;

% ax = gca;              % Get current axes
% ax.XTickMode = 'auto'; % Restore x-ticks if removed
% ax.YTickMode = 'auto'; % Restore y-ticks if removed
% ax.TickDir = 'out';     % Tick direction: 'in', 'out', or 'both'
% 
% cb = colorbar('location','northoutside')%, 'FontSize', 14);
% ylabel(cb, 'Embryos undergoing hatching (%)')% Optional: show scale
% % cb.Ticks = [min(backgroundVal):1:max(backgroundVal)];
% cb.FontSize = 14;

% savefig(f14,fullfile(folder_save,'all_aligned_embryo_volumes_mean_std.fig'))
% exportgraphics(f14,fullfile(folder_save,'all_aligned_embryo_mean.png'), 'Resolution',300)

%% Mann-Whitney test 
nTimepoints = numel(x_common);
pvals_MW = nan(1,nTimepoints);
pvals_tTest = nan(1,nTimepoints);

for i = 1:nTimepoints
    y1 = aligned_volumes_condition_1(:,i); y2 = aligned_volumes_condition_3(:,i);
    y1 = y1(~isnan(y1)); y2 = y2(~isnan(y2));

        if isempty(y1) && isempty(y2)
            pvals_MW(i) = NaN;  % impossible de tester
            pvals_tTest(i) = NaN;
        elseif isempty(y1) || isempty(y2)
            pvals_MW(i) = NaN;  % pas assez de données pour test
            pvals_tTest(i) = NaN;
        else
            pvals_MW(i) = ranksum(y1, y2);  % test de Mann-Whitney (indépendant)
            [~,p] = ttest2(y1, y2);
            pvals_tTest(i) = p;
        end
end

figure
hold on
plot(x_common, pvals_tTest, 'b-o')
plot(x_common, pvals_MW, 'r-o')
yline(0.05)
xlim([0 15])

%% Check Sample size
aligned_volumes_condition_1_norm = nan(size(aligned_volumes_condition_1));
aligned_volumes_condition_2_norm = nan(size(aligned_volumes_condition_2));
normalize_first = @(row) row ./ row(find(~isnan(row),1,'first'));

for i = 1:size(aligned_volumes_condition_1,1)
    if any(~isnan(aligned_volumes_condition_1(i,:)))
        aligned_volumes_condition_1_norm(i,:) = normalize_first(aligned_volumes_condition_1(i,:));
    end
end

for i = 1:size(aligned_volumes_condition_2,1)
    if any(~isnan(aligned_volumes_condition_2(i,:)))
        aligned_volumes_condition_2_norm(i,:) = normalize_first(aligned_volumes_condition_2(i,:));
    end
end


nb_embryos_overtime_condition_1 = sum(~isnan(aligned_volumes_condition_1_norm), 1);
nb_embryos_overtime_condition_2 = sum(~isnan(aligned_volumes_condition_2_norm), 1);
nb_embryos_overtime_condition_3 = sum(~isnan(aligned_volumes_condition_3), 1);

f = figure
hold on
plot(x_common, nb_embryos_overtime_condition_1, 'LineWidth', 2, 'Color','k','DisplayName','Control')
plot(x_common, nb_embryos_overtime_condition_2, 'LineWidth', 2, 'Color',colors(2,:),'DisplayName','AQP3-KO')
plot(x_common, nb_embryos_overtime_condition_3, 'LineWidth', 2, 'Color',colors(3,:),'DisplayName','EIPA')

xlabel('Time (h)')
ylabel('Sample size')
legend()
fontsize(18, 'points');

hatching_embryonumber_dynamics = sum(aligned_ZP_hatching_period_condition_1, 1,'omitnan');
savefig(f,fullfile(folder_save,'sample_size.fig'))
exportgraphics(f,fullfile(folder_save,'sample_size.png'), 'Resolution',300)

%% Plot ZP vs embryo volume
S = zp_results;
result_zp_thickness_beforehatch = [];
result_embryo_volumes_beforehatch = [];
for i = 1:numel(S)
    idx = S(i).hatching_start;

    if isnumeric(idx)
    valid = ~isnan(idx);
    elseif ischar(idx) || isstring(idx)
        valid = ~strcmp(string(idx), "NaN");
    end

    if valid
        result_zp_thickness_beforehatch = [result_zp_thickness_beforehatch, S(i).zp_median_thickness(1:idx)];
        result_embryo_volumes_beforehatch = [result_embryo_volumes_beforehatch; S(i).embryo_volumes(1:idx)];

        
    end
end

% if conversion to radius
% result_embryo_volumes_beforehatch = (3 .* result_embryo_volumes_beforehatch .* 1000 ./ (4 .* pi)).^(1/3);

[R2_zp_th_volumeemb, pval_zp_th_volumeemb] = corrcoef(result_embryo_volumes_beforehatch, result_zp_thickness_beforehatch')

fZP = figure
scatter(result_embryo_volumes_beforehatch,result_zp_thickness_beforehatch','k','filled','MarkerFaceAlpha',0.3,'MarkerEdgeColor','w','LineWidth',0.3)
xlabel('Embryo volume (pL)')
ylabel('Zona pelludica thickness (µm)')
fontsize(21, 'points');
ylim([0,10])

%adding correlation to the graph
hold on

p = polyfit(result_embryo_volumes_beforehatch, result_zp_thickness_beforehatch', 1);
xfit = [min(result_embryo_volumes_beforehatch) max(result_embryo_volumes_beforehatch)];
yfit = polyval(p, xfit);

plot(xfit, yfit, 'k-', 'LineWidth', 2)

savefig(fZP,fullfile(folder_save,date,'ZP_volume_versus_embryo_volume.fig'))
exportgraphics(fZP,fullfile(folder_save,date,'ZP_volume_versus_embryo_volume.png'), 'Resolution',300)
save(fullfile(folder_save,date,'pval_ZP_volume_versus_embryo_volume.mat'),'pval_zp_th_volumeemb', '-mat')
save(fullfile(folder_save,date,'R2_ZP_volume_versus_embryo_volume.mat'),'R2_zp_th_volumeemb', '-mat')


%% Plotting binned parameters from growth and collapse phases
%% 1) Binning
binning = 2; %h
bins = -20:binning:50;%0:binning:40%-70:binning:70;
% 1. Define bin edges (common for all)
bin_centers = (bins(1:end-1) + bins(2:end))/2;

% 2. Prepare accumulator
binned_influx_condition_1 = cell(1, length(bin_centers));
binned_deltaOsm_condition_1 = cell(1, length(bin_centers));
binned_deltaVolumeGrowth_condition_1 = cell(1, length(bin_centers));
binned_deltaTGrowth_condition_1 = cell(1, length(bin_centers));

binned_Outflux_condition_1 = cell(1, length(bin_centers));
binned_deltaVolumeCollapses_condition_1 = cell(1, length(bin_centers));
binned_deltaTCollapses_condition_1 = cell(1, length(bin_centers));

n_curves_condition_1 = numel(X_minima_shifted_condition_1);
curve_contributions_condition_1 = zeros(n_curves_condition_1, length(bin_centers));  % Rows = curves, Cols = bins


% 3. Loop over curves and collect y values per bin
for i_1 = 1:numel(X_minima_shifted_condition_1)
    xi_min = X_minima_shifted_condition_1{i_1};

    influx_i = Influx_condition_1{i_1}';

    deltaOsm_i = deltaOsm_condition_1{i_1};
    deltaVolumeGrowth_i = deltaVolumeGrowth_condition_1{i_1};
    deltaTGrowth_i = deltaTGrowth_condition_1{i_1};

    % Assign each x to a bin
    bin_idx_min = discretize(xi_min, bins);

    % For each bin, add y to that bin - minima shifted
    for j = 1:length(bin_centers)
        mask = bin_idx_min == j;
        if any(mask)
            binned_influx_condition_1{j} = [binned_influx_condition_1{j}; influx_i(mask)];
            binned_deltaOsm_condition_1{j} = [binned_deltaOsm_condition_1{j}; deltaOsm_i(mask)'];
            binned_deltaVolumeGrowth_condition_1{j} = [binned_deltaVolumeGrowth_condition_1{j};deltaVolumeGrowth_i(mask)];
            binned_deltaTGrowth_condition_1{j} = [binned_deltaTGrowth_condition_1{j}; deltaTGrowth_i(mask)];
        
            % Add to contribution matrix
            curve_contributions_condition_1(i_1, j) = sum(mask);
        end
    end

    xi_max = X_maxima_shifted_condition_1{i_1};
    remove_last_max = xi_max(1:end-1); %last collapse is not taken into account
    Outflux_i = Outflux_condition_1{i_1}';
    deltaVolumeCollapses_i = deltaVolumeCollapses_condition_1{i_1};
    deltaTCollapses_i = deltaTCollapses_condition_1{i_1};

    bin_idx_max = discretize(remove_last_max, bins);

    for k = 1:length(bin_centers)
        mask_2 = bin_idx_max == k;
        if any(mask_2)
            binned_Outflux_condition_1{k} = [binned_Outflux_condition_1{k};Outflux_i(mask_2)];
            binned_deltaVolumeCollapses_condition_1{k} = [binned_deltaVolumeCollapses_condition_1{k};deltaVolumeCollapses_i(mask_2)];
            binned_deltaTCollapses_condition_1{k} = [binned_deltaTCollapses_condition_1{k}; deltaTCollapses_i(mask_2)];
        end
    end

end

binned_influx_condition_2 = cell(1, length(bin_centers));
binned_deltaOsm_condition_2 = cell(1, length(bin_centers));
binned_deltaVolumeGrowth_condition_2 = cell(1, length(bin_centers));
binned_deltaTGrowth_condition_2 = cell(1, length(bin_centers));

binned_Outflux_condition_2 = cell(1, length(bin_centers));
binned_deltaVolumeCollapses_condition_2 = cell(1, length(bin_centers));
binned_deltaTCollapses_condition_2 = cell(1, length(bin_centers));

n_curves_condition_2 = numel(X_minima_shifted_condition_2);
curve_contributions_condition_2 = zeros(n_curves_condition_2, length(bin_centers));  % Rows = curves, Cols = bins


% 3. Loop over curves and collect y values per bin
for i_2 = 1:numel(X_minima_shifted_condition_2)
    xi_min = X_minima_shifted_condition_2{i_2};
    xi_max = X_maxima_shifted_condition_2{i_2};

    influx_i = Influx_condition_2{i_2}';
    deltaOsm_i = deltaOsm_condition_2{i_2};

    deltaVolumeGrowth_i = deltaVolumeGrowth_condition_2{i_2};
    deltaTGrowth_i = deltaTGrowth_condition_2{i_2};
    Outflux_i = Outflux_condition_2{i_2}';
    deltaVolumeCollapses_i = deltaVolumeCollapses_condition_2{i_2};
    deltaTCollapses_i = deltaTCollapses_condition_2{i_2};

    % Assign each x to a bin
    bin_idx_min = discretize(xi_min, bins);
    remove_last_max = xi_max(1:end-1); %last collapse is not taken into account
    bin_idx_max = discretize(remove_last_max, bins);

    % For each bin, add y to that bin
    for j = 1:length(bin_centers)
        mask = bin_idx_min == j;
        if any(mask)
            binned_influx_condition_2{j} = [binned_influx_condition_2{j}; influx_i(mask)];
            binned_deltaOsm_condition_2{j} = [binned_deltaOsm_condition_2{j}; deltaOsm_i(mask)'];
            binned_deltaVolumeGrowth_condition_2{j} = [binned_deltaVolumeGrowth_condition_2{j};deltaVolumeGrowth_i(mask)];
            binned_deltaTGrowth_condition_2{j} = [binned_deltaTGrowth_condition_2{j}; deltaTGrowth_i(mask)];

            % Add to contribution matrix
            curve_contributions_condition_2(i_2, j) = sum(mask);
        end
    end

     % For each   bin, add y to that bin - maxima shifted
    for k = 1:length(bin_centers)
        mask = bin_idx_max == k;
        if any(mask)
            binned_Outflux_condition_2{k} = [binned_Outflux_condition_2{k};Outflux_i(mask)];
            binned_deltaVolumeCollapses_condition_2{k} = [binned_deltaVolumeCollapses_condition_2{k};deltaVolumeCollapses_i(mask)];
            binned_deltaTCollapses_condition_2{k} = [binned_deltaTCollapses_condition_2{k}; deltaTCollapses_i(mask)];
        end
    end
end

binned_influx_condition_3 = cell(1, length(bin_centers));
binned_deltaOsm_condition_3 = cell(1, length(bin_centers));
binned_deltaVolumeGrowth_condition_3 = cell(1, length(bin_centers));
binned_deltaTGrowth_condition_3 = cell(1, length(bin_centers));

binned_Outflux_condition_3 = cell(1, length(bin_centers));
binned_deltaVolumeCollapses_condition_3 = cell(1, length(bin_centers));
binned_deltaTCollapses_condition_3 = cell(1, length(bin_centers));

n_curves_condition_3 = numel(X_minima_shifted_condition_3);
curve_contributions_condition_3 = zeros(n_curves_condition_3, length(bin_centers));  % Rows = curves, Cols = bins


% 3. Loop over curves and collect y values per bin
for i_3 = 1:numel(X_minima_shifted_condition_3)
    xi_min = X_minima_shifted_condition_3{i_3};
    xi_max = X_maxima_shifted_condition_3{i_3};

    influx_i = Influx_condition_3{i_3}';
    deltaOsm_i = deltaOsm_condition_3{i_3};

    deltaVolumeGrowth_i = deltaVolumeGrowth_condition_3{i_3};
    deltaTGrowth_i = deltaTGrowth_condition_3{i_3};
    Outflux_i = Outflux_condition_3{i_3}';
    deltaVolumeCollapses_i = deltaVolumeCollapses_condition_3{i_3};
    deltaTCollapses_i = deltaTCollapses_condition_3{i_3};

    % Assign each x to a bin
    bin_idx_min = discretize(xi_min, bins);
    remove_last_max = xi_max(1:end-1); %last collapse is not taken into account
    bin_idx_max = discretize(remove_last_max, bins);

    % For each bin, add y to that bin
    for j = 1:length(bin_centers)
        mask = bin_idx_min == j;
        if any(mask)
            binned_influx_condition_3{j} = [binned_influx_condition_3{j}; influx_i(mask)];
            binned_deltaOsm_condition_3{j} = [binned_deltaOsm_condition_3{j}; deltaOsm_i(mask)'];
            binned_deltaVolumeGrowth_condition_3{j} = [binned_deltaVolumeGrowth_condition_3{j};deltaVolumeGrowth_i(mask)];
            binned_deltaTGrowth_condition_3{j} = [binned_deltaTGrowth_condition_3{j}; deltaTGrowth_i(mask)];

            % Add to contribution matrix
            curve_contributions_condition_3(i_3, j) = sum(mask);
        end
    end

     % For each bin, add y to that bin - maxima shifted
    for k = 1:length(bin_centers)
        mask = bin_idx_max == k;
        if any(mask)
            binned_Outflux_condition_3{k} = [binned_Outflux_condition_3{k};Outflux_i(mask)];
            binned_deltaVolumeCollapses_condition_3{k} = [binned_deltaVolumeCollapses_condition_3{k};deltaVolumeCollapses_i(mask)];
            binned_deltaTCollapses_condition_3{k} = [binned_deltaTCollapses_condition_3{k}; deltaTCollapses_i(mask)];
        end
    end
end
disp('OK')
disp('OK')
%% 2) Plotting
% Compute mean per bin
% INFLUX -----------------------------------------------------
mean_binned_influx_condition_1 = cellfun(@(v) mean(v), binned_influx_condition_1);
n_c1   = cellfun(@numel, binned_influx_condition_1);
SEM_c1 = cellfun(@(v) std(v), binned_influx_condition_1)./ sqrt(n_c1);

mean_binned_influx_condition_2 = cellfun(@(v) mean(v), binned_influx_condition_2);
n_c2   = cellfun(@numel, binned_influx_condition_2);
SEM_c2 = cellfun(@(v) std(v), binned_influx_condition_2)./ sqrt(n_c2);
% 
% mean_binned_influx_condition_3 = cellfun(@(v) mean(v), binned_influx_condition_3);
% n_c3   = cellfun(@numel, binned_influx_condition_3);
% SEM_c3 = cellfun(@(v) std(v), binned_influx_condition_3)./ sqrt(n_c3);

% INFLUX PLOT
% Plot the mean curves with error bars for both conditions
f22 = figure(1) % Post-loop processing
hold on;
% Plot Condition 1
errorbar(bin_centers(:), mean_binned_influx_condition_1(:), SEM_c1(:), 'Color', [colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_influx_condition_1(:),'-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 2
errorbar(bin_centers(:), mean_binned_influx_condition_2(:), SEM_c2(:), 'Color', [colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_influx_condition_2(:),'-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 3
% errorbar(bin_centers, mean_binned_influx_condition_3, SEM_c2, 'Color', [colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_binned_influx_condition_3,'-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Customize the plot

xlabel('Time after reaching 300 pL (h)');
ylabel('Uninterrupted influx (pL/min)');

fontsize(18, 'points');
xlim([0 50])
ylim([0 5]) %limits for pL/min

hold off;
savefig(f22,fullfile(folder_save,date,'binned2h_embryo_influx_mean_SEM.fig'))
exportgraphics(f22,fullfile(folder_save,date,'binned2h_influx_mean_SEM.png'), 'Resolution',300)

% OSMOTIC PUMPING ------------------------------------------------------------

mean_binned_deltaOsm_condition_1 = cellfun(@(v) mean(v), binned_deltaOsm_condition_1);
n_c1   = cellfun(@numel, binned_deltaOsm_condition_1);
SEM_c1 = cellfun(@(v) std(v), binned_deltaOsm_condition_1)./ sqrt(n_c1);

mean_binned_deltaOsm_condition_2 = cellfun(@(v) mean(v), binned_deltaOsm_condition_2);
n_c2   = cellfun(@numel, binned_deltaOsm_condition_2);
SEM_c2 = cellfun(@(v) std(v), binned_deltaOsm_condition_2)./ sqrt(n_c2);

% mean_binned_deltaOsm_condition_3 = cellfun(@(v) mean(v), binned_deltaOsm_condition_3);
% n_c3   = cellfun(@numel, binned_deltaOsm_condition_3);
% SEM_c3 = cellfun(@(v) std(v), binned_deltaOsm_condition_3)./ sqrt(n_c3);

% PUMPING PLOT
% Plot the mean curves with error bars for both conditions
f23 = figure(5); % Post-loop processing
hold on;
% Plot Condition 1
errorbar(bin_centers(:), mean_binned_deltaOsm_condition_1(:), SEM_c1(:), 'Color', [colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaOsm_condition_1(:),'-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 2
errorbar(bin_centers(:), mean_binned_deltaOsm_condition_2(:), SEM_c2(:), 'Color', [colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaOsm_condition_2(:),'-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 3
% errorbar(bin_centers, mean_binned_deltaOsm_condition_3, SEM_c3, 'Color', [colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_binned_deltaOsm_condition_3,'-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Customize the plot
% xlabel('Time after E3.5 (h)');
xlabel('Time after reaching 300 pL (h)');
ylabel('Osmotic gradient (ΔmOsm)');

fontsize(18, 'points');
xlim([0 50])
ylim([0 2])
hold off;

savefig(f23,fullfile(folder_save,date,'binned2h_embryo_osmpumping_mean_SEM_fromRadius.fig'))
exportgraphics(f23,fullfile(folder_save,date,'binned2h_osmpumping_mean_SEM_fromRadius.png'), 'Resolution',300)

% Delta volume Growth ------------------------------------------------------------
mean_binned_deltaVolumeGrowth_condition_1 = cellfun(@(v) mean(v), binned_deltaVolumeGrowth_condition_1);
n_c1   = cellfun(@numel, binned_deltaVolumeGrowth_condition_1);
SEM_c1 = cellfun(@(v) std(v), binned_deltaVolumeGrowth_condition_1)./ sqrt(n_c1);

mean_binned_deltaVolumeGrowth_condition_2 = cellfun(@(v) mean(v), binned_deltaVolumeGrowth_condition_2);
n_c2   = cellfun(@numel, binned_deltaVolumeGrowth_condition_2);
SEM_c2 = cellfun(@(v) std(v), binned_deltaVolumeGrowth_condition_2)./ sqrt(n_c2);

% mean_binned_deltaVolumeGrowth_condition_3 = cellfun(@(v) mean(v), binned_deltaVolumeGrowth_condition_3);
% n_c3   = cellfun(@numel, binned_deltaVolumeGrowth_condition_3);
% SEM_c3 = cellfun(@(v) std(v), binned_deltaVolumeGrowth_condition_3)./ sqrt(n_c3);

% Delta volume Growth PLOT
% Plot the mean curves with error bars for both conditions
f24 = figure(3); % Post-loop processing
hold on;
% Plot Condition 1
errorbar(bin_centers(:), mean_binned_deltaVolumeGrowth_condition_1(:), SEM_c1(:), 'Color', [colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaVolumeGrowth_condition_1(:),'-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 2
errorbar(bin_centers(:), mean_binned_deltaVolumeGrowth_condition_2(:), SEM_c2(:), 'Color', [colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaVolumeGrowth_condition_2(:),'-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 3
% errorbar(bin_centers, mean_binned_deltaVolumeGrowth_condition_3, SEM_c2, 'Color', [colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_binned_deltaVolumeGrowth_condition_3,'-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Customize the plot
xlabel('Time after reaching 300 pL (h)');
ylabel('Volume gain between collapses (pL)');
% ylabel('Radius gain between collapses (μm)');

fontsize(18, 'points');
xlim([0 50])
ylim([0 800]) %limits for pL/min
% ylim([0 16]) %limits for microns/min
hold off;
savefig(f24,fullfile(folder_save,date,'binned2h_embryo_deltaV_growth_mean_SEM.fig'))
exportgraphics(f24,fullfile(folder_save,date,'binned2h_deltaV_growth_mean_SEM.png'), 'Resolution',300)

% Delta t Growth ------------------------------------------------------------
mean_binned_deltaTGrowth_condition_1 = cellfun(@(v) mean(v), binned_deltaTGrowth_condition_1);
n_c1   = cellfun(@numel, binned_deltaTGrowth_condition_1);
SEM_c1 = cellfun(@(v) std(v), binned_deltaTGrowth_condition_1)./ sqrt(n_c1);

mean_binned_deltaTGrowth_condition_2 = cellfun(@(v) mean(v), binned_deltaTGrowth_condition_2);
n_c2   = cellfun(@numel, binned_deltaTGrowth_condition_2);
SEM_c2 = cellfun(@(v) std(v), binned_deltaTGrowth_condition_2)./ sqrt(n_c2);

% mean_binned_deltaTGrowth_condition_3 = cellfun(@(v) mean(v), binned_deltaTGrowth_condition_3);
% n_c3   = cellfun(@numel, binned_deltaTGrowth_condition_3);
% SEM_c3 = cellfun(@(v) std(v), binned_deltaTGrowth_condition_3)./ sqrt(n_c3);

% Delta t Growth PLOT
% Plot the mean curves with error bars for both conditions
f25 = figure(6); % Post-loop processing
hold on;
% Plot Condition 1
errorbar(bin_centers(:), mean_binned_deltaTGrowth_condition_1(:), SEM_c1(:), 'Color', [colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaTGrowth_condition_1(:),'-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 2
errorbar(bin_centers(:), mean_binned_deltaTGrowth_condition_2(:), SEM_c2(:), 'Color', [colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaTGrowth_condition_2(:),'-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 3
% errorbar(bin_centers, mean_binned_deltaTGrowth_condition_3, SEM_c3, 'Color', [colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_binned_deltaTGrowth_condition_3,'-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Customize the plot
% xlabel('Time after E3.5 (h)');
xlabel('Time after reaching 300 pL (h)');
ylabel('Interval between collapses (h)');
fontsize(18, 'points');
xlim([0 50])
ylim([0 8])
hold off;
savefig(f25,fullfile(folder_save,date,'binned2h_embryo_deltaT_growth_mean_SEM.fig'))
exportgraphics(f25,fullfile(folder_save,date,'binned2h_deltaT_growth_mean_SEM.png'), 'Resolution',300)

% Outflux ------------------------------------------------------------
mean_binned_Outflux_condition_1 = cellfun(@(v) mean(v), cellfun(@(x) abs(x), binned_Outflux_condition_1, 'UniformOutput', false));
n_c1   = cellfun(@numel, binned_Outflux_condition_1);
SEM_c1 = cellfun(@(v) std(v), cellfun(@(x) abs(x), binned_Outflux_condition_1, 'UniformOutput', false))./ sqrt(n_c1);

mean_binned_Outflux_condition_2 = cellfun(@(v) mean(v), cellfun(@(x) abs(x), binned_Outflux_condition_2, 'UniformOutput', false));
n_c2   = cellfun(@numel, binned_Outflux_condition_2);
SEM_c2 = cellfun(@(v) std(v), cellfun(@(x) abs(x), binned_Outflux_condition_2, 'UniformOutput', false))./ sqrt(n_c2);

% mean_binned_Outflux_condition_3 = cellfun(@(v) mean(v), cellfun(@(x) abs(x), binned_Outflux_condition_3, 'UniformOutput', false));
% n_c3   = cellfun(@numel, binned_Outflux_condition_3);
% SEM_c3 = cellfun(@(v) std(v), cellfun(@(x) abs(x), binned_Outflux_condition_3, 'UniformOutput', false))./ sqrt(n_c3);


% Outflux PLOT
% Plot the mean curves with error bars for both conditions
f26 = figure(2); % Post-loop processing
hold on;
% Plot Condition 1
errorbar(bin_centers(:), mean_binned_Outflux_condition_1(:), SEM_c1(:), 'Color', [colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_Outflux_condition_1(:),'-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 2
errorbar(bin_centers(:), mean_binned_Outflux_condition_2(:), SEM_c2(:), 'Color', [colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_Outflux_condition_2(:),'-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 3
% errorbar(bin_centers, mean_binned_Outflux_condition_3, SEM_c3, 'Color', [colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_binned_Outflux_condition_3,'-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Customize the plot
xlabel('Time after reaching 300 pL (h)');
ylabel('Leakage (pL/min)');
fontsize(18, 'points');
xlim([0 50])
ylim([0 30]) %limits for pL/min
% ylim([0 15]) %limits for microns/min
hold off;
savefig(f26,fullfile(folder_save,date,'binned2h_embryo_Outflux_mean_SEM.fig'))
exportgraphics(f26,fullfile(folder_save,date,'binned2h_Outflux_mean_SEM.png'), 'Resolution',300)

% Delta Volume Collapse ------------------------------------------------------------
mean_binned_deltaVolumeCollapses_condition_1 = cellfun(@(v) mean(v), binned_deltaVolumeCollapses_condition_1);
n_c1   = cellfun(@numel, binned_deltaVolumeCollapses_condition_1);
SEM_c1 = cellfun(@(v) std(v), binned_deltaVolumeCollapses_condition_1)./ sqrt(n_c1);

mean_binned_deltaVolumeCollapses_condition_2 = cellfun(@(v) mean(v), binned_deltaVolumeCollapses_condition_2);
n_c2   = cellfun(@numel, binned_deltaVolumeCollapses_condition_2);
SEM_c2 = cellfun(@(v) std(v), binned_deltaVolumeCollapses_condition_2)./ sqrt(n_c2);

% mean_binned_deltaVolumeCollapses_condition_3 = cellfun(@(v) mean(v), binned_deltaVolumeCollapses_condition_3);
% n_c3   = cellfun(@numel, binned_deltaVolumeCollapses_condition_3);
% SEM_c3 = cellfun(@(v) std(v), binned_deltaVolumeCollapses_condition_3)./ sqrt(n_c3);

% Delta Volume Collapse PLOT
% Plot the mean curves with error bars for both conditions
f27 = figure(4); % Post-loop processing
hold on;
% Plot Condition 1
errorbar(bin_centers(:), mean_binned_deltaVolumeCollapses_condition_1(:), SEM_c1(:), 'Color', [colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaVolumeCollapses_condition_1(:),'-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 2
errorbar(bin_centers(:), mean_binned_deltaVolumeCollapses_condition_2(:), SEM_c2(:), 'Color', [colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaVolumeCollapses_condition_2(:),'-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 3
% errorbar(bin_centers, mean_binned_deltaVolumeCollapses_condition_3, SEM_c3, 'Color', [colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_binned_deltaVolumeCollapses_condition_3,'-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Customize the plot
xlabel('Time after reaching 300 pL (h)');
ylabel('Volume loss during collapse (pL)');
fontsize(18, 'points');
xlim([0 50])
ylim([0 600]) %limits for pL/min
hold off;
savefig(f27,fullfile(folder_save,date,'binned2h_embryo_deltaV_collapse_mean_SEM.fig'))
exportgraphics(f27,fullfile(folder_save,date,'binned2h_deltaV_collapse_mean_SEM.png'), 'Resolution',300)

% Delta t Collapse ------------------------------------------------------------
mean_binned_deltaTCollapses_condition_1 = cellfun(@(v) mean(v), binned_deltaTCollapses_condition_1);
n_c1   = cellfun(@numel, binned_deltaTCollapses_condition_1);
SEM_c1 = cellfun(@(v) std(v), binned_deltaTCollapses_condition_1)./ sqrt(n_c1);

mean_binned_deltaTCollapses_condition_2 = cellfun(@(v) mean(v), binned_deltaTCollapses_condition_2);
n_c2   = cellfun(@numel, binned_deltaTCollapses_condition_2);
SEM_c2 = cellfun(@(v) std(v), binned_deltaTCollapses_condition_2)./ sqrt(n_c2);

% mean_binned_deltaTCollapses_condition_3 = cellfun(@(v) mean(v), binned_deltaTCollapses_condition_3);
% n_c3   = cellfun(@numel, binned_deltaTCollapses_condition_3);
% SEM_c3 = cellfun(@(v) std(v), binned_deltaTCollapses_condition_3)./ sqrt(n_c3);

% Delta t Collapse PLOT
% Plot the mean curves with error bars for both conditions
f28 = figure(7); % Post-loop processing
hold on;
% Plot Condition 1
errorbar(bin_centers(:), mean_binned_deltaTCollapses_condition_1(:), SEM_c1(:), 'Color', [colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaTCollapses_condition_1(:),'-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 2
errorbar(bin_centers(:), mean_binned_deltaTCollapses_condition_2(:), SEM_c2(:), 'Color', [colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_binned_deltaTCollapses_condition_2(:),'-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Plot Condition 3
% errorbar(bin_centers, mean_binned_deltaTCollapses_condition_3, SEM_c3, 'Color', [colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_binned_deltaTCollapses_condition_3,'-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)],'LineWidth', 2, 'DisplayName', 'Mean')

% Customize the plot
% xlabel('Time after E3.5 (h)');
xlabel('Time after reaching 300 pL (h)');
ylabel('Duration of collapse (h)');
% title("Synchronised curves - Mean with SEM");
% legend('show');
fontsize(18, 'points');
xlim([0 50])
ylim([0 1])
hold off;
savefig(f28,fullfile(folder_save,date,'binned2h_embryo_deltaT_collapse_mean_SEM.fig'))
exportgraphics(f28,fullfile(folder_save,date,'binned2h_deltaT_collapse_mean_SEM.png'), 'Resolution',300)

% Collapse frequency
% Compute mean and SEM across rows
mean_counts_condition_1 = mean(counts_collapse_categories_condition_1, 1,'omitnan');
% sem_counts_condition_1 = std(counts_collapse_categories_condition_1(counts_collapse_categories_condition_1 ~= 0), 0, 1) ./ sqrt(sum(counts_collapse_categories_condition_1 > 0, 1));  % SEM (optional: use n instead of count of >0)
sem_counts_condition_1 = cellfun(@(v) std(v,'omitnan'), counts_collapse_categories_condition_1)./ sqrt(n_c1);

mean_counts_condition_2 = mean(counts_collapse_categories_condition_2, 1,'omitnan');
sem_counts_condition_2 = std(counts_collapse_categories_condition_2(counts_collapse_categories_condition_2 ~= 0), 0, 1) ./ sqrt(sum(counts_collapse_categories_condition_2 > 0, 1));  % SEM (optional: use n instead of count of >0)

% mean_counts_condition_3 = mean(counts_collapse_categories_condition_3, 1);
% sem_counts_condition_3 = std(counts_collapse_categories_condition_3(counts_collapse_categories_condition_3 ~= 0), 0, 1) ./ sqrt(sum(counts_collapse_categories_condition_3 > 0, 1));  % SEM (optional: use n instead of count of >0)

sem_counts_condition_1(isinf(sem_counts_condition_1)) = NaN;
sem_counts_condition_2(isinf(sem_counts_condition_2)) = NaN;
% sem_counts_condition_3(isinf(sem_counts_condition_3)) = NaN;

% Bin centers for plotting
bin_centers = bins(1:end-1) + diff(bins)/2;

% Plot
f29 = figure;
hold on
errorbar(bin_centers(:), mean_counts_condition_1(:), sem_counts_condition_1(:), '-','Color', [colors(1, :)],'MarkerFaceColor',[colors(1, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_counts_condition_1(:), 'Color', [colors(1, :)], 'LineWidth', 2);

errorbar(bin_centers(:), mean_counts_condition_2(:), sem_counts_condition_2(:), '-','Color', [colors(2, :)],'MarkerFaceColor',[colors(2, :)], 'LineWidth', 0.5);
plot(bin_centers(:), mean_counts_condition_2(:), 'Color', [colors(2, :)], 'LineWidth', 2);

% errorbar(bin_centers, mean_counts_condition_3, sem_counts_condition_3, '-','Color', [colors(3, :)],'MarkerFaceColor',[colors(3, :)], 'LineWidth', 0.5);
% plot(bin_centers, mean_counts_condition_3, 'Color', [colors(3, :)], 'LineWidth', 2);

fontsize(18, 'points');
ylim([0 1])
% xlabel('Time after E3.5 (h)');
xlabel('Time after reaching 300 pL (h)');
ylabel('Collapse rate (/h)');

savefig(f29,fullfile(folder_save,date,'binned3h_embryo_collapse_frequency_mean_SEM_2.fig'))
exportgraphics(f29,fullfile(folder_save,date,'binned3h_collapse_frequency_SEM_2.png'), 'Resolution',300)

%% Sample size (after binning) (number of embryos)

nb_embryos_overtime_afterbinning_condition_1 = sum(curve_contributions_condition_1 ~= 0, 1);
nb_embryos_overtime_afterbinning_condition_2 = sum(curve_contributions_condition_2 ~= 0, 1);
% nb_embryos_overtime_afterbinning_condition_3 = sum(curve_contributions_condition_3 ~= 0, 1);

f = figure
hold on
plot(bin_centers, nb_embryos_overtime_afterbinning_condition_1, 'LineWidth', 2, 'Color',[colors(1, :)],'DisplayName','NED9-KO')
plot(bin_centers, nb_embryos_overtime_afterbinning_condition_2, 'LineWidth', 2, 'Color',[colors(2, :)],'DisplayName','AQP3-KO')
% plot(bin_centers, nb_embryos_overtime_afterbinning_condition_3, 'LineWidth', 2, 'Color',[colors(3, :)],'DisplayName','EIPA')

xlabel('Time (h)')
ylabel('Sample size after binning')
legend()
fontsize(18, 'points'); 
savefig(f,fullfile(folder_save,date,'sample_size_after_binning.fig'))
exportgraphics(f,fullfile(folder_save,date,'sample_size_after_binning.png'), 'Resolution',300)

%% Sample size (after binning) (number of measurements)

nb_measurements_overtime_afterbinning_condition_1 = cellfun(@numel, binned_influx_condition_1);
nb_measurements_overtime_afterbinning_condition_2 = cellfun(@numel, binned_influx_condition_2);
% nb_measurements_overtime_afterbinning_condition_3 = cellfun(@numel, binned_influx_condition_3);

figure
hold on

plot(bin_centers, nb_embryos_overtime_afterbinning_condition_1, 'LineWidth', 2, 'Color',[colors(1, :)],'DisplayName','Control')
plot(bin_centers, nb_embryos_overtime_afterbinning_condition_2, 'LineWidth', 2, 'Color',[colors(2, :)],'DisplayName','Ouabain')
% plot(bin_centers, nb_embryos_overtime_afterbinning_condition_3, 'LineWidth', 2, 'Color',[colors(3, :)],'DisplayName','EIPA')

xlabel('Time (h)')
ylabel('Measurements size after binning')
legend()
fontsize(18, 'points');