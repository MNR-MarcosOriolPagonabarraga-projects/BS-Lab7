function filtered_signal = butter_lowpass_filter(signal, cutoff_freq, fs, order)
    [b, a] = butter(order, cutoff_freq/(fs/2), 'low');
    filtered_signal = filtfilt(b, a, signal);
end