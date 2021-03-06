function [] = refine_cyclicity_movies(data_file, n, save_figs_bool)
% Analyzes cyclicity for data_file in current directory 
% and then reanalyzes using only traces corresponding to n
% highest phases (in absolute value).

if ~exist('n','var')
    n=10;
    save_figs_bool=false;
elseif ~exist('save_figs_bool','var')
    save_figs_bool = false;
end

% Save figures settings
SAVE_PICS = save_figs_bool;

if SAVE_PICS
    close all;
end

s = HWSetup(min(7, n));
root_save_plots = '/Users/emilyschlafly/Work/cyclicity_repo/Notes/pictures/';

header_file = dir('header_data*');
load(header_file.name);

data = importdata(data_file);
group = '1';
p = 1;
[phase_sort, ~] = run_analysis(data, n, p, group);
fileid = set_fileid(root_save_plots, data_file, p, n, group);
save_fig(gcf, fileid, s, SAVE_PICS);

% group 2
group = '2';
in_perm = phase_sort(n+1:end);
run_analysis(data(phase_sort(n+1:end),:), n, p, ...
    group, in_perm);
fileid = set_fileid(root_save_plots, data_file, p, n, group);
save_fig(gcf, fileid, s, SAVE_PICS);

% group 3
% Use second eigenvector to determine top traces
group = '1';
p=3;
run_analysis(data, n, p, group); 
fileid = set_fileid(root_save_plots, data_file, p, n, group);
save_fig(gcf, fileid, s, SAVE_PICS);

end

function [fileid] = set_fileid(root, data_file, p, n, group)
% Returns a string to be used for fileid when saving. Takes as input root
% (the root directory where the file should be saved), data_file (the name
% of the file where the data is stored), n (the number of categories),
% group (the subset of n categories).

fileid = [root, data_file(1:end-4), '_p',num2str(p),...
    '_n',num2str(n),'_gp', group];
end

function [phase_sort, out_perm] = run_analysis(data, n, p, group, in_perm)
% Input:
%     data = time series data, stored row wise
%     n = output analysis of traces corresponding to n largest phases 
%         (default = 10);
%     p = choose which eigenvector to use for phases
%         (default = 1);
%     group = string identifier to name analysis of group
%         (default = []);
%     in_perm = permutation of original data set
%         (default = (1:size(data,1)))

header_file = dir('header_data*');
load(header_file.name);
if ~exist('in_perm', 'var')
    in_perm = (1:size(data,1))';
end

% First analysis to get all phases
[orig_phases, orig_perm, ~, ~] = cyclic_analysis(data, 'quad', p);
[~, phase_sort] = sort(abs(orig_phases),'descend');  % sort

% Analyze and make figs for top n
[phases, perm, slm, evals] = ...
    cyclic_analysis(data(phase_sort(1:n),:),'quad', 1);

data_lines = data(phase_sort(perm),:);
cyclicity_figs([], data_lines, orig_phases, orig_perm, phase_sort(1:n), ...
    {perm}, {phases}, {slm}, {evals}, 1, ...
    in_perm, group, p, header_data.categories);
out_perm = phase_sort(perm);
% regions = in_perm(phase_sort(1:n));
% region_perm = regions(perm{:});
end

function [] = cyclicity_figs(file_name, data_lines, orig_phases, orig_perm,...
    phase_sort, perms, phases, slm, evals, ...
    subject, region_numbers, group, p, categories)
% creates cyclicity figures for file_name containing variables phases,
% perms, slm, evals.

if ischar(file_name)
    load(file_name);
end

header_file = dir('header_data*');
load(header_file.name);

