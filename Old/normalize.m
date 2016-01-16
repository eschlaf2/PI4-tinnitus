function [normed_Z] = normalize(Z)
% Normalize a vector so that the quadratic variation is equal to 1

[~, time_dim] = size(Z);
t = linspace(0,1,time_dim);
z_adjusted = Z-(Z(:,time_dim)-Z(:,1))*t;
z_diff = (z_adjusted-circshift(z_adjusted,1,2));
normf = sqrt(diag(z_diff*z_diff'));
normed_Z = (z_adjusted'/(diag(normf)))';
normed_Z = normed_Z - repmat(mean(normed_Z,2),1,length(normed_Z));
