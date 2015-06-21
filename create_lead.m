function [lead_matrix] = create_lead(normed_Z)

[N, time] = size(normed_Z);

% Create matrix of areas a
lead_matrix=zeros(N);
for ii=1:N;
    lead_matrix(ii,ii)=0;
    for jj=ii+1:N;
      x=normed_Z(ii,:); y=normed_Z(jj,:);
      lead_matrix(ii,jj)= time * x * (diff([y(end), y])');
%           (x * (diff([y(end),y])') - y * (diff([x(end),x])'));
      lead_matrix(jj,ii)=-lead_matrix(ii,jj);
    end;
end;
