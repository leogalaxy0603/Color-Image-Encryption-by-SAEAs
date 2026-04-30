function [RXY2_R,RXY2_G,RXY2_B]=After_Correlation_analysis(Q_R,Q_G,Q_B,NN,x1,y1)
XX_R_SP=zeros(1,NN);YY_R_SP=zeros(1,NN);  % Preallocate memory
XX_G_SP=zeros(1,NN);YY_G_SP=zeros(1,NN);
XX_B_SP=zeros(1,NN);YY_B_SP=zeros(1,NN);
% Vertical
XX_R_CZ=zeros(1,NN);YY_R_CZ=zeros(1,NN);  % Preallocate memory
XX_G_CZ=zeros(1,NN);YY_G_CZ=zeros(1,NN);
XX_B_CZ=zeros(1,NN);YY_B_CZ=zeros(1,NN);
% Diagonal
XX_R_DJX=zeros(1,NN);YY_R_DJX=zeros(1,NN);  % Preallocate memory
XX_G_DJX=zeros(1,NN);YY_G_DJX=zeros(1,NN);
XX_B_DJX=zeros(1,NN);YY_B_DJX=zeros(1,NN);
for i=1:NN
    % Horizontal
    XX_R_SP(i)=Q_R(x1(i),y1(i));
    YY_R_SP(i)=Q_R(x1(i)+1,y1(i));
    XX_G_SP(i)=Q_G(x1(i),y1(i));
    YY_G_SP(i)=Q_G(x1(i)+1,y1(i));
    XX_B_SP(i)=Q_B(x1(i),y1(i));
    YY_B_SP(i)=Q_B(x1(i)+1,y1(i));
    % Vertical
    XX_R_CZ(i)=Q_R(x1(i),y1(i));
    YY_R_CZ(i)=Q_R(x1(i),y1(i)+1);
    XX_G_CZ(i)=Q_G(x1(i),y1(i));
    YY_G_CZ(i)=Q_G(x1(i),y1(i)+1);
    XX_B_CZ(i)=Q_B(x1(i),y1(i));
    YY_B_CZ(i)=Q_B(x1(i),y1(i)+1);
    % Diagonal
    XX_R_DJX(i)=Q_R(x1(i),y1(i));
    YY_R_DJX(i)=Q_R(x1(i)+1,y1(i)+1);
    XX_G_DJX(i)=Q_G(x1(i),y1(i));
    YY_G_DJX(i)=Q_G(x1(i)+1,y1(i)+1);
    XX_B_DJX(i)=Q_B(x1(i),y1(i));
    YY_B_DJX(i)=Q_B(x1(i)+1,y1(i)+1);
