% % % I think this entire file is already in createz

[N,time]=size(z);

% % % t=(1:time)/time;

% % % zz=z-(z(:,time)-z(:,1))*t;
% % % zz=zz-sum(zz,2)*ones(1,time)/time;
% % % zd=(zz'-circshift(zz',1))';
% % % norm=diag(zd*zd').^(1/2);
% % % zz=(zz'/(diag(norm)))';

a=zeros(N);

for ii=1:N;
    a(ii,ii)=0;
    for jj=ii+1:N;
      x=zz(ii,:); y=zz(jj,:);a(ii,jj)=x*(y'-circshift(y',1));
      a(jj,ii)=-a(ii,jj);
    end;
end;

% ## a=imag(rb./rb');

ro=exp(rand(1,N)*2*pi*1i);
r=ro;
