function result = exp_02_noise_comparison(img, cfg, outDir)
% EXPERIMENT 02: Inverse vs Wiener filtering under Gaussian noise.

img = double(img);
[M, N] = size(img);
psf = generate_motion_psf(cfg.motionLength, cfg.motionAngle);
H = create_frequency_response(psf, size(img));

rng(cfg.randomSeed);
blurred = apply_blur(img, H);
noise = sqrt(cfg.noiseVariance) * randn(M, N);
degraded = blurred + noise;
actualNoiseVariance = var(noise(:));

restoredInverse = inverse_filter(degraded, H, cfg.epsilon);
F = fft2(img);
restoredWiener = wiener_filter(degraded, H, F, cfg.noiseVariance);

[mseInverse, psnrInverse] = calculate_metrics(img, restoredInverse);
[mseWiener, psnrWiener] = calculate_metrics(img, restoredWiener);

fprintf('\n=============================================\n');
fprintf('EXPERIMENT 02: NOISE COMPARISON (%s)\n', cfg.imageName);
fprintf('=============================================\n');
fprintf('Motion length           : %g\n', cfg.motionLength);
fprintf('Motion angle            : %.1f degrees\n', cfg.motionAngle);
fprintf('Target noise variance   : %.4f\n', cfg.noiseVariance);
fprintf('Measured noise variance : %.4f\n', actualNoiseVariance);
fprintf('Inverse MSE / PSNR      : %.6f / %.4f dB\n', mseInverse, psnrInverse);
fprintf('Wiener MSE / PSNR       : %.6f / %.4f dB\n', mseWiener, psnrWiener);
fprintf('Wiener improvement      : %.4f dB\n', psnrWiener - psnrInverse);

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 1400, 400], ...
    'Name', sprintf('%s - Experiment 02', cfg.imageName));

t = tiledlayout(fig, 1, 4, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile(t);
imshow(img, []);
title('Original', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

nexttile(t);
imshow(degraded, []);
title('Blur + noise', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

nexttile(t);
imshow(restoredInverse, []);
title(sprintf('Inverse (%.2f dB)', psnrInverse), 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

nexttile(t);
imshow(restoredWiener, []);
title(sprintf('Wiener (%.2f dB)', psnrWiener), 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

title(t, sprintf('%s: Motion Blur + Gaussian Noise (\\sigma^2 = %.4f)', cfg.imageName, cfg.noiseVariance), ...
    'Color', 'k', 'FontSize', 14, 'FontWeight', 'bold');

exportgraphics(fig, fullfile(outDir.figures, 'exp02_noise_comparison.png'), ...
    'Resolution', 300, 'BackgroundColor', 'white');

Method = ["Inverse"; "Wiener"];
MSE = [mseInverse; mseWiener];
PSNR_dB = [psnrInverse; psnrWiener];
writetable(table(Method, MSE, PSNR_dB), fullfile(outDir.tables, 'exp02_noise_comparison.csv'));

result = struct('mseInverse', mseInverse, 'psnrInverse', psnrInverse, ...
    'mseWiener', mseWiener, 'psnrWiener', psnrWiener, ...
    'targetNoiseVariance', cfg.noiseVariance, 'actualNoiseVariance', actualNoiseVariance);
end