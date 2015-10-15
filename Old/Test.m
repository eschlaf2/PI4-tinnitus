close all; clear all; clc
t = 0:.01*pi:10*pi; m = 5;
n = 1;
noiseMag = .5;
noise = @(len,noiseMag) (2*noiseMag)*rand(len,1) - noiseMag;

data1 = sin(t) + noise(length(t),noiseMag).';
data2 = sin(t + m) + noise(length(t),noiseMag).';

if 0 == 0
    data1 = sin(t);
    data2 = sin(t+m);
end

sub_plot_dim = ceil(sqrt(length(n)));
highlight = 'm'; 

fig1 = figure; fig2 = figure;
ic = 0;
for i = n
    ic = ic + 1;
%     D = X-Y;
    X = data1; Y = data2;
%     X = 3*sin(m*t+noise.'); Y = cos(i*t);
    ds = [X(1),diff(X)];
    lineInt = Y.*ds;    I = trapz(t,lineInt);
    if abs(I) > noiseMag^2 
        color = highlight; 
    else
        color = 'g'; 
    end

    figure(fig1)
    subplot(sub_plot_dim,sub_plot_dim,ic);
    plot(X,Y,color);
    title(strcat('n =',{' '},num2str(i)));
    
    figure(fig2)
    subplot(sub_plot_dim,sub_plot_dim,ic);
    plot(t,lineInt,color); 
    title(strcat('n =',{' '},num2str(i)));
    text(floor(3*max(t)/4),3*max(lineInt)/4,...
        num2str(I),'BackgroundColor', [1 1 1]);
end
