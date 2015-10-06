cd('/Users/emilyschlafly/Box Sync/PI4/Raw Data/Data (matrices)/Resting matrices of music subjects');
files = dir('*.mat');
for file = files.'
    fileData = load(file.name);
    csvwrite([file.name(1:20),'.csv'],fileData.sub_rois);
end

