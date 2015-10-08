%%
group_keys = {'Resting', 'Music'};
% Resting groups
groups = {{'Normal hearing',[12, 13, 14, 16, 18, 20, 35, 41, 45, 46, 52, 53, 65, 75, 79]; ...
     'Tinnitus', [9,10,11,21,23,25,26,27,28,39,54,78];
     'Hearing loss', [15,17,19,44,47,49,55,62,71,74,83,101,102]},...
	{'Low Severity',[4    30    32    35    38    39    44    48    50]; ...
    'High Severity', [5    10    31    40    41    42]}};

Subj_Groups = containers.Map(group_keys, groups);

%%
% Music groups
% Subj_Groups = {'Low Severity',[4    30    32    35    38    39    44    48    50]; ...
%     'High Severity', [5    10    31    40    41    42]};
