function restored = inverse_filter(degraded, H, epsilon)
    G = fft2(degraded);
    F_hat = zeros(size(G));
    valid = abs(H) > epsilon;
    F_hat(valid) = G(valid) ./ H(valid);
    restored = real(ifft2(F_hat));
end
