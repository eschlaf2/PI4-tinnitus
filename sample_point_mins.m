time = (10:10:1000);
periods = (2:2:12);
d_time = zeros(1,numel(time));
d_period = zeros(1,numel(periods));
N = 100;  

asTime = figure();
asPd = figure();
for pp = 1:numel(periods)
    for tt = 1:numel(time)
        for i = 1:N
            [toy_data, ss] = create_toy_data(6,periods(pp),time(tt),0.5,'sines',0);
            normed_data = normalize(toy_data);
            lead = create_lead(normed_data);
            [~,perm,~,~] = sort_lead(lead);
            d_time(tt) = d_time(tt) + cyclic_distance_ben(perm,ss);
        end
        
        d_time(tt) = d_time(tt)/N;
    end
    
    figure(asTime)
    subplot(floor(sqrt(numel(periods))),ceil(sqrt(numel(periods))),pp)
    loglog(time,d_time);
    xlabel('Samples'); ylabel('Cyclic Distance');
    title(strcat('Periods: ', num2str(periods(pp))));
    
    [~,min_i] = min(d_time);
    d_period(pp) = time(min_i);
end

figure(asPd)
plot(periods,d_period)
title('Optimum number of samples vs. number of periods')
xlabel('Periods'); ylabel('Optimum number of samples')
