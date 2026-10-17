function result = exp_01_inverse_filter(img, cfg, outDir)
% EXPERIMENT 01: Noise-free inverse filtering under motion blur.

img = double(img);
psf = generate_motion_psf(cfg.motionLength, cfg.motionAngle);
H = create_frequency_response(psf, size(img));
blurred = apply_blur(img, H);
restored = inverse_filter(blurred, H, cfg.epsilon);
[mse, psnrValue] = calculate_metrics(img, restored);

%% Numerical reconstruction diagnostic

% Original image: img
% Blurred image: blurred
% Reconstructed image: restored

errorImage = img - restored;

mseDiagnostic = mean(errorImage(:).^2);
maxAbsError = max(abs(errorImage(:)));
rmseDiagnostic = sqrt(mseDiagnostic);

fprintf('\n--- Numerical Reconstruction Diagnostic ---\n');
fprintf('Image: %s\n', cfg.imageName);
fprintf('MSE: %.16e\n', mseDiagnostic);
fprintf('RMSE: %.16e\n', rmseDiagnostic);
fprintf('Maximum absolute error: %.16e\n', maxAbsError);
fprintf('Minimum restored value: %.8f\n', min(restored(:)));
fprintf('Maximum restored value: %.8f\n', max(restored(:)));
fprintf('Restored image contains NaN: %d\n', any(isnan(restored(:))));
fprintf('Restored image contains Inf: %d\n', any(isinf(restored(:))));

minH = min(abs(H(:)));
maxH = max(abs(H(:)));
valid = abs(H) > cfg.epsilon;
discardedPoints = nnz(~valid);
totalPoints = numel(H);
discardedPercentage = 100 * discardedPoints / totalPoints;

fprintf('\n=============================================\n');
fprintf('EXPERIMENT 01: INVERSE FILTERING (%s)\n', cfg.imageName);
fprintf('=============================================\n');
fprintf('Image size              : %d x %d\n', size(img,1), size(img,2));
fprintf('Motion blur length      : %g\n', cfg.motionLength);
fprintf('Motion blur angle       : %.1f degrees\n', cfg.motionAngle);
fprintf('Minimum |H|             : %.8f\n', minH);
fprintf('Maximum |H|             : %.8f\n', maxH);
fprintf('Inverse threshold       : %.1e\n', cfg.epsilon);
fprintf('Discarded frequencies   : %d / %d (%.4f%%)\n', ...
    discardedPoints, totalPoints, discardedPercentage);
fprintf('MSE                     : %.8f\n', mse);
fprintf('PSNR                    : %.4f dB\n', psnrValue);

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 1200, 420], ...
    'Name', sprintf('%s - Experiment 01', cfg.imageName));

% 2. Use tiledlayout for tight margins and proper spacing
t = tiledlayout(fig, 1, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

% Subplot 1
nexttile(t);
imshow(img, []);
title('Original', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

% Subplot 2
nexttile(t);
imshow(blurred, []);
title('Motion blurred', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

% Subplot 3
nexttile(t);
imshow(restored, []);
title(sprintf('Inverse (%.2f dB)', psnrValue), 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

% Overall Title in bold black
title(t, sprintf('%s: Inverse Filtering | Length = %g, Angle = %.1f deg', ...
    cfg.imageName, cfg.motionLength, cfg.motionAngle), ...
    'Color', 'k', 'FontSize', 14, 'FontWeight', 'bold');

% 3. Export with tight bounding box
exportgraphics(fig, fullfile(outDir.figures, 'exp01_inverse_filter.png'), ...
    'Resolution', 300, 'BackgroundColor', 'white');

result = struct('imageName', cfg.imageName, 'imageSize', size(img), ...
    'motionLength', cfg.motionLength, 'motionAngle', cfg.motionAngle, ...
    'epsilon', cfg.epsilon, 'minAbsH', minH, 'maxAbsH', maxH, ...
    'discardedPoints', discardedPoints, 'totalPoints', totalPoints, ...
    'discardedPercentage', discardedPercentage, 'MSE', mse, 'PSNR_dB', psnrValue);
T = table(string(cfg.imageName), size(img,1), size(img,2), ...
    cfg.motionLength, cfg.motionAngle, cfg.epsilon, minH, maxH, ...
    discardedPoints, totalPoints, discardedPercentage, mse, psnrValue, ...
    'VariableNames', {'Image','Rows','Columns','MotionLength','MotionAngle', ...
    'Epsilon','MinAbsH','MaxAbsH','DiscardedPoints','TotalPoints', ...
    'DiscardedPercentage','MSE','PSNR_dB'});
writetable(T, fullfile(outDir.tables, 'exp01_inverse_filter.csv'));
end
