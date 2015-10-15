% Generatea circular errorbar plot with the size of the markers dependent
% upon the variance in the data.

GROUPS; regions_of_interest;
for group = 1:3

cd('/Users/emilyschlafly/Box Sync/PI4/Raw Data/Data (matrices)');
expected_rois = 9;  % check

count = 0;
for i = Subj_Groups{group,2}
    file_name = strcat('newRois_subject_',num2str(i),'.mat');
    try
        data = importdata(file_name);  
% %         for testing
%         if i == Subj_Groups{group,2}(1)
%             [data, pp] = create_toy_data(9,6,100,0,'gaussian',1);
%         end
    catch ME
        warning(strcat(file.name,' did not load properly.'))
        continue
    end
    
%     Create and sort lead matrix
    normed_data = normalize(data);
    lead_matrix = create_lead(normed_data); 
    [eig_phases, eig_perm, sorted_lead_matrix, spectrum] = ...
        sort_lead(lead_matrix);
%     one_first_perm = keep_one_first(eig_perm);
    
%     Check for data errors
    if length(lead_matrix) ~= expected_rois
        disp(strcat(file.name,' is missing data.'));
        continue
    end
    if length(normed_data) < 100
        disp(strcat(file.name, ' has less than one hundred sample times.'))
    end
    
    count = count + 1;
    
%     Create a matrix of phases returned by sort_lead for each subject
    if count == 1   %initialize eig_cycles
        eig_cycles = zeros(numel(Subj_Groups{group,2}),numel(eig_perm));
    end
    eig_cycles(count,eig_perm) = eig_phases;

end

% Kill zero rows
eig_cycles = eig_cycles(1:count,:);

% % Create histograms of phases for each ROI
% for roi = 1:expected_rois
%     figure(eig_hist)
%     subplot(3,3,roi)
%     hist(eig_cycles(:,roi),4);
%     title({ROIS{roi,1},Subj_Groups{group}});
% end

% Sort by Mean so that ROIS are plotted in order (makes the legend come out
% ordered); sort by Standdev so that later big markers are plotted first 
% (so they don't cover smaller markers)
[meansort,sm] = sort(mean(eig_cycles));
[stdsort,ss] = sort(std(eig_cycles(:,sm)),'descend');

colorset = [lines(7);cool(2)];
figure
set(gcf,'DefaultAxesColorOrder',colorset)
% plot the lines (without markers) for the mean of the phases. If you plot
% with markers, the legend gets ridiculous looking
h = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * meansort)]);
% plot the black unit circle
t = linspace(0, 2*pi, 250); hold on;
plot(cos(t), sin(t),'k'); 
axis([-1.4, 1.4, -1.4, 1.4]);
axis('square');
title(Subj_Groups{group})
legend(ROIS(sm),'Location','southwest'); 

% Add in the error bars
for i = 1:numel(ss)
    t = linspace(max(meansort(ss(i)) - 2 * stdsort(i),0), ...
        meansort(ss(i)) + 2 * stdsort(i), 250);
    plot((3 * numel(ss) + ss(i))/(4 * numel(ss)) * exp(1j * t), ...
        'Color', get(h(ss(i)),'Color'), ...
        'LineWidth',2)
end

% Add the markers (ordered from largest to smallest) and correct the colors
g = plot([zeros(1, numel(eig_cycles(1,:))); exp(1j * meansort(ss))]);
for i = 1:numel(ss)
    set(g(i),'Marker','o','MarkerSize',4 * stdsort(i)^4 + 4,...
        'MarkerFaceColor',get(h(ss(i)),'Color'),...
        'Color', get(h(ss(i)),'Color'))
end


end