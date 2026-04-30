# HSADE-IQUA Color Image Encryption

This repository contains MATLAB code for color image encryption and decryption based on hierarchical surrogate-assisted optimization, Chen hyperchaotic sequences, Logistic chaotic sequences, DNA coding, and anti-clipping permutation.

The main entry point is `main_auto.m`.

## Citation

If you use this code, please cite:

Liu, Gao-Yuan, Ying Yu, Hui-Qi Zhao, Tian-Yu Gao, and Zhi-Yang Chen. 2025. "A Novel Color Image Encryption Method Based on Hierarchical Surrogate-Assisted Optimization" Electronics 14, no. 23: 4716. https://doi.org/10.3390/electronics14234716

## Overview

The encryption workflow contains the following major steps:

1. Read a color image and split it into R, G, and B channels.
2. Compute information entropy and adjacent-pixel correlation of the original image.
3. Zero-pad the image so that its dimensions are divisible by the block size.
4. Generate a Logistic chaotic sequence and reshape it into a random mask matrix.
5. Use `HSADE_IQUA` to optimize the initial parameters of the Chen hyperchaotic system.
6. Generate Chen hyperchaotic sequences from the optimized parameters.
7. Encrypt image blocks using DNA encoding, DNA operations, and block diffusion.
8. Apply anti-clipping row and column permutation.
9. Evaluate the encrypted image using entropy, correlation, and fitness metrics.
10. Save the encrypted image, decrypt it, and save the decrypted result.

## Repository Structure

```text
main_auto.m                       Main encryption, evaluation, logging, and decryption script
HSADE_IQUA.m                      Hierarchical surrogate-assisted optimizer with improved QUATRE sampling
output.m                          Maps optimizer parameters to Chen-system initial values
chen_output.m                     Generates Chen hyperchaotic sequences
DNA_code.m                        Performs DNA-based block encryption and diffusion
DNA_bian.m                        DNA encoding helper
DNA_jie.m                         DNA decoding helper
DNA_yunsuan.m                     DNA operation helper
fenkuai.m                         Block extraction helper
Copy_of_Anti_clipping.m           Anti-clipping row and column permutation
main_jiemi.m                      Decryption function
zero_padding.m                    Zero-padding helper
Calculate_information_entropy.m   Original-image entropy calculation
After_information_entropy.m       Encrypted-image entropy calculation
Orginal_Correlation_analysis.m    Original-image correlation analysis
After_Correlation_analysis.m      Encrypted-image correlation analysis
fobj.m                            Fitness function for correlation minimization
image_Baboon512rgb.png            Example input image
```

## Requirements

This project is implemented in MATLAB.

Required MATLAB capabilities include:

1. Image Processing Toolbox, for functions such as `imread`, `imhist`, `imshow`, and `imwrite`.
2. Statistics and Machine Learning Toolbox, for `lhsdesign`.
3. Deep Learning Toolbox or Neural Network Toolbox, for `newrbe` and `sim`.

If `newrbe` is unavailable, `HSADE_IQUA.m` includes a simple fallback surrogate evaluator, but the optimization behavior may differ from the intended implementation.

## Input Configuration

Edit the configuration section at the top of `main_auto.m`:

```matlab
BASE_IMAGE_NAME = 'image_Baboon512rgb';
IMAGE_EXT = 'png';
INPUT_FOLDER = '';
OUTPUT_FOLDER = '';
```

By default, the script expects:

```text
image_Baboon512rgb.png
```

in the current folder.

## Running the Code

Open MATLAB, set the current folder to this repository, and run:

```matlab
main_auto
```

The script will generate encrypted and decrypted images, display histograms and correlation figures, and write a text log containing key parameters and evaluation metrics.

## Outputs

For the default input image, the expected output names are:

```text
HSADE_en_image_Baboon512rgb.png
HSADE_de_image_Baboon512rgb.png
HSADE_image_image_Baboon512rgb_results_diary.txt
```

The log file records:

1. Key parameters used for decryption.
2. Original and encrypted image entropy.
3. Original and encrypted adjacent-pixel correlation values.
4. Final fitness value.
5. Optimization evaluation count and success statistics.

## Important Notes

The decryption routine depends on the same key parameters generated during encryption, including:

```text
u, x0, X0, Y0, Z0, H0, M1, N1, xx0, xx1
```

The anti-clipping helper `Copy_of_Anti_clipping.m` generates `Q_jiami`, `xx0`, and `xx1`. Ensure this step is enabled in `main_auto.m` before saving or decrypting the encrypted image.

The block size is fixed as:

```matlab
t = 4;
```

Both encryption and decryption assume this value. If you change it in `main_auto.m`, update `main_jiemi.m` accordingly.

## Reproducibility

The code uses random sampling for correlation analysis and optimization initialization. Results may vary between runs unless MATLAB's random seed is fixed manually, for example:

```matlab
rng(1);
```

Add the seed before the first random operation if deterministic runs are required.

## License

This project is released under the MIT License. See `LICENSE` for details.
