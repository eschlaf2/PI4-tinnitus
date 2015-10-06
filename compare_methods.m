function [eig_dist] = compare_methods(type, varargin)
% This script compares method performance and shows behavior using
% different toy data sets. The methods are comparable except when using the
% Gaussian data - the eigenvalue method cannot determine where to place
% data when peaks do not overlap. This could most likely be compensated for
% in some other way, however. I would still like to play more with some
% real data in a controlled way (seed toy data with one roi sample and see
% how well we recover known permutations).

display_ = 0;
[toy_data, ss] = create_toy(type, varargin{:});
% display(ss.','given permutation')
data = toy_data;
% data = smoothts(toy_data);
filtered = integration_filter(data);
normed_data = alt_norm(filtered);
lead_matrix = create_lead(normed_data);
[phases, eig_perm, sorted_lead_matrix, spect] = ...
    sort_lead(lead_matrix);

if display_
    
    data_fig = figure(); eig_fig = figure();
    figure(data_fig)
    subplot(1,2,1)
    t=(1:time)/time;
    plot(t,data)
    legend(num2str((1:size(data)).'))
    title('Original Data')
    subplot(1,2,2)
    plot(t,normed_data);
    title('Normalized Data')

    % Show plots for eig analysis
%     [phases, eig_perm, sorted_lead_matrix, spect] = sort_lead(lead_matrix);
    figure(eig_fig)
    subplot(1,2,1)
    imagesc(lead_matrix(ss,ss));
    title('Actual')
    subplot(1,2,2)
    imagesc(sorted_lead_matrix);
    title('Experimental')

    % Display permutations for comparison
    disp([eig_perm, cyclic_distance_ben(eig_perm,ss)]);
end

eig_dist = cyclic_distance(eig_perm,ss);