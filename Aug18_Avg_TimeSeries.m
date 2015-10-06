% Averages time series of all members of a given group

%% Parameters
close all; clear all;
GROUPS; regions_of_interest;
groups = [1 2];

    %% Data
for group = groups
    cd('/Users/emilyschlafly/Box Sync/PI4/Raw Data/Music/fitness study');
    expected_rois = 9;  % check
    
    count = 1;
    for i = Subj_Groups{group,2}
        file_name = strcat('processed_subject_',num2str(i, '%02.0f'),'.mat');
        try
            dd = alt_norm(integration_filter(importdata(file_name)));
            if count == 1 && group == 1
                data_whole = zeros([numel(groups) size(Subj_Groups{group,2},2) size(dd)]);
                data = zeros([numel(groups) size(dd)]);
            end
        catch ME
            warning(strcat(file_name,' did not load properly.'))
            continue
        end
        data_whole(group,count,:,:) = dd;
        data(group,:,:) = squeeze(data(group,:,:)) + dd;
        count = count + 1;
    end
    data(group,:,:) = data(group,:,:) ./ count;
%     colorset = [lines(7);cool(2)];
%     figure(1); 
%     set(gcf,'DefaultAxesColorOrder',colorset)   
%     set(gcf, 'DefaultAxesPosition', [.2 .1 .6 .8]);
%     data = data ./ count;
%     music_on = [(10*25:10*(25 + 30)), (10*85:10*(85 + 30))];
%     x = zeros(1, 10 * size(data, 2)); x(music_on) = 1;
%     colr = .9 * [1 1 1];
%     subplot(1, numel(groups), group);
%     area((.1:.1:size(data,2)), 50 .* x, 'FaceColor', colr, 'EdgeColor', colr); hold on;
%     spread_ts = data + repmat(3*(1:numel(data(:,1))).', 1, size(data,2));
%     plot(spread_ts.', 'LineWidth', 2);
%     if group == 1
%         legend(['Music On', ROIS((1:9))],'Position', [.07, .85, 0, 0]);
%     end
%     ylim([min(spread_ts(1,:)) - 1, max(spread_ts(end,:)) + 1]);
%     title({Subj_Groups{group};strcat('n = ',num2str(count))})

end
for i = 1:numel(groups)
    ttle{i} = {Subj_Groups{i};strcat('n = ', num2str(size(Subj_Groups{i,2},2)))};
end
lgnd = ['Music On', ROIS((1:9))];
music_on = [(10*25:10*(25 + 30)), (10*85:10*(85 + 30))];
figure(1)
ts_plot(data, music_on, [1 numel(groups)], ttle, lgnd)

fullscreen(figure(1));
msg = 'Average of time series';
    annotation(figure(1), 'textbox', [0.25, .975, 0.5, 0], ...
            'string', msg,...
            'linestyle', 'none', ...
            'HorizontalAlignment', 'center', ...
            'fontsize', 18, 'fontweight', 'bold',...
            'units', 'normalized');
