function result = exp_05_regularized_inverse(img, cfg, outDir)
% EXPERIMENT 05: Compare inverse, Wiener and regularized inverse filters.

img = double(img);
[M,N] = size(img);
psf = generate_motion_psf(cfg.motionLength, cfg.motionAngle);
H = create_frequency_response(psf, size(img));

rng(cfg.randomSeed);
blurred = apply_blur(img, H);
noise = sqrt(cfg.noiseVariance) * randn(M,N);
degraded = blurred + noise;
actualNoiseVariance = var(noise(:), 1);

restoredInverse = inverse_filter(degraded, H, cfg.epsilon);
F = fft2(img);
restoredWiener = wiener_filter(degraded, H, F, cfg.noiseVariance);

lambdaValues = cfg.lambdaValues(:);
nLambda = numel(lambdaValues);
mseReg = zeros(nLambda,1); psnrReg = zeros(nLambda,1);
restoredCandidates = cell(nLambda,1);
for k = 1:nLambda
    restoredCandidates{k} = regularized_inverse_filter(degraded, H, lambdaValues(k));
    [mseReg(k), psnrReg(k)] = calculate_metrics(img, restoredCandidates{k});
end

[~, bestIndex] = max(psnrReg);
bestLambda = lambdaValues(bestIndex);
restoredRegularized = restoredCandidates{bestIndex};

[mseInverse, psnrInverse] = calculate_metrics(img, restoredInverse);
[mseWiener, psnrWiener] = calculate_metrics(img, restoredWiener);
[mseBestReg, psnrBestReg] = calculate_metrics(img, restoredRegularized);

fprintf('\n=============================================\n');
fprintf('EXPERIMENT 05: FILTER COMPARISON (%s)\n', cfg.imageName);
fprintf('=============================================\n');
fprintf('Motion length: %g | angle: %.1f deg\n', cfg.motionLength, cfg.motionAngle);
fprintf('Target noise variance: %.4f | actual: %.4f\n', cfg.noiseVariance, actualNoiseVariance);
fprintf('Inverse: MSE = %.6f, PSNR = %.4f dB\n', mseInverse, psnrInverse);
fprintf('Wiener: MSE = %.6f, PSNR = %.4f dB\n', mseWiener, psnrWiener);
fprintf('Regularized inverse: lambda = %.6g, MSE = %.6f, PSNR = %.4f dB\n', ...
    bestLambda, mseBestReg, psnrBestReg);

Tlambda = table(lambdaValues, mseReg, psnrReg, ...
    'VariableNames', {'Lambda','MSE','PSNR_dB'});
writetable(Tlambda, fullfile(outDir.tables, 'exp05_regularization_sweep.csv'));

Method = ["Inverse"; "Wiener"; "Regularized Inverse"];
MSE = [mseInverse; mseWiener; mseBestReg];
PSNR_dB = [psnrInverse; psnrWiener; psnrBestReg];
writetable(table(Method, MSE, PSNR_dB), fullfile(outDir.tables, 'exp05_filter_comparison.csv'));

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 1150, 750], ...
             'Name', sprintf('%s - Experiment 05', cfg.imageName));

t = tiledlayout(fig, 2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

% Tile 1: Original
nexttile(t);
imshow(img, []);
title('Original', 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');

% Tile 2: Degraded
nexttile(t);
imshow(degraded, []);
title('Blurred + noisy', 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');

% Tile 3: Inverse
nexttile(t);
imshow(restoredInverse, []);
title(sprintf('Inverse (%.2f dB)', psnrInverse), 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');

% Tile 4: Wiener
nexttile(t);
imshow(restoredWiener, []);
title(sprintf('Wiener (%.2f dB)', psnrWiener), 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');

% Tile 5: Regularized
nexttile(t);
imshow(restoredRegularized, []);
title(sprintf('Regularized (%.2f dB)', psnrBestReg), 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');

% Tile 6: Parameter Sweep Plot
ax6 = nexttile(t);
plot(ax6, lambdaValues, psnrReg, '-o', 'LineWidth', 2, 'MarkerSize', 5);

set(ax6, 'Color', 'w', 'XScale', 'log', 'XColor', 'k', 'YColor', 'k', ...
    'FontSize', 10, 'LineWidth', 1.1);
grid(ax6, 'on');
set(ax6, 'GridColor', [0.25 0.25 0.25], 'GridAlpha', 0.35);

xlabel(ax6, 'Regularization Parameter (\lambda)', 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');
ylabel(ax6, 'PSNR (dB)', 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');
title(ax6, sprintf('Optimal \\lambda = %.1e', bestLambda), 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');
title(t, sprintf('%s: Filter Restoration Comparison (L = %g, \\theta = %.1f^\\circ, \\sigma^2 = %.4f)', ...
    cfg.imageName, cfg.motionLength, cfg.motionAngle, cfg.noiseVariance), ...
    'Color', 'k', 'FontSize', 13, 'FontWeight', 'bold');

exportgraphics(fig, fullfile(outDir.figures, 'exp05_filter_comparison.png'), ...
    'Resolution', 300, 'BackgroundColor', 'white');

result = struct('mseInverse',mseInverse,'psnrInverse',psnrInverse, ...
    'mseWiener',mseWiener,'psnrWiener',psnrWiener, ...
    'bestLambda',bestLambda,'mseRegularized',mseBestReg,'psnrRegularized',psnrBestReg, ...
    'actualNoiseVariance',actualNoiseVariance,'lambdaTable',Tlambda);
end