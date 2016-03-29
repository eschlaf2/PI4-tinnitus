function [] = cyclicity_figs(file_name, varargin)
% creates cyclicity figures for file_name containing variables phases,
% perm, slm, evals.

% ===== parse input =====
p = inputParser;

defaultGroupTitle = 'results';
defaultRowLabels = 0;

addRequired(p, 'file_name', @isstr);
addParameter(p, 'group_title', defaultGroupTitle);
addParameter(p, 'row_labels', defaultRowLabels);

parse(p, file_name, varargin{:});

file_name = p.Results.file_name;
C = load(file_name);
group_title = p.Results.group_title;
row_labels = p.Results.row_labels;
if isnumeric(row_labels)
    row_labels = cell(numel(C.perms{1}),1);
    for i = (1:numel(row_labels))
        row_labels{i} = num2str(i);
    end
%     row_labels = row_labels
end
% ===== end parse =====

INTERVAL_SIZE = 20;
for set_start = (1:INTERVAL_SIZE:length(C.perms))
    set_size = min(INTERVAL_SIZE, length(C.perms) - set_start + 1);
    close all;
    h=zeros(1,set_size);
    for i=1:set_size
        index = set_start + i - 1;
        h(i) = figure;
        subplot(1,3,1)
        plot(.25*exp(1i*angle(C.phases{index}(C.perms{index}))),'bo-')
        hold on;
        plot(C.phases{index}(C.perms{index}),'g')
        plot(.25*exp(1i*angle(C.phases{index}(C.perms{index}(1)))),'r*')
        axis([-.4, .4, -.4, .4])
        title(['Subject ',C.subject(index)]);
        axis('square')
        hold off;
        subplot(1,3,2)
        stem(abs(C.evals{index}),'b')
        C.evals{index} = abs(C.evals{index});
        eval_ratio = C.evals{index}(2)/C.evals{index}(4);
        
        title(['1:2 = ', num2str(eval_ratio)]);
%         title(['first:second =
%         ',num2str(abs(evals{index}(1)/evals{index}(3)))]); 2/2
        axis('square')
        subplot(1,3,3)
        imagesc(C.slm{index})
        title(group_title,'interpreter','none')
        set(gca,'xtick',[],'ytick',[]);
        axis('square')
%         p = num2str(region_numbers{index}(C.perms{index}));
%         p = strjoin(num2str(C.perms{index},',');
        p = strjoin(strtrim(row_labels(C.perms{index}))','    ');
%         p = strjoin({num2str(C.perms{index}(:)')},',');
        annotation('textbox',[.05 .05 .9 .05], 'string', p, ...
            'linestyle','none','horizontalalignment','center');
        set(h(i),'units','normalized','position',[0 .5 1 .5]);
    %     fullscreen(h(i));
    end

    folder_name = [group_title,'_figs'];
    if ~exist(folder_name,'dir')
        mkdir(folder_name)
    end

    file_name = [group_title, num2str(set_start), '-', num2str(index), '.fig'];
    savefig(h,[folder_name, '/', file_name])
end