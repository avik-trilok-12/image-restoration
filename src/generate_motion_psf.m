function psf = generate_motion_psf(length, angle)
    psf = fspecial('motion', length, angle);
end
