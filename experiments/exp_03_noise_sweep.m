%% EXPERIMENT 03
% Restoration performance vs Gaussian noise variance
%
% Objective:
%   Evaluate the robustness of inverse and Wiener filtering as
%   Gaussian noise variance increases.

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

noiseVariances = [1 10 25 50 100 200 500];

epsilon = 1e-3;

%% Generate blur model

psf = generate_motion_psf(motionLength, motionAngle);

H = create_frequency_response(psf, size(img));

blurred = apply_blur(img, H);

F = fft2(img);

%% Preallocate results

numExperiments = length(noiseVariances);

mseInverse = zeros(size(noiseVariances));
mseWiener  = zeros(size(noiseVariances));

psnrInverse = zeros(size(noiseVariances));
psnrWiener  = zeros(size(noiseVariances));

%% Reproducible noise

rng(1);

%% Run experiment

for i = 1:numExperiments

    noiseVariance = noiseVariances(i);

    %% Generate Gaussian noise

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

%% Display numerical results

fprintf('\n');
fprintf('=============================================\n');
fprintf('EXPERIMENT 03: NOISE SWEEP\n');
fprintf('=============================================\n');

fprintf('\n');
fprintf('Noise Variance | Inverse PSNR | Wiener PSNR\n');
fprintf('---------------------------------------------\n');

for i = 1:numExperiments

    fprintf('%14.1f | %12.2f | %11.2f dB\n', ...
        noiseVariances(i), ...
        psnrInverse(i), ...
        psnrWiener(i));

end

%% Plot PSNR

figure('Name', 'Experiment 03 - PSNR vs Noise');

plot(noiseVariances, psnrInverse, '-o', ...
    'LineWidth', 1.5);

hold on;

plot(noiseVariances, psnrWiener, '-s', ...
    'LineWidth', 1.5);

grid on;

xlabel('Noise Variance');
ylabel('PSNR (dB)');

title('Restoration Performance vs Gaussian Noise');

legend('Inverse Filter', ...
       'Wiener Filter', ...
       'Location', 'best');

%% Save PSNR figure

resultsDir = fullfile(projectRoot, 'results', 'figures');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

exportgraphics(gcf, ...
    fullfile(resultsDir, 'exp03_psnr_vs_noise.png'), ...
    'Resolution', 300);

%% Plot MSE

figure('Name', 'Experiment 03 - MSE vs Noise');

semilogy(noiseVariances, mseInverse, '-o', ...
    'LineWidth', 1.5);

hold on;

semilogy(noiseVariances, mseWiener, '-s', ...
    'LineWidth', 1.5);

grid on;

xlabel('Noise Variance');
ylabel('MSE');

title('MSE vs Gaussian Noise');

legend('Inverse Filter', ...
       'Wiener Filter', ...
       'Location', 'best');

%% Save MSE figure

exportgraphics(gcf, ...
    fullfile(resultsDir, 'exp03_mse_vs_noise.png'), ...
    'Resolution', 300);

%% Save numerical results

resultsDirTables = fullfile(projectRoot, 'results', 'tables');

if ~exist(resultsDirTables, 'dir')
    mkdir(resultsDirTables);
end

resultsTable = table( ...
    noiseVariances(:), ...
    mseInverse(:), ...
    psnrInverse(:), ...
    mseWiener(:), ...
    psnrWiener(:), ...
    'VariableNames', { ...
    'NoiseVariance', ...
    'MSE_Inverse', ...
    'PSNR_Inverse', ...
    'MSE_Wiener', ...
    'PSNR_Wiener'});

writetable(resultsTable, ...
    fullfile(resultsDirTables, ...
    'exp03_noise_sweep.csv'));