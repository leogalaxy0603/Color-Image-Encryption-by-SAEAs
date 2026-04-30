function Q_jiemi=main_jiemi(I,u,x0,X0,Y0,Z0,H0,M1,N1,xx0,xx1)
% I=imread('en_169.tif','tif');           % Read encrypted image information
I1=I(:,:,1);     % R channel
I2=I(:,:,2);     % G channel
I3=I(:,:,3);     % B channel
[M,N]=size(I1);                      % Assign image dimensions to M and N
t=4;    % Block size
SUM=M*N;
% u=3.9999;     % Key 1 parameter
% xx0=0.3883;
% xx1=0.4134;
ppx=zeros(1,M+1000);        % Preallocate memory
ppy=zeros(1,N+1000);
ppx(1)=xx0;
ppy(1)=xx1;
for i=1:M+999                 % Generate M+1000 Logistic values from the initial value
    ppx(i+1)=u*ppx(i)*(1-ppx(i));
end
for i=1:N+999                 % Generate N+1000 Logistic values from the initial value
    ppy(i+1)=u*ppy(i)*(1-ppy(i));
end
ppx=ppx(1001:length(ppx));            % Discard the first 1000 values to improve randomness
ppy=ppy(1001:length(ppy));

[~,Ux]=sort(ppx,'descend');
[~,Uy]=sort(ppy,'descend');

for i=N:-1:1
    temp = I1(:,i);
    I1(:,i) = I1(:,Uy(i));
    I1(:,Uy(i)) = temp;
    temp = I2(:,i);
    I2(:,i) = I2(:,Uy(i));
    I2(:,Uy(i)) = temp;
    temp = I3(:,i);
    I3(:,i) = I3(:,Uy(i));
    I3(:,Uy(i)) = temp;
end
for i=M:-1:1
    temp = I1(i,:);
    I1(i,:) = I1(Ux(i),:);
    I1(Ux(i),:) = temp;
    temp = I2(i,:);
    I2(i,:) = I2(Ux(i),:);
    I2(Ux(i),:) = temp;
    temp = I3(i,:);
    I3(i,:) = I3(Ux(i),:);
    I3(Ux(i),:) = temp;
%% 2. Generate Logistic chaotic sequence
%% 2.����Logistic��������
% u=3.990000000000001; % Key sensitivity test 10^-15
% u=3.99; % Logistic map parameter key
% x0=0.7067000000000001; % Key sensitivity test 10^-16
% x0=0.5475; % Logistic map initial value key x0
% x0=0.3462;            % home image
p=zeros(1,SUM+1000);
p(1)=x0;
for i=1:SUM+999                        % Generate SUM+1000 values from the Logistic sequence
    p(i+1)=u*p(i)*(1-p(i));
end
p=p(1001:length(p));

%% 3. Transform p to the 0-255 range and reshape it into an M-by-N matrix R
p=mod(round(p*10^4),256);
R=reshape(p,N,M)';  % Convert to an M-by-N matrix

%% 4. Chen hyperchaotic system
% Four initial values X0, Y0, Z0, H0
r=(M/t)*(N/t);
% X0=0.5008000000000001;        % Key sensitivity test
% X0=1;
% Y0=0.3562;
% Z0=-0.4482;
% H0=-0.6109;
% X0=0.5056;        % home image
% Y0=0.505;
% Z0=0.4564;
% H0=0.3062;
A=chen_output(X0,Y0,Z0,H0,r);
X=A(:,1);
X=X(3002:length(X));
Y=A(:,2);
Y=Y(3002:length(Y));
Z=A(:,3);
Z=Z(3002:length(Z));
H=A(:,4);
H=H(3002:length(H));

%% 5.DNA����
% X and Y are DNA encoding rules for I and R respectively, with values 1-8
X=mod(round(X*10^4),8)+1;
Y=mod(round(Y*10^4),8)+1;
Z=mod(round(Z*10^4),4);
Z(Z==0)=4;      % Inverse operation mapping for addition/subtraction
Z(Z==1)=0;
Z(Z==4)=1;
H=mod(round(H*10^4),8)+1;
e=N/t;
for i=r:-1:2
    Q1_R=DNA_bian(fenkuai(t,I1,i),H(i));
    Q1_G=DNA_bian(fenkuai(t,I2,i),H(i));
    Q1_B=DNA_bian(fenkuai(t,I3,i),H(i));
    
    Q1_last_R=DNA_bian(fenkuai(t,I1,i-1),H(i-1));
    Q1_last_G=DNA_bian(fenkuai(t,I2,i-1),H(i-1));
    Q1_last_B=DNA_bian(fenkuai(t,I3,i-1),H(i-1));
    
    Q2_R=DNA_yunsuan(Q1_R,Q1_last_R,Z(i));        % Before de-diffusion
    Q2_G=DNA_yunsuan(Q1_G,Q1_last_G,Z(i));
    Q2_B=DNA_yunsuan(Q1_B,Q1_last_B,Z(i));

    Q3=DNA_bian(fenkuai(t,R,i),Y(i));
    
    Q4_R=DNA_yunsuan(Q2_R,Q3,Z(i));
    Q4_G=DNA_yunsuan(Q2_G,Q3,Z(i));
    Q4_B=DNA_yunsuan(Q2_B,Q3,Z(i));
    
    xx=floor(i/e)+1;
    yy=mod(i,e);
    if yy==0
        xx=xx-1;
        yy=e;
    end
    I1((xx-1)*t+1:xx*t,(yy-1)*t+1:yy*t)=DNA_jie(Q4_R,X(i));
    I2((xx-1)*t+1:xx*t,(yy-1)*t+1:yy*t)=DNA_jie(Q4_G,X(i));
    I3((xx-1)*t+1:xx*t,(yy-1)*t+1:yy*t)=DNA_jie(Q4_B,X(i));
end
Q5_R=DNA_bian(fenkuai(t,I1,1),H(1));
Q5_G=DNA_bian(fenkuai(t,I2,1),H(1));
Q5_B=DNA_bian(fenkuai(t,I3,1),H(1));

Q6=DNA_bian(fenkuai(t,R,1),Y(1));

Q7_R=DNA_yunsuan(Q5_R,Q6,Z(1));
Q7_G=DNA_yunsuan(Q5_G,Q6,Z(1));
Q7_B=DNA_yunsuan(Q5_B,Q6,Z(1));

I1(1:t,1:t)=DNA_jie(Q7_R,X(1));
I2(1:t,1:t)=DNA_jie(Q7_G,X(1));
I3(1:t,1:t)=DNA_jie(Q7_B,X(1));

Q_jiemi(:,:,1)=uint8(I1);
Q_jiemi(:,:,2)=uint8(I2);
Q_jiemi(:,:,3)=uint8(I3);

%% 6. Remove zero-padding added during encryption
% M1=0;   % Padding remainder M1=mod(M,t), used as a decryption key
% N1=0;   % Padding remainder N1=mod(N,t), used as a decryption key
if M1~=0
    Q_jiemi=Q_jiemi(1:M-t+M1,:,:);
end
if N1~=0
    Q_jiemi=Q_jiemi(:,1:N-t+N1,:);
end

figure;imhist(Q_jiemi(:,:,1));
figure;imhist(Q_jiemi(:,:,2));
figure;imhist(Q_jiemi(:,:,3));

%% Output image


% title('Decrypted image');
end