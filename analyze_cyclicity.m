% Returns cyclicity results for processed subject data in current
% directory. Saves results in 'cyclicity.mat'.
files = dir('processed*');
n = length(files);
phases = cell(1,n); perms = cell(1,n); slm = cell(1,n); evals = cell(1,n); 
subject = cell(1,n);
i = 1;
for file = files.'
	data_file = file.name;
    sbj = strsplit(file.name,{'_','.'},'Collapsedelimiters',true);
    subject{i} = sbj{3};
	[phases{i}, perms{i}, slm{i}, evals{i}] = cyclic_analysis(data_file);
	i = i + 1;
end
save('cyclicity.mat', 'phases', 'perms','slm','evals','subject');
