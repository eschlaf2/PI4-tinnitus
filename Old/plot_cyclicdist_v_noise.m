% Compare performance of two methods of extracting cycles 
noise_magnitude = (0:.1:3);
rois = 6; loops = 6; time = 100; 
trials = 100;
types = {'sines', 'altered_sines', 'non-cyclic','step','gaussian', 'data'};
% set display_ to non-zero to show plots of methods during analysis.
% Probably only do this for single values of types and noise_magnitude.
display_ = 0; 

fft_dist = zeros(size(noise_magnitude)); eig_dist = fft_dist;

cdist_plot = figure();
% subplot dimensions 
p = floor(sqrt(numel(types))); q = ceil(numel(types)/p);
for t = 1:length(types)
    type = types{t};
    for n = 1:length(noise_magnitude)
        for k = 1:trials
            [f, e] = compare_methods(rois, loops, time, noise_magnitude(n), type, display_);
            fft_dist(n) = fft_dist(n) + f;
            eig_dist(n) = eig_dist(n) + e;
        end
        fft_dist(n) = fft_dist(n)/trials; eig_dist(n) = eig_dist(n)/trials;
    end
    
    figure(cdist_plot)
    subplot(p, q, t)
    plot(noise_magnitude, fft_dist, 'b', noise_magnitude, eig_dist, 'r');
    title(type, 'FontWeight', 'bold');
    legend('fft', 'eig', 'Location', 'southeast')
    xlabel('Noise magnitude')
    ylabel('Cyclic distance')
end
