function avg_beat = extract_average_beat(signal, peak_locs, window_pre, window_post)

    num_peaks = length(peak_locs);
    beat_segments = [];
    
    for i = 1:num_peaks
        start_idx = peak_locs(i) - window_pre;
        end_idx = peak_locs(i) + window_post;
        
        if start_idx > 0 && end_idx <= length(signal)
            segment = signal(start_idx:end_idx);
            beat_segments = [beat_segments; segment(:)']; 
        end
    end
    
    avg_beat = mean(beat_segments, 1);
end