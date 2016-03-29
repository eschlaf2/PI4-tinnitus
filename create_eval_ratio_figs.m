% plot eval ratios
file = dir('cyclicity_*.mat');
load(file.name);
region = strsplit(pwd,'/');
region = region{end};
title_str = ['Eigenvalue ratio - ', region];

close all;
eval_mat = abs(cell2mat(evals));
eval_ratio = [eval_mat(2,:)./eval_mat(4,:);eval_mat(4,:)./eval_mat(6,:)];

[plot_vals, order] = sort(eval_ratio,2);
plot_vals = [plot_vals; eval_ratio(2, order(1,:))];
f = fit((1:size(plot_vals,2))',plot_vals(3,:)','poly3');
% plot_vals = [plot_vals; smooth(plot_vals(3,:),10)'];
% plot_vals = [plot_vals; plot_vals(1,:)./plot_vals(3,:)];

% semilogy(sort(eval_ratio,2)', '*-');
semilogy(plot_vals','*-');
hold on;
plot(f);
set(gca,'ytick',sort([2 4 8 16 32 max(eval_ratio,[],2)']),...
    'yticklabel',num2str(sort([2 4 8 16 32 max(eval_ratio,[],2)']'), 3));
grid('on')
legend({'1:2';'2:3 (sorted)';'2:3 (matching 1:2)'})
title(title_str);
outid = ['eval_ratio_new_',file.name(11:end-4)];
savefig(outid)
try
    hgexport(gcf, outid, s)
catch ME
    s = HWSetup();
end