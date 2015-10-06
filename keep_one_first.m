function [P] = keep_one_first(permutation)
[r,c] = size(permutation);
if r > c
    permutation = permutation.';
end
P=circshift(permutation,[0,length(permutation)+1-find(permutation==1)]);
