% Determine which triples show up in at least 2/3 subjects. The cell array
% 'perms' (from analyze_cyclicity.m) should already be in the list of
% variables. This script will produce a file in the current directory
% called 'triples.txt'.
n = length(perms{1});
triples = zeros(n^3,4);
for i = (1:n)
    for j = (1:n)
        for k = (1:n)
            triples(n*n*(i-1) + n*(j-1) + k,1:3) = [i,j,k];
        end
    end
end
for count = (1:length(perms))
    p = perms{count};
    for i = (1:n-2)
        for j = (i+1:n-1)
            for k = (j+1:n)
                x = p(i); y = p(j); z = p(k);
                index = (x-1)*n*n + (y-1)*n + z;
                triples(index,4) = triples(index,4) + 1;
            end
        end
    end
end
coords = triples(triples(:,4)>=2*count/3,:);
try
    plot3(coords(:,1),coords(:,2),coords(:,3),'bo')
end
    
xlabel('X'); ylabel('Y'); zlabel('Z');
regions_of_interest;
fileID = fopen('triples.txt','w');
fprintf(fileID,'%s\nTotal subjects: %d\n',pwd,count);
for i = (1:size(coords,1))
    x = strtrim(ROIS{coords(i,1)});
    y = strtrim(ROIS{coords(i,2)});
    z = strtrim(ROIS{coords(i,3)});
    w = coords(i,4);
    fprintf(fileID,'%s,%s,%s,%d\n',x,y,z,w);
end
fclose(fileID);
save('triples','triples');