% OS_ONCHIP_COMMON_PUBLI Summarize fast on-chip osmotic shock responses.
%
% Purpose:
%   Compare osmotic-shock and recovery flow rates across experiments and
%   generate Boyle-Van't Hoff volume plots.
% Inputs:
%   A workspace variable microflu_data with slope_OS_MicronsperH,
%   slope_Rec_MicronsperH, osmolarity, embryo_change_start_volumes, and
%   embryo_change_stop_volumes fields. Configure folder_save and date below.
% Outputs:
%   Figures, PNG exports, MAT files containing fitted lines, correlations and
%   p-values, and an XLS table counting embryos per osmotic condition.
% Overview:
%   Groups measurements by osmolarity, fits linear relationships for shock and
%   recovery rates, then compares initial and final embryo volumes.
% Dependencies:
%   The external generic_codes path added below; Statistics and Machine
%   Learning Toolbox for corrcoef/polyfit-related analysis may be required.

folder_save = '/path/to/results/fast_osmotic_shocks_onChip'
date = string(datetime("now"));
mkdir(fullfile(folder_save,date))

% Osmotic shocks on chip - Final analysis 2025
addpath('/path/to/external_tools/generic_codes');

slopes_OS =  cell2mat({microflu_data.slope_OS_MicronsperH})';%cell2mat({microflu_data.slope_OS_pLperMin})';%
slopes_rec = cell2mat({microflu_data.slope_Rec_MicronsperH})';%cell2mat({microflu_data.slope_recovery_pLperMin})';%

medium_osm = cell2mat({microflu_data.osmolarity})';

Osmolarities_str = {'257 mOsm'; '295 mOsm'; '345 mOsm'; '445 mOsm'; '234 mOsm'; '169 mOsm'; '123 mOsm'};
Conditions = {'Control'; 'Sucrose 43.25mM'; 'Sucrose 87.5mM'; 'Sucrose 175mM'; 'Water dilution 10%'; 'Water dilution 30%'; 'Water dilution 50%'};
colours = [0.15,0.15,0.15; 0.38,0.77,0.09;0.09,0.66,0.06;0.05,0.45,0.03;0.94,0.57,0.73;0.84,0.07,0.40;0.57,0,0.25];
group_osm = [257;295;345;445;234;169;123];

% Map each label in color_label to an index in group_names
[~, group_idx] = ismember(medium_osm, group_osm);  % group_idx now has integer indices

% Get the corresponding RGB for each point
RGB_colors = colours(group_idx,:);

control_osmolarity = 257; %mOsm
applied_deltaPi = control_osmolarity - medium_osm;

% Flow rates after osmotic shocks on chip
f = figure
scatter(applied_deltaPi, slopes_OS,70,RGB_colors,'filled', 'MarkerEdgeColor',[1 1 1])
hold on
scatter(applied_deltaPi, slopes_rec,70,'r','filled', 'MarkerEdgeColor',[1 1 1], 'Marker', 'square')

xlim([-300 300])
ylim([-1000 1000])
yticks(-1000:200:1000);
xlabel('Applied osmotic pressure (mOsm)');
ylabel('Flow rate (μm/h)');
fontsize(18,"points")

% Linear correlation
rmNaN = isnan(slopes_OS); %to remove NaN values from arrays (= Controls)
% Slopes OS
p_all_onchip_slopes_OS = polyfit(applied_deltaPi(~rmNaN), slopes_OS(~rmNaN),1);
f_all_onchip_slopes_OS = polyval(p_all_onchip_slopes_OS,applied_deltaPi(~rmNaN));
hold on
plot(applied_deltaPi(~rmNaN),f_all_onchip_slopes_OS,'k', 'LineWidth',1);
[R_onchip_slopes_OS, pval_onchip_slopes_OS] = corrcoef(applied_deltaPi(~rmNaN), slopes_OS(~rmNaN));

% Slopes Recovery
p_all_onchip_slopes_rec = polyfit(applied_deltaPi(~rmNaN), slopes_rec(~rmNaN),1);
f_all_onchip_slopes_rec = polyval(p_all_onchip_slopes_rec,applied_deltaPi(~rmNaN));
hold on
plot(applied_deltaPi(~rmNaN),f_all_onchip_slopes_rec,'r','LineWidth',1);
[R_onchip_slopes_rec, pval_onchip_slopes_rec] = corrcoef(applied_deltaPi(~rmNaN), slopes_rec(~rmNaN));

% Create dummy plots for legend
yline(0,':','LineWidth',1);
h1(1) = xline(0,'--', 'Control osm.', 'DisplayName','257 mOsm', 'FontSize',14,'LineWidth',1);
for c = 2:size(colours,1)
    h1(c) = plot(nan, nan, 'o', 'MarkerSize', 8, 'MarkerFaceColor', colours(c,:), ...
        'MarkerEdgeColor', 'none', 'DisplayName', string(Osmolarities_str(c)));
end
h0(1) = plot(nan, nan, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'k', ...
        'MarkerEdgeColor', 'w', 'DisplayName', 'OS phase');
h0(2) = plot(nan, nan, 'square', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
        'MarkerEdgeColor', 'w', 'DisplayName', 'Recovery phase');
h = [h0,h1];

legend(h, 'Location', 'bestoutside','FontSize',14);


savefig(f,fullfile(folder_save,date,'OS-onChip_FluxRate_pLperMin.fig'))
exportgraphics(f,fullfile(folder_save,date,'OS-onChip_FluxRate_pLperMin.png'), 'Resolution',300)

save(fullfile(folder_save,date,'line_onchip_slopes_OS_pLperMin.mat'),'p_all_onchip_slopes_OS', '-mat')
save(fullfile(folder_save,date,'pval_onchip_slopes_OS_pLperMin.mat'),'pval_onchip_slopes_OS', '-mat')
save(fullfile(folder_save,date,'R_onchip_slopes_OS_pLperMin.mat'),'R_onchip_slopes_OS', '-mat')

save(fullfile(folder_save,date,'line_onchip_slopes_rec_pLperMin.mat'),'p_all_onchip_slopes_rec', '-mat')
save(fullfile(folder_save,date,'pval_onchip_slopes_rec_pLperMin.mat'),'pval_onchip_slopes_rec', '-mat')
save(fullfile(folder_save,date,'R_onchip_slopes_rec_pLperMin.mat'),'R_onchip_slopes_rec', '-mat')

%% Save how many embryos we have per condition
[unique_vals, ~, idx] = unique(medium_osm_filt);
% Create table
Experiments_OS_onChip = table(unique_vals, accumarray(idx, 1), 'VariableNames', {'Osmotic_shock_mOsm', 'Nb_embryos'});
writetable(Experiments_OS_onChip, fullfile(folder_save,date,'Experiments_OS_onChip_nbembryos.xls'));

%% Boyle Vant Hoff plot
medium_osm_all = cell2mat({microflu_data.osmolarity})';

start_volumes = {microflu_data.embryo_change_start_volumes}';
stop_volumes = {microflu_data.embryo_change_stop_volumes}';

% Keep rows where not all elements are NaN - will be same for both
% conditions
isValid = cellfun(@(x) ~all(isnan(x)), start_volumes);

Vi = cell2mat(start_volumes(isValid));
Vf = cell2mat(stop_volumes(isValid));
medium_osm_filt = medium_osm_all(isValid);
RGB_colors_filt = RGB_colors(isValid,:);

Vi_OS = Vi(:,1);
Vf_OS = Vf(:,1);

Vi_rec = Vi(:,2);
Vf_rec = Vf(:,2);

f2 = figure
hold on
scatter(1./medium_osm_filt, Vf_OS ./ Vi_OS,70,RGB_colors_filt,'filled', 'MarkerEdgeColor',[1 1 1])

fontsize(18,"points")

for c = 2:size(colours,1)
    L(c) = plot(NaN, NaN, 'o', 'MarkerSize', 8, 'MarkerFaceColor', colours(c,:), 'MarkerEdgeColor', 'none', 'DisplayName', string(Osmolarities_str(c)));
end

legend(L(2:7),'Location', 'southeast', 'FontSize',14)
xlim([0 0.01])
ylim([0 2.5])
ax = gca; 
ax.XAxis.Exponent = -3;
ylabel('Embryo V_f / V_i');
xlabel('1 / Concentration (mM^{-1})');

% Linear correlation
rmNaN = isnan(Vi_OS); %to remove NaN values from arrays (= Controls)
% Slopes OS
p_all_onchip_VH_OS = polyfit(1./medium_osm_filt(~rmNaN), Vf_OS(~rmNaN) ./ Vi_OS(~rmNaN),1);
f_all_onchip_VH_OS = polyval(p_all_onchip_VH_OS,1./medium_osm_filt(~rmNaN));
hold on
plot(1./medium_osm_filt(~rmNaN),f_all_onchip_VH_OS,'k', 'LineWidth',1, 'DisplayName',strcat('y =  ', string(p_all_onchip_VH_OS(1)), 'x +  ', string(p_all_onchip_VH_OS(2))));

[R_onchip_VH_OS, pval_onchip_VH_OS] = corrcoef(medium_osm_filt(~rmNaN), Vf_OS(~rmNaN) ./ Vi_OS(~rmNaN));

savefig(f2,fullfile(folder_save,date,'OS-onChip_VH_OSphase_volume.fig'))
exportgraphics(f2,fullfile(folder_save,date,'OS-onChip_VH_OSphase_volume.png'), 'Resolution',300)

save(fullfile(folder_save,date,'line_onchip_VH_OS_volume.mat'),'p_all_onchip_VH_OS', '-mat')
save(fullfile(folder_save,date,'pval_onchip_VH_OS_volume.mat'),'pval_onchip_VH_OS', '-mat')
save(fullfile(folder_save,date,'R_onchip_VH_OS_volume.mat'),'R_onchip_VH_OS', '-mat')

save(fullfile(folder_save,date,'microflu_data.mat'),'microflu_data','-mat')
disp("save")
