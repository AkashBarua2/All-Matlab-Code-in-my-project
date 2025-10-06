clear all;
close all;
clc;

% Read in the data files
mmWave = csvread('mmWave.csv');
resp = csvread('resp.csv');
ekg = csvread('ekg.csv');

% Define indices for antenna and frame (if mmWave is 3D)
antenna_index = 1;  % Set to the appropriate antenna index
frame_index = 1;    % Set to the appropriate frame index

% Check if mmWave is 3D; if not, remove the index references
if ndims(mmWave) == 3
    mmWave_data = mmWave(:, antenna_index, frame_index); % Extract antenna and frame data
else
    mmWave_data = mmWave;  % Use 2D data directly
end

% Respiration: Compute and plot FFT for respiration data
resp_fft = fft(resp);
figure;
subplot(2,1,1); 
plot(abs(resp_fft(1:end/2))); % Only positive frequencies
title('Magnitude Spectrum of Respiration Data');
xlabel('Frequency');
ylabel('Magnitude');

subplot(2,1,2); 
plot(angle(resp_fft(1:end/2))); 
title('Phase Response of Respiration Data');
xlabel('Frequency');
ylabel('Phase (radians)');

% EKG: Compute and plot FFT for EKG data
ekg_fft = fft(ekg);
figure;
subplot(2,1,1); 
plot(abs(ekg_fft(1:end/2))); % Only positive frequencies
title('Magnitude Spectrum of EKG Data');
xlabel('Frequency');
ylabel('Magnitude');

subplot(2,1,2); 
plot(angle(ekg_fft(1:end/2))); 
title('Phase Response of EKG Data');
xlabel('Frequency');
ylabel('Phase (radians)');

% mmWave Data: Compute FFT for mmWave data
mmWave_fft = fft(mmWave_data);  % Use the extracted mmWave data
figure; 
plot(abs(mmWave_fft(1:end/2))); % Plot only positive frequencies
title('Magnitude Spectrum of mmWave Data');
xlabel('Frequency');
ylabel('Magnitude');

% Example of Butterworth Filter Design
Fs = 100; % Sampling frequency in Hz (adjust as needed)
cutoff_freq = 0.5; % Example cutoff frequency for lowpass filter (adjust as needed)
[b,a] = butter(4, cutoff_freq/(Fs/2), 'low'); % 4th-order lowpass Butterworth filter

% Filter mmWave data (in the time domain)
mmWave_filtered = filtfilt(b, a, mmWave_data);

% Compute phase from filtered data using Hilbert transform
filtered_phase = angle(hilbert(mmWave_filtered));

% Plot the filtered phase response
figure;
plot(filtered_phase);
title('Filtered Phase Response of mmWave Data');
xlabel('Time (samples)');
ylabel('Phase (radians)');

% Counting peaks in the filtered phase data
[pks, locs] = findpeaks(filtered_phase);
num_peaks = length(pks);
fprintf('Number of peaks in filtered phase response: %d\n', num_peaks);

% Compare to ground truth respiration data (find peaks in respiration data)
[pks_resp, locs_resp] = findpeaks(resp);
num_peaks_resp = length(pks_resp);
fprintf('Number of peaks in respiratory ground truth: %d\n', num_peaks_resp);

% Compare the number of peaks
if num_peaks == num_peaks_resp
    fprintf('Number of peaks in filtered mmWave phase matches the respiratory ground truth.\n');
else
    fprintf('Number of peaks does NOT match the respiratory ground truth.\n');
end