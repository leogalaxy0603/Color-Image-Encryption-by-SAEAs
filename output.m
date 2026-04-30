function [X,Y,Z,H,r,X0,Y0,Z0,H0]=output(XP,M,N,t,I1,I2,I3,SUM)
%% 4. Generate Chen hyperchaotic system
% Four initial values X0, Y0, Z0, H0
r=(M/t)*(N/t);      % r is the number of blocks
% Compute the four initial values
I_sum = sum(I1(:)) + sum(I2(:)) + sum(I3(:));
I_normalized = I_sum / (255 * SUM * 3);  % Normalize to [0,1]

% Step 2: Chen-system baseline values + optimized-position perturbation + image-feature perturbation
X0 = 35 + XP(1) * 5 + I_normalized;     % Baseline 35 with perturbation range [-5,5]
Y0 = -7 + XP(2) * 3 + I_normalized;     % Baseline -7 with perturbation range [-3,3]
Z0 = 26 + XP(3) * 5 + I_normalized;     % Baseline 26 with perturbation range [-5,5]
H0 = -4 + XP(4) * 2 + I_normalized;     % Baseline -4 with perturbation range [-2,2]

% Step 3: Use bit masks to extract image-related bit-plane average information
% Bit-mask design:
% 85  = 01010101 (extract alternating bits)
% 170 = 10101010 (extract complementary alternating bits)
% 51  = 00110011 (extract low two-bit groups)
% 204 = 11001100 (extract high two-bit groups)
bit_feature1 = sum(sum(bitand(I1, 85))) / (85 * SUM);   % R-channel alternating-bit feature
bit_feature2 = sum(sum(bitand(I2, 170))) / (170 * SUM); % G-channel complementary alternating-bit feature
bit_feature3 = sum(sum(bitand(I3, 51))) / (51 * SUM);   % B-channel low-bit-group feature
bit_feature4 = sum(sum(bitand(I1, 204))) / (204 * SUM); % R-channel high-bit-group feature

% Step 4: Add bit-feature perturbations
X0 = X0 + bit_feature1 * 0.1;  % Bit features provide a 0-0.1 perturbation
Y0 = Y0 + bit_feature2 * 0.1;
Z0 = Z0 + bit_feature3 * 0.1;
H0 = H0 + bit_feature4 * 0.1;

% Step 5: Optional extra security enhancement
% Use cross-channel bit features
cross_feature1 = sum(sum(bitand(I1, bitxor(170, uint8(I2))))) / (255 * SUM);
cross_feature2 = sum(sum(bitand(I2, bitxor(51, uint8(I3))))) / (255 * SUM);
X0 = X0 + cross_feature1 * 0.05;  % Cross features provide small perturbations
Y0 = Y0 + cross_feature2 * 0.05;

% Round to four decimal places to control precision
X0 = round(X0 * 10^4) / 10^4;
Y0 = round(Y0 * 10^4) / 10^4;
Z0 = round(Z0 * 10^4) / 10^4;
H0 = round(H0 * 10^4) / 10^4;

% Generate four chaotic sequences from the Chen hyperchaotic system using the initial values
A=chen_output(X0,Y0,Z0,H0,r);
X=A(:,1);
X=X(3002:length(X));        % Discard the first 3001 values to improve randomness after transient dynamics
Y=A(:,2);
Y=Y(3002:length(Y));
Z=A(:,3);
Z=Z(3002:length(Z));
H=A(:,4);
H=H(3002:length(H));

end