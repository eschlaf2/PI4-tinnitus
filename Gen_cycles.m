% Generate cycle data for raw data using FFT and eig methods and return
% histograms of where each roi mapped to. For example, for roi #1, the
% column 1 will show the number of times 1 was followed by 2, by 3, etc.,
% in the permutation ordering.

cd('/Users/emilyschlafly/Box Sync/PI4/Raw Data/Data (matrices)'); 
files = dir('newRois*.mat');
expected_rois = 9;

count = 1;
for file = files.'
    try
        data = importdata(file.name);
    catch ME
        warning(strcat(file.name,' did not load properly.'))
        continue
    end

%     Sort by Eig method
%     (create_lead checks data for Nan and removes that time step)
    filtered = integration_filter(data);
    normed_data = alt_norm(filtered);
    lead_matrix = create_lead(normed_data); 
    [eig_phases, eig_perm, sorted_lead_matrix, spectrum] = ...
        sort_lead(lead_matrix);
%     eig_perm = keep_one_first(eig_perm);
%     Check for data errors
    if length(lead_matrix) ~= expected_rois
        disp(strcat(file.name,' is missing data.'));
        continue
    end
    if length(normed_data) < 100
        disp(strcat(file.name, ' has less than one hundred sample times.'))
    end
    
%     Sort by FFT method
    [~,fft_perm] = fft_sort(normed_data);
    
    if count == 1
        fft_cycles = zeros(length(files),length(fft_perm));
        eig_cycles = fft_cycles;
        mtx = zeros(expected_rois, expected_rois, length(files)); 
    end
    
    fft_cycles(count,:) = fft_perm;
%     eig_cycles(count,:) = eig_phases(eig_perm);
    eig_cycles(count,:) = eig_perm;
    for k = 1:expected_rois
        [~, ss] = sort(eig_perm);
        mtx(k, eig_perm(ss(k):end), count) = 1;
    end
    mtx(:,:,count) = mtx(:,:,count) - eye(expected_rois);
    
    count = count + 1;

end
mtx = sum(mtx, 3);
count = count - 1;

% Kill zero rows
fft_cycles = fft_cycles(1:count,:);
eig_cycles = eig_cycles(1:count,:);


% Create histograms of data
fft_cycle_data = zeros(expected_rois,count);
eig_cycle_data = fft_cycle_data;

for j = 1:count
    fft_cycle_data(1,j) = fft_cycles(j,2);
    eig_cycle_data(1,j) = eig_cycles(j,2);
end

for i = 2:expected_rois
    for j = 1:count
%         col = find(fft_cycles(j,:) == i);
        shifted = circshift(fft_cycles(j, :), [0, -1]);
        fft_cycle_data(i,j) = shifted(fft_cycles(j,:) == i);
        
        col = find(eig_cycles(j,:) == i);
        shifted = circshift(eig_cycles(j, :), [0, -1]);
        eig_cycle_data(i,j) = shifted(col);
    end
end

fft_cycle_analysis = zeros(expected_rois);
eig_cycle_analysis = fft_cycle_analysis;

for i = 1:expected_rois
    for j = 1:expected_rois
        fft_cycle_analysis(i, j) = sum(fft_cycle_data(i,:)==j);
        eig_cycle_analysis(i, j) = sum(eig_cycle_data(i,:)==j);
    end
end

fft_hist = figure();
figure(fft_hist)
bar(fft_cycle_analysis,'stack');
set(figure(fft_hist),'Colormap',lines);
legend(num2str((1:expected_rois)'));
title('Cycles using FFT method')

eig_hist = figure();
figure(eig_hist)
bar(eig_cycle_analysis, 'stack');
legend(num2str((1:expected_rois)'));
title('Cycles using Eig method');

eig_hist_before = figure();
bar(mtx, 'stack');
legend(num2str((1:expected_rois).'));
title({'Count of precedence'; '(number of times each region came before another)'})
