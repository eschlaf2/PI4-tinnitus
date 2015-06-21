function [normed_Z] = normalize(Z)

[~, time] = size(Z);

normalizer = meshgrid(Z(:,time) - Z(:,1),ones(time,1))';
normed_Z=Z-normalizer/time;
dz=diag(diag(normed_Z*normed_Z').^(-1/2));
normed_Z=dz*normed_Z;
