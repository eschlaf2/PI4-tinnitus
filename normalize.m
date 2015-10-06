function [normed_Z] = normalize(Z)

[~, time] = size(Z);
t = (1:time)/time;
za=Z-(Z(:,time)-Z(:,1))*t;
zd=(za'-circshift(za',1))';
norm=diag(zd*zd').^(1/2);
normed_Z=(za'/(diag(norm)))';
normed_Z=normed_Z - repmat(mean(normed_Z,2),1,length(normed_Z));
