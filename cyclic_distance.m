function [dist] = cyclic_distance(V1, V2)
% Takes permutations of the same length and measures the distance between 
% them in terms of how far the elements are - add .5 for each place different. 
% For example, [1 2 3 4] and [1 3 2 4] have a distance of 1; [1 2 3 4] and 
% [1 4 3 2] have a distance of 2. Note that the algorithm cycles through
% each ordering to find the minimum distance between permutations and
% returns that distance.

if numel(V1)~=numel(V2)
    display(numel(V1),'V1'); display(numel(V2),'V2');
    warning('Inputs should be cycles with the same number of elements');
    return
end

V1 = reshape(V1,1,[]); V2 = reshape(V2,1,[]);

N = numel(V1);

for i = 0:numel(V1) - 1
    V2 = circshift(V2, [0, i]);
    dist = 0;
    for v = V2
        d = abs(find(V2 == v) - find(V1 == v));
        d = min([d, N - d]);
        dist = dist + d/2;
    end
    if i == 0; min_dist = dist; continue; end
    if dist < min_dist; min_dist = dist; end
end

dist = min_dist;
