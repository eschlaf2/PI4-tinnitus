function [sample_data] = create_toy(rois, loops, time, noise_magnitude, varargin)

rois=6; %number of samples
loops = 6; %number of loops
time=100; %number of time steps
noise_magnitude = .1;

ang=rand(1,rois)*2*pi;
% ang=linspace(0,2*pi,N);
% one=ones(1,N);
% rb=exp(1i*ang); %sorted random vectors

t=(1:time)/time;
[time_mesh, ang_mesh] = meshgrid(loops*2*pi.*t,ang);

%create sine waves from starting angle ang
%normalize
z=sin(ang_mesh + time_mesh) + noise_magnitude*randn(rois,time);
[~,ss] = sort(ang, 'descend'); ss = keep_one_first(ss); display(ss)
z2 = sin(2*(ang_mesh + time_mesh));

% z(2:3,:) = z2(2:3,:);

%non-cyclic z
% z = ang_mesh + time_mesh;
% z(2,:) = ang_mesh(2,:) + time_mesh(2,:);
% z(2,:) = 2 * z(2,:);
% z(3,:) = 2*ang_mesh(3,:) + time_mesh(3,:);

step_test = z > .5;
% z(2,:) = step_test(2,:);
% z(2,:) = z(1,:);

% Gaussian z
% z=exp(-(time_mesh-5*ang_mesh).^2) + noise_magnitude*randn(N,time);
% [~,ss] = sort(ang); ss = keep_one_first(ss); display(ss)

% normalizer = meshgrid(z(:,time) - z(:,1),ones(time,1))';
% zz=z-normalizer/time;
% dz=diag(diag(zz*zz').^(-1/2));
% zz=dz*zz;
% % figure()
% plot(t,zz)
% legend(num2str(ang'))


% % Create matrix of areas a
% a=zeros(N);
% for ii=1:N;
%     a(ii,ii)=0;
%     for jj=ii+1:N;
%       x=zz(ii,:); y=zz(jj,:);
%       a(ii,jj)= time * ...
%           (x * (diff([y(end),y])'));
% %           (x * (diff([y(end),y])') - y * (diff([x(end),x])'));
%                     
% 
%       a(jj,ii)=-a(ii,jj);
%     end;
% end;

% ## a=imag(rb./rb');

% % % ro=exp(rand(1,N)*2*pi*1i); %original random vectors
% % % r=ro;

% disp(a)
% figure()
% plot(real(a),'-o')
% legend(num2str(ang'))

