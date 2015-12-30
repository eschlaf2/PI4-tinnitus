no_rois = 33;
no_subjects = length(phases);
sig = zeros(1,no_rois);

% plot all phases
for i = 1:no_subjects
    plot(abs(phases{i})); hold on;
end

% calculate average
for i = 1:no_rois
    for j = 1:no_subjects
        sig(i) = sig(i) + abs(phases{j}(i));
    end
end
plot(sig./no_subjects,'r', 'linewidth',2);
hold off;