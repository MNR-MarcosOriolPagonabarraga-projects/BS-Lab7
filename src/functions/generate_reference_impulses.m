function ref_impulses = generate_reference_impulses(signal, template_beat, fs)
    
    signal_norm = (signal - mean(signal)) / std(signal);
    template_norm = (template_beat - mean(template_beat)) / std(template_beat);
    
    [correlation, lag] = xcorr(signal_norm, template_norm);
    
    [~, peak_locs_corr] = findpeaks(correlation, 'MinPeakDistance', 0.5 * fs, 'MinPeakProminence', 0.5);
    
    qrs_offset_in_template = 199;
    detected_samps = lag(peak_locs_corr) + qrs_offset_in_template;

    valid_locs = detected_samps(detected_samps > 0 & detected_samps <= length(signal));

    ref_impulses = zeros(size(signal));
    ref_impulses(valid_locs) = 1;
end