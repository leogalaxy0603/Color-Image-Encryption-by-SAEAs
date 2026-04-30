%% ======================= main.m =======================
% Color image encryption-decryption and evaluation (using HSADE_IQUA optimized parameters)
% Termination condition: maximum function evaluations MaxFEs
%
% If you use this code, please cite:
% Liu, Gao-Yuan, Ying Yu, Hui-Qi Zhao, Tian-Yu Gao, and Zhi-Yang Chen. 2025.
% "A Novel Color Image Encryption Method Based on Hierarchical
% Surrogate-Assisted Optimization" Electronics 14, no. 23: 4716.
% https://doi.org/10.3390/electronics14234716
% -------------------------------------------------------
clear; close all; clc;

%% =================== Filename configuration ===================
% Edit only this section when changing the target image.
BASE_IMAGE_NAME = 'image_Baboon512rgb';           % Base image name (without extension)
IMAGE_EXT = 'png';                 % Image extension
INPUT_FOLDER = '';                 % Input folder path (empty means current folder)
OUTPUT_FOLDER = '';                % Output folder path (empty means current folder)

% Auto-generate all related filenames
if ~isempty(INPUT_FOLDER) && ~endsWith(INPUT_FOLDER, filesep)
    INPUT_FOLDER = [INPUT_FOLDER, filesep];
end
if ~isempty(OUTPUT_FOLDER) && ~endsWith(OUTPUT_FOLDER, filesep)
    OUTPUT_FOLDER = [OUTPUT_FOLDER, filesep];
end

% Build full file paths
ORIGINAL_IMAGE  = [INPUT_FOLDER, BASE_IMAGE_NAME, '.', IMAGE_EXT];
ENCRYPTED_IMAGE = [OUTPUT_FOLDER, 'HSADE_en_', BASE_IMAGE_NAME, '.', IMAGE_EXT];
DECRYPTED_IMAGE = [OUTPUT_FOLDER, 'HSADE_de_', BASE_IMAGE_NAME, '.', IMAGE_EXT];
LOG_FILE        = [OUTPUT_FOLDER, 'HSADE_image_', BASE_IMAGE_NAME, '_results_diary.txt'];

% Display configuration information
fprintf('========== File configuration ==========\n');
fprintf('Original image: %s\n', ORIGINAL_IMAGE);
fprintf('Encrypted image: %s\n', ENCRYPTED_IMAGE);
fprintf('Decrypted image: %s\n', DECRYPTED_IMAGE);
fprintf('Log file: %s\n', LOG_FILE);
fprintf('===================================\n\n');

%% 0) Read image and separate channels
% Check whether the original image exists
if ~exist(ORIGINAL_IMAGE, 'file')
    error('Error: image file not found "%s"', ORIGINAL_IMAGE);
end

I = imread(ORIGINAL_IMAGE);         % Read image
I1 = I(:,:,1);  % R
I2 = I(:,:,2);  % G
I3 = I(:,:,3);  % B

% Visualize original channel histograms
figure; imhist(I1); title('Original image R-channel histogram');
figure; imhist(I2); title('Original image G-channel histogram');
figure; imhist(I3); title('Original image B-channel histogram');

% Size information
[M,N] = size(I1);
t = 4;                 % Block size

%% 1) Original image information entropy and correlation
[xxs1_R, xxs1_G, xxs1_B] = Calculate_information_entropy(I1, I2, I3);
NN = 5000;   % Number of correlation sample pairs
[RXY1_SP_R,RXY1_CZ_R,RXY1_DJX_R, ...
 RXY1_SP_G,RXY1_CZ_G,RXY1_DJX_G, ...
 RXY1_SP_B,RXY1_CZ_B,RXY1_DJX_B, x1, y1] = Orginal_Correlation_analysis(NN, M, N, I1, I2, I3);

%% 2) Zero-pad to dimensions divisible by t
[I1, I2, I3, M1, N1] = zero_padding(M, N, I1, I2, I3, t);
[M, N] = size(I1);                 % Padded size
SUM = M * N;                       % Total number of pixels

%% 3) Logistic chaotic sequence and random matrix R
u  = 3.9999;                                   % Logistic parameter
x0 = (sum(I1(:)) + sum(I2(:))) / (255*SUM*2);  % Initial value (image-dependent)
x0 = floor(x0*1e4)/1e4;                         % Keep four decimal places

