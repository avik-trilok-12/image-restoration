function restored = laplacian_tikhonov_filter(degraded, H, lambda)
    [M, N] = size(degraded);
    u = (0:M-1)';
    v = 0:N-1;
    P = 4 - 2*cos(2*pi*u/M) - 2*cos(2*pi*v/N);
    P2 = abs(P).^2;
    G = fft2(degraded);
    denominator = abs(H).^2 + lambda * P2;
    F_hat = conj(H) .* G ./ denominator;
    restored = real(ifft2(F_hat));
end