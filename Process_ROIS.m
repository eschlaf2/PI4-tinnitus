function Process_ROIS(radius)
% Run from inside directory to be processed. Files to pe processed should
% be labeled as 'subject*.mat' and results will be saved as
% 'processed_subject*.mat'. Returns mean value of points within specified
% radius of ROIS indicated in regions_of_interest file.
% inputs: radius (optional, default = 5)


files = dir('*.mat');
regions_of_interest;

if nargin==0
    radius = 5;
end

for file = files.'
    try
        data = importdata(file.name);
    catch ME
        warning(strcat(file.name,' did not load properly.'))
        continue
    end
    
    [~,c] = size(data);
    sub_rois = zeros(length(ROIS), c - 3);
    for i = 1:length(ROIS)
        filename = strcat('processed_', file.name);
        sub_rois(i,:) = average_regions(ROIS{i, 2},data,radius);
    end
    save(filename,'sub_rois')
    clear data sub_rois;
end

