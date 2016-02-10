function [dist] = cyclic_distance(V1, V2)
% Takes orderings of the same length and measures the distance between 
% them in terms of how apart they are - add .5 for each place different. 
% For example, [1 2 3 4] and [1 3 2 4] have a distance of 1; [1 2 3 4] and 
% [1 4 3 2] have a distance of 2. 

try
    [~, ss] = sort([V1(:), V2(:)]);
    dist = sum(abs(diff(ss,1,2)))/2;
%     dist = sum(abs(ss(:,2:end) - repmat(ss(:,1), 1, size(ss, 2) - 1)))/2;
catch
    display([numel(V1), numel(V2)],'V1, V2');
    warning('Inputs should be cycles with the same number of elements');
    return
end

%%%
if 0 == 1 % cyclic_distance retired 7/1/15
    [r, c] = size(V2);

    distances = zeros(r,c);
    for i = 1:r
        [~, ss] = sort([circshift(V1(:), i), V2]);
    %     dd = min(abs(diff(ss, 1, 2)),N - abs(diff(ss, 1, 2)));
    %     distances(i) = pdist(dd,'chebychev');
    %     distances(i,:) = sum(min(abs(diff(ss, 1, 2)), r - abs(diff(ss, 1, 2))));
        distances(i,:) = sum(abs(diff(ss, 1, 2)));
    end
    dist = min(distances)/2;
end