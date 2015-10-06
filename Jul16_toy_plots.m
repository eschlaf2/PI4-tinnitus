close all; clear all;
Rois = 9; Time = 100; stypes = {'sines'}; 
noiseMag = 0; %1/sqrt(1.4); %in terms of number of stds 
% m = 2 .* rand(Rois, 1); %all data is shifted within two time steps
m = 3 .* linspace(0,1,Rois).';
shiftMag = 10; %std of time shift between subjects
subjects = 1;
data = zeros(Rois, Time, subjects);
eig_cycles = zeros(subjects,Rois);

for tt = 1:numel(stypes)
    stype = stypes{tt};
for i = 1:subjects
    shift = linspace(0, .03, Rois).';
%     shift = m + shiftMag .* randn(Rois, 1);
    data(:,:,i) = create_toy(stype,'shift',shift,'Time',Time,'Rois',Rois,...
        'NoiseMag', noiseMag, 'loops', 2);
    
%     Create and sort lead matrix
    normed_data = normalize(data(:,:,i));
    lead_matrix = create_lead(normed_data); 
    [eig_phases, eig_perm, sorted_lead_matrix, spectrum] = ...
        sort_lead(lead_matrix);
    
%     Create a matrix of phases returned by sort_lead for each subject
    eig_cycles(i,eig_perm) = eig_phases;


end

%% PI4 figs
figure; 
set(gcf, 'DefaultAxesPosition', [.05 .05 .86 1], ...
    'PaperOrientation', 'landscape',...
    'units', 'normalized', 'outerposition', [0 0 1 .4]);
r=1; c=6;

tight_subplot(r,c,1);
set(gcf,'DefaultAxesColorOrder',[0,0,1;1,0,1])
plot(normed_data(1:3:4,:).');
set(gca, 'ytick', [], 'xtick', []);
axis('square');

tight_subplot(r,c,2);
plot(normed_data(1,:), normed_data(2,:));
set(gca, 'ytick', [], 'xtick', []);
axis('square');
 
tight_subplot(r,c,3);
set(gcf,'DefaultAxesColorOrder',jet(9))
plot(normed_data.');
set(gca, 'ytick', [], 'xtick', []);
axis('square')

tight_subplot(r,c,4);
imagesc(sorted_lead_matrix); 
set(gca, 'ytick', [], 'xtick', []);
axis('square')

tight_subplot(r,c,5);
[V,~] = eig(sorted_lead_matrix); 
plot(V(:,1),'b*-'); hold on; plot(0,0,'r*');
set(gca, 'ytick', [], 'xtick', []);
axis([-.5, .5, -.5, .5]); axis('square');

tight_subplot(r,c,6);
stem(abs(spectrum));
set(gca, 'ytick', [], 'xtick', []);
axis('square')


% Sort by Mean so that ROIS are plotted in order (makes the legend come out
% ordered); sort by Standdev so that later big markers are plotted first 
% (so they don't cover smaller markers)
% [meansort,sm] = sort(mean(eig_cycles));
% [stdsort,ss] = sort(std(eig_cycles(:,sm)));
% 
% colorset = [lines(7);cool(2)];
% if numel(sm) > 9; colorset = varycolor(numel(sm)); end;
% figure
% set(gcf,'DefaultAxesColorOrder',colorset(sm,:))
% % plot the lines (without markers) for the mean of the phases. If you plot
% % with markers, the legend gets ridiculous looking
% h = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * meansort)]);
% % plot the black unit circle
% t = linspace(0, 2*pi, 250); hold on;
% plot(cos(t), sin(t),'k'); 
% axis([-1.4, 1.4, -1.4, 1.4]);
% axis('square');
% title(stype)
% legend(num2str(sm.'),'Location','southwest'); 
% 
% % Add in the error bars
% for i = 1:numel(ss)
%     t = linspace(max(meansort(ss(i)) - stdsort(i), min(eig_cycles(:,sm(ss(i))))), ...
%         min(meansort(ss(i)) + stdsort(i), max(eig_cycles(:,sm(ss(i))))), 250);
%     plot((3 * numel(ss) + ss(i))/(4 * numel(ss)) * exp(1j * t), ...
%         'Color', get(h(ss(i)),'Color'), ...
%         'LineWidth',2)
% end
% 
% % Add the markers (ordered from largest to smallest) and correct the colors
% g = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * meansort(ss))]);
% for i = 1:numel(ss)
%     set(g(i),'Marker','o','MarkerSize',min((2 / max(stdsort(i), 1))^4 * 7, 40),...
%         'MarkerFaceColor',get(h(ss(i)),'Color'),...
%         'Color', get(h(ss(i)),'Color'))
% end
% c = 'cmg';
% figure(2); plot(m(sm),meansort,c(tt),'Marker', 'o')
% xlabel('Original Shift'); ylabel('Angle');
% title(stype); hold on;
end
% figure(2);
% [F, gof] = fit(m(sm), meansort.', 'fourier1');
% x = linspace(min(m), max(m));
% plot(x, F(x), 'r.', 'LineWidth', 2);
% 
% y1 = min(meansort); y2 = max(meansort);
% x1 = min(m); x2 = max(m); 
% G = (y2 - y1)/2 * (1 + cos(pi * (x)/(x2)));
% plot(x, G, 'b*');

% legend(stypes); title('Angle v. shift');hold off;