p = zeros(1, SUM+1000);
p(1) = x0;
for i=1:SUM+999
    p(i+1) = u * p(i) * (1 - p(i));
end
p = p(1001:end);                    % Discard the first 1000 values to improve randomness
p = mod(round(p*1e4), 256);         % Map to 0-255
R = reshape(p, N, M)';              % M-by-N random matrix (source of the uint8 mask)

%% 4) Optimization algorithm: HSADE_IQUA (replaces SCA)
% Dimension: matches the parameter mapping in output() (the original code used dim=4)
dim = 4;
LB  = -ones(1, dim);
UB  =  ones(1, dim);

% Maximum number of evaluations (main termination condition); adjust as needed
MaxFEs = 200;   % Suggested starting range: 200-1000; larger values search more thoroughly

% Fitness (scalar): candidate x -> one encryption pass (without anti-clipping) -> correlation -> fobj
FUN = @(x) local_encrypt_fitness(x, M, N, t, I1, I2, I3, SUM, R, u, NN, x1, y1, @fobj);
% parfor i=1:runs
%     % Run HSADE_IQUA (ensure HSADE_IQUA.m is in the same folder)
%     [~, Best_val_1, ~, ~, ~] = HSADE_IQUA(FUN, dim, UB, LB, MaxFEs);
%     [~, Best_val_2, ~, ~, ~] = DE_basic(FUN, dim, UB, LB, MaxFEs);
%     [~, Best_val_3, ~, ~, ~] = SADE_AMSS(FUN, dim, UB, LB, MaxFEs);
%     gbest_1(1,i)=Best_val_1;
%     gbest_2(2,i)=Best_val_2;
%     gbest_3(2,i)=Best_val_2;
% end
[Best_pos, Best_val, CE, NFEs, SN] = HSADE_IQUA(FUN, dim, UB, LB, MaxFEs);
% fprintf('[HSADE] NFEs=%d  BestVal=%.6e  GS/LS-Success=%d/%d\n', NFEs, Best_val, SN(1), SN(2));
% [Best_pos, Best_val, CE, NFEs, SN] = DE_basic(FUN, dim, UB, LB, MaxFEs);
% [Best_pos, Best_val, CE, NFEs, SN] = SADE_AMSS(FUN, dim, UB, LB, MaxFEs);
%
%% 5) Generate Chen hyperchaotic sequences with the optimal parameters
[X, Y, Z, H, r, X0, Y0, Z0, H0] = output(Best_pos, M, N, t, I1, I2, I3, SUM);

%% 6) DNA encoding encryption (final full pass)
[Q_R, Q_G, Q_B] = DNA_code(N, R, t, X, Y, Z, H, I1, I2, I3, r);

%% 7) Anti-clipping permutation (same helper version as the original script)
[Q_R, Q_G, Q_B, xx0, xx1, Q_jiami] = Copy_of_Anti_clipping(u, M, N, Q_R, Q_G, Q_B, I2, I3, SUM);
% To test noise:
% Q_jiami = imnoise(Q_jiami,'salt & pepper',0.5);

%% 8) Information entropy and correlation after encryption
[xxs2_R, xxs2_G, xxs2_B] = After_information_entropy(Q_R, Q_G, Q_B);
[RXY2_R, RXY2_G, RXY2_B] = After_Correlation_analysis(Q_R, Q_G, Q_B, NN, x1, y1);
fitness = fobj(RXY2_R, RXY2_G, RXY2_B);

% Expand the three directional correlations
RXY2_SP_R=RXY2_R(1,1);  RXY2_CZ_R=RXY2_R(1,2);  RXY2_DJX_R=RXY2_R(1,3);
RXY2_SP_G=RXY2_G(1,1);  RXY2_CZ_G=RXY2_G(1,2);  RXY2_DJX_G=RXY2_G(1,3);
RXY2_SP_B=RXY2_B(1,1);  RXY2_CZ_B=RXY2_B(1,2);  RXY2_DJX_B=RXY2_B(1,3);

