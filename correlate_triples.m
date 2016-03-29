function [corr_mat, trips] = correlate_triples(coords,perms)
% Generates a correlation matrix for triples (i.e. which triples show up
% together). Inputs are:
%           coords: 3xN array containing triples of interest
%               (in the form of coords from triples.mat)
%           perms: cell array of permutations from set of subjects
% Note that the algorithm does not normalize coords so that the lowest
% index is first (if this needs to be done, it should be done prior)

SAVE = true;

% coord_str = strsplit(coord2str(coords(:,1:3)'),'\n');
% N = numel(coord_str);
N = length(coords);
P = length(perms);
% coord_map = containers.Map(coord_str,(1:N));
corr_mat = zeros(N,N);
trips = cell(size(perms));

for p = (1:P)
    fprintf('Starting subject %d out of %d\n',p,P)
    trp = maketrips(perms(p),true);
    trips{p} = trp;
    for i = 1:N-1
        m1 = trp(:,1)==coords(i,1);
        m2 = trp(:,2)==coords(i,2);
        m3 = trp(:,3)==coords(i,3);
        if max(min([m1,m2,m3],[],2))
            ai = i;
        else 
            continue
        end
        for j = i+1:N
            m1 = trp(:,1)==coords(j,1);
            m2 = trp(:,2)==coords(j,2);
            m3 = trp(:,3)==coords(j,3);
            if max(min([m1 m2 m3],[],2))
                aj = j;
            else
                continue
            end
            corr_mat(ai,aj) = corr_mat(ai,aj) + 1;
        end
%     for i = 1:size(trips,1)-1
%         ai = strcmp(coord_str,coord2str(trips(i,1:3)));
%         try
%             ai = coord_map(coord2str(trips(i,1:3)));
%         catch 
%             continue
%         end
%         for j = i+1:size(trips,1)
%             try
%                 aj = coord_map(coord2str(trips(j,1:3)));
%             catch 
%                 continue
%             end
%             corr_mat(ai,aj) = corr_mat(ai,aj) + 1;
    end
end
corr_mat = corr_mat + corr_mat.';
corr_mat = corr_mat + diag(mean(corr_mat));
imagesc(corr_mat)
colorbar
plotid = strsplit(pwd,'/');
title(plotid(end),'interpreter','none')

if SAVE
    save('correlations','corr_mat','trips','coords','perms');
    savefig('correlations')
    hgexport(gcf,'correlations',HWSetup())
end

end

% function [cstr] = coord2str(coord)
% cstr = sprintf('%02d%02d%02d\n',coord);
% cstr = cstr(1:end-1);
% end