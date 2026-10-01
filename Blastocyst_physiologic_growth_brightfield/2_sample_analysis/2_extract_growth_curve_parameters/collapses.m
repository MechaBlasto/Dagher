% COLLAPSES Extract growth, collapse, and zona-pellucida dynamics.
%
% Purpose:
%   Detect maxima and minima in one embryo's time series and calculate growth
%   (influx), collapse (outflux), timing, and optional hatching parameters.
% Inputs:
%   A workspace variable zp_results created by zp_seg_postprocessing.m. Set
%   emb and Embryo below; for ZP analysis, the selected record must also have
%   hatching_start and hatching_stop fields. Configure the output path below.
% Outputs:
%   Updated zp_results(emb), saved as a MAT file, with detected extrema and
%   derived rates; diagnostic plots are also produced.
% Overview:
%   Selects embryo volume or ZP thickness, optionally fills outliers, detects
%   extrema with findpeaks, computes interval and rate parameters, then writes
%   them back to the selected structure and performs follow-up plots.
% Dependencies:
%   Signal Processing Toolbox for findpeaks and MATLAB functions filloutliers,
%   rmmissing, and plotting utilities. Requires the upstream zp_results MAT
%   file to be loaded into the workspace before execution.

%% Within a sample, Extract fluid rates and collapses
% Within the final zp_results matrix, specify the embryo you want to
% analyse

emb = 50; %Sample number




% Embryo volume or ZP thickness analysis?
Embryo = 1; %--------------------------------------

x1 = zp_results(emb).time_hours;
name  = zp_results(emb).date;
hatching_start = zp_results(emb).hatching_start;
hatching_stop = zp_results(emb).hatching_stop;

if Embryo == 1
    y1 = zp_results(emb).embryo_volumes;
else
    zp_thick = zp_results(emb).zp_median_thickness;
    y1 = zp_thick(1:hatching_start);
    x1 = x1(1:hatching_start);
    embryo = zp_results(emb).embryo_volumes;
end


figure(1)
hold off
scatter(x1,y1,'filled','DisplayName', name)
legend

%% If needed, remove outliers points
x = rmmissing(x1);
[y,TF,L,U,C] = filloutliers(rmmissing(y1),"makima","movmedian",6,"SamplePoints",x);

%show without the outliers
figure(1)
hold on
plot(x1,y1)
hold on
plot(x,y,"o-")
legend("Original Data","Filled Data")
hold off
x = x1 ;
y = y1 ;

%% Growth rates, due to fluid influx, are between a minimal peak and a maximal peak; Collapses events occurs with a sharp decrease of embryo volume within one timepoint.
%% Look for peaks
% For each peak founded, 
% pks contains the y-values positions
% locs contains the x-values positions
% w is the width
% p is the prominence of the peak
% The peaks are chosen to have at least 25 of prominence and be separated
% by at 30 minutes (3 timepoints)

% Look for maxima peaks (stop of growth)
[pks,locs,w,p1] = findpeaks(y,x,'MinPeakProminence', 25,'MinPeakDistance',0.5);

% Look for minima peaks (start of growth)
[pks2,locs2,w2,p2] = findpeaks(-y,x,'MinPeakProminence', 25,'MinPeakDistance',0.5);

%% Post processing
pks2 = abs(pks2);
% add the first timepoint as the initial minimal embryo size
if minus(locs(1),locs2(1)) < 0
    locs2 = [x(1), locs2];
    pks2 = [y(1); pks2];
end 

if numel(pks2) > numel(pks)
   pks2 = pks2(1:(end - 1)); 
   locs2 = locs2(1:(end - 1));
end

% The arrays are organised in the folowing way
% locs = [1st maximum before 1st collapse; 2nd maximum before 2nd collapse; ... ]; x values
% pks corresponds to the y values (embryo volumes)
% 
% locs2 = [1st timepoint embryo volume; 1st collapse; 2nd collapse; ... ]; x values
% pks2 corresponds to the y values (embryo volumes)

%% Show the results
% show the peaks 
figure(2) 
hold off 
% findpeaks(y,x,'MinPeakProminence',50)
plot(x,y,".-")
hold on   
plot(locs,pks,'ro','MarkerSize',12)
xlabel('Time (hours)')  
ylabel('Embryo volume (pL)')
hold on
plot(locs2,pks2,'bo','MarkerSize',12)

%% Hatching experiment?
hatching = 0 %if ZP hatching occurs, set to 1

%% Extract parameters
%(easy parameters)
p1 = rmmissing(pks);
l1 = rmmissing(locs);
p2 = rmmissing(pks2);
l2 = rmmissing(locs2);

if Embryo == 0 %ZP dynamics
    start_deformation_ZP_timing = l2(1);
    start_deformation_ZP_thickness = p2(1);
    [~, start_deformation_ZP_idx] = min(abs(x1 - start_deformation_ZP_timing));
    embryo_volume_touching_ZP = embryo(start_deformation_ZP_idx);

    slopes_influx = rmmissing(minus(p2,p1)) ./ rmmissing(minus(l2',l1'));
    slopes_outflux = []; %flux of collapsing
    for i = 1 : (numel(p1) - 1)
        slope = rmmissing(minus(p1(i+1),p2(i))) ./ rmmissing(minus(l1(i+1)',l2(i)'));
        slopes_outflux = [slopes_outflux; slope];
    end

