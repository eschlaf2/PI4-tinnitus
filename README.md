# PI4-tinnitus
I will start posting project code here. So far, everything I have is in Matlab. If I have time, I will convert to IPython notebook and post that here as well. 

plot_cycledist_v_noise: For running an analysis on method performance to see how methods hold up as noise increases use 'plot_cycledist_v_noise'. The code creates sample data using the 'create_toy_data' function, which has a few different types of sample data. The last type - 'data' - uses a line of roi data from the TIN files and stretches and shifts it before adding noise.

Gen_cycles: For analyzing the actual roi sets I used 'Gen_cycles' which will analyze the samples and plot a histogram in an effort to visualize the results. If anyone has a better way to vizualize, we can update.

Checking changes...
