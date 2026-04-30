function [xxs2_R,xxs2_G,xxs2_B]=After_information_entropy(Q_R,Q_G,Q_B)
T2_R=imhist(Q_R);
S2_R=sum(T2_R);
xxs2_R=0;
% G channel
T2_G=imhist(Q_G);
S2_G=sum(T2_G);
xxs2_G=0;
% B channel
T2_B=imhist(Q_B);
S2_B=sum(T2_B);
xxs2_B=0;
for i=1:256
    pp2_R=T2_R(i)/S2_R;
    pp2_G=T2_G(i)/S2_G;
    pp2_B=T2_B(i)/S2_B;
    if pp2_R~=0
        xxs2_R=xxs2_R-pp2_R*log2(pp2_R);
    end
    if pp2_G~=0
        xxs2_G=xxs2_G-pp2_G*log2(pp2_G);
    end
    if pp2_B~=0
        xxs2_B=xxs2_B-pp2_B*log2(pp2_B);
    end
end
end