%% 9) Visual comparison
figure('Position',[284 214 1200 400]);
subplot(2,4,1);
imshow(I);
title('Plain Image');
subplot(2,4,2);
imhist(I1);
title('Ch1 Channel Histogram of Plain Image');
axis([0 255 0 2000]);
subplot(2,4,3);
imhist(I2);
title('Ch2 Channel Histogram of Plain Image');
axis([0 255 0 2000]);
subplot(2,4,4);
imhist(I3);
title('Ch3 Channel Histogram of Plain Image');
axis([0 255 0 2000]);
subplot(2,4,5);
imshow(Q_jiami);
title('Cipher Image');
subplot(2,4,6);
imhist(Q_R);
title('Ch1 Channel Histogram of Cipher Image');
axis([0 255 0 2000]);
subplot(2,4,7);
imhist(Q_G);
title('Ch2 Channel Histogram of Cipher Image');
axis([0 255 0 2000]);
subplot(2,4,8);
imhist(Q_B);
title('Ch3 Channel Histogram of Cipher Image');
axis([0 255 0 2000]);
%
% Save encrypted image
imwrite(Q_jiami, ENCRYPTED_IMAGE);
fprintf('Encrypted image saved to: %s\n', ENCRYPTED_IMAGE);
figure; imshow(Q_jiami); title('Encrypted image');

%% 10) Organize keys and write the log
% Real parameters used for decryption (keep original values)
u_1=u; x0_1=x0; X0_1=X0; Y0_1=Y0; Z0_1=Z0; H0_1=H0; M1_1=M1; N1_1=N1; xx0_1=xx0; xx1_1=xx1;

% Text display only: multiply by 10000 and convert to strings (avoid overly short display)
u_v  = num2str(u   *10000);
x0_v = num2str(x0  *10000);
X0_v = num2str(X0  *10000);
Y0_v = num2str(Y0  *10000);
Z0_v = num2str(Z0  *10000);
H0_v = num2str(H0  *10000);
M1_v = num2str(M1  *10000);
N1_v = num2str(N1  *10000);
xx0_v= num2str(xx0 *10000);
xx1_v= num2str(xx1 *10000);

key = [u_v,' - ',x0_v,' - ',X0_v,' - ',Y0_v,' - ',Z0_v,' - ',H0_v,' - ',M1_v,' - ',N1_v,' - ',xx0_v,' - ',xx1_v];

% Write log file 
diary(LOG_FILE); diary on;
disp(['========== Image "', BASE_IMAGE_NAME, '" encryption results ==========']);
disp('Encryption succeeded');
disp('Keys (displayed as parameter x 10000 strings):');
disp(['Key 1: mu=',u_v,' Key 2: x0=',x0_v,' Key 3: x(0)=',X0_v,' Key 4: y(0)=',Y0_v,' Key 5: z(0)=',Z0_v]);
disp(['Key 6: h(0)=',H0_v,' Key 7: M1=',M1_v,' Key 8: N1=',N1_v,' Key 9: xx0=',xx0_v,' Key 10: xx1=',xx1_v]);
disp('Information entropy:');
disp(['Original image R-channel entropy=',num2str(xxs1_R),' Original image G-channel entropy=',num2str(xxs1_G),' Original image B-channel entropy=',num2str(xxs1_B)]);
disp(['Encrypted image R-channel entropy=',num2str(xxs2_R),' Encrypted image G-channel entropy=',num2str(xxs2_G),' Encrypted image B-channel entropy=',num2str(xxs2_B)]);
disp('R-channel correlation:');
disp(['Original R: horizontal=',num2str(RXY1_SP_R),' vertical=',num2str(RXY1_CZ_R),' diagonal=',num2str(RXY1_DJX_R)]);
disp(['Encrypted R: horizontal=',num2str(RXY2_SP_R),' vertical=',num2str(RXY2_CZ_R),' diagonal=',num2str(RXY2_DJX_R)]);
disp('G-channel correlation:');
disp(['Original G: horizontal=',num2str(RXY1_SP_G),' vertical=',num2str(RXY1_CZ_G),' diagonal=',num2str(RXY1_DJX_G)]);
disp(['Encrypted G: horizontal=',num2str(RXY2_SP_G),' vertical=',num2str(RXY2_CZ_G),' diagonal=',num2str(RXY2_DJX_G)]);
disp('B-channel correlation:');
disp(['Original B: horizontal=',num2str(RXY1_SP_B),' vertical=',num2str(RXY1_CZ_B),' diagonal=',num2str(RXY1_DJX_B)]);
disp(['Encrypted B: horizontal=',num2str(RXY2_SP_B),' vertical=',num2str(RXY2_CZ_B),' diagonal=',num2str(RXY2_DJX_B)]);
disp(['Final fitness (fobj)=', num2str(fitness,'%.6e')]);
disp(['Optimizer evaluations NFEs=', num2str(NFEs), ', GS/LS success count=', num2str(SN(1)), '/', num2str(SN(2))]);
disp('==============================================');
diary off;
fprintf('Log saved to: %s\n', LOG_FILE);

