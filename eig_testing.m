function [lead_matrix] = eig_testing(varargin)
close all
switch nargin
    case 0
        roi_line;
        x = .01:.01:1;
        data_line1 = sin(x);
        data_line2 = data_line2(1:numel(data_line1));
    case 1
        roi_line;
        data_line1 = varargin{1};        
    case 2
        data_line1 = varargin{1};
        data_line2 = varargin{2};
    otherwise
        warning('Too many input arguments')
end


data_fig = figure();
lead_fig = figure();
eig_plot = figure();

N = 6;
m = .15;

data = zeros(N,numel(data_line1));

% for i = 1:floor(N/2)
for i = 1:N
    xshift = i*m * ones(size(data_line1)) + (1:numel(data_line1));
    data(i,:) = interp1((1:2*numel(data_line1)), [data_line1,data_line1], xshift);
%     data(i,:) = circshift(data_line1,[0,i-1]);
end

% for i = floor(N/2) + 1:N
%     data(i,:) = circshift(data_line2,[0,i-1]);
% end

% data(N + 1,:) = data(floor(N/4),:);
% for i = 1:N
%     data(i,:) = circshift(data_line2,[0,i]);
% end

lead_matrix = create_lead(normalize(data));
figure(data_fig)
plot(data.');

figure(lead_fig);
subplot(1,2,1)
imagesc(lead_matrix);

[u,~] = eig(lead_matrix);

figure(eig_plot);
subplot(2,2,1);
plot(lead_matrix(floor(N/4),lead_matrix(floor(N/4),:)~=0)); % hold on
% stem(diag(spectrum)); hold off

subplot(2,2,2);
plot(u(:,floor(N/4)))

[~,permutation,sorted_lead,~] = sort_lead(lead_matrix);
[U,~] = eig(sorted_lead);
figure(lead_fig)
subplot(1,2,2)
imagesc(sorted_lead);

figure(eig_plot);
subplot(2,2,3);
plot(sorted_lead(floor(N/4),:), 'r'); % hold on
% stem(diag(spect), 'r'); hold off

subplot(2,2,4);
plot(U(:,floor(N/4)), 'r')
display(permutation, 'Permutation')
% val_plot = subplot(1,3,3);
% stem(diag(spectrum))