if ~exist('region_numbers', 'var')
    region_numbers = {(1:length(perms))'};
    group = 'quad';
    p = 1;
elseif ~exist('group','var')
    group = 'quad';
    p = 1;
elseif ~exist('p','var')
    p=1;
end

INTERVAL_SIZE = 20;
for set_start = (1:INTERVAL_SIZE:length(perms))
    set_size = min(INTERVAL_SIZE, length(perms) - set_start + 1);
%     close all;
    h=zeros(1,set_size);
    NO_SUBPLOTS = 5;
    for i=1:set_size
        index = set_start + i - 1;
        
        h(i) = figure;
        subplot(1,NO_SUBPLOTS,1);
        plot(repmat((header_data.years(1):header_data.years(end)), ...
            size(data_lines,1),1)',data_lines');
        set(gca,'ytick',[]);
        leg1 = legend(categories(region_numbers(phase_sort(perms{index}))), ...
            'interpreter','none');
        set(leg1, 'position', [.06,.5,.01,.01], 'unit', 'normalized');
        axis('tight')
        axis('square')
        title('Time series')
        
        subplot(1,NO_SUBPLOTS,2)
        phase_plot(orig_phases, orig_perm, [{'ko-'},{'k'}]);
        plot(.25*exp(1i*angle(orig_phases(phase_sort(perms{index})))),...
            'bo-', 'linewidth', 2);
        plot(complex(.25*exp(1i*angle(orig_phases(phase_sort(perms{index}(1)))))),...
            'r*');
        axis([-.4, .4, -.4, .4])
        axis('square')
        hold off;
        title('Original phases')
        
        subplot(1,NO_SUBPLOTS,3)
        phase_plot(phases{index},perms{index});
%         plot(.25*exp(1i*angle(phases{index}(perms{index}))),'bo-')
%         hold on;
%         plot(phases{index}(perms{index}),'g')
%         plot(.25*exp(1i*angle(phases{index}(perms{index}(1)))),'r*') 2/2
        axis([-.4, .4, -.4, .4])
        axis('square')
        hold off;
        n = length(perms{index});
        title(['Top ', num2str(n), ' phases'])
%         title(['Subject ',subject(index)]);
        
        subplot(1,NO_SUBPLOTS,4)
        stem(abs(evals{index}),'b')
        xlim([0 n+1])
        title(['1:2 =',...
            num2str(min(abs(evals{index}(1)/evals{index}(3)),...
            abs(evals{index}(1)/evals{index}(4))),...
            '%2.3g')]);
        axis('square')
%         title([num2str(p),':',num2str(p+1),' = ',...
%             num2str(abs(evals{index}(2*p-1)/evals{index}(2*p+1)))]);        
        
        subplot(1,NO_SUBPLOTS,5)
%         title(group,'interpreter','none')
        imagesc(slm{index})
        set(gca,'xtick',[],'ytick',[]);
        axis('square')
        title([{['p = ', num2str(p), ...
            ', n = ', num2str(length(perms{index}))]},...
            {['group = ', group]}], 'interpreter', 'none')
        
%         p = num2str(region_numbers{index}(perms{index}));
%         p = strjoin(num2str(perms{index},',');
%         cat_results = categories(region_numbers(phase_sort(perms{index})));
%         p = strjoin(cat_results','  ');
% %         p = strjoin({num2str(region_numbers(phase_sort(perms{index}))')},',');
%         annotation('textbox',[.05 .05 .9 .05], 'string', p, ...
%             'linestyle','none','horizontalalignment','center',...
%             'interpreter', 'none');
        set(h(i),'units','normalized','position',[0 .65 1 .35]);
    %     fullscreen(h(i));
    end

    folder_name = [group,'_figs'];
    if ~exist(folder_name,'dir')
        mkdir(folder_name)
    end

    file_name = [group, num2str(set_start), '-', num2str(index), '.fig'];
    savefig(h,[folder_name, '/', file_name])
end
end

function [] = phase_plot(phases, perm, style)
if ~exist('style','var')
    style = [{'bo-'}, {'g'}];
end
plot(.25*exp(1i*angle(phases(perm))),style{1})
hold on;
plot(phases(perm),style{2})
plot(complex(.25*exp(1i*angle(phases(perm(1))))),'r*')
end

function [] = save_fig(h, fileid, s, save_bool)
%     h           figure handle
%     fileid      where to save
%     s           hgexport settings (default: HWSetup(7))   
%     save_bool   boolean save (default: true)
    
if ~exist('s', 'var')
    s = HWSetup(7);
    save_bool = true;
elseif ~exist('save_bool','var')
    save_bool = true;
end

if save_bool
    hgexport(h, fileid, s);
end

end