function restored = regularized_inverse_filter(degraded, H, lambda)

    if lambda <= 0
        error("lambda must be strictly positive")
    end
    
    G = fft2(double(degraded));
    
    denominator = abs(H).^2 + lambda;
    F_hat = conj(H) .* G ./ denominator;
    
    restored = real(ifft2(F_hat));
end

