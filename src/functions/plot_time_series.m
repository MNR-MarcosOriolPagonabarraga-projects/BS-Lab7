function ax_handle = plot_time_series(array, fs)
    time_vector = (1:length(array)) / fs;
    
    plot(time_vector, array);
    ax_handle = gca;
    
    xlabel(ax_handle, 'Time (s)');
    ylabel(ax_handle, 'Amplitude (V)');
    grid(ax_handle, 'on');
    xlim([0 time_vector(end)])
end