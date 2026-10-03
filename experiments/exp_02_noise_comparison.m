%% EXPERIMENT 02
% Inverse filtering vs Wiener filtering under Gaussian noise
%
% Objective:
%   Demonstrate the instability of inverse filtering in the presence
%   of additive Gaussian noise and compare it with Wiener filtering.

clearvars;
close all;
clc;

%% Setup

projectRoot = fileparts(fileparts(mfilename('fullpath')));

addpath(fullfile(projectRoot, 'src'));

%% Load image

data = load(fullfile(projectRoot, 'data', 'img_restoration.mat'));

img = data.I1;

%% Experiment parameters

motionLength = 15;
motionAngle  = 0;

noiseVariance = 100;

epsilon = 1e-3;

%% Generate blur model

psf = generate_motion_psf(motionLength, motionAngle);

H = create_frequency_response(psf, size(img));

%% Apply motion blur

blurred = apply_blur(img, H);

%% Add Gaussian noise

rng(1);

noise = sqrt(noiseVariance) * randn(size(img));

degraded = blurred + noise;

%% Inverse filtering

restoredInverse = inverse_filter( ...
    degraded, H, epsilon);

%% Wiener filtering

F = fft2(img);

restoredWiener = wiener_filter( ...
    degraded, H, F, noiseVariance);

%% Calculate metrics

[mseInverse, psnrInverse] = ...
    calculate_metrics(img, restoredInverse);

[mseWiener, psnrWiener] = ...
    calculate_metrics(img, restoredWiener);

%% Actual noise statistics

actualNoiseVariance = var(noise(:));

%% Display results

fprintf('\n');
fprintf('=============================================\n');
fprintf('EXPERIMENT 02: NOISE COMPARISON\n');
fprintf('=============================================\n');

fprintf('Motion blur length      : %d\n', motionLength);
fprintf('Noise variance          : %.2f\n', noiseVariance);
fprintf('Measured noise variance : %.2f\n', actualNoiseVariance);

fprintf('\n');
fprintf('Inverse Filter\n');
fprintf('MSE                     : %.4f\n', mseInverse);
fprintf('PSNR                    : %.2f dB\n', psnrInverse);

fprintf('\n');
fprintf('Wiener Filter\n');
fprintf('MSE                     : %.4f\n', mseWiener);
fprintf('PSNR                    : %.2f dB\n', psnrWiener);

fprintf('\n');
fprintf('Wiener improvement      : %.2f dB\n', ...
    psnrWiener - psnrInverse);

%% Display images

figure('Name', 'Experiment 02 - Noise Comparison');

subplot(1,4,1);
imshow(img, []);
title('Original');

subplot(1,4,2);
imshow(degraded, []);
title('Blur + Noise');

subplot(1,4,3);
imshow(restoredInverse, []);
title('Inverse Filter');

subplot(1,4,4);
imshow(restoredWiener, []);
title('Wiener Filter');

sgtitle('Restoration under Motion Blur + Gaussian Noise');

%% Save figure

resultsDir = fullfile(projectRoot, 'results', 'figures');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

exportgraphics(gcf, ...
    fullfile(resultsDir, 'exp02_noise_comparison.png'), ...
    'Resolution', 300);