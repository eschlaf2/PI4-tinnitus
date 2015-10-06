function [fft_dist, eig_dist] = compare_methods(rois, loops, time, noise_magnitude, type, display_)
% This script compares method performance and shows behavior using
% different toy data sets. The methods are comparable except when using the
% Gaussian data - the eigenvalue method cannot determine where to place
% data when peaks do not overlap. This could most likely be compensated for
% in some other way, however. I would still like to play more with some
% real data in a controlled way (seed toy data with one roi sample and see
% how well we recover known permutations).

[toy_data, ss] = create_toy_data(rois, loops, time, noise_magnitude, type, display_);
data = toy_data;
% data = smoothts(toy_data,'g');
normed_data = normalize(data);
lead_matrix = create_lead(normed_data);
[~,fft_perm] = fft_sort(normed_data);
[~, eig_perm, ~, ~] = sort_lead(lead_matrix);

if display_
    % Show plots for fft analysis
    data_fig = figure(); fft_fig = figure(); eig_fig = figure();
    tol = .0025;    %for keeping fft plots clean only
    figure(data_fig)
    subplot(1,2,1)
    t=(1:time)/time;
    plot(t,data)
    legend(num2str((1:size(data)).'))
    title('Original Data')
    subplot(1,2,2)
    plot(t,normed_data);
    title('Normalized Data')
    [~, labels] = sort(fft_perm);
    legend(num2str(labels.'));
    
    transform = fft(normed_data,[],2);
    figure(fft_fig)
    subplot(3,1,1)
    plot(t,real(transform));
    title('Real(FFT)')
    subplot(3,1,2)
    plot(t,imag(transform));
    title('Imag(FFT)')
    subplot(3,1,3)
    smalls = abs(transform) > tol;
    phases = angle(smalls .* transform);
    plot(t,phases);
    title('Angle(FFT)')

    % Show plots for eig analysis
    [~, eig_perm, sorted_lead_matrix, ~] = sort_lead(lead_matrix);
    figure(eig_fig)
    subplot(1,2,1)
    imagesc(lead_matrix(ss,ss));
    title('Actual')
    subplot(1,2,2)
    imagesc(sorted_lead_matrix);
    title('Experimental')

    % Display permutations for comparison
    disp([fft_perm, cyclic_distance(fft_perm,ss)]); 
    disp([eig_perm, cyclic_distance(eig_perm,ss)]);
end

fft_dist = cyclic_distance(fft_perm,ss);
eig_dist = cyclic_distance(eig_perm,ss);