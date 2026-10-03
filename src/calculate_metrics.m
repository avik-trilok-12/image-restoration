function [mse, psnr_value] = calculate_metrics(original, restored)
    mse = mean((original(:) - restored(:)).^2);
    psnr_value = 10*log10(255^2/mse);
end
