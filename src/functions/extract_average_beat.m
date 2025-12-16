function [avg_beat, peak_locs, filtered_signal] = extract_average_beat(signal, fs, lpf_cutoff, peak_find_params, window_pre, window_post)
    
    filtered_signal = butter_lowpass_filter(signal, lpf_cutoff, fs, 6);

    [~, peak_locs] = findpeaks(filtered_signal, ...
        'MinPeakHeight', peak_find_params.min_peak_height, ...
        'MinPeakDistance', peak_find_params.min_peak_distance);

    num_peaks = length(peak_locs);
    beat_segments = zeros(num_peaks, window_pre + window_post + 1);

    valid_peaks = 0;
    for i = 1:num_peaks
        start_idx = peak_locs(i) - window_pre;
        end_idx = peak_locs(i) + window_post;
        
        if start_idx > 0 && end_idx <= length(signal)
            valid_peaks = valid_peaks + 1;
            beat_segments(valid_peaks, :) = signal(start_idx:end_idx);
        end
    end
    
    beat_segments = beat_segments(1:valid_peaks, :);
    avg_beat = mean(beat_segments, 1);
end