cd('/home/eschlaf2/PI4/Resting_matrices_of_music_subjects'); 
files = dir('subject*.mat');
regions_of_interest;

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
        sub_rois(i,:) = average_regions(ROIS{i, 2},data,5);
    end
    save(filename,'sub_rois')
end

