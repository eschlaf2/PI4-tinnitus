% Generate a circular errorbar plot with the size of the markers dependent
% upon the variance in the data. July 14th updated Jul2 version to
% highlight smaller (rather than larger) variances and hold colors constant
% for each ROI across plots.

%% Parameters
close all; clear all;
GROUPS; regions_of_interest;
colorset = [lines(7);cool(2)];
bilat_avg = {};
% {'parahippocampus', 'auditory cortex', 'frontal lobe'};
base_roi = 'l parahip';
groups = [1];
bin_starts = 'divided'; %(1:60:200); %Music starts at 25; can also put 'divided' or 'rand'
period_length = [120]; %[30 60 120]; 
plot_ts = 'n'; %'y' or 'n'%
subject_set = 'Music';
data_set = 'Resting';

%% Data sets
data_location = {'Resting', '/home/eschlaf2/PI4/Resting_matrices_of_music_subjects'; ...
    'Music intervals', '/Users/emilyschlafly/Box Sync/PI4/Raw Data/Music/fitness study'};
data_set = validatestring(data_set, data_location(:,1));
%%
for L = period_length
    %% point size parameters
    min_ps = 2; max_ps = 40;
    min_std = 1; max_std = 2.5;
    syms a b;
    [aa, bb] = solve([a * 1/min_std + b == max_ps; a * 1/max_std + b == min_ps]);
    point_size = @(x) double(max(min(aa * 1/x + bb, max_ps), min_ps));
    %% ROI management
    if exist('bilat_avg', 'var') && ~isempty(bilat_avg)
        del = zeros(numel(bilat_avg),1);
        mn = zeros(2,numel(bilat_avg));
        for r = 1:numel(bilat_avg)
            tt = regexpi(ROIS(:,1), bilat_avg{r});
            ix = cellfun(@isempty,tt);
            tt(ix) = {0};
            tt = find([tt{:}]);
            mn(:,r) = tt;
            ROIS(tt(1),1) = bilat_avg(r);
            del(r) = tt(2);
        end
        ROIS(del,:) = [];
    end

    base_roi = validatestring(base_roi,[ROIS(:,1)]);
    %% Data
    for group = groups
        cd(data_location{strcmpi(data_location(:,1), data_set),2});
        expected_rois = 9;  % check

        count = 0;
	subjects = Subj_Groups(subject_set);
        for i = subjects{group,2}
            file_name = strcat('processed_subject_',num2str(i, '%02.0f'),'.mat');
            try
                data_whole = integration_filter(importdata(file_name));  
            catch ME
                warning(strcat(file_name,' did not load properly.'))
                continue
            end
            
            %% time series plots
            if L == period_length(1)
                if plot_ts == 'y'
                    [~, ~, ~, total_spect] = ...
                        sort_lead(create_lead(alt_norm(integration_filter(data_whole)))...
                        , ROIS, base_roi);
                    figure(30 + group)
                    if count == 0; fullscreen(gcf); end
                    set(gcf,'DefaultAxesColorOrder',colorset)
                    subplot(3, 3, find(subjects{group,2} == i))
                    treated = alt_norm(integration_filter(data_whole));
                    plot(treated.');
                    set(gca, 'ytick', []);
                    title({strcat('Subj', num2str(i, ' %i')); ...
                        strcat('Mean var =', num2str(mean(var(treated)), ' %5.2f'))});
                    ratio = abs(total_spect(1:2:5,1)) ./ abs(total_spect(3:2:7, 1));
                    xlabel(num2str(ratio.', '  %6.2g  '));
                    axis('tight')
                    annotation('textbox', [.25, .99, .5, 0.01], ...
                    'string', {subjects{group}}, ...
                    'linestyle', 'none', ...
                    'fontsize', 18, 'fontweight', 'bold',...
                    'horizontalalignment','center', ...
                    'units', 'normalized');
                end
            end
            
            %% binning
            if ischar(bin_starts)
                if strcmpi(bin_starts,'rand')
                    starts = randi(length(data_whole) - L, ...
                        1, round(length(data_whole) / L));
                elseif strcmpi(bin_starts, 'divided')
                    starts = (1:L:length(data_whole) - L);
                else
                    warning(['Variable ''bin_starts'' can be ',...
                        '''rand'' or ''divided''. Assumed ''divided''.']);
                    bin_starts = 'divided';
                    starts = (1:L:length(data_whole) - L);
                end
                        
            elseif isnumeric(bin_starts)
                starts = bin_starts(bin_starts + L <= length(data_whole));
            else 
                error('The variable ''bin_starts'' must be character or numeric type');
            end
            bins = numel(starts);
            
            %% analysis
            for n = 1:bins
                count = count + 1;
                data = data_whole(:, starts(n): starts(n) + L);

                if exist('r', 'var')
                    for c = 1:r
                        data(mn(1,r),:) = mean(data(mn(:,r),:));
                    end
                    data(del,:) = [];
                end

                normed_data = alt_norm(data);
                lead_matrix = create_lead(normed_data); 
                if count == 1
                    if group == 1
                        eig_vals = zeros(size(groups,2), numel(subjects{group, 2})*bins,...
                            numel(ROIS(:, 1)));
                    end
                    eig_cycles = zeros(numel(subjects{group,2}) * bins, numel(ROIS(:,1)));
                    eig_perm = eig_cycles;
%                     eig_vals(group,count,:) = eig_cycles;
                    mtx = zeros(size(data,1)); 
                end
                [eig_vec, eig_perm(count,:), sorted_lead_matrix, spectrum(group,count,:)] = ...
                    sort_lead(lead_matrix, ROIS, base_roi);

                eig_cycles(count,eig_perm(count,:)) = eig_vec(:,1);
                mm = zeros(size(data,1));
                for k = 1:size(data,1)
                    p = eig_perm(count,:);
                    [~, ps] = sort(p);
                    mm(k, p(1:ps(k))) = 1;
                end
                mtx = mtx + mm - eye(size(data,1));
            end

        end
        mtx = mtx ./ count;

        % Kill zero rows
        eig_cycles = eig_cycles(1:count,:);

        %% textboxes
        if ischar(bin_starts); 
            msg = ['Time bin starts = ',bin_starts]; 
        else 
            msg = ['Time bin starts = [', num2str(sort(starts)),']'];
        end
        bin_txt = @(more_txt) annotation('textbox', [0.01, .52, .2, 0], ...
            'string', {data_set;more_txt;msg},...
            'linestyle', 'none', ...
            'fontsize', 18, 'fontweight', 'bold',...
            'units', 'normalized');
        pos = @(pp)[pp(1), pp(2) + pp(4) - .005, pp(3), 0];
        txt = @(pos) annotation('textbox',pos,'String',['n = ',num2str(count)],...
            'horizontalAlignment', 'center', 'linestyle', 'none');
        legend_label = ROIS(:,1); 
            for roi = 1:numel(ROIS(:,1))
                roi_name = ROIS(roi, 1);
                legend_label(roi) = strcat('(',num2str(roi),')',{' '}, ...
                    roi_name(1:min(length(roi_name), 8)));
            end
        lgnd_box = @() annotation('textbox', [.01, .95, .15, 0], ...
            'string', legend_label,...
            'fontweight', 'bold', ...
            'units', 'normalized',...
            'fontsize', 14,...
            'linestyle', 'none');
        
        %% bubble plots
        mean_cycles = mean(eig_cycles);
%         [stdsort,ss] = sort(std(eig_cycles));
% 
%         figure(1); 
%         set(gcf,'DefaultAxesColorOrder',colorset)
%     subplotNo = find(L == period_length) + (group - 1) * numel(period_length);
%         tight_subplot(numel(groups), numel(period_length), subplotNo)
%         % plot the lines (without markers) for the mean of the phases. If you plot
%         % with markers, the legend gets ridiculous looking
%         h = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * mean_cycles)],'linewidth',2);
%         % plot the black unit circle
%         t = linspace(0, 2*pi, 250); hold on;
%         plot(cos(t), sin(t),'k'); 
%         axis([-1.2, 1.2, -1.2, 1.2]);
%         axis('square');
%         title({subjects{group};strcat('Period length = ',num2str(L))})
%         % legend(ROIS(sm),'Location','northwest'); 
%         if subplotNo == 1
%             bin_txt('Bubbles');
%             legend(ROIS(sort(ss)),'Position', [.07, .85, 0, 0]);
% %             legend(ROIS(sort(ss)),'Location', 'northwestoutside')
%             fullscreen(gcf)
%         end;
%         set(gca, 'xtick', [], 'ytick', []);
%         pp = get(gca, 'position'); 
%         txt(pos(pp))
% 
%         % Add in the error bars
%         for i = 1:numel(ss)
%             t = linspace(max(mean_cycles(ss(i)) - stdsort(i), min(eig_cycles(:,ss(i)))), ...
%                 min(mean_cycles(ss(i)) + stdsort(i), max(eig_cycles(:,ss(i)))), 250);
%             if sum(abs(t)) == 0; continue; end;
%             plot((3 * numel(ss) + ss(i))/(4 * numel(ss)) * exp(1j * t), ...
%                 'Color', get(h(ss(i)),'Color'), ...
%                 'LineWidth',2)
%         end
% 
%         % Add the markers (ordered from largest to smallest) and correct the colors
%         g = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * mean_cycles(ss))], 'linewidth', 2);
% 
%         for i = 1:numel(ss)
%             set(g(i),'Marker','o','MarkerSize',point_size(stdsort(i)),...
%                 'MarkerFaceColor',get(h(ss(i)),'Color'),...
%                 'Color', get(h(ss(i)),'Color'))
%         end
        
        %% angle matrices
        [rows, cols] = meshgrid(mean_cycles);
        angle_mtx = cols - rows;
        figure(41)
        set(gcf, 'DefaultAxesPosition', [.15 .05 .86 .9]);
        tight_subplot(numel(groups), numel(period_length), ...
            find(L == period_length) + (group - 1) * numel(period_length))
        angle_range = [-pi/4, pi/4];
        imagesc(angle_mtx, angle_range);
        set(gca, 'Xtick', (1:size(ROIS,1)));
        xlabel('Ahead'); ylabel('Behind')
        title({subjects{group};strcat('Period length = ',num2str(L));...
            strcat('n=',num2str(count))})
        colorbar('Ytick', (angle_range(1):pi/8:angle_range(2)),...
            'Yticklabel', {'-pi/4'; '-pi/8'; '0'; 'pi/8'; 'pi/4'});
        angle_expln = ['The color in position (i, j) indicates the angular ',...
            'distance between i and j. If the color at (i, j) is ',...
            'equivalent to \pi/4, then i is \pi/4 behind j. ',...
            'If (i, j) is -\pi/4, then i is \pi/4 ahead of j. ',...
            'Angles range from -\pi/4 to \pi/4; angles greater than \pi/4 ',...
            'show as \pi/4, and those less than -\pi/4 show as -\pi/4.'];

%         pp = get(gca, 'position'); 
%         txt(pos(pp))
        
%         %% bar plots
%         figure(11);
%         colormap(colorset);
%         set(gcf, 'DefaultAxesPosition', [.16 .05 .77 .9]);
%         subplot(numel(groups), numel(period_length), ...
%             find(L == period_length) + (group - 1) * numel(period_length))
%         bar(mtx, 'stack');
%         pp = get(gca, 'position'); 
%         txt(pos(pp));
%         ylim([0 7])
%         title({subjects{group};strcat('Period length = ',num2str(L))})
%         xlabel('Region'); ylabel('Proportion of time showing up after')
%         if subplotNo == 1
%             legend_label = ROIS(:,1); 
%             for roi = 1:numel(ROIS(:,1))
%                 legend_label(roi) = strcat('(',num2str(roi),')',{' '}, ROIS(roi,1));
%             end
%             legend(legend_label,'Position', [.07, .85, 0, 0])
%             bin_txt();
%             fullscreen(gcf)
%         end
        %% variance matrices
        figure(21)
        set(gcf, 'DefaultAxesPosition', [.15 .05 .86 .9]);
        tight_subplot(numel(groups), numel(period_length), ...
            find(L == period_length) + (group - 1) * numel(period_length));
        imagesc(mtx, [0 1])
        var_colors = [0 0 0; .6667 0 0; 1.0 .3333 0; 1 1 0; 1 1 1];
        colormap(var_colors);
%         pp = get(gca, 'position'); 
%         txt(pos(pp));
        title({subjects{group};strcat('Period length = ',num2str(L));...
            strcat('n=',num2str(count))})
        xlabel('Before'); ylabel('After')
        colorbar;   
        set(gca, 'Xtick', (1:size(ROIS,1)));
        var_expln = ['The color in position (i, j) indicates the proportion ',...
            'of times i came after j. If the color at (i, j) is ',...
            'equivalent to 1, then i came after j every time. ',...
            'If (i, j) is 0.5, then i came after j only 50% of the time. '];
    end
end


figure(41); bin_txt('Angles'); lgnd_box(); fullscreen(gcf);
annotation('textbox', [.01, .35, .12, 0], ...
            'string', angle_expln,...
            'units', 'normalized',...
            'fontsize', 12,...
            'linestyle', 'none');
figure(21); bin_txt('Variation'); lgnd_box(); fullscreen(gcf);
annotation('textbox', [.01, .35, .12, 0], ...
            'string', var_expln,...
            'units', 'normalized',...
            'fontsize', 12,...
            'linestyle', 'none');
% 
% figure(1); 
% legend(ROIS(sort(sm)),'Location', 'northwestoutside')
% figure(11);
% legend(legend_label, 'Location', 'northwestoutside');

%% For PI4 Slides
% figure; 
% tight_subplot(1,2,1);
% set(gcf,'DefaultAxesColorOrder',[0,0,1;1,0,1])
% plot(normed_data(1:2,:).'); axis('tight');
% tight_subplot(1,2,2);
% plot(normed_data(1,:), normed_data(2,:));
% 
% figure; 
% subplot(2,2,1);
% set(gcf,'DefaultAxesColorOrder',jet(9))
% plot(normed_data.'); axis('tight');
% set(gca, 'ytick', [], 'xtick', []);
% subplot(2,2,2);
% imagesc(sorted_lead_matrix); 
% set(gca, 'ytick', [], 'xtick', []);
% subplot(2,2,3);
% [V,S] = eig(sorted_lead_matrix); 
% plot(V(:,1),'b*-'); hold on; plot(0,0,'r*');
% set(gca, 'ytick', [], 'xtick', []);
% axis([-.5, .5, -.5, .5]); axis('square');
% subplot(2,2,4);
% stem(abs(diag(S)));
% set(gca, 'ytick', [], 'xtick', []);

figure; 
set(gcf, 'DefaultAxesPosition', [.05 .05 .86 1], ...
    'PaperOrientation', 'landscape',...
    'units', 'normalized', 'outerposition', [0 0 1 .4]);
r=1; c=7;

tight_subplot(r,c,1);
set(gcf,'DefaultAxesColorOrder',jet(9))
plot(data.');
set(gca, 'ytick', [], 'xtick', []);
axis('square', 'tight')

tight_subplot(r,c,2);
set(gcf,'DefaultAxesColorOrder',[0,0,1;1,0,1])
plot(normed_data(1:3:4,:).');
set(gca, 'ytick', [], 'xtick', []);
axis('square', 'tight');

tight_subplot(r,c,3);
plot(normed_data(1,:), normed_data(2,:));
set(gca, 'ytick', [], 'xtick', []);
axis('square');
 
tight_subplot(r,c,4);
set(gcf,'DefaultAxesColorOrder',jet(9))
plot(normed_data.');
set(gca, 'ytick', [], 'xtick', []);
axis('square', 'tight')

tight_subplot(r,c,5);
imagesc(sorted_lead_matrix); 
set(gca, 'ytick', [], 'xtick', []);
axis('square')

tight_subplot(r,c,0);
[V,S] = eig(sorted_lead_matrix); 
plot(V(:,1),'b*-'); hold on; plot(0,0,'r*');
set(gca, 'ytick', [], 'xtick', []);
axis([-.5, .5, -.5, .5]); axis('square');
% [V,~] = eig(sorted_lead_matrix); 
% plot(V(:,1),'b*-'); hold on; plot(0,0,'r*');
% set(gca, 'ytick', [], 'xtick', []);
% axis([-.5, .5, -.5, .5]); axis('square');

tight_subplot(r,c,7);
stem(abs(diag(S)));
set(gca, 'ytick', [], 'xtick', []);
axis('square')
