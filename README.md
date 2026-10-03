# Frequency-Domain Image Restoration

Image restoration of motion-blurred and noisy images using inverse filtering and Wiener filtering in the frequency domain.

---

## Overview

Image degradation is commonly caused by motion blur, defocus, sensor noise, and other imperfections during image acquisition. Recovering the original image from a degraded observation is known as **image restoration**.

This project investigates frequency-domain techniques for restoring images degraded by:

- Linear motion blur
- Additive Gaussian noise

Two classical restoration approaches are implemented and compared:

1. **Inverse Filtering**
2. **Wiener Filtering**

The project studies how the performance of these methods changes as the degradation becomes more severe. In particular, experiments investigate the effects of:

- Frequency-domain inversion and ill-conditioned blur transfer functions
- Increasing Gaussian noise variance
- Increasing motion-blur length
- Noise amplification in inverse filtering
- The robustness of Wiener filtering under noisy conditions

All experiments are implemented in MATLAB and are organized into reusable source functions and independent experiment scripts.

---

## Objectives

The main objectives of this project are:

1. Model image degradation mathematically in the spatial and frequency domains.
2. Implement a frequency-domain motion-blur model.
3. Implement inverse filtering for image restoration.
4. Implement Wiener filtering for restoration in the presence of noise.
5. Quantitatively evaluate restoration using:
   - Mean Squared Error (MSE)
   - Peak Signal-to-Noise Ratio (PSNR)
6. Study the effect of increasing noise variance.
7. Study the effect of increasing motion-blur length.
8. Compare the robustness of inverse and Wiener filtering.
9. Build a reproducible MATLAB project structure suitable for further research.

---

# Mathematical Background

## 1. Image Degradation Model

The observed degraded image can be modeled as:

$$
g(x,y) = h(x,y) \ast f(x,y) + n(x,y)
$$

where:

- $f(x,y)$ is the original image.
- $h(x,y)$ is the point spread function (PSF).
- $\ast$ denotes spatial convolution.
- $n(x,y)$ is additive noise.
- $g(x,y)$ is the observed degraded image.

For this project, the degradation consists of a linear motion blur followed by additive Gaussian noise.

---

## 2. Frequency-Domain Representation

Using the Fourier transform, convolution becomes multiplication:

$$
G(u,v) = H(u,v)F(u,v) + N(u,v)
$$

where:

- $F(u,v)$ is the Fourier transform of the original image.
- $H(u,v)$ is the frequency response of the blur PSF.
- $G(u,v)$ is the Fourier transform of the degraded image.
- $N(u,v)$ is the Fourier transform of the noise.

This representation allows restoration to be performed directly in the frequency domain.

---

# Restoration Methods

## Inverse Filtering

The ideal inverse filter attempts to recover the original spectrum using:

$$
\hat{F}_{\mathrm{inv}}(u,v)
=
\frac{G(u,v)}{H(u,v)}
$$

However, when $H(u,v)$ is close to zero, the division becomes numerically unstable.

Considering the degradation model:

$$
G = HF + N
$$

the inverse-filter estimate becomes:

$$
\begin{aligned}
\hat{F}_{\mathrm{inv}}
&= \frac{G}{H} \\
&= \frac{HF + N}{H} \\
&= F + \frac{N}{H}
\end{aligned}
$$

Therefore, frequencies where $|H(u,v)|$ is small can cause significant noise amplification.

A threshold is therefore used during implementation:

$$
|H(u,v)| < \epsilon
$$

Frequencies below this threshold are not directly inverted.

---

## Wiener Filtering

Wiener filtering incorporates information about both the degradation and the noise.

The frequency-domain Wiener filter is implemented as:

$$
W(u,v)
=
\frac{H^{*}(u,v)}
{|H(u,v)|^2 + \frac{S_N(u,v)}{S_F(u,v)}}
$$

where:

- $H^{*}(u,v)$ is the complex conjugate of the degradation response.
- $S_N$ is the noise power spectrum.
- $S_F$ is the original image power spectrum.

The restored spectrum is then:

$$
\hat{F}_{W}(u,v)
=
W(u,v)G(u,v)
$$

Unlike direct inverse filtering, the Wiener filter does not aggressively amplify frequencies where the blur response is weak.

This makes it considerably more robust when the degraded image contains noise.

---

# Project Structure

```text
image-restoration/
│
├── data/
│   └── img_restoration.mat
│
├── experiments/
│   ├── exp_01_inverse_filter.m
│   ├── exp_02_noise_comparison.m
│   ├── exp_03_noise_sweep.m
│   └── exp_04_blur_sweep.m
│
├── results/
│   ├── figures/
│   │   ├── exp01_inverse_filter.png
│   │   ├── exp02_noise_comparison.png
│   │   ├── exp03_psnr_vs_noise.png
│   │   ├── exp03_mse_vs_noise.png
│   │   ├── exp04_psnr_vs_blur_length.png
│   │   └── exp04_mse_vs_blur_length.png
│   │
│   └── tables/
│       ├── exp03_noise_sweep.csv
│       └── exp04_blur_sweep.csv
│
├── src/
│   ├── apply_blur.m
│   ├── calculate_metrics.m
│   ├── create_frequency_response.m
│   ├── generate_motion_psf.m
│   ├── inverse_filter.m
│   └── wiener_filter.m
│
├── main.m
│
└── README.md