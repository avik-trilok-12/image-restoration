%% MAIN
% Frequency-Domain Image Restoration
% Runs configurable experiments on I1 and I2.

clearvars;
close all;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'src'));
addpath(fullfile(projectRoot, 'experiments'));

%% Load images
data = load(fullfile(projectRoot, 'data', 'img_restoration.mat'), ...
    'I1', 'I2');

img1 = double(data.I1);
img2 = double(data.I2);

fprintf('I1 dimensions: %d x %d\n', size(img1, 1), size(img1, 2));
fprintf('I2 dimensions: %d x %d\n', size(img2, 1), size(img2, 2));

fprintf('I1 intensity range: %.4f to %.4f\n', ...
    min(img1(:)), max(img1(:)));
fprintf('I2 intensity range: %.4f to %.4f\n', ...
    min(img2(:)), max(img2(:)));

%% Configuration for I1
% Preserve the existing I1 settings.
cfgimg1.imageName = 'I1';
cfgimg1.motionLength = 15;
cfgimg1.motionAngle = 0;
cfgimg1.epsilon = 1e-3;
cfgimg1.noiseVariance = 100;
cfgimg1.noiseVariances = [1 10 25 50 100 200 500];
cfgimg1.motionLengths = [5 10 15 20 30 40 50];
cfgimg1.lambdaValues = [1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 5e-2, 1e-1];
cfgimg1.randomSeed = 1;

%% Configuration for I2
% Start with the same settings for a controlled comparison.
% Tune parameters independently after establishing the baseline.
cfgimg2.imageName = 'I2';
cfgimg2.motionLength = 15;
cfgimg2.motionAngle = 0;
cfgimg2.epsilon = 1e-3;
cfgimg2.noiseVariance = 100;
cfgimg2.noiseVariances = [1 10 25 50 100 200 500];
cfgimg2.motionLengths = [5 10 15 20 30 40 50];
cfgimg2.lambdaValues = [ 0.005, 0.01, 0.015, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.10, 0.15, 0.20];
cfgimg2.randomSeed = 1;

%% Run experiments for both images
results = struct();

results.I1 = runImageExperiments(img1, cfgimg1, projectRoot);
results.I2 = runImageExperiments(img2, cfgimg2, projectRoot);

fprintf('\n=============================================\n');
fprintf('ALL EXPERIMENTS COMPLETED FOR I1 AND I2\n');
fprintf('=============================================\n');


%% Local helper function
function results = runImageExperiments(img, cfg, projectRoot)

% Create image-specific output directories.
outDir.root = fullfile(projectRoot, 'results', cfg.imageName);
outDir.figures = fullfile(outDir.root, 'figures');
outDir.tables = fullfile(outDir.root, 'tables');

if ~exist(outDir.figures, 'dir')
    mkdir(outDir.figures);
end

if ~exist(outDir.tables, 'dir')
    mkdir(outDir.tables);
end

fprintf('\n=============================================\n');
fprintf('IMAGE RESTORATION PROJECT: %s\n', cfg.imageName);
fprintf('=============================================\n');

% Run all five experiments.
results = struct();
results.exp01 = exp_01_inverse_filter(img, cfg, outDir);
results.exp02 = exp_02_noise_comparison(img, cfg, outDir);
results.exp03 = exp_03_noise_sweep(img, cfg, outDir);
results.exp04 = exp_04_blur_sweep(img, cfg, outDir);
results.exp05 = exp_05_regularized_inverse(img, cfg, outDir);
results.exp06 = exp_06_laplacian_tikhonov(img, cfg, outDir);

fprintf('\nExperiments completed for %s.\n', cfg.imageName);
fprintf('Results saved under: %s\n', outDir.root);

end
