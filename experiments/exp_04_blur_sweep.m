%% EXPERIMENT 04
% Restoration performance vs motion blur length
%
% Objective:
%   Evaluate the robustness of inverse and Wiener filtering as
%   motion blur severity increases.

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

motionLengths = [5 10 15 20 30 40 50];

motionAngle = 0;

noiseVariance = 100;

epsilon = 1e-3;

%% Preallocate results

numExperiments = length(motionLengths);

mseInverse = zeros(size(motionLengths));
mseWiener  = zeros(size(motionLengths));

psnrInverse = zeros(size(motionLengths));
psnrWiener  = zeros(size(motionLengths));

%% Fourier transform of original

F = fft2(img);

%% Reproducible noise

rng(1);

%% Run experiment

for i = 1:numExperiments

    motionLength = motionLengths(i);

    %% Generate motion blur

    psf = generate_motion_psf( ...
        motionLength, motionAngle);

    H = create_frequency_response( ...
        psf, size(img));

    blurred = apply_blur(img, H);

    %% Add Gaussian noise

    noise = sqrt(noiseVariance) * randn(size(img));

    degraded = blurred + noise;

    %% Inverse filtering

    restoredInverse = inverse_filter( ...
        degraded, H, epsilon);

    [mseInverse(i), psnrInverse(i)] = ...
        calculate_metrics(img, restoredInverse);

    %% Wiener filtering

    restoredWiener = wiener_filter( ...
        degraded, H, F, noiseVariance);

    [mseWiener(i), psnrWiener(i)] = ...
        calculate_metrics(img, restoredWiener);

end

%% Display results

fprintf('\n');
fprintf('=============================================\n');
fprintf('EXPERIMENT 04: BLUR LENGTH SWEEP\n');
fprintf('=============================================\n');

fprintf('\n');
fprintf('Blur Length | Inverse PSNR | Wiener PSNR\n');
fprintf('------------------------------------------\n');

for i = 1:numExperiments

    fprintf('%11.1f | %12.2f | %11.2f dB\n', ...
        motionLengths(i), ...
        psnrInverse(i), ...
        psnrWiener(i));

end

%% Plot PSNR

figure('Name', 'Experiment 04 - PSNR vs Blur Length');

plot(motionLengths, psnrInverse, '-o', ...
    'LineWidth', 1.5);

hold on;

plot(motionLengths, psnrWiener, '-s', ...
    'LineWidth', 1.5);

grid on;

xlabel('Motion Blur Length');
ylabel('PSNR (dB)');

title('Restoration Performance vs Motion Blur Length');

legend('Inverse Filter', ...
       'Wiener Filter', ...
       'Location', 'best');

%% Save PSNR figure

resultsDir = fullfile(projectRoot, 'results', 'figures');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

exportgraphics(gcf, ...
    fullfile(resultsDir, 'exp04_psnr_vs_blur_length.png'), ...
    'Resolution', 300);

%% Plot MSE

figure('Name', 'Experiment 04 - MSE vs Blur Length');

semilogy(motionLengths, mseInverse, '-o', ...
    'LineWidth', 1.5);

hold on;

semilogy(motionLengths, mseWiener, '-s', ...
    'LineWidth', 1.5);

grid on;

xlabel('Motion Blur Length');
ylabel('MSE');

title('MSE vs Motion Blur Length');

legend('Inverse Filter', ...
       'Wiener Filter', ...
       'Location', 'best');

%% Save MSE figure

exportgraphics(gcf, ...
    fullfile(resultsDir, 'exp04_mse_vs_blur_length.png'), ...
    'Resolution', 300);

%% Save numerical results

resultsDirTables = fullfile(projectRoot, 'results', 'tables');

if ~exist(resultsDirTables, 'dir')
    mkdir(resultsDirTables);
end

resultsTable = table( ...
    motionLengths(:), ...
    mseInverse(:), ...
    psnrInverse(:), ...
    mseWiener(:), ...
    psnrWiener(:), ...
    'VariableNames', { ...
    'BlurLength', ...
    'MSE_Inverse', ...
    'PSNR_Inverse', ...
    'MSE_Wiener', ...
    'PSNR_Wiener'});

writetable(resultsTable, ...
    fullfile(resultsDirTables, ...
    'exp04_blur_sweep.csv'));