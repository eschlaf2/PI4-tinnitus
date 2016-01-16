function [normed_Z] = alt_norm(Z)

[~, time] = size(Z);
t = (1:time)/time;
Z=Z-(Z(:,time)-Z(:,1))*t;
Z = Z - repmat(mean(Z, 2), 1, time);

normed_Z = repmat(var(Z, [], 2).^(-1/2), 1, time) .* Z;

