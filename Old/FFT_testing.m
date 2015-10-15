clear all; close all;
% data = load('Raw Data/roisThrTime_sub_83.txt');
create_toy_data;
data = toy_data;
normed_data = normalize(data);
lead_matrix = create_lead(normed_data);
time = length(normed_data);
t=(1:time)/time;

% Show plots for fft analysis
tol = .0025;    %for keeping fft plots clean only
[~,fft_perm] = fft_sort(normed_data);
figure(1)
subplot(1,2,1)
plot(t,data)
legend(num2str((1:size(data)).'))
title('Original Data')
subplot(1,2,2)
plot(t,normed_data);
title('Normalized Data')
[~, labels] = sort(fft_perm);
legend(num2str(labels.'));
transform = fft(normed_data,[],2);
figure(2)
subplot(3,1,1)
plot(t,real(transform));
title('Real(FFT)')
subplot(3,1,2)
plot(t,imag(transform));
title('Imag(FFT)')
subplot(3,1,3)
smalls = abs(transform) > tol;
phases = angle(smalls .* transform);
plot(t,phases);
title('Angle(FFT)')

% Show plots for eig analysis
[eig_phases, eig_perm, sorted_lead_matrix, spectrum]= ...
    sort_lead(lead_matrix);
figure(3)
imagesc(sorted_lead_matrix);

% Display permutations for comparison
disp(fft_perm); 
disp(eig_perm);
