function [xxs1_R,xxs1_G,xxs1_B]=Calculate_information_entropy(I1,I2,I3)
%% Information entropy of the original RGB channels
% R channel
T1_R=imhist(I1);   % Count the gray-level distribution of the R channel over 0-255 and store it in T1_R
S1_R=sum(T1_R);     % Total number of gray-value samples in the R channel
xxs1_R=0;           % Original image R-channel entropy
% G channel
T1_G=imhist(I2);
S1_G=sum(T1_G);
xxs1_G=0;
% B channel
T1_B=imhist(I3);
S1_B=sum(T1_B);
xxs1_B=0;

for i=1:256
    pp1_R=T1_R(i)/S1_R;   % Probability of each gray value
    pp1_G=T1_G(i)/S1_G;
    pp1_B=T1_B(i)/S1_B;
    if pp1_R~=0
        xxs1_R=xxs1_R-pp1_R*log2(pp1_R);
    end
    if pp1_G~=0
        xxs1_G=xxs1_G-pp1_G*log2(pp1_G);
    end
    if pp1_B~=0
        xxs1_B=xxs1_B-pp1_B*log2(pp1_B);
    end
end

end