% Generate a circular errorbar plot with the size of the markers dependent
% upon the variance in the data. July 14th updated Jul2 version to
% highlight smaller (rather than larger) variances and hold colors constant
% for each ROI across plots.
% *** Errors in legends of bubble plots ***

%% Parameters
close all; clear all;
GROUPS; regions_of_interest;
bilat_avg = {};
% {'parahippocampus', 'auditory cortex', 'frontal lobe'};
base_roi = 'l parahip';
groups = [1 2];
% time_bins = 5;
bin_starts = 'divided'; %(25:60:200);
period_length = [30 60 120]; 
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
        cd('/Users/emilyschlafly/Box Sync/PI4/Raw Data/Music/fitness study');
        expected_rois = 9;  % check

        count = 0;
        for i = Subj_Groups{group,2}
            file_name = strcat('processed_subject_',num2str(i, '%02.0f'),'.mat');
            try
                data_whole = integration_filter(importdata(file_name));  
            catch ME
                warning(strcat(file_name,' did not load properly.'))
                continue
            end
            
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
        %     if L == 15;
        %         starts = starts + 15;
        %     end

        %     bins = min(time_bins, round(length(data_whole)/L));
            bins = numel(starts);

            for n = 1:bins
                count = count + 1;
        %         els = floor(length(data_whole)/bins);
                % Take random periods of length L rather than sequential bins
                data = data_whole(:, starts(n): starts(n) + L);
        %         if L > 0
        %             start = randi(length(data_whole) - L);
        %             data = data_whole(:, start:start + L);
        %         else
        %             data = data_whole(:,(n - 1) * els + 1 : n * els);
        %         end

                if exist('r', 'var')
                    for c = 1:r
                        data(mn(1,r),:) = mean(data(mn(:,r),:));
                    end
                    data(del,:) = [];
                end

            %     Create and sort lead matrix
        %         filtered = integration_filter(data); % filtered at acquisition
                normed_data = alt_norm(data);
                lead_matrix = create_lead(normed_data); 
                if count == 1
                    eig_cycles = zeros(numel(Subj_Groups{group,2}) * bins, numel(ROIS(:,1)));
                    eig_perm = eig_cycles;
                    spectrum = eig_cycles;
                    mtx = zeros(size(data,1)); 
                end
                [eig_phases, eig_perm(count,:), sorted_lead_matrix, spectrum(count,:)] = ...
                    sort_lead(lead_matrix, ROIS, base_roi);

                eig_cycles(count,eig_perm(count,:)) = eig_phases;
                mm = zeros(size(data,1));
                for k = 1:size(data,1)
                    p = eig_perm(count,:);
                    [~, ss] = sort(p);
                    mm(k, p(1:ss(k))) = 1;
                end
                mtx = mtx + mm - eye(size(data,1));
            end

        end
        mtx = mtx ./ count;

        % Kill zero rows
        eig_cycles = eig_cycles(1:count,:);

        % Sort by Mean so that ROIS are plotted in order (makes the legend come out
        % ordered); sort by Standdev so that later big markers are plotted first 
        % (so they don't cover smaller markers)

        %% textboxes
        if ischar(bin_starts); 
            msg = ['Time bin starts = ',bin_starts]; 
        else 
            msg = ['Time bin starts = [', num2str(sort(starts)),']'];
        end
        bin_txt = @() annotation('textbox', [0.01, .55, .15, 0], ...
            'string', msg,...
            'linestyle', 'none', ...
            'fontsize', 18, 'fontweight', 'bold',...
            'units', 'normalized');
        pos = @(pp)[pp(1), pp(2) + pp(4) - .005, pp(3), 0];
        txt = @(pos) annotation('textbox',pos,'String',['n = ',num2str(count)],...
            'horizontalAlignment', 'center', 'linestyle', 'none');

        %% bubble plots
        [meansort,sm] = sort(mean(eig_cycles));
        [stdsort,ss] = sort(std(eig_cycles(:,sm)));

        colorset = [lines(7);cool(2)];
        figure(1); 
        set(gcf,'DefaultAxesColorOrder',colorset(sm,:))
        subplotNo = find(L == period_length) + (group - 1) * numel(period_length);
        tight_subplot(numel(groups), numel(period_length), subplotNo)
        % plot the lines (without markers) for the mean of the phases. If you plot
        % with markers, the legend gets ridiculous looking
        h = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * meansort)],'linewidth',2);
        % plot the black unit circle
        t = linspace(0, 2*pi, 250); hold on;
        plot(cos(t), sin(t),'k'); 
        axis([-1.2, 1.2, -1.2, 1.2]);
        axis('square');
        title({Subj_Groups{group};strcat('Period length = ',num2str(L))})
        % legend(ROIS(sm),'Location','northwest'); 
        legend(ROIS(sm),'Location', 'northwestoutside')
        if subplotNo == 1
            bin_txt();
            fullscreen(gcf)
        end;
        set(gca, 'xtick', [], 'ytick', []);
        pp = get(gca, 'position'); 
        txt(pos(pp))

        % Add in the error bars
        for i = 1:numel(ss)
            t = linspace(max(meansort(ss(i)) - stdsort(i), min(eig_cycles(:,sm(ss(i))))), ...
                min(meansort(ss(i)) + stdsort(i), max(eig_cycles(:,sm(ss(i))))), 250);
            if sum(abs(t)) == 0; continue; end;
            plot((3 * numel(ss) + ss(i))/(4 * numel(ss)) * exp(1j * t), ...
                'Color', get(h(ss(i)),'Color'), ...
                'LineWidth',2)
        end

        % Add the markers (ordered from largest to smallest) and correct the colors
        g = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * meansort(ss))], 'linewidth', 2);

        for i = 1:numel(ss)
        %     set(g(i),'Marker','o','MarkerSize',min((min_ps / max(stdsort(i), 1))^4 * 7, max_ps),...
            set(g(i),'Marker','o','MarkerSize',point_size(stdsort(i)),...
                'MarkerFaceColor',get(h(ss(i)),'Color'),...
                'Color', get(h(ss(i)),'Color'))
        end

        %% bar plots
        figure(11);
        % fullscreen(gcf);
        colormap(colorset);
        set(gcf, 'DefaultAxesPosition', [.16 .05 .77 .9]);
        subplot(numel(groups), numel(period_length), ...
            find(L == period_length) + (group - 1) * numel(period_length))
        bar(mtx, 'stack');
        pp = get(gca, 'position'); %pos = [pos(1), pos(2) + pos(4), pos(3), 0];
        txt(pos(pp));
        ylim([0 7])
        title({Subj_Groups{group};strcat('Period length = ',num2str(L))})
        xlabel('Region'); ylabel('Proportion of time showing up after')
        if subplotNo == 1
            legend_label = ROIS(:,1); count = 0;
            for roi = 1:numel(ROIS(:,1))
                legend_label(roi) = strcat('(',num2str(roi),')',{' '}, ROIS(roi,1));
            end
            legend(legend_label,'Location', 'northwestoutside')
            bin_txt();
            fullscreen(gcf)
        end
    end
end



% 
% figure(1); 
% legend(ROIS(sort(sm)),'Location', 'northwestoutside')
% figure(11);
% legend(legend_label, 'Location', 'northwestoutside');

