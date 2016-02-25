function [] = make_triples()
% Determine which triples show up in at least 2/3 subjects. The cell array
% 'perms' (from analyze_cyclicity.m) should already be in the list of
% variables. This script will produce a file in the current directory
% called 'triples.txt'.

files = dir('cyclicity_quad.mat');
regions = importdata('regions.mat'); 
% regions = importdata('top10_p2.mat');
% regions = regions(:,2);
% regions = regions.region_names;

% files = [files;dir('NH*cyclicity.mat');dir('TIN*cyclicity.mat')];
CYCLE = true;
CREATE_TRIP_FILE = true;

close all;

bool2char = containers.Map({true,false},{'T','F'});
figs_out_file = ['triples_figs_cycle',bool2char(CYCLE)];

if CYCLE
    THRESH = .6;
    HI_THRESH = .7;
    LO_THRESH = .6;
else
    THRESH = 1/3;
    HI_THRESH = .5;
    LO_THRESH = 1/3;
end

% regions_of_interest;
% regions = ROIS(:,1);

STYLE = 'rbkmcg';

% style = [{'ro'}, {'b.'}, {'m^'},{'kv'}, {'g*'}, {'ys'}];
lgnd = cell(numel(files),1);
if ~exist('s','var')
    s = 1;
end


for file = files'
    load(file.name);

    N = length(perms{1});
    COUNT = length(perms);
    
%     triples = maketrips_old(perms,CYCLE);
    triples = maketrips(perms,CYCLE);

    coords = triples(triples(:,4)>=THRESH*COUNT,:);
    disp(size(coords,1))
    if size(coords,1) < N^2/10
        coords = triples(triples(:,4)>LO_THRESH*COUNT,:);
        disp([file.name,': lo_thresh']);
    elseif size(coords,1) > N^3/2
        coords = triples(triples(:,4)>=HI_THRESH*COUNT,:);
        disp([file.name,': hi_thresh']);
    end
    
    [~,coord_sort] = sort(coords(:,4), 'descend');
    coords = coords(coord_sort,:);
    
    coord_ct = size(coords,1);
 
    h = zeros(3,1);
    h(1) = figure(1);
    ms = (length(files) + 1 - s)*4;
    subplot(1,3,1);
    plot(coords(:,1),coords(:,2),[STYLE(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('1');
    ylabel('2');
    hold on;
    subplot(1,3,2);
    plot(coords(:,1),coords(:,3),[STYLE(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('1');
    ylabel('3');
    hold on;
    subplot(1,3,3);
    plot(coords(:,2),coords(:,3),[STYLE(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('2');
    ylabel('3');
    hold on;
    h(2) = figure(2);
    plot3(coords(:,1),coords(:,2),coords(:,3),...
        [STYLE(s),'o'],'markersize',ms,'linewidth',2);
    xlabel('1'); ylabel('2'); zlabel('3');
    axis([1 N 1 N 1 N])
    grid('on');
    hold on;
    h(3) = figure(3);
    subplot(1,3,1)
    hist(coords(:,1),(1:N))
    axis('tight')
    title('position 1')
    ylim([0 coord_ct])
    subplot(1,3,2)
    hist(coords(:,2),(1:N))
    axis('tight')
    title('position 2')
    ylim([0 coord_ct])
    subplot(1,3,3)
    hist(coords(:,3),(1:N))
    axis('tight')
    title('position 3')
    ylim([0 coord_ct])

    ind = strfind(file.name,'cyclicity');
    group = file.name(1:ind-2);

    % create triples files
    if CREATE_TRIP_FILE
%         regions_of_interest;
        ind = strfind(file.name,'cyclicity');
        filename = [file.name(1:ind-1),'triples'];
        fileID = fopen([filename,'.txt'],'w');
        fprintf(fileID,'%s\nTotal subjects: %d\n',pwd,COUNT);
        for i = (1:size(coords,1))
            x = strtrim(regions{coords(i,1)});
            y = strtrim(regions{coords(i,2)});
            z = strtrim(regions{coords(i,3)});
            w = coords(i,4);
            fprintf(fileID,'%s,%s,%s,%d\n',x,y,z,w);
        end
        fclose(fileID);
        save(filename,'coords');
    end
    
    lgnd{s} = group;
    s = s+1;
end
% h(1)
% legend(lgnd,'interpreter','none')
% h(2)
% legend(lgnd,'interpreter','none')
clear s
savefig(h,figs_out_file);

end

function [trips] = maketrips_old(PERMS,CYCLE)

    N = length(PERMS{1});
    trips = zeros(N,N,N);
    [a, b, c] = ndgrid(1:N, 1:N, 1:N);    
    
    for count = (1:length(PERMS))
        p = PERMS{count};
        
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
        
        for i = (1:N-2)
            for j = (i+1:N-1)
                for k = (j+1:N)
                    if CYCLE
                        pp = [p(i), p(j), p(k)];
                        [~,m] = min(pp);
                        pp = circshift(pp,4-m,2);
                        index = sub2ind(size(trips),pp(1),pp(2),pp(3));
                    else
                        index = sub2ind(size(trips),p(i),p(j),p(k));
                    end
                    trips(index) = trips(index) + 1;
                end
            end
        end
    end
    
    trips = [a(:) b(:) c(:) trips(:)];
    trips = trips(trips(:,4) > 0,:);

end

function [trips] = maketrips(PERMS, CYCLE)

N = length(PERMS{1});
trips = zeros(N,N,N);
[a, b, c] = ndgrid(1:N, 1:N, 1:N);

for p = (1:length(PERMS))
    perm = PERMS{p};
    
    for i = (1:N-2)
        for j = (i+1:N-1)
            wheel = [perm;circshift(perm,-i,2);circshift(perm,-j,2)];
            new_trips = wheel(:,1:end-j)';
            if CYCLE
                new_trips = cycle_trips(new_trips);
            end
            inds = sub2ind(size(trips),...
                new_trips(:,1), new_trips(:,2), new_trips(:,3));
            trips(inds) = trips(inds) + 1;
        end
    end
end
trips = [a(:) b(:) c(:) trips(:)];
trips = trips(trips(:,4) > 0,:);
        
end

function [trips] = cycle_trips(trips)
[~,min_loc] = min(trips(:,1:3),[],2);
shift = mod([min_loc,min_loc+1,min_loc+2] - 1, 3) + 1;
for i =(1:size(trips,1))
    trips(i,1:3) = trips(i,shift(i,:));
end
end