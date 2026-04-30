function [Q_R,Q_G,Q_B]=DNA_code(N,R,t,X,Y,Z,H,I1,I2,I3,r)
% X and Y are DNA encoding rules for image I and random matrix R respectively, with values 1-8
% Z is the DNA operation rule, with values 0-3: 0 addition, 1 subtraction, 2 XOR, 3 XNOR
% H is the DNA decoding rule, with values 1-8
X=mod(round(X*10^4),8)+1;
Y=mod(round(Y*10^4),8)+1;
Z=mod(round(Z*10^4),4);
H=mod(round(H*10^4),8)+1;
e=N/t;  % Number of blocks per row

Q2=DNA_bian(fenkuai(t,R,1),Y(1));
% R channel
Q1_R=DNA_bian(fenkuai(t,I1,1),X(1));
Q_last_R=DNA_yunsuan(Q1_R,Q2,Z(1));
Q_R(1:t,1:t)=DNA_jie(Q_last_R,H(1));
% G channel
Q1_G=DNA_bian(fenkuai(t,I2,1),X(1));
Q_last_G=DNA_yunsuan(Q1_G,Q2,Z(1));
Q_G(1:t,1:t)=DNA_jie(Q_last_G,H(1));
% B channel
Q1_B=DNA_bian(fenkuai(t,I3,1),X(1));
Q_last_B=DNA_yunsuan(Q1_B,Q2,Z(1));
Q_B(1:t,1:t)=DNA_jie(Q_last_B,H(1));

for i=2:r
    Q1_R=DNA_bian(fenkuai(t,I1,i),X(i));   % DNA-encode each original-image R-channel block using the rule from X
    Q1_G=DNA_bian(fenkuai(t,I2,i),X(i));
    Q1_B=DNA_bian(fenkuai(t,I3,i),X(i));
    
    Q2=DNA_bian(fenkuai(t,R,i),Y(i));   % DNA-encode each random-matrix R block using the rule from Y
    % R channel
    Q3_R=DNA_yunsuan(Q1_R,Q2,Z(i));         % Apply the DNA operation from Z to the two encoded blocks
    Q4_R=DNA_yunsuan(Q3_R,Q_last_R,Z(i));     % Combine with the previous block once more for diffusion
    Q_last_R=Q4_R;
    % G channel
    Q3_G=DNA_yunsuan(Q1_G,Q2,Z(i));
    Q4_G=DNA_yunsuan(Q3_G,Q_last_G,Z(i));
    Q_last_G=Q4_G;
    % B channel
    Q3_B=DNA_yunsuan(Q1_B,Q2,Z(i));
    Q4_B=DNA_yunsuan(Q3_B,Q_last_B,Z(i));
    Q_last_B=Q4_B;
    
    xx=floor(i/e)+1;
    yy=mod(i,e);
    if yy==0
        xx=xx-1;
        yy=e;
    end
    Q_R((xx-1)*t+1:xx*t,(yy-1)*t+1:yy*t)=DNA_jie(Q4_R,H(i));    % Write each processed block into encrypted image Q
    Q_G((xx-1)*t+1:xx*t,(yy-1)*t+1:yy*t)=DNA_jie(Q4_G,H(i));
    Q_B((xx-1)*t+1:xx*t,(yy-1)*t+1:yy*t)=DNA_jie(Q4_B,H(i));
end
Q_R=uint8(Q_R);
Q_G=uint8(Q_G);
Q_B=uint8(Q_B);
end