function Process_ROIS_FIND(search_pattern)
% Run from inside directory to be processed. Processes files matching input
% search_pattern. Results will be saved as
% 'FIND_processed_(search_pattern)'. Returns mean value of points within 
% regions of interest from the Stanford FIND lab.


files = dir(search_pattern);

for file = files'
    if ~exist('regions','var')
	try
	    load('/home/eschlaf2/PI4/rois-FIND/regions.mat');
	catch ME
	    error('Could not load regions.')
	end
    end
    try
        data = importdata(file.name);
    catch ME
        warning(strcat(file.name,' did not load properly.'))
        continue
    end
    
    sub_rois = zeros(104, size(data,2) - 3);
    i = 0;
    region = fieldnames(regions);
    for j = 1:length(region)
	subregion = fieldnames(regions.(region{j}));
	for k = 1:length(subregion)
	    i = i+1;
	    sub_rois(i,:) = mean(data(regions.(region{j}).(subregion{k})==1,4:end));
	end
    end

    sub_rois = sub_rois(1:i,:);

    filename = ['FIND_processed_',file.name];
    save(filename,'sub_rois');
    clear data sub_rois;
end

