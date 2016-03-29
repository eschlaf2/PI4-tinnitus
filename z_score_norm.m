function [normed_Z] = z_score_norm(Z)
% Normalize vector(s) Z using Z-score-scaling - mu=0, sigma=1.

    time_steps = size(Z,2);
%     Z = match_ends(Z);
%     t = linspace(0,1,time_steps);
%     Z=Z-(Z(:,time_steps)-Z(:,1))*t;
    Z = mean_center(Z);
    normed_Z = repmat(var(Z, [], 2).^(-1/2), 1, time_steps) .* Z;
end

function matched_Z = match_ends(Z)
% Linearly adjusts a matrix (set of vectors) Z so that the end points match
% the starting points - Z(:,1) == Z(:,end)
n = size(Z,2);
matched_Z = Z - (Z(:,n) - Z(:,1)) * linspace(0,1,n);
end

function centered_Z = mean_center(Z)
% Shifts vector(s) Z so that mean == 0.
centered_Z = Z - repmat(mean(Z, 2), 1, size(Z, 2));
end