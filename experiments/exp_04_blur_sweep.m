function result = exp_04_blur_sweep(img, cfg, outDir)
% EXPERIMENT 04: Restoration performance vs motion blur length.

img = double(img);
motionLengths = cfg.motionLengths(:);
F = fft2(img);
nExp = numel(motionLengths);
mseInverse = zeros(nExp,1); psnrInverse = zeros(nExp,1);
mseWiener = zeros(nExp,1); psnrWiener = zeros(nExp,1);
actualNoiseVariance = zeros(nExp,1);

rng(cfg.randomSeed);
for i = 1:nExp
    motionLength = motionLengths(i);
    psf = generate_motion_psf(motionLength, cfg.motionAngle);
    H = create_frequency_response(psf, size(img));
    blurred = apply_blur(img, H);
    noise = sqrt(cfg.noiseVariance) * randn(size(img));
    actualNoiseVariance(i) = var(noise(:));
    degraded = blurred + noise;

    restoredInverse = inverse_filter(degraded, H, cfg.epsilon);
    [mseInverse(i), psnrInverse(i)] = calculate_metrics(img, restoredInverse);

    restoredWiener = wiener_filter(degraded, H, F, cfg.noiseVariance);
    [mseWiener(i), psnrWiener(i)] = calculate_metrics(img, restoredWiener);
end

fprintf('\n=============================================\n');
fprintf('EXPERIMENT 04: BLUR LENGTH SWEEP (%s)\n', cfg.imageName);
fprintf('=============================================\n');
disp(table(motionLengths, actualNoiseVariance, mseInverse, psnrInverse, mseWiener, psnrWiener));

fig1 = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 750, 500], ...
    'Name', sprintf('%s - Experiment 04 PSNR', cfg.imageName));
ax1 = axes(fig1);
plot(ax1, motionLengths, psnrInverse, '-o', 'LineWidth', 2, 'MarkerSize', 6); hold(ax1, 'on');
plot(ax1, motionLengths, psnrWiener, '-s', 'LineWidth', 2, 'MarkerSize', 6);

set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 11, 'LineWidth', 1.2);
grid(ax1, 'on');
set(ax1, 'GridColor', [0.25 0.25 0.25], 'GridAlpha', 0.35);

xlabel(ax1, 'Motion blur length (pixels)', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(ax1, 'PSNR (dB)', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
title(ax1, sprintf('%s: PSNR vs Motion Blur Length', cfg.imageName), ...
    'Color', 'k', 'FontSize', 13, 'FontWeight', 'bold');

lgd1 = legend(ax1, 'Inverse filter', 'Wiener filter', 'Location', 'best');
set(lgd1, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.4 0.4 0.4], 'FontSize', 11);

exportgraphics(fig1, fullfile(outDir.figures, 'exp04_psnr_vs_blur_length.png'), ...
    'Resolution', 300, 'BackgroundColor', 'white');

fig2 = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 750, 500], ...
    'Name', sprintf('%s - Experiment 04 MSE', cfg.imageName));
ax2 = axes(fig2);
semilogy(ax2, motionLengths, mseInverse, '-o', 'LineWidth', 2, 'MarkerSize', 6); hold(ax2, 'on');
semilogy(ax2, motionLengths, mseWiener, '-s', 'LineWidth', 2, 'MarkerSize', 6);

set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 11, 'LineWidth', 1.2);
grid(ax2, 'on');
set(ax2, 'GridColor', [0.25 0.25 0.25], 'GridAlpha', 0.35);

xlabel(ax2, 'Motion blur length (pixels)', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(ax2, 'MSE (log scale)', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
title(ax2, sprintf('%s: MSE vs Motion Blur Length', cfg.imageName), ...
    'Color', 'k', 'FontSize', 13, 'FontWeight', 'bold');

lgd2 = legend(ax2, 'Inverse filter', 'Wiener filter', 'Location', 'best');
set(lgd2, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.4 0.4 0.4], 'FontSize', 11);

exportgraphics(fig2, fullfile(outDir.figures, 'exp04_mse_vs_blur_length.png'), ...
    'Resolution', 300, 'BackgroundColor', 'white');

T = table(motionLengths, actualNoiseVariance, mseInverse, psnrInverse, mseWiener, psnrWiener, ...
    'VariableNames', {'BlurLength','ActualNoiseVariance','MSE_Inverse','PSNR_Inverse','MSE_Wiener','PSNR_Wiener'});
writetable(T, fullfile(outDir.tables, 'exp04_blur_sweep.csv'));

result = T;
end