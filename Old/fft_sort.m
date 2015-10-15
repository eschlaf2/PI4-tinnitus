function [sorted, permutation] = fft_sort(zz)

tol = eps^.75;

%1 fft
transform = fft(zz,[],2);
smalls = abs(transform) > tol;
trans_angles = angle(smalls .* transform);

% 2. Find abs maxes
[~,M] = max(abs(real(transform)),[],2);
M = mode(M); if M == 1; M = M + 1; end;

% 3. Calculate phases
angles = trans_angles(:,M);
phases = angles - 1i * angles.^2;
phases = angle(phases);

% 4. Sort by phases
[~,permutation] = sort(phases);
permutation=keep_one_first(permutation);

sorted = zz(permutation,:);