end
%{
% Horizontal
figure;scatter(XX_R_SP,YY_R_SP,18,'filled');xlabel('R-channel selected pixel gray value');ylabel('Adjacent horizontal pixel gray value');title('Cipher image R-channel horizontal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_SP,YY_G_SP,18,'filled');xlabel('G-channel selected pixel gray value');ylabel('Adjacent horizontal pixel gray value');title('Cipher image G-channel horizontal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_SP,YY_B_SP,18,'filled');xlabel('B-channel selected pixel gray value');ylabel('Adjacent horizontal pixel gray value');title('Cipher image B-channel horizontal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% Vertical
figure;scatter(XX_R_CZ,YY_R_CZ,18,'filled');xlabel('R-channel selected pixel gray value');ylabel('Adjacent vertical pixel gray value');title('Cipher image R-channel vertical adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_CZ,YY_G_CZ,18,'filled');xlabel('G-channel selected pixel gray value');ylabel('Adjacent vertical pixel gray value');title('Cipher image G-channel vertical adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_CZ,YY_B_CZ,18,'filled');xlabel('B-channel selected pixel gray value');ylabel('Adjacent vertical pixel gray value');title('Cipher image B-channel vertical adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% Diagonal
figure;scatter(XX_R_DJX,YY_R_DJX,18,'filled');xlabel('R-channel selected pixel gray value');ylabel('Adjacent diagonal pixel gray value');title('Cipher image R-channel diagonal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_DJX,YY_G_DJX,18,'filled');xlabel('G-channel selected pixel gray value');ylabel('Adjacent diagonal pixel gray value');title('Cipher image G-channel diagonal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_DJX,YY_B_DJX,18,'filled');xlabel('B-channel selected pixel gray value');ylabel('Adjacent diagonal pixel gray value');title('Cipher image B-channel diagonal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% R channel
%}
Q_R=double(Q_R);
EX2_R=0;EY2_SP_R=0;DX2_R=0;DY2_SP_R=0;COVXY2_SP_R=0;    % Horizontal
EY2_CZ_R=0;DY2_CZ_R=0;COVXY2_CZ_R=0;    % Vertical
EY2_DJX_R=0;DY2_DJX_R=0;COVXY2_DJX_R=0;   % Diagonal
% G channel
Q_G=double(Q_G);
EX2_G=0;EY2_SP_G=0;DX2_G=0;DY2_SP_G=0;COVXY2_SP_G=0;    % Horizontal
EY2_CZ_G=0;DY2_CZ_G=0;COVXY2_CZ_G=0;    % Vertical
EY2_DJX_G=0;DY2_DJX_G=0;COVXY2_DJX_G=0;   % Diagonal
% B channel
Q_B=double(Q_B);
EX2_B=0;EY2_SP_B=0;DX2_B=0;DY2_SP_B=0;COVXY2_SP_B=0;    % Horizontal
EY2_CZ_B=0;DY2_CZ_B=0;COVXY2_CZ_B=0;    % Vertical
EY2_DJX_B=0;DY2_DJX_B=0;COVXY2_DJX_B=0;   % Diagonal
for i=1:NN
    % The first pixel mean is shared across horizontal, vertical, and diagonal correlation calculations and is denoted by EX2
    EX2_R=EX2_R+Q_R(x1(i),y1(i));
    EX2_G=EX2_G+Q_G(x1(i),y1(i));
    EX2_B=EX2_B+Q_B(x1(i),y1(i));
    % The second pixel means are denoted by EY2_SP, EY2_CZ, and EY2_DJX for horizontal, vertical, and diagonal directions
    % R channel
    EY2_SP_R=EY2_SP_R+Q_R(x1(i),y1(i)+1);
    EY2_CZ_R=EY2_CZ_R+Q_R(x1(i)+1,y1(i));
    EY2_DJX_R=EY2_DJX_R+Q_R(x1(i)+1,y1(i)+1);
    % G channel
    EY2_SP_G=EY2_SP_G+Q_G(x1(i),y1(i)+1);
    EY2_CZ_G=EY2_CZ_G+Q_G(x1(i)+1,y1(i));
    EY2_DJX_G=EY2_DJX_G+Q_G(x1(i)+1,y1(i)+1);
    % B channel
    EY2_SP_B=EY2_SP_B+Q_B(x1(i),y1(i)+1);
    EY2_CZ_B=EY2_CZ_B+Q_B(x1(i)+1,y1(i));
    EY2_DJX_B=EY2_DJX_B+Q_B(x1(i)+1,y1(i)+1);
end
% Normalize the accumulated sample sums
% R channel
EX2_R=EX2_R/NN;
EY2_SP_R=EY2_SP_R/NN;
EY2_CZ_R=EY2_CZ_R/NN;
EY2_DJX_R=EY2_DJX_R/NN;
% G channel
EX2_G=EX2_G/NN;
EY2_SP_G=EY2_SP_G/NN;
EY2_CZ_G=EY2_CZ_G/NN;
EY2_DJX_G=EY2_DJX_G/NN;
% B channel
EX2_B=EX2_B/NN;
EY2_SP_B=EY2_SP_B/NN;
EY2_CZ_B=EY2_CZ_B/NN;
EY2_DJX_B=EY2_DJX_B/NN;

for i=1:NN
    % The first pixel variance is shared across horizontal, vertical, and diagonal calculations and is denoted by DX2
    DX2_R=DX2_R+(Q_R(x1(i),y1(i))-EX2_R)^2;
    DX2_G=DX2_G+(Q_G(x1(i),y1(i))-EX2_G)^2;
    DX2_B=DX2_B+(Q_B(x1(i),y1(i))-EX2_B)^2;
    % The second pixel variances are denoted by DY2_SP, DY2_CZ, and DY2_DJX for horizontal, vertical, and diagonal directions
    % R channel
    DY2_SP_R=DY2_SP_R+(Q_R(x1(i),y1(i)+1)-EY2_SP_R)^2;
    DY2_CZ_R=DY2_CZ_R+(Q_R(x1(i)+1,y1(i))-EY2_CZ_R)^2;
    DY2_DJX_R=DY2_DJX_R+(Q_R(x1(i)+1,y1(i)+1)-EY2_DJX_R)^2;
    % G channel
    DY2_SP_G=DY2_SP_G+(Q_G(x1(i),y1(i)+1)-EY2_SP_G)^2;
    DY2_CZ_G=DY2_CZ_G+(Q_G(x1(i)+1,y1(i))-EY2_CZ_G)^2;
    DY2_DJX_G=DY2_DJX_G+(Q_G(x1(i)+1,y1(i)+1)-EY2_DJX_G)^2;
    % B channel
    DY2_SP_B=DY2_SP_B+(Q_B(x1(i),y1(i)+1)-EY2_SP_B)^2;
    DY2_CZ_B=DY2_CZ_B+(Q_B(x1(i)+1,y1(i))-EY2_CZ_B)^2;
    DY2_DJX_B=DY2_DJX_B+(Q_B(x1(i)+1,y1(i)+1)-EY2_DJX_B)^2;
    % Compute covariance for adjacent pixels in the horizontal, vertical, and diagonal directions
    % R channel
    COVXY2_SP_R=COVXY2_SP_R+(Q_R(x1(i),y1(i))-EX2_R)*(Q_R(x1(i),y1(i)+1)-EY2_SP_R);
    COVXY2_CZ_R=COVXY2_CZ_R+(Q_R(x1(i),y1(i))-EX2_R)*(Q_R(x1(i)+1,y1(i))-EY2_CZ_R);
    COVXY2_DJX_R=COVXY2_DJX_R+(Q_R(x1(i),y1(i))-EX2_R)*(Q_R(x1(i)+1,y1(i)+1)-EY2_DJX_R);
    % G channel
    COVXY2_SP_G=COVXY2_SP_G+(Q_G(x1(i),y1(i))-EX2_G)*(Q_G(x1(i),y1(i)+1)-EY2_SP_G);
    COVXY2_CZ_G=COVXY2_CZ_G+(Q_G(x1(i),y1(i))-EX2_G)*(Q_G(x1(i)+1,y1(i))-EY2_CZ_G);
    COVXY2_DJX_G=COVXY2_DJX_G+(Q_G(x1(i),y1(i))-EX2_G)*(Q_G(x1(i)+1,y1(i)+1)-EY2_DJX_G);
    % B channel
    COVXY2_SP_B=COVXY2_SP_B+(Q_B(x1(i),y1(i))-EX2_B)*(Q_B(x1(i),y1(i)+1)-EY2_SP_B);
    COVXY2_CZ_B=COVXY2_CZ_B+(Q_B(x1(i),y1(i))-EX2_B)*(Q_B(x1(i)+1,y1(i))-EY2_CZ_B);
    COVXY2_DJX_B=COVXY2_DJX_B+(Q_B(x1(i),y1(i))-EX2_B)*(Q_B(x1(i)+1,y1(i)+1)-EY2_DJX_B);
end
% Normalize the accumulated sample sums
% R channel
DX2_R=DX2_R/NN;
DY2_SP_R=DY2_SP_R/NN;
DY2_CZ_R=DY2_CZ_R/NN;
DY2_DJX_R=DY2_DJX_R/NN;
COVXY2_SP_R=COVXY2_SP_R/NN;
COVXY2_CZ_R=COVXY2_CZ_R/NN;
COVXY2_DJX_R=COVXY2_DJX_R/NN;
% G channel
DX2_G=DX2_G/NN;
DY2_SP_G=DY2_SP_G/NN;
DY2_CZ_G=DY2_CZ_G/NN;
DY2_DJX_G=DY2_DJX_G/NN;
COVXY2_SP_G=COVXY2_SP_G/NN;
COVXY2_CZ_G=COVXY2_CZ_G/NN;
COVXY2_DJX_G=COVXY2_DJX_G/NN;
% B channel
DX2_B=DX2_B/NN;
DY2_SP_B=DY2_SP_B/NN;
DY2_CZ_B=DY2_CZ_B/NN;
DY2_DJX_B=DY2_DJX_B/NN;
COVXY2_SP_B=COVXY2_SP_B/NN;
COVXY2_CZ_B=COVXY2_CZ_B/NN;
COVXY2_DJX_B=COVXY2_DJX_B/NN;
% Correlation coefficients in the horizontal, vertical, and diagonal directions
% R channel
RXY2_SP_R=COVXY2_SP_R/sqrt(DX2_R*DY2_SP_R);
RXY2_CZ_R=COVXY2_CZ_R/sqrt(DX2_R*DY2_CZ_R);
RXY2_DJX_R=COVXY2_DJX_R/sqrt(DX2_R*DY2_DJX_R);
% G channel
RXY2_SP_G=COVXY2_SP_G/sqrt(DX2_G*DY2_SP_G);
RXY2_CZ_G=COVXY2_CZ_G/sqrt(DX2_G*DY2_CZ_G);
RXY2_DJX_G=COVXY2_DJX_G/sqrt(DX2_G*DY2_DJX_G);
% B channel
RXY2_SP_B=COVXY2_SP_B/sqrt(DX2_B*DY2_SP_B);
RXY2_CZ_B=COVXY2_CZ_B/sqrt(DX2_B*DY2_CZ_B);
RXY2_DJX_B=COVXY2_DJX_B/sqrt(DX2_B*DY2_DJX_B);
RXY2_R(1,1)=RXY2_SP_R;RXY2_R(1,2)=RXY2_CZ_R;RXY2_R(1,3)=RXY2_DJX_R;
RXY2_G(1,1)=RXY2_SP_G;RXY2_G(1,2)=RXY2_CZ_G;RXY2_G(1,3)=RXY2_DJX_G;
RXY2_B(1,1)=RXY2_SP_B;RXY2_B(1,2)=RXY2_CZ_B;RXY2_B(1,3)=RXY2_DJX_B;
end