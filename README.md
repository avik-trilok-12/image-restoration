# Frequency-Domain Image Restoration

A MATLAB project exploring frequency-domain restoration of motion-blurred and noisy images. The project implements inverse filtering, Wiener filtering, scalar regularization, and Laplacian/Tikhonov regularization, then evaluates their behavior under controlled noise and blur conditions.

## Table of Contents

- [Overview](#overview)
- [Objectives](#objectives)
- [Dataset](#dataset)
- [Methods](#methods)
- [Experiments](#experiments)
- [Repository Structure](#repository-structure)
- [Requirements](#requirements)
- [Running the Project](#running-the-project)
- [Evaluation Metrics](#evaluation-metrics)
- [Current Results](#current-results)
- [Interpretation and Limitations](#interpretation-and-limitations)
- [Reproducibility](#reproducibility)

## Overview

Image restoration aims to estimate a clean image from an observation degraded by blur and noise. This project uses the synthetic degradation model

$$
g(x,y) = h(x,y) * f(x,y) + n(x,y),
$$

where $f(x,y)$ is the original image, $h(x,y)$ is the motion-blur point-spread function (PSF), $*$ denotes convolution, $n(x,y)$ is additive noise, and $g(x,y)$ is the degraded observation.

The blur is represented in the frequency domain using the two-dimensional Fourier transform. Restoration filters operate on the degraded image's spectrum to estimate the original image.

## Objectives

- Simulate motion blur and additive noise.
- Implement and compare inverse and Wiener filtering.
- Study how noise variance and motion-blur length affect restoration quality.
- Evaluate scalar regularization of inverse filtering.
- Implement Laplacian/Tikhonov regularization and compare it with baseline methods.
- Quantitatively evaluate restoration using mean squared error (MSE) and peak signal-to-noise ratio (PSNR).
- Save experiment figures and tables for analysis and reporting.

## Dataset

The project uses two grayscale images supplied in `data/img_restoration.mat`:

| Image | Dimensions | Intensity range |
|---|---:|---:|
| `I1` | 220 × 220 | 21–240 |
| `I2` | 256 × 256 | 0–255 |

The data file contains the variables `I1` and `I2`. Images are converted to `double` for numerical processing.

## Methods

### 1. Motion-blur model

A motion-blur PSF is generated with MATLAB's `fspecial('motion', motionLength, motionAngle)`. The PSF is embedded in an image-sized array, shifted to place its origin appropriately, and transformed with `fft2` to obtain the frequency response $H(u,v)$.

The implementation uses FFT-based circular convolution. Therefore, the noise-free inverse reconstruction experiment tests the consistency of this simulated model; it does not represent every boundary condition encountered in real photographs.

### 2. Inverse filtering

Inverse filtering estimates the original spectrum by dividing the degraded spectrum by the blur response:

$$
\hat F(u,v) = \frac{G(u,v)}{H(u,v)}.
$$

Division by very small values of $H(u,v)$ can amplify noise. The implementation therefore uses a threshold $\epsilon$ and only divides at frequencies satisfying $|H(u,v)| > \epsilon$.

### 3. Wiener filtering

Wiener filtering balances inversion of the blur response with suppression of frequencies where noise is dominant. In this implementation, the filter uses the clean image's Fourier spectrum to calculate the signal power term, together with the configured noise variance.

**Important:** because the clean image is used to supply its spectrum, this implementation is an oracle-informed benchmark. It should not be interpreted as a fully deployable Wiener filter for an unknown real-world image without a corresponding method to estimate the signal spectrum.

### 4. Scalar regularized inverse filtering

Scalar regularization stabilizes inverse filtering by adding a regularization term to the denominator. The experiment sweeps candidate regularization values and selects the one with the best PSNR against the clean reference image.

The selected parameter is therefore ground-truth-informed for the tested image and degradation.

### 5. Laplacian/Tikhonov regularization

Laplacian/Tikhonov filtering penalizes spatial variation through the frequency response of a discrete two-dimensional Laplacian. Its frequency-domain form in this project is:

$$
\hat F(u,v) =
\frac{H^*(u,v)G(u,v)}
{|H(u,v)|^2 + \lambda |P(u,v)|^2},
$$

where $H(u,v)$ is the blur transfer function, $G(u,v)$ is the degraded image spectrum, $H^*(u,v)$ is the complex conjugate of $H(u,v)$, $P(u,v)$ is the Laplacian frequency response, and $\lambda$ controls the strength of regularization.

A lambda sweep is used to study the effect of regularization strength. In the current experiment, the best lambda is selected using PSNR against the clean image, so this is also an oracle-informed parameter-selection procedure.

## Experiments

The project contains six experiments. Each experiment accepts an image, a configuration structure, and an output-directory structure, allowing the same implementation to run on `I1` and `I2`.

| Experiment | Script | Purpose |
|---|---|---|
| 01 | `experiments/exp_01_inverse_filter.m` | Tests inverse filtering under the configured blur model, including a noise-free reconstruction diagnostic. |
| 02 | `experiments/exp_02_noise_comparison.m` | Compares inverse and Wiener filtering for a fixed blur and noise setting. |
| 03 | `experiments/exp_03_noise_sweep.m` | Measures restoration quality across several noise variances. |
| 04 | `experiments/exp_04_blur_sweep.m` | Measures restoration quality across several motion-blur lengths. |
| 05 | `experiments/exp_05_regularized_inverse.m` | Sweeps scalar regularization values and compares the selected result with baseline filters. |
| 06 | `experiments/exp_06_laplacian_tikhonov.m` | Sweeps Laplacian/Tikhonov regularization values and compares the selected reconstruction with inverse and Wiener filtering. |

The current configuration described during development uses a motion length of 15, motion angle of 0 degrees, target noise variance of 100, inverse threshold of $10^{-3}$, and random seed of 1. The noise sweep uses variances `[1, 10, 25, 50, 100, 200, 500]`; the blur sweep uses lengths `[5, 10, 15, 20, 30, 40, 50]`. Check `main.m` for the active configuration, as values may be changed for further experiments.

## Repository Structure

```text
image-restoration/
├── data/
│   └── img_restoration.mat
├── experiments/
│   ├── exp_01_inverse_filter.m
│   ├── exp_02_noise_comparison.m
│   ├── exp_03_noise_sweep.m
│   ├── exp_04_blur_sweep.m
│   ├── exp_05_regularized_inverse.m
│   └── exp_06_laplacian_tikhonov.m
├── src/
│   ├── apply_blur.m
│   ├── calculate_metrics.m
│   ├── create_frequency_response.m
│   ├── generate_motion_psf.m
│   ├── inverse_filter.m
│   ├── laplacian_tikhonov_filter.m
│   └── wiener_filter.m
├── results/
│   ├── I1/
│   │   ├── figures/
│   │   └── tables/
│   └── I2/
│       ├── figures/
│       └── tables/
├── main.m
└── README.md
```

The exact files in `src/` and the result folders may evolve as the project develops.

## Requirements

- MATLAB
- Image Processing Toolbox for `fspecial` (used to generate the motion-blur PSF)
- `data/img_restoration.mat` containing `I1` and `I2`

## Running the Project

1. Clone or download the repository.
2. Open MATLAB and set the current folder to the project root.
3. Confirm that `data/img_restoration.mat` contains `I1` and `I2`.
4. Check the configurations in `main.m`.
5. Run:

```matlab
main
```

The main script loads the images, configures the experiments, and saves figures and CSV tables under the corresponding image-specific result directories.

To run only one experiment, call its function with an image, a configuration structure, and an output-directory structure. For example:

```matlab
results = exp_06_laplacian_tikhonov(img, cfg, outDir);
```

Ensure that `src/` and `experiments/` are on the MATLAB path. If `main.m` adds these paths automatically, running `main` from the project root should be sufficient.

## Evaluation Metrics

### Mean squared error (MSE)

For an original image $f$ and restored image $\hat f$ with $M \times N$ pixels:

$$
{MSE} =
\frac{1}{MN}\sum_{x=1}^{M}\sum_{y=1}^{N}
\left(f(x,y)-\hat f(x,y)\right)^2.
$$

Lower MSE indicates a smaller average squared pixel error.

### Peak signal-to-noise ratio (PSNR)

$$
{PSNR} =
10\log_{10}\left(\frac{L^2}{{MSE}}\right),
$$

where \(L\) is the peak intensity used by the metric implementation. This project currently uses $L=255$. Higher PSNR generally indicates lower reconstruction error. Extremely high PSNR in a noise-free reconstruction experiment can occur when the numerical error is close to floating-point precision.

## Current Results

The following results are from the current **I2** run with motion length 15, angle 0 degrees, and target noise variance 100. They are included as a development snapshot, not as final results for both images.

| Method / experiment | MSE | PSNR (dB) |
|---|---:|---:|
| Inverse filtering, noisy observation | 350394.016 | -7.3148 |
| Wiener filtering, noisy observation | 324.564 | 23.0178 |
| Scalar regularized inverse, selected lambda = 0.06 | 545.237 | 20.7649 |
| Laplacian/Tikhonov, selected lambda ≈ 0.0921711 | 370.217 | 22.4462 |

For Experiment 06, the measured noise variance was approximately 100.31. The best Laplacian/Tikhonov lambda was selected from the configured sweep using the clean reference image's PSNR.

The noise-sweep and blur-sweep experiments also show that, for the current I2 configuration, Wiener-filter PSNR decreases as the target noise variance or motion-blur length increases. Consult the CSV files in `results/I2/tables/` for the full numerical results.

## Interpretation and Limitations

- The blur response is generated synthetically and assumed known to the restoration filters. Real applications may require blur estimation.
- The experiments use a circular-convolution model through FFTs. Real image boundaries may behave differently.
- The Wiener implementation uses the original image's Fourier spectrum. This is oracle-informed and would require an estimated spectrum in a practical deployment.
- The current regularization sweeps select parameters using reference-image PSNR. This is suitable for controlled analysis but is not available when the clean test image is unknown.
- Noise is generated synthetically as zero-mean Gaussian noise with the configured variance. Actual measured variance can differ slightly from the target due to finite image size.
- PSNR uses a peak intensity of 255. This is appropriate for the 8-bit intensity scale used in the experiments, but metric conventions should remain consistent when comparing images.

## Reproducibility

- A fixed random seed is used to make noise generation reproducible.
- The experiments save numerical tables as CSV files and plots as PNG files.
- Run both images with the same experimental settings when comparing image-dependent behavior.
- Record any changes to blur parameters, noise levels, thresholds, lambda ranges, or metric conventions when generating final results.
