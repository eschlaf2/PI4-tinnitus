function [] = refine_cyclicity_HCP(file_pattern, region_names_file, n, out_dir)
% Analyzes cyclicity for data_file in current directory 
% and then reanalyzes using only traces corresponding to n
% highest phases (in absolute value).

% regions_of_interest;    % generates ROIS variable
if ~exist('n','var')
    n=10;
    out_dir = '';
elseif ~exist('out_dir','var')
    out_dir = '';
end

if ~strcmp(out_dir, '') && out_dir(end) ~= '/'
    out_dir = [out_dir,'/'];
end

SAVE_PICS = true;
s = HWSetup(min(n,7));

files = dir(file_pattern);
subject = cell(length(files),1);
out_perm = cell(length(files),3);
eval_ratio = out_perm;
region_names = importdata(region_names_file);

i = 1;
for file = files'
    
    subject{i} = file.name(end-9:end-4);
    data = importdata(file.name);

    group = '1';
    p = 1;
    [phase_sort, out_perm{i,1}, eval_ratio{i,1}] = ...
        run_analysis(data, n, p, group, region_names);
    fileid = set_fileid(out_dir, subject{i}, p, n, group);
    fprintf('Generating file %s\n',fileid);
    save_fig(gcf, fileid, s, SAVE_PICS);

    % group 2
    group = '2';
    in_perm = phase_sort(n+1:end);
    [~, out_perm{i,2}, eval_ratio{i,2}] = run_analysis(data(phase_sort(n+1:end),:), ...
        n, p, group, region_names, in_perm);
    fileid = set_fileid(out_dir, subject{i}, p, n, group);
    fprintf('Generating file %s\n',fileid);
    save_fig(gcf, fileid, s, SAVE_PICS);

    % group 3
    % Use second eigenvector to determine top traces
    group = '1';
    p=3;
    [~, out_perm{i,3}, eval_ratio{i,3}] = run_analysis(data, n, p, ...
        group, region_names); 
    fileid = set_fileid(out_dir, subject{i}, p, n, group);
    fprintf('Generating file %s\n',fileid);
    save_fig(gcf, fileid, s, SAVE_PICS);
    
    i = i+1;
end
save([out_dir,'refine_cyclicity_output'],'subject','out_perm','eval_ratio')
end

function [fileid] = set_fileid(root, file_name, p, n, group)
% Returns a string to be used for fileid when saving. Takes as input root
% (the root directory where the file should be saved), data_file (the name
% of the file where the data is stored), n (the number of categories),
% group (the subset of n categories).

fileid = [root, file_name, '_p',num2str(p),...
    '_n',num2str(n),'_gp', group];
end

function [phase_sort, out_perm, eval_ratio] = ...
    run_analysis(data, n, p, group, region_names, in_perm)
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


if ~exist('in_perm', 'var')
    in_perm = (1:size(data,1))';
end

% First analysis to get all phases
[orig_phases, orig_perm, ~, ~] = cyclic_analysis(data, p);
% [orig_phases, ~, ~, ~] = cyclic_analysis(data, 'quad', p);
[~, phase_sort] = sort(abs(orig_phases),'descend');  % sort

% Analyze and make figs for top n
% [~, perm, ~, evals] = ...
[phases, perm, slm, evals] = ...
    cyclic_analysis(data(phase_sort(1:n),:), 1);

data_lines = data(phase_sort(perm),:);
cyclicity_figs([], data_lines, orig_phases, orig_perm, phase_sort(1:n), ...
    {perm}, {phases}, {slm}, {evals}, 1, ...
    region_names, in_perm, group, p);
out_perm = in_perm(phase_sort(perm));
evals = abs(evals);
if evals(1) < evals(2)
	eval_ratio = evals(2)/evals(4);
else
	eval_ratio = evals(1)/max(evals(3),evals(4));
end
end

function [] = cyclicity_figs(file_name, data_lines, orig_phases, orig_perm,...
    phase_sort, perms, phases, slm, evals, ...
    subject, region_names, region_numbers, group, p)
% creates cyclicity figures for file_name containing variables phases,
% perms, slm, evals.

if ischar(file_name)
    load(file_name);
end

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

% regions_of_interest;
% region_names = ROIS(:,1);
% categories = cell(length(orig_perm),1);
% for i = (1:length(categories))
%     categories{i} = num2str(i);
% end

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
        plot(data_lines');
        set(gca,'ytick',[]);
        leg1 = legend(region_names(region_numbers(phase_sort(perms{index}))), ...
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

%     folder_name = [group,'_figs'];
%     if ~exist(folder_name,'dir')
%         mkdir(folder_name)
%     end
% 
%     file_name = [group, num2str(set_start), '-', num2str(index), '.fig'];
%     savefig(h,[folder_name, '/', file_name])
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

savefig(h,fileid);

if save_bool
    hgexport(h, fileid, s);
end

end