end

if Embryo == 1 %Embryo dynamics
    % Extract Growth rate (fluid influx)
    % between a minima peak and a maxima peak
    slopes_influx = rmmissing(minus(p1,p2)) ./ rmmissing(minus(l1',l2'));
    delta_volume_inst = rmmissing(minus(p1,p2));
    delta_t_growth_inst = rmmissing(minus(l1',l2')); %equivalent to time between two collapses
    
    if hatching == 1 & isnan(hatching_start) == 0
        delta_volume_overall_before_hatching = rmmissing(minus(y(1),y(hatching_start)));
    end 
    
    %Extract Collapses
    nb_collapses = numel(rmmissing(l2)) - 1; %number %remove added first timepoint
    delta_t_collapses = diff(rmmissing(l1))'; %delta t
    
    slopes_outflux = []; %flux of collapsing
    for i = 1 : (numel(p2) - 1)
        slope = rmmissing(minus(p2(i+1),p1(i))) ./ rmmissing(minus(l2(i+1)',l1(i)'));
        slopes_outflux = [slopes_outflux; slope];
    end
    
    
    first_collapse_embvolume = p1(1); %first maxima
    first_collapse_timing = l1(1);
end

%% Clustering if you have a ZP hatching process
if hatching == 1 & isnan(hatching_start) == 0
    %-----------Before hatching started 
    slopes_influx_beforehatching = slopes_influx(rmmissing(locs) < x(hatching_start));
    delta_t_growth_inst_beforehatching = delta_t_growth_inst(rmmissing(locs) < x(hatching_start));
    frequency_collapse_before_hatching = numel(rmmissing(locs) < x(hatching_start)) ./ rmmissing(minus(x(hatching_start), x(1)));
else
    slopes_influx_beforehatching = NaN;
    delta_t_growth_inst_beforehatching = NaN;
end

if hatching == 1 & isnan(hatching_stop) == 0
    %----------After hatching finished
    slopes_influx_afterhatching = slopes_influx(rmmissing(locs) > x(hatching_stop));
    delta_t_growth_inst_afterhatching = delta_t_growth_inst(rmmissing(locs) > x(hatching_stop));
    frequency_collapse_after_hatching = numel(rmmissing(locs) > x(hatching_stop)) ./ rmmissing(minus(x(end), x(hatching_stop)));

else 
    slopes_influx_afterhatching = NaN;
    delta_t_growth_inst_afterhatching = NaN;
end

%% Add computed parameters to the final matrix - Embryo
if Embryo == 1
    zp_results(emb).maxima_volumes = p1;
    zp_results(emb).maxima_time_hours = l1;
    zp_results(emb).minima_volumes = p2;
    zp_results(emb).minima_time_hours = l2;
    zp_results(emb).slopes_influx_pL = slopes_influx;
    zp_results(emb).detla_volume_pL = delta_volume_inst;
    zp_results(emb).delta_t_growth_h = delta_t_growth_inst;
    zp_results(emb).nb_collapses = nb_collapses;
    zp_results(emb).delta_t_collapses_h = delta_t_collapses;
    zp_results(emb).slopes_outflux_pL = slopes_outflux;
    zp_results(emb).first_collapse_embvolume = first_collapse_embvolume;
    zp_results(emb).first_collapse_timing = first_collapse_timing;
    zp_results(emb).slopes_influx_beforehatching = slopes_influx_beforehatching;
    zp_results(emb).delta_t_growth_inst_beforehatching = delta_t_growth_inst_beforehatching;
    zp_results(emb).slopes_influx_afterhatching = slopes_influx_afterhatching;
    zp_results(emb).delta_t_growth_inst_afterhatching = delta_t_growth_inst_afterhatching;
else
    zp_results(emb).maxima_thicknesses_zp = p1;
    zp_results(emb).maxima_time_hours_zp = l1;
    zp_results(emb).minima_thicknesses_zp = p2;
    zp_results(emb).minima_time_hours_zp = l2;
    zp_results(emb).slopes_stretching_micromperh = slopes_influx;
    zp_results(emb).nb_collapses_zp = nb_collapses;
    zp_results(emb).delta_t_collapses_h = delta_t_collapses;
    zp_results(emb).slopes_relaxation_micromperh = slopes_outflux;
    zp_results(emb).start_deformation_ZP_timing_h = start_deformation_ZP_timing;
    zp_results(emb).start_deformation_ZP_thickness_microns = start_deformation_ZP_thickness;
    zp_results(emb).start_deformation_ZP_idx = start_deformation_ZP_idx;
    zp_results(emb).embryo_volume_touching_ZP = embryo_volume_touching_ZP;
end

disp('added')
%% Save final matrix
path_all = '/path/to/results/';
alldatafile_name = 'final_matrix.mat'
save(fullfile(path_all, alldatafile_name),'zp_results','-mat')
disp('ok saved')