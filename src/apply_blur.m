function blurred = apply_blur(img, H)
    F = fft2(img);
    G = H .* F;
    blurred = real(ifft2(G));
end