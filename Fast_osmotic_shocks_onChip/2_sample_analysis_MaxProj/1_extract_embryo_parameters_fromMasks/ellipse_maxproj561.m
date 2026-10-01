% ELLIPSE_MAXPROJ561 Segment a max-projection embryo and quantify its size.
%
% Purpose:
%   Segment an embryo through a max-projection TIFF stack and estimate its
%   area, diameter, volume, and ellipse descriptors at each time point.
% Inputs:
%   folder_path, mask_name, micron_scale, timestep, experiment, and the
%   interactive polygon selections configured below. The TIFF stack must be
%   available at fullfile(folder_path, mask_name).
% Outputs:
%   maxproj_results saved to filename, plus an optional segmentation GIF in
%   folder_path. The script also creates diagnostic figures.
% Overview:
%   Reads the stack, initializes an interactive ROI, propagates an active
%   contour, measures the fitted ellipse and equivalent spherical volume, and
%   optionally records manually excluded outliers.
% Dependencies:
%   Image Processing Toolbox (including tiffreadVolume, activecontour,
%   regionprops, and interactive ROI functions) and the external
%   segmentation_Matlab path added below.
%
% Warning: the outlier section is interactive; do not run the whole file
% unattended without reviewing that section.

%% /!\ Be carefull to the outlier section! Don't run all the code at once
addpath('/path/to/external_tools/segmentation_Matlab')

folder_path = '/path/to/data/fast_osmotic_shocks_onChip/2023-07-07-E4.5-OS/87.5mM/1/fast';
mask_name = 'Max_proj.tif';
folder_save = folder_path;
filename = 'maxproj_ellipse_results.mat';
namegif = 'masked_image_circle_final.gif';
double_mask = 0;

micron_scale = 0.1625;
timestep = 0.25 ; % timestep in minutes
experiment = "87.5mM - 1 - 07/07/23 - 2inlets E4.5";
cd(folder_path)
imageData = tiffreadVolume(fullfile(folder_path, mask_name));

%% Segmentation
area = [];
diameter_microns = [];
volume_microns_cube = [];
centroid = [];
Orientation = [];
MajorAxisLength = [];
MinorAxisLength = [];

for t = 1 : size(imageData,3)
    I = imageData(:,:,t);
    I = rescale(double(I));
       I = imgaussfilt(I,6);
    I = imsharpen(I,'Radius',100,'Amount',10);% 100, 10 en 16 bits
    
    if t == 1
        figure(1)
        imshow(I, [])
        roi = drawpolygon;
        BW = createMask(roi,I);
        
        roi_exclude = drawpolygon;
        BW_exclude = createMask(roi_exclude,I);
        
        if double_mask == 1
            roi_exclude2 = drawpolygon;
            BW_exclude2 = createMask(roi_exclude2,I);
        end
    end
    
    I(BW_exclude == 1) = 0;
    if double_mask == 1
        I(BW_exclude2 == 1) = 0;
    end
    
    bw = activecontour(I,BW,300,'Chan-Vese','SmoothFactor',1);
    bw = bwareaopen(bw,10000);
    se = strel('disk',400);
    bw = imclose(bw,se);
    %Display the active contour over the original image in red
    figure(2)
    imshow(I, [])
    hold on;
    visboundaries(bw,'Color','r');
       
    % Calculate centroid, orientation and major/minor axis length of the ellipse
    s = regionprops(bw,{'Centroid','Orientation','MajorAxisLength','MinorAxisLength'});
    centroid = [centroid;s.Centroid];
    Orientation = [Orientation;s.Orientation];
    MajorAxisLength = [MajorAxisLength;s.MajorAxisLength];
    MinorAxisLength = [MinorAxisLength;s.MinorAxisLength];
    
    % Calculate the ellipse line
    theta = linspace(0,2*pi);
    col = (s.MajorAxisLength/2)*cos(theta);
    row = (s.MinorAxisLength/2)*sin(theta);
    M = makehgtform('translate',[s.Centroid, 0],'zrotate',deg2rad(-1*s.Orientation));
    D = M*[col;row;zeros(1,numel(row));ones(1,numel(row))];
    plot(D(1,:),D(2,:),'c','LineWidth',2)
    hold off
    
    Bw = poly2mask(D(1,:),D(2,:),size(I,1),size(I,2));

    %get the figure to save it as a gif
    F = getframe(gcf);
    [new_I] = frame2im(F);
    [imind,cm]=rgb2ind(new_I,256);

    % create a gif of the masked images
    if t == 1
        imwrite(imind,cm,fullfile(folder_path,namegif), "gif", 'LoopCount',inf);
    else
        imwrite(imind,cm,fullfile(folder_path,namegif), "gif",'WriteMode','append');
    end
    %create a mask from the fitted circle
    A = bwarea(Bw);
    area = [area ; A];
    radius_microns = sqrt(A/pi) * micron_scale;
    diameter_microns = [diameter_microns ; radius_microns * 2];
    v = 4/3 * pi * (radius_microns .^ 3);
    volume_microns_cube = [volume_microns_cube; v];
    disp(t)
    BW = Bw;
end

%% Sample data visualisation
time = linspace(0,timestep * size(diameter_microns,1),size(diameter_microns,1));
figure(500)
hold on

plot(time, diameter_microns,'DisplayName',experiment)
legend
ylabel('microns')
xlabel('minutes')

%% Save results
maxproj_results.area = area;
maxproj_results.diameter_microns = diameter_microns;
maxproj_results.volume_microns_cube = volume_microns_cube;
maxproj_results.time_minutes = time;
maxproj_results.mask_name = mask_name;
maxproj_results.experiment = experiment;
maxproj_results.micron_scale = micron_scale;

maxproj_results.ellipse_centroid = centroid;
maxproj_results.Orientation = Orientation;
maxproj_results.MajorAxisLength = MajorAxisLength;
maxproj_results.MinorAxisLength = MinorAxisLength;
if outliers == 1
    maxproj_results.no_outliers_x = x;
    maxproj_results.no_outliers_y = y;
end
save(fullfile(folder_save,filename),'maxproj_results','-mat')
