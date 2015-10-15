% Generate a circular errorbar plot with the size of the markers dependent
% upon the variance in the data. July 14th updated Jul2 version to
% highlight smaller (rather than larger) variances and hold colors constant
% for each ROI across plots.

%% Parameters
close all; clear all;
GROUPS; regions_of_interest;
bilat_avg = {};
% {'parahippocampus', 'auditory cortex', 'frontal lobe'};
base_roi = 'r primary auditory';
group = 1; %run different groups separately
bin_starts = 'divided'; %(1:60:200); %Music starts at 25; can also put 'divided' or 'rand'
period_length = 120; %run different lengths separately; 
plot_ts = 'n'; %'y' or 'n'%
subject_set = 'Music';
data_set = 'Resting';

%% Data sets
data_location = {'Resting', '/home/eschlaf2/PI4/Resting_matrices_of_music_subjects'; ...
    'Music intervals', '/Users/emilyschlafly/Box Sync/PI4/Raw Data/Music/fitness study'};
data_set = validatestring(data_set, data_location(:,1));
%%
% for period_length = period_length
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


        %% binning
        if ischar(bin_starts)
            if strcmpi(bin_starts,'rand')
                starts = randi(length(data_whole) - period_length, ...
                    1, round(length(data_whole) / period_length));
            elseif strcmpi(bin_starts, 'divided')
                starts = (1:period_length:length(data_whole) - period_length);
            else
                warning(['Variable ''bin_starts'' can be ',...
                    '''rand'' or ''divided''. Assumed ''divided''.']);
                bin_starts = 'divided';
                starts = (1:period_length:length(data_whole) - period_length);
            end

        elseif isnumeric(bin_starts)
            starts = bin_starts(bin_starts + period_length <= length(data_whole));
        else 
            error('The variable ''bin_starts'' must be character or numeric type');
        end
        bins = numel(starts);

        %% analysis
        for n = 1:bins
            count = count + 1;
            data = data_whole(:, starts(n): starts(n) + period_length);

            %bilateral averages
            if exist('r', 'var')
                for c = 1:r
                    data(mn(1,r),:) = mean(data(mn(:,r),:));
                end
                data(del,:) = [];
            end

            %analysis
            normed_data = alt_norm(data);
            lead_matrix = create_lead(normed_data); 
            if count == 1
                eig_vals = zeros(numel(subjects{group, 2})*bins,...
                    numel(ROIS(:, 1)));
                eig_vec = eig_vals;
                eig_perm = eig_vals;
                eig_phases = eig_vals;
                sorted_lead_matrix = zeros(numel(subjects{group, 2})*bins,...
                    numel(ROIS(:,1)), numel(ROIS(:,1)));
%                 eig_cycles = zeros(numel(subjects{group,2}) * bins, numel(ROIS(:,1)));
%                 eig_perm = eig_cycles;
%                 mtx = zeros(size(data,1)); 
            end
            [eig_vec(count,:), eig_phases(count,:), eig_perm(count,:), ...
                sorted_lead_matrix(count,:,:), ...
                eig_vals(count,:)] = ...
                sort_lead(lead_matrix, ROIS, base_roi);


%             eig_cycles(count,:) = eig_vec(:,1);
% Don't remember what this was for...
%             mm = zeros(size(data,1));
%             for k = 1:size(data,1)
%                 p = eig_perm(count,:);
%                 [~, ps] = sort(p);
%                 mm(k, p(1:ps(k))) = 1;
%             end
%             mtx = mtx + mm - eye(size(data,1));
        end

    end
%     mtx = mtx ./ count;

    % Kill zero rows
   % eig_cycles = eig_cycles(1:count,:);
% end
