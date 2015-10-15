close all; clear all;
data = 'Resting';

%% Import
data_location = {'Resting', '/Users/emilyschlafly/Box Sync/PI4/Raw Data/Spectrum_Restingsameasmusic.mat', 'b'; ...
    'Music intervals', '/Users/emilyschlafly/Box Sync/PI4/Raw Data/Spectrum_music.mat','r'};
data = validatestring(data, data_location(:,1));
tag = find(strcmpi(data_location(:,1),data));
pt_color = data_location{tag, 3};
load(data_location{tag, 2}, 'spect');
% load(data_location{strcmpi(data_location(:,1), data),2}, 'spect');

%% Fix
spect_abs = abs(spect(:,:,1:2:end));
spect_abs(spect_abs<.0001) = 0;
spect_ratio = spect_abs./circshift(spect_abs, [0 0 -1]);
spect_ratio = spect_ratio(:,:,1:end-1);
[groups, subjects, eigs] = size(spect_abs);
i=0;

%% Plot
for group = 1:groups
    sr = squeeze(spect_ratio(group,:,:));
    h = sum(sr == Inf);%  sum(isnan(sr));
    figure(4);
    set(gcf, 'DefaultAxesPosition', [0.1300    0.1500    0.7750    0.775]);
    subplot(2, size(spect_ratio,1), group + groups);
%     boxplot(sr); hold on;
    plot(squeeze(spect_ratio(group,:,:)).',strcat(pt_color,'o'),...
        'Markersize', 10);
    xlim([0 eigs]); set(gca, 'Xtick', (1:eigs-1), 'Xticklabel', h);
    title('Ratio \lambda_i:\lambda_{i+1}');
    xlabel({'i'; '(showing number of Inf for each i)'});
    ylabel('Ratio')
    subplot(2, groups, group);
%     boxplot(squeeze(spect_abs(group,:,:))); hold on;
    semilogy(squeeze(spect_abs(group,:,:)).',strcat(pt_color, 'o'));
    title('Eigenvalues \lambda_i');
    xlim([0 eigs+1]); set(gca, 'Xtick', (1:eigs));
    ylabel('Magnitude'); xlabel('i');
end
annotation('textbox', [.45 .99, .1 0],...
    'horizontalalignment', 'center',...
    'string', data,...
    'fontweight', 'bold',...
    'fontsize', 14,...
    'linestyle', 'none')