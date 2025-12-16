clear; clc; close all;

%% Load data and plot for High and Low effort scenarios
data_path = 'data/adapecg.mat';
adapecg = load(data_path);
fs_emg = 1000;

fig = figure;
subplot(2,1,1);
ax = plot_time_series(adapecg.emg1, fs_emg);
title(ax, 'Raw EMG Signal - Low Effort');
subplot(2,1,2);
ax = plot_time_series(adapecg.emg2, fs_emg);
title(ax, 'Raw EMG Signal - High Effort');
saveas(fig, 'report/img/raw_emg_signals.png');

%% Generate Average ECG Beat Template
peak_find_params.min_peak_height = 0.2e-3;
peak_find_params.min_peak_distance = 500;
window_pre = 199;
window_post = 400;

[avg_beat, peak_locs, emg1_lpf] = extract_average_beat(adapecg.emg1, fs_emg, 70, peak_find_params, window_pre, window_post);

fig = figure;
plot_time_series(emg1_lpf, fs_emg);
hold on;
plot(peak_locs/fs_emg, emg1_lpf(peak_locs), 'r*', 'MarkerSize', 8);
title('Low-Pass Filtered Low-Effort EMG with Detected QRS Peaks');
legend('Filtered EMG', 'Detected Peaks');
saveas(fig, 'report/img/lpf_emg1_peaks.png');

fig = figure;
plot(((1:length(avg_beat)) - window_pre - 1) / fs_emg * 1000, avg_beat);
title('Average ECG Beat Template');
xlabel('Time (ms)');
ylabel('Amplitude (V)');
grid on;
saveas(fig, 'report/img/average_ecg_beat.png');

%% Adaptive Filtering for Low-Effort EMG
ref_impulses_low = generate_reference_impulses(adapecg.emg1, avg_beat, fs_emg);

fig = figure;
plot_time_series(adapecg.emg1, fs_emg);
hold on;
stem(find(ref_impulses_low)/fs_emg, 0.5e-3 * ones(size(find(ref_impulses_low))), 'r');
title('Low-Effort EMG with Reference Impulses');
legend('EMG', 'Reference Impulses');
ylim([-1e-3, 1e-3]);
saveas(fig, 'report/img/emg1_with_impulses.png');

mu_values = [1e-3, 1e-2, 1e-1];
filter_order = 600;

% Grouped plots for filtered EMG (Low Effort)
fig_filtered_low = figure;
subplot(length(mu_values) + 1, 1, 1);
plot_time_series(adapecg.emg1, fs_emg);
title('Original Low-Effort EMG');

% Grouped plots for artifacts (Low Effort)
fig_artifacts_low = figure;

for i = 1:length(mu_values)
    mu = mu_values(i);
    [filtered_emg_low, ecg_estimate_low] = lms_filter(adapecg.emg1, ref_impulses_low, filter_order, mu);
    
    figure(fig_filtered_low);
    subplot(length(mu_values) + 1, 1, i + 1);
    plot_time_series(filtered_emg_low, fs_emg);
    title(['Filtered Low-Effort EMG (\mu = ' num2str(mu) ')']);
    
    figure(fig_artifacts_low);
    subplot(length(mu_values), 1, i);
    plot_time_series(ecg_estimate_low, fs_emg);
    title(['Estimated ECG Artifact (\mu = ' num2str(mu) ')']);
end
saveas(fig_filtered_low, 'report/img/lms_filtered_emg1_all_mu.png');
saveas(fig_artifacts_low, 'report/img/ecg_artifact_emg1_all_mu.png');


%% Adaptive Filtering for High-Effort EMG
emg2_lpf = butter_lowpass_filter(adapecg.emg2, 70, fs_emg, 6);
ref_impulses_high = generate_reference_impulses(emg2_lpf, avg_beat, fs_emg);

fig = figure;
plot_time_series(adapecg.emg2, fs_emg);
hold on;
stem(find(ref_impulses_high)/fs_emg, 2e-3 * ones(size(find(ref_impulses_high))), 'r');
title('High-Effort EMG with Reference Impulses');
legend('EMG', 'Reference Impulses');
ylim([-4e-3, 4e-3]);
saveas(fig, 'report/img/emg2_with_impulses.png');

% Grouped plots for filtered EMG (High Effort)
fig_filtered_high = figure;
subplot(length(mu_values) + 1, 1, 1);
plot_time_series(adapecg.emg2, fs_emg);
title('Original High-Effort EMG');

% Grouped plots for artifacts (High Effort)
fig_artifacts_high = figure;

for i = 1:length(mu_values)
    mu = mu_values(i);
    [filtered_emg_high, ecg_estimate_high] = lms_filter(adapecg.emg2, ref_impulses_high, filter_order, mu);
    
    figure(fig_filtered_high);
    subplot(length(mu_values) + 1, 1, i + 1);
    plot_time_series(filtered_emg_high, fs_emg);
    title(['Filtered High-Effort EMG (\mu = ' num2str(mu) ')']);
    
    figure(fig_artifacts_high);
    subplot(length(mu_values), 1, i);
    plot_time_series(ecg_estimate_high, fs_emg);
    title(['Estimated ECG Artifact (\mu = ' num2str(mu) ')']);
end
saveas(fig_filtered_high, 'report/img/lms_filtered_emg2_all_mu.png');
saveas(fig_artifacts_high, 'report/img/ecg_artifact_emg2_all_mu.png');