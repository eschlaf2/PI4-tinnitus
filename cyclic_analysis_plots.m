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

%%Old plots
% %% angle matrices
%         mean_cycles = mean(eig_cycles);
%         [rows, cols] = meshgrid(angle(mean_cycles));
%         angle_mtx = cols - rows;
%         fig_angle_mtxs = figure();
%         set(gcf, 'DefaultAxesPosition', [.15 .05 .86 .9]);
%         tight_subplot(numel(groups), numel(period_length), ...
%             find(L == period_length) + (group - 1) * numel(period_length))
%         angle_range = [-pi/4, pi/4];
%         imagesc(angle_mtx, angle_range);
%         set(gca, 'Xtick', (1:size(ROIS,1)));
%         xlabel('Ahead'); ylabel('Behind')
%         title({subjects{group};strcat('Period length = ',num2str(L));...
%             strcat('n=',num2str(count))})
%         colorbar('Ytick', (angle_range(1):pi/8:angle_range(2)),...
%             'Yticklabel', {'-pi/4'; '-pi/8'; '0'; 'pi/8'; 'pi/4'});
%         angle_expln = ['The color in position (i, j) indicates the angular ',...
%             'distance between i and j. If the color at (i, j) is ',...
%             'equivalent to \pi/4, then i is \pi/4 behind j. ',...
%             'If (i, j) is -\pi/4, then i is \pi/4 ahead of j. ',...
%             'Angles range from -\pi/4 to \pi/4; angles greater than \pi/4 ',...
%             'show as \pi/4, and those less than -\pi/4 show as -\pi/4.'];
% 
% 
%         %% variance matrices
%         fig_var_mtxs = figure();
%         set(gcf, 'DefaultAxesPosition', [.15 .05 .86 .9]);
%         tight_subplot(numel(groups), numel(period_length), ...
%             find(L == period_length) + (group - 1) * numel(period_length));
%         imagesc(mtx, [0 1])
%         var_colors = [0 0 0; .6667 0 0; 1.0 .3333 0; 1 1 0; 1 1 1];
%         colormap(var_colors);
% %         pp = get(gca, 'position'); 
% %         txt(pos(pp));
%         title({subjects{group};strcat('Period length = ',num2str(L));...
%             strcat('n=',num2str(count))})
%         xlabel('Before'); ylabel('After')
%         colorbar;   
%         set(gca, 'Xtick', (1:size(ROIS,1)));
%         var_expln = ['The color in position (i, j) indicates the proportion ',...
%             'of times i came after j. If the color at (i, j) is ',...
%             'equivalent to 1, then i came after j every time. ',...
%             'If (i, j) is 0.5, then i came after j only 50% of the time. '];
%         
%         %% textboxes
%         if ischar(bin_starts); 
%             msg = ['Time bin starts = ',bin_starts]; 
%         else 
%             msg = ['Time bin starts = [', num2str(sort(starts)),']'];
%         end
%         bin_txt = @(more_txt) annotation('textbox', [0.01, .52, .2, 0], ...
%             'string', {data_set;more_txt;msg},...
%             'linestyle', 'none', ...
%             'fontsize', 18, 'fontweight', 'bold',...
%             'units', 'normalized');
%         pos = @(pp)[pp(1), pp(2) + pp(4) - .005, pp(3), 0];
%         txt = @(pos) annotation('textbox',pos,'String',['n = ',num2str(count)],...
%             'horizontalAlignment', 'center', 'linestyle', 'none');
%         legend_label = ROIS(:,1); 
%             for roi = 1:numel(ROIS(:,1))
%                 roi_name = ROIS(roi, 1);
%                 legend_label(roi) = strcat('(',num2str(roi),')',{' '}, ...
%                     roi_name(1:min(length(roi_name), 8)));
%             end
%         lgnd_box = @() annotation('textbox', [.01, .95, .15, 0], ...
%             'string', legend_label,...
%             'fontweight', 'bold', ...
%             'units', 'normalized',...
%             'fontsize', 14,...
%             'linestyle', 'none');
%         
%         figure(fig_angle_mtxs); bin_txt('Angles'); lgnd_box(); fullscreen(gcf);
% annotation('textbox', [.01, .35, .12, 0], ...
%             'string', angle_expln,...
%             'units', 'normalized',...
%             'fontsize', 12,...
%             'linestyle', 'none');
% figure(fig_var_mtxs); bin_txt('Variation'); lgnd_box(); fullscreen(gcf);
% annotation('textbox', [.01, .35, .12, 0], ...
%             'string', var_expln,...
%             'units', 'normalized',...
%             'fontsize', 12,...
%             'linestyle', 'none');

%%ts plots
%% time series plots
%             if L == period_length(1)
%                 if plot_ts == 'y'
%                     [~, ~, ~, ~, total_spect] = ...
%                         sort_lead(create_lead(alt_norm(integration_filter(data_whole)))...
%                         , ROIS, base_roi);
%                     figure(30 + group)
%                     if count == 0; fullscreen(gcf); end
%                     set(gcf,'DefaultAxesColorOrder',colorset)
%                     subplot(3, 3, find(subjects{group,2} == i))
%                     treated = alt_norm(integration_filter(data_whole));
%                     plot(treated.');
%                     set(gca, 'ytick', []);
%                     title({strcat('Subj', num2str(i, ' %i')); ...
%                         strcat('Mean var =', num2str(mean(var(treated)), ' %5.2f'))});
%                     ratio = abs(total_spect(1:2:5,1)) ./ abs(total_spect(3:2:7, 1));
%                     xlabel(num2str(ratio.', '  %6.2g  '));
%                     axis('tight')
%                     annotation('textbox', [.25, .99, .5, 0.01], ...
%                     'string', {subjects{group}}, ...
%                     'linestyle', 'none', ...
%                     'fontsize', 18, 'fontweight', 'bold',...
%                     'horizontalalignment','center', ...
%                     'units', 'normalized');
%                 end
%             end
%             