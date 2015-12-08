% Returns cyclicity results for processed subject data in current
% directory. Saves results in 'cyclicity.mat'.
files = dir('processed*');
phases = {}; perms = {}; slm = {}; evals = {};
i = 1;
for file = files.'
	data_file = file.name;
	[phases{i}, perms{i}, slm{i}, evals{i}] = cyclic_analysis(data_file);
	i = i + 1;
end
save('cyclicity.mat', 'phases', 'perms','slm','evals');
