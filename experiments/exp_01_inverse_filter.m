%% EXPERIMENT 01
% Inverse filtering under motion blur
%
% Objective:
%   Evaluate inverse filtering when the degradation consists only
%   of known motion blur.
%
% Output:
%   - Original image
%   - Motion blurred image
%   - Inverse-filtered reconstruction
%   - MSE and PSNR

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
epsilon      = 1e-3;

%% Generate degradation model

psf = generate_motion_psf(motionLength, motionAngle);

H = create_frequency_response(psf, size(img));

%% Apply motion blur

blurred = apply_blur(img, H);

%% Inverse filtering

restored = inverse_filter(blurred, H, epsilon);

%% Calculate metrics

[mse, psnrValue] = calculate_metrics(img, restored);

%% Frequency response analysis

minH = min(abs(H(:)));
maxH = max(abs(H(:)));

valid = abs(H) > epsilon;

discardedPoints = sum(~valid);
totalPoints = numel(H);
discardedPercentage = 100 * discardedPoints / totalPoints;

%% Display results

fprintf('\n');
fprintf('=============================================\n');
fprintf('EXPERIMENT 01: INVERSE FILTERING\n');
fprintf('=============================================\n');

fprintf('Image size              : %d x %d\n', ...
    size(img,1), size(img,2));

fprintf('Motion blur length      : %d\n', motionLength);
fprintf('Motion blur angle       : %.1f degrees\n', motionAngle);

fprintf('Minimum |H|             : %.6f\n', minH);
fprintf('Maximum |H|             : %.6f\n', maxH);

fprintf('Inverse threshold       : %.1e\n', epsilon);

fprintf('Discarded frequencies  : %d / %d (%.2f%%)\n', ...
    discardedPoints, totalPoints, discardedPercentage);

fprintf('MSE                     : %.4f\n', mse);
fprintf('PSNR                    : %.2f dB\n', psnrValue);

%% Display restoration

figure('Name', 'Experiment 01 - Inverse Filtering');

subplot(1,3,1);
imshow(img, []);
title('Original');

subplot(1,3,2);
imshow(blurred, []);
title('Motion Blurred');

subplot(1,3,3);
imshow(restored, []);
title('Inverse Filter');

sgtitle('Inverse Filtering under Motion Blur');

%% Save figure

resultsDir = fullfile(projectRoot, 'results', 'figures');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

exportgraphics(gcf, ...
    fullfile(resultsDir, 'exp01_inverse_filter.png'), ...
    'Resolution', 300);