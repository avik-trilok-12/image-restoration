%% MAIN
% Image Restoration Project
%
% Runs all experiments and generates figures/tables.

clearvars;
close all;
clc;

%% Project setup

projectRoot = fileparts(mfilename('fullpath'));

addpath(fullfile(projectRoot, 'src'));
addpath(fullfile(projectRoot, 'experiments'));

fprintf('\n');
fprintf('=============================================\n');
fprintf('IMAGE RESTORATION PROJECT\n');
fprintf('=============================================\n');

%% Experiment 01

fprintf('\nRunning Experiment 01...\n');

run(fullfile(projectRoot, ...
    'experiments', ...
    'exp_01_inverse_filter.m'));

%% Experiment 02

fprintf('\nRunning Experiment 02...\n');

run(fullfile(projectRoot, ...
    'experiments', ...
    'exp_02_noise_comparison.m'));

%% Experiment 03

fprintf('\nRunning Experiment 03...\n');

run(fullfile(projectRoot, ...
    'experiments', ...
    'exp_03_noise_sweep.m'));

%% Experiment 04

fprintf('\nRunning Experiment 04...\n');

run(fullfile(projectRoot, ...
    'experiments', ...
    'exp_04_blur_sweep.m'));

fprintf('\n');
fprintf('=============================================\n');
fprintf('ALL EXPERIMENTS COMPLETED\n');
fprintf('=============================================\n');