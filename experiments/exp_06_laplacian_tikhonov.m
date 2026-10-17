function results = exp_06_laplacian_tikhonov(img, cfg, outDir)
% EXP_06_LAPLACIAN_TIKHONOV: Evaluates Laplacian/Tikhonov regularization for motion-blurred,
% noisy images and compares it with existing restoration filters.
    fprintf('\n=============================================\n');
    fprintf('EXPERIMENT 06: LAPLACIAN/TIKHONOV (%s)\n', ...
        cfg.imageName);
    fprintf('=============================================\n');
    %% Configuration
    motionLength = cfg.motionLength;
    motionAngle = cfg.motionAngle;
    noiseVariance = cfg.noiseVariance;
    % Broad initial sweep; refine around the best value later.
    % lambdaValues = logspace(-5, 1, 25);
    lambdaValues = logspace(log10(0.03), log10(0.4), 31);
    % Reproducible noise realization.
    rng(cfg.randomSeed, 'twister');
    %% Generate blur and noise ONCE
    psf = generate_motion_psf(motionLength, motionAngle);
    H = create_frequency_response(psf, size(img));
    blurred = apply_blur(img, H);
    noise = sqrt(noiseVariance) * randn(size(img));
    noisyBlurred = blurred + noise;
    actualNoiseVariance = var(noise(:), 1);
    %% Baseline inverse and Wiener filters
    inverseRestored = inverse_filter( ...
        noisyBlurred, H, cfg.epsilon);
    F = fft2(img);
    wienerRestored = wiener_filter( ...
        noisyBlurred, H, F, noiseVariance);
    [mseInverse, psnrInverse] = ...
        calculate_metrics(img, inverseRestored);
    [mseWiener, psnrWiener] = ...
        calculate_metrics(img, wienerRestored);
    %% Laplacian/Tikhonov lambda sweep
    numLambdas = numel(lambdaValues);
    mseValues = zeros(numLambdas, 1);
    psnrValues = zeros(numLambdas, 1);
    bestPSNR = -Inf;
    bestLambda = NaN;
    bestRestored = [];
    for k = 1:numLambdas
        lambda = lambdaValues(k);
        restored = laplacian_tikhonov_filter( ...
            noisyBlurred, H, lambda);
        [mseValues(k), psnrValues(k)] = ...
            calculate_metrics(img, restored);
        if psnrValues(k) > bestPSNR
            bestPSNR = psnrValues(k);
            bestLambda = lambda;
            bestRestored = restored;
        end
    end
    %% Results table
    sweepTable = table( ...
        lambdaValues(:), mseValues, psnrValues, ...
        'VariableNames', {'lambda', 'mse', 'psnr'});
    csvSweep = fullfile(outDir.tables, ...
        'exp_06_laplacian_tikhonov_sweep.csv');
    writetable(sweepTable, csvSweep);
    %% Filter comparison table
    comparisonTable = table( ...
        ["Inverse"; "Wiener"; "Laplacian_Tikhonov"], ...
        [mseInverse; mseWiener; min(mseValues)], ...
        [psnrInverse; psnrWiener; bestPSNR], ...
        'VariableNames', {'filter', 'mse', 'psnr'});
    csvComparison = fullfile(outDir.tables, ...
        'exp_06_filter_comparison.csv');
    writetable(comparisonTable, csvComparison);
    
    %% Plot 1: PSNR versus lambda (High-contrast line plot)
    fig1 = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 750, 500], ...
                  'Visible', 'off');
    ax1 = axes(fig1);
    semilogx(ax1, lambdaValues, psnrValues, '-o', ...
        'LineWidth', 2, 'MarkerSize', 5, 'Color', [0 0.4470 0.7410]);
    hold(ax1, 'on');
    
    % Reference lines with explicit styling
    yline(ax1, psnrWiener, '--', 'Wiener baseline', ...
        'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5, ...
        'FontSize', 10, 'FontWeight', 'bold');
    xline(ax1, bestLambda, ':', sprintf('Best \\lambda = %.4g', bestLambda), ...
        'Color', [0.2 0.2 0.2], 'LineWidth', 1.5, ...
        'FontSize', 10, 'FontWeight', 'bold');
    
    % Force clean white plot canvas and sharp grid
    set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
        'FontSize', 11, 'LineWidth', 1.2);
    grid(ax1, 'on');
    set(ax1, 'GridColor', [0.25 0.25 0.25], 'GridAlpha', 0.35);
    
    xlabel(ax1, 'Regularization parameter \lambda', ...
        'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel(ax1, 'PSNR (dB)', ...
        'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
    title(ax1, sprintf('Laplacian/Tikhonov Sweep (%s)', cfg.imageName), ...
        'Color', 'k', 'FontSize', 13, 'FontWeight', 'bold');
    
    % High-contrast legend box
    lgd1 = legend(ax1, 'Laplacian/Tikhonov', 'Location', 'best');
    set(lgd1, 'Color', 'w', 'TextColor', 'k', ...
        'EdgeColor', [0.4 0.4 0.4], 'FontSize', 11);
    
    exportgraphics(fig1, fullfile(outDir.figures, 'exp_06_psnr_vs_lambda.png'), ...
        'Resolution', 300, 'BackgroundColor', 'white');

    %% Plot 2: Best reconstruction versus baselines (2x2 tiled image layout)
    fig2 = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 800, 800], ...
                  'Visible', 'off');
    t = tiledlayout(fig2, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
    
    % Subplot 1: Original
    nexttile(t);
    imagesc(img);
    axis image off;
    colormap(gca, gray);
    title('Original', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Subplot 2: Blurred + noisy
    nexttile(t);
    imagesc(noisyBlurred);
    axis image off;
    colormap(gca, gray);
    title('Blurred + noisy', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Subplot 3: Wiener
    nexttile(t);
    imagesc(wienerRestored);
    axis image off;
    colormap(gca, gray);
    title(sprintf('Wiener: %.2f dB', psnrWiener), ...
        'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Subplot 4: Laplacian/Tikhonov
    nexttile(t);
    imagesc(bestRestored);
    axis image off;
    colormap(gca, gray);
    title(sprintf('Laplacian: %.2f dB', bestPSNR), ...
        'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Global title across tiles
    title(t, sprintf('%s: Filter Comparison (L = %g, \\theta = %.1f^\\circ, \\sigma^2 = %.4f)', ...
        cfg.imageName, motionLength, motionAngle, noiseVariance), ...
        'Color', 'k', 'FontSize', 14, 'FontWeight', 'bold');
    
    exportgraphics(fig2, fullfile(outDir.figures, 'exp_06_restoration_comparison.png'), ...
        'Resolution', 300, 'BackgroundColor', 'white');

    %% Print summary
    fprintf('Image                   : %s\n', cfg.imageName);
    fprintf('Image size              : %d x %d\n', ...
        size(img, 1), size(img, 2));
    fprintf('Motion length / angle   : %.2f / %.2f deg\n', ...
        motionLength, motionAngle);
    fprintf('Target noise variance   : %.4f\n', noiseVariance);
    fprintf('Actual noise variance   : %.4f\n', actualNoiseVariance);
    fprintf('\nInverse filter          : MSE = %.6f, PSNR = %.4f dB\n', ...
        mseInverse, psnrInverse);
    fprintf('Wiener filter           : MSE = %.6f, PSNR = %.4f dB\n', ...
        mseWiener, psnrWiener);
    fprintf(['Laplacian/Tikhonov      : Best lambda = %.6g, ' ...
        'MSE = %.6f, PSNR = %.4f dB\n'], ...
        bestLambda, min(mseValues), bestPSNR);
    fprintf('\nSaved sweep table       : %s\n', csvSweep);
    fprintf('Saved comparison table  : %s\n', csvComparison);
    %% Return results
    results.lambdaValues = lambdaValues(:);
    results.mse = mseValues;
    results.psnr = psnrValues;
    results.bestLambda = bestLambda;
    results.bestMSE = min(mseValues);
    results.bestPSNR = bestPSNR;
    results.bestRestored = bestRestored;
    results.noisyBlurred = noisyBlurred;
    results.actualNoiseVariance = actualNoiseVariance;
    results.comparisonTable = comparisonTable;
end