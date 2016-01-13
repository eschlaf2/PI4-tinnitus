no_rois = 33;
no_subjects = length(phases);
sigma = zeros(1,no_rois);

% plot all phases
for i = 1:no_subjects
    plot(abs(phases{i}),'b','linewidth',2); xlim([1 33]); hold on;
end

% calculate average
for i = 1:no_rois
    for j = 1:no_subjects
        sigma(i) = sigma(i) + abs(phases{j}(i));
    end
end
plot(sigma./no_subjects,'r', 'linewidth',4);
hold off;