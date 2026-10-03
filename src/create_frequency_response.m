function H = create_frequency_response(psf, imageSize)
    M = imageSize(1);
    N = imageSize(2);
    H_spatial = zeros(M,N);
    [hM, hN] = size(psf);
    H_spatial(1:hM, 1:hN) = psf;
    H_spatial = circshift(H_spatial, -floor([hM hN]/2));
    H = fft2(H_spatial);
end
