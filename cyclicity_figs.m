function [] = cyclicity_figs(file_name, group, p)
% creates cyclicity figures for file_name containing variables phases,
% perm, slm, evals.

if ischar(file_name)
    C = load(file_name);
else
    error('First input should be the name of a file.')
end

if ~exist('group','var')
    group = 'quad';
    p = 1;
elseif ~exist('p','var')
    p=1;
end

INTERVAL_SIZE = 20;
for set_start = (1:INTERVAL_SIZE:length(C.perms))
    set_size = min(INTERVAL_SIZE, length(C.perms) - set_start + 1);
%     close all;
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
        title([num2str(p),':',num2str(p+1),' = ',...
            num2str(abs(C.evals{index}(2*p-1)/C.evals{index}(2*p+1)))]);
%         title(['first:second =
%         ',num2str(abs(evals{index}(1)/evals{index}(3)))]); 2/2
        axis('square')
        subplot(1,3,3)
        imagesc(C.slm{index})
        title(group,'interpreter','none')
        set(gca,'xtick',[],'ytick',[]);
        axis('square')
%         p = num2str(region_numbers{index}(C.perms{index}));
%         p = strjoin(num2str(C.perms{index},',');
        p = strjoin({num2str(C.perms{index}(:)')},',');
        annotation('textbox',[.05 .05 .9 .05], 'string', p, ...
            'linestyle','none','horizontalalignment','center');
        set(h(i),'units','normalized','position',[0 .5 1 .5]);
    %     fullscreen(h(i));
    end

    folder_name = [group,'_figs'];
    if ~exist(folder_name,'dir')
        mkdir(folder_name)
    end

    file_name = [group, num2str(set_start), '-', num2str(index), '.fig'];
    savefig(h,[folder_name, '/', file_name])
end