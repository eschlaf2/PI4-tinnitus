% Determine which triples show up in at least 2/3 subjects. The cell array
% 'perms' (from analyze_cyclicity.m) should already be in the list of
% variables. This script will produce a file in the current directory
% called 'triples.txt'.

files = dir('HCP*cyclicity.mat');
files = [files;dir('NH*cyclicity.mat');dir('TIN*cyclicity.mat')];

thresh = 2/3;
hi_thresh = 3/4;
lo_thresh = 1/2;

style = 'rbkmcg';

% style = [{'ro'}, {'b.'}, {'m^'},{'kv'}, {'g*'}, {'ys'}];
lgnd = {};
if (exist('s','var') == 0)
    s = 1;
end


for file = files'
    load(file.name);

    n = length(perms{1});
    [a, b, c] = ndgrid(1:n, 1:n, 1:n);
    
    triples = zeros(n,n,n);
    for count = (1:length(perms))
        p = perms{count};
        
%         for i = (1:n)
%             for j = (i+1:n+i-2)
%                 jj = mod(j-1,n)+1;
%                 for k = (jj+1:n+i-1)
%                     kk = mod(k-1,n)+1;
%                     index = sub2ind(size(triples),p(i),p(jj),p(kk));
%                     triples(index) = triples(index) + 1;
%                 end
%             end
%         end
        
        for i = (1:n-2)
            for j = (i+1:n-1)
                for k = (j+1:n)
                    index = sub2ind(size(triples),p(i),p(j),p(k));
                    triples(index) = triples(index) + 1;
                end
            end
        end
    end
    triples = [a(:) b(:) c(:) triples(:)];
    
    coords = triples(triples(:,4)>=thresh*count,:);
    if size(coords,1) < 50
        coords = triples(triples(:,4)>lo_thresh*count,:);
        disp([file.name,': lo_thresh']);
    elseif size(coords,1) > 300
        coords = triples(triples(:,4)>=hi_thresh*count,:);
        disp([file.name,': hi_thresh']);
    end
 
%     try
    figure(1);
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
    figure(2);
    plot3(coords(:,1),coords(:,2),coords(:,3),...
        [style(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('1'); ylabel('2'); zlabel('3');
    grid('on');
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
        save(filename,'coords');
    end
    
    lgnd{s} = group;
    s = s+1;
end
figure(1)
legend(lgnd,'interpreter','none')
figure(2)
legend(lgnd,'interpreter','none')
clear s