%% 11) Decryption and display
% Check whether the encrypted image exists
if ~exist(ENCRYPTED_IMAGE, 'file')
    error('Error: encrypted image file not found "%s"', ENCRYPTED_IMAGE);
end

I_en = imread(ENCRYPTED_IMAGE);           % Read image information
Q_jiemi = main_jiemi(I_en,u_1, x0_1, X0_1, Y0_1, Z0_1, H0_1, M1_1, N1_1, xx0_1, xx1_1);
imwrite(Q_jiemi, DECRYPTED_IMAGE);


fprintf('Decrypted image saved to: %s\n', DECRYPTED_IMAGE);

disp('Real key parameters used for decryption (not multiplied by 10000):');
disp(['mu=',num2str(u_1),'  x0=',num2str(x0_1),'  x(0)=',num2str(X0_1),'  y(0)=',num2str(Y0_1),'  z(0)=',num2str(Z0_1),'  h(0)=',num2str(H0_1)]);
disp(['M1=',num2str(M1_1),'  N1=',num2str(N1_1),'  xx0=',num2str(xx0_1),'  xx1=',num2str(xx1_1)]);
disp('Decryption complete');
figure; imshow(Q_jiemi); title('Decrypted image');

%{
%% 12) Key-space analysis
disp(' ');
disp('=====================================');
disp('Starting key-space capacity analysis...');
disp('=====================================');
[total_key_space, key_space_bits] = analyze_key_space(u_1, x0_1, X0_1, Y0_1, Z0_1, H0_1, M1_1, N1_1, xx0_1, xx1_1);
disp(['Total key space approx ', num2str(total_key_space)]);
disp(['Equivalent bit count approx ', num2str(key_space_bits)]);
%}

%% Optional convergence curve
if exist('CE','var') && numel(CE)>1
    figure; plot(CE,'LineWidth',1.5); grid on;
    xlabel('True evaluations NFE'); ylabel('Historical best value');
    title('Optimizer convergence curve');
end
%}
%% =================== Local function: fitness evaluation ===================
%
function fit = local_encrypt_fitness(x, M, N, t, I1, I2, I3, SUM, R, u, NN, x1, y1, fobj_handle)
    % Given candidate parameter x:
    % 1) Generate Chen hyperchaotic sequences
    [X, Y, Z, H, r, ~, ~, ~, ~] = output(x, M, N, t, I1, I2, I3, SUM);
    % 2) DNA-encode encrypted channels (anti-clipping is skipped here for speed)
    [Q_R, Q_G, Q_B] = DNA_code(N, R, t, X, Y, Z, H, I1, I2, I3, r);
    % 3) Analyze correlation and reduce it to a scalar fitness
    [RXY2_R, RXY2_G, RXY2_B] = After_Correlation_analysis(Q_R, Q_G, Q_B, NN, x1, y1);
    fit = fobj_handle(RXY2_R, RXY2_G, RXY2_B);  % Smaller is better
end
%}
%{
function fit = local_encrypt_fitness(x, M, N, t, I1, I2, I3, SUM, R, u, NN, x1, y1, fobj_handle)
    % Given candidate parameter x:
    % 1) Generate Chen hyperchaotic sequences
    [X, Y, Z, H, r, ~, ~, ~, ~] = output(x, M, N, t, I1, I2, I3, SUM);
    % 2) DNA-encode encrypted channels (anti-clipping is skipped here for speed)
    [Q_R, Q_G, Q_B] = DNA_code(N, R, t, X, Y, Z, H, I1, I2, I3, r);
    % 3) Analyze correlation and reduce it to a scalar fitness
    [RXY2_R, RXY2_G, RXY2_B] = After_Correlation_analysis(Q_R, Q_G, Q_B, NN, x1, y1);
    fit = fobj_handle(RXY2_R, RXY2_G, RXY2_B);  % Smaller is better
end
%}
