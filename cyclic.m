createz

[N,c]=size(a);

tt=(1:c)/c; %time stepper
b=a-(a(:,c)-a(:,1))*tt; %normalize?

qq=zeros(N);
for ii=1:N-1; 
    for jj=ii+1:N; 
%         sum of 2x2 determinants along rows ii,jj
        dd = .5 * (b(ii,:)*circshift(b(jj,:),[0,-1])' - ...
            b(ii,:)*circshift(b(jj,:),[0,1])');
        qq(ii,jj)=dd;
        qq(jj,ii)=-dd;
    end
end

bb=b'-circshift(b',1); %diff b
cc=diag(bb'*bb);
ss=sqrt(diag(cc*cc')); %This is the same as cc???
% q=qq./(ss*ss')*c; %edited: see next line
q=qq./((ss*ss')*c);
disp(q)
