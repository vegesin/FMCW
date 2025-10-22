% MATLAB Simulation of Human Vital Signs: Breathing and Heartbeat Signals
clear;
close all;

% Parameters for breathing signal
breath_freq = 0.25; % breaths per second (typical range 12-20 breaths per minute)
breath_amp = 1;     % amplitude of the breathing signal
fs = 100;           % sampling frequency in Hz
t = 0:1/fs:10;      % time vector from 0 to 10 seconds

% Generate breathing signal using a sine wave with added noise
breathing_signal = breath_amp * sin(2*pi*breath_freq*t) + 0.1*randn(size(t));

% Parameters for heartbeat signal
heart_freq = 1;     % heartbeats per second (typical range 60-100 beats per minute)
heart_amp = 2;      % amplitude of the heartbeat signal

% Generate heartbeat signal using a sine wave with added noise and occasional spikes to mimic heartbeats
heartbeat_signal = heart_amp * sin(2*pi*heart_freq*t) + 0.5*randn(size(t));
spike_times = round(rand(1,round(length(t)/3)) * length(t)); % Random spike times
heartbeat_signal(spike_times) = heartbeat_signal(spike_times) + 3; % Add spikes

% Plot the signals
figure;
subplot(2,1,1);
plot(t,breathing_signal);
title('ºôÎüĞÅºÅ');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t,heartbeat_signal);
title('ĞÄÌøĞÅºÅ');
xlabel('Time (s)');
ylabel('Amplitude');