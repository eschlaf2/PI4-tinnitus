% Determine which triples show up in at least 2/3 subjects. The cell array
% 'perms' (from analyze_cyclicity.m) should already be in the list of
% variables. This script will produce a file in the current directory
% called 'triples.txt'.
thresh = 2/3;
hi_thresh = 3/4;
lo_thresh = 1/2;

style = 'rbk';

% style = [{'ro'}, {'b.'}, {'m^'},{'kv'}, {'g*'}, {'ys'}];
lgnd = {};
if (exist('s','var') == 0)
    s = 1;
end

files = dir('TIN*cyclicity.mat');
files = [files;dir('Rest*cyclicity.mat')];


for file = files'
    load(file.name);

    n = length(perms{1});
    [a, b, c] = ndgrid(1:n, 1:n, 1:n);
    
%     triples = zeros(n^3,4);
%     for i = (1:n)
%         for j = (1:n)
%             for k = (1:n)
%                 triples(n*n*(i-1) + n*(j-1) + k,1:3) = [i,j,k];
%             end
%         end
%     end
    triples = zeros(n,n,n);
    for count = (1:length(perms))
        p = perms{count};
        for i = (1:n-2)
            for j = (i+1:n-1)
                for k = (j+1:n)
                    index = sub2ind(size(triples),p(i),p(j),p(k));
                    triples(index) = triples(index) + 1;
                end
            end
        end
    end
    thresh = 2/3;
    triples = [a(:) b(:) c(:) triples(:)];
    coords = triples(triples(:,4)>=thresh*count,:);
    if size(coords,1) < 50
        coords = triples(triples(:,4)>=lo_thresh*count,:);
    end
    if size(coords,1) > 300
        coords = triples(triples(:,4)>=hi_thresh*count,:);
    end
    
%     for count = (1:length(perms))
%         p = perms{count};
%         for i = (1:n-2)
%             for j = (i+1:n-1)
%                 for k = (j+1:n)
%                     x = p(i); y = p(j); z = p(k);
%                     index = (x-1)*n*n + (y-1)*n + z;
%                     triples(index,4) = triples(index,4) + 1;
%                 end
%             end
%         end
%     end
 
%     try
    ms = (length(files) + 1 - s)*4;
    subplot(1,3,1);
    plot(coords(:,1),coords(:,2),[style(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('1');
    ylabel('2');
    hold on;
    subplot(1,3,2);
    plot(coords(:,1),coords(:,3),[style(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('1');
    ylabel('3');
    hold on;
    subplot(1,3,3);
    plot(coords(:,2),coords(:,3),[style(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('2');
    ylabel('3');
    hold on;
%     end

    ind = strfind(file.name,'cyclicity');
    group = file.name(1:ind-2);

    % create triples files
    if (0==1)
        regions_of_interest;
        ind = strfind(file.name,'cyclicity');
        filename = [file.name(1:ind-1),'triples'];
        fileID = fopen([filename,'.txt'],'w');
        fprintf(fileID,'%s\nTotal subjects: %d\n',pwd,count);
        for i = (1:size(coords,1))
            x = strtrim(ROIS{coords(i,1)});
            y = strtrim(ROIS{coords(i,2)});
            z = strtrim(ROIS{coords(i,3)});
            w = coords(i,4);
            fprintf(fileID,'%s,%s,%s,%d\n',x,y,z,w);
        end
        fclose(fileID);
        save(filename,'triples');
    end
    
    lgnd{s} = group;
    s = s+1;
end
legend(lgnd,'interpreter','none')
clear s