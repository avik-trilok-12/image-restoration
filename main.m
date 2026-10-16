%% MAIN
% Frequency-Domain Image Restoration
% Runs configurable experiments on I1. I2 can be enabled later by adding
% a second configuration and calling these same experiment functions again.

clearvars;
close all;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'src'));
addpath(fullfile(projectRoot, 'experiments'));

data = load(fullfile(projectRoot, 'data', 'img_restoration.mat'), 'I1');
img = double(data.I1);

% Image-specific configuration. These values preserve the current I1 setup.
cfg.imageName = 'I1';
cfg.motionLength = 15;
cfg.motionAngle = 0;
cfg.epsilon = 1e-3;
cfg.noiseVariance = 100;
cfg.noiseVariances = [1 10 25 50 100 200 500];
cfg.motionLengths = [5 10 15 20 30 40 50];
cfg.lambdaValues = [1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 5e-2, 1e-1];
cfg.randomSeed = 1;

% Keep result files grouped by image. The existing results/figures and
% results/tables folders are not deleted or modified by this setup.
outDir.root = fullfile(projectRoot, 'results', cfg.imageName);
outDir.figures = fullfile(outDir.root, 'figures');
outDir.tables = fullfile(outDir.root, 'tables');

if ~exist(outDir.figures, 'dir'), mkdir(outDir.figures); end
if ~exist(outDir.tables, 'dir'), mkdir(outDir.tables); end

fprintf('\n=============================================\n');
fprintf('IMAGE RESTORATION PROJECT: %s\n', cfg.imageName);
fprintf('=============================================\n');

results = struct();
results.exp01 = exp_01_inverse_filter(img, cfg, outDir);
results.exp02 = exp_02_noise_comparison(img, cfg, outDir);
results.exp03 = exp_03_noise_sweep(img, cfg, outDir);
results.exp04 = exp_04_blur_sweep(img, cfg, outDir);
results.exp05 = exp_05_regularized_inverse(img, cfg, outDir);

fprintf('\n=============================================\n');
fprintf('ALL EXPERIMENTS COMPLETED FOR %s\n', cfg.imageName);
fprintf('=============================================\n');
