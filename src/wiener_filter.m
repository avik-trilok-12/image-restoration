function restored = wiener_filter(degraded, H, F, noiseVariance)
    G = fft2(degraded);
    Sf = abs(F).^2;
    Sf = max(Sf, 1e-12);
    M = size(degraded, 1);
    N = size(degraded, 2);
    Sn = M * N * noiseVariance;
    K = Sn ./ Sf;
    denominator = abs(H).^2 + K;
    W = zeros(size(H));
    valid = denominator > 1e-12;
    W(valid) = conj(H(valid)) ./ denominator(valid);
    F_hat = W .* G;
    restored = real(ifft2(F_hat));
end
