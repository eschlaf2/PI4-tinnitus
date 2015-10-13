function cyclic_analysis_plots(eig_vec, sorted_lead_matrix, eig_vals)


%% Plots
figure; 
set(gcf, 'DefaultAxesPosition', [.05 .05 .86 1], ...
    'PaperOrientation', 'landscape',...
    'units', 'normalized', 'outerposition', [0 0 1 .4]);
r=1; c=3;

plot_keys = {'data', 'normed_data_2_traces', 'normed_data_area',...
    'normed_data', 'lead_matrix', 'eigenvectors', 'eigenvalues', ...
    'eigenvector_magnitude'};
plot_ordering = [0 0 0 0 0 1 3 2];
% plot_data = {plot(data.'), ...
%     plot(normed_data(1:3:4,:).'), ...
%     plot(normed_data(1,:), normed_data(2,:)), ...
%     plot(normed_data.'), ...
%     imagesc(sorted_lead_matrix), ...
%     {plot(V(:,1),'b*-')}, ...
%     stem(abs(diag(S))), ...
%     stem(abs(V(:,1)))};

% Map_plotData = containers.Map(plot_keys, plot_data);
Map_plotOrder = containers.Map(plot_keys, plot_ordering);

% tight_subplot(r,c,Map_plotOrder('data'));
% set(gcf,'DefaultAxesColorOrder',jet(9))
% plot(data.');
% set(gca, 'ytick', [], 'xtick', []);
% axis('square', 'tight')

% tight_subplot(r,c,Map_plotOrder('normed_data_2_traces'));
% set(gcf,'DefaultAxesColorOrder',[0,0,1;1,0,1])
% plot(normed_data(1:3:4,:).');
% set(gca, 'ytick', [], 'xtick', []);
% axis('square', 'tight');
% 
% tight_subplot(r,c,Map_plotOrder('normed_data_area'));
% plot(normed_data(1,:), normed_data(2,:));
% set(gca, 'ytick', [], 'xtick', []);
% axis('square');
 
% tight_subplot(r,c,Map_plotOrder('normed_data'));
% set(gcf,'DefaultAxesColorOrder',jet(9))
% plot(normed_data.');
% set(gca, 'ytick', [], 'xtick', []);
% axis('square', 'tight')

tight_subplot(r,c,Map_plotOrder('lead_matrix')); %out
imagesc(sorted_lead_matrix)
set(gca, 'ytick', [], 'xtick', []);
axis('square')

tight_subplot(r,c,Map_plotOrder('eigenvectors')); %in
plot(squeeze(eig_vec(:,:,1)),'b*-');
hold on; plot(0,0,'r*');
set(gca, 'ytick', [], 'xtick', []);
axis([-.5, .5, -.5, .5]); axis('square');

tight_subplot(r,c,Map_plotOrder('eigenvalues')); %in
stem(abs(squeeze(eig_vals)).')
set(gca, 'ytick', [], 'xtick', []);
axis('square')

tight_subplot(r,c,Map_plotOrder('eigenvector_magnitude')); %in
stem(abs(squeeze(eig_vec(:,:,1))))
set(gca, 'ytick', [], 'xtick', []);
axis('square')

hgexport(gcf, 'analysis.fig');