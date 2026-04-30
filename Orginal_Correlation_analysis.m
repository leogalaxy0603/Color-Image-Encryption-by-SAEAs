function [RXY1_SP_R,RXY1_CZ_R,RXY1_DJX_R,RXY1_SP_G,RXY1_CZ_G,RXY1_DJX_G,RXY1_SP_B,RXY1_CZ_B,RXY1_DJX_B,x1,y1]=Orginal_Correlation_analysis(NN,M,N,I1,I2,I3)
% NN=5000;    % Randomly select 5000 pixel pairs
x1=ceil(rand(1,NN)*(M-1));      % Generate row indices in the range 1 to M-1
y1=ceil(rand(1,NN)*(N-1));      % Generate column indices in the range 1 to N-1
% Preallocate memory
XX_R_SP=zeros(1,NN);YY_R_SP=zeros(1,NN);        % Horizontal
XX_G_SP=zeros(1,NN);YY_G_SP=zeros(1,NN);
XX_B_SP=zeros(1,NN);YY_B_SP=zeros(1,NN);
XX_R_CZ=zeros(1,NN);YY_R_CZ=zeros(1,NN);        % Vertical
XX_G_CZ=zeros(1,NN);YY_G_CZ=zeros(1,NN);
XX_B_CZ=zeros(1,NN);YY_B_CZ=zeros(1,NN);
XX_R_DJX=zeros(1,NN);YY_R_DJX=zeros(1,NN);      % Diagonal
XX_G_DJX=zeros(1,NN);YY_G_DJX=zeros(1,NN);
XX_B_DJX=zeros(1,NN);YY_B_DJX=zeros(1,NN);
for i=1:NN
    % Horizontal
    XX_R_SP(i)=I1(x1(i),y1(i));
    YY_R_SP(i)=I1(x1(i)+1,y1(i));
    XX_G_SP(i)=I2(x1(i),y1(i));
    YY_G_SP(i)=I2(x1(i)+1,y1(i));
    XX_B_SP(i)=I3(x1(i),y1(i));
    YY_B_SP(i)=I3(x1(i)+1,y1(i));
    % Vertical
    XX_R_CZ(i)=I1(x1(i),y1(i));
    YY_R_CZ(i)=I1(x1(i),y1(i)+1);
    XX_G_CZ(i)=I2(x1(i),y1(i));
    YY_G_CZ(i)=I2(x1(i),y1(i)+1);
    XX_B_CZ(i)=I3(x1(i),y1(i));
    YY_B_CZ(i)=I3(x1(i),y1(i)+1);
    % Diagonal
    XX_R_DJX(i)=I1(x1(i),y1(i));
    YY_R_DJX(i)=I1(x1(i)+1,y1(i)+1);
    XX_G_DJX(i)=I2(x1(i),y1(i));
    YY_G_DJX(i)=I2(x1(i)+1,y1(i)+1);
    XX_B_DJX(i)=I3(x1(i),y1(i));
    YY_B_DJX(i)=I3(x1(i)+1,y1(i)+1);
end
% Horizontal
figure;scatter(XX_R_SP,YY_R_SP,18,'filled');xlabel('R-channel selected pixel gray value');ylabel('Adjacent horizontal pixel gray value');title('Plain image R-channel horizontal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_SP,YY_G_SP,18,'filled');xlabel('G-channel selected pixel gray value');ylabel('Adjacent horizontal pixel gray value');title('Plain image G-channel horizontal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_SP,YY_B_SP,18,'filled');xlabel('B-channel selected pixel gray value');ylabel('Adjacent horizontal pixel gray value');title('Plain image B-channel horizontal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% Vertical
figure;scatter(XX_R_CZ,YY_R_CZ,18,'filled');xlabel('R-channel selected pixel gray value');ylabel('Adjacent vertical pixel gray value');title('Plain image R-channel vertical adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_CZ,YY_G_CZ,18,'filled');xlabel('G-channel selected pixel gray value');ylabel('Adjacent vertical pixel gray value');title('Plain image G-channel vertical adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_CZ,YY_B_CZ,18,'filled');xlabel('B-channel selected pixel gray value');ylabel('Adjacent vertical pixel gray value');title('Plain image B-channel vertical adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% Diagonal
figure;scatter(XX_R_DJX,YY_R_DJX,18,'filled');xlabel('R-channel selected pixel gray value');ylabel('Adjacent diagonal pixel gray value');title('Plain image R-channel diagonal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_DJX,YY_G_DJX,18,'filled');xlabel('G-channel selected pixel gray value');ylabel('Adjacent diagonal pixel gray value');title('Plain image G-channel diagonal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_DJX,YY_B_DJX,18,'filled');xlabel('B-channel selected pixel gray value');ylabel('Adjacent diagonal pixel gray value');title('Plain image B-channel diagonal adjacent-pixel correlation');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% R channel
EX1_R=0;EY1_SP_R=0;DX1_R=0;DY1_SP_R=0;COVXY1_SP_R=0;    % Variables used for horizontal correlation
EY1_CZ_R=0;DY1_CZ_R=0;COVXY1_CZ_R=0;                % Vertical
EY1_DJX_R=0;DY1_DJX_R=0;COVXY1_DJX_R=0;             % Diagonal
% G channel
EX1_G=0;EY1_SP_G=0;DX1_G=0;DY1_SP_G=0;COVXY1_SP_G=0;
EY1_CZ_G=0;DY1_CZ_G=0;COVXY1_CZ_G=0;
EY1_DJX_G=0;DY1_DJX_G=0;COVXY1_DJX_G=0;
% B channel
EX1_B=0;EY1_SP_B=0;DX1_B=0;DY1_SP_B=0;COVXY1_SP_B=0;
EY1_CZ_B=0;DY1_CZ_B=0;COVXY1_CZ_B=0;
EY1_DJX_B=0;DY1_DJX_B=0;COVXY1_DJX_B=0;

I1=double(I1);
I2=double(I2);
I3=double(I3);
for i=1:NN
    % The first pixel mean is shared across horizontal, vertical, and diagonal correlation calculations and is denoted by EX1
    EX1_R=EX1_R+I1(x1(i),y1(i)); 
    EX1_G=EX1_G+I2(x1(i),y1(i)); 
    EX1_B=EX1_B+I3(x1(i),y1(i)); 
    % The second pixel means are denoted by EY1_SP, EY1_CZ, and EY1_DJX for horizontal, vertical, and diagonal directions
    % R channel
    EY1_SP_R=EY1_SP_R+I1(x1(i),y1(i)+1);
    EY1_CZ_R=EY1_CZ_R+I1(x1(i)+1,y1(i));
    EY1_DJX_R=EY1_DJX_R+I1(x1(i)+1,y1(i)+1);
    % G channel
    EY1_SP_G=EY1_SP_G+I2(x1(i),y1(i)+1);
    EY1_CZ_G=EY1_CZ_G+I2(x1(i)+1,y1(i));
    EY1_DJX_G=EY1_DJX_G+I2(x1(i)+1,y1(i)+1);
    % B channel
    EY1_SP_B=EY1_SP_B+I3(x1(i),y1(i)+1);
    EY1_CZ_B=EY1_CZ_B+I3(x1(i)+1,y1(i));
    EY1_DJX_B=EY1_DJX_B+I3(x1(i)+1,y1(i)+1);
end
% Normalize the accumulated sample sums
% R channel
EX1_R=EX1_R/NN;
EY1_SP_R=EY1_SP_R/NN;
EY1_CZ_R=EY1_CZ_R/NN;
EY1_DJX_R=EY1_DJX_R/NN;
% G channel
EX1_G=EX1_G/NN;
EY1_SP_G=EY1_SP_G/NN;
EY1_CZ_G=EY1_CZ_G/NN;
EY1_DJX_G=EY1_DJX_G/NN;
% B channel
EX1_B=EX1_B/NN;
EY1_SP_B=EY1_SP_B/NN;
EY1_CZ_B=EY1_CZ_B/NN;
EY1_DJX_B=EY1_DJX_B/NN;
for i=1:NN
    % The first pixel variance is shared across horizontal, vertical, and diagonal calculations and is denoted by DX
    DX1_R=DX1_R+(I1(x1(i),y1(i))-EX1_R)^2;
    DX1_G=DX1_G+(I2(x1(i),y1(i))-EX1_G)^2;
    DX1_B=DX1_B+(I3(x1(i),y1(i))-EX1_B)^2;
    % The second pixel variances are denoted by DY1_SP, DY1_CZ, and DY1_DJX for horizontal, vertical, and diagonal directions
    % R channel
    DY1_SP_R=DY1_SP_R+(I1(x1(i),y1(i)+1)-EY1_SP_R)^2;
    DY1_CZ_R=DY1_CZ_R+(I1(x1(i)+1,y1(i))-EY1_CZ_R)^2;
    DY1_DJX_R=DY1_DJX_R+(I1(x1(i)+1,y1(i)+1)-EY1_DJX_R)^2;
    % G channel
    DY1_SP_G=DY1_SP_G+(I2(x1(i),y1(i)+1)-EY1_SP_G)^2;
    DY1_CZ_G=DY1_CZ_G+(I2(x1(i)+1,y1(i))-EY1_CZ_G)^2;
    DY1_DJX_G=DY1_DJX_G+(I2(x1(i)+1,y1(i)+1)-EY1_DJX_G)^2;
    % B channel
    DY1_SP_B=DY1_SP_B+(I3(x1(i),y1(i)+1)-EY1_SP_B)^2;
    DY1_CZ_B=DY1_CZ_B+(I3(x1(i)+1,y1(i))-EY1_CZ_B)^2;
    DY1_DJX_B=DY1_DJX_B+(I3(x1(i)+1,y1(i)+1)-EY1_DJX_B)^2;
    % Compute covariance for adjacent pixels in the horizontal, vertical, and diagonal directions
    % R channel
    COVXY1_SP_R=COVXY1_SP_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i),y1(i)+1)-EY1_SP_R);
    COVXY1_CZ_R=COVXY1_CZ_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i)+1,y1(i))-EY1_CZ_R);
    COVXY1_DJX_R=COVXY1_DJX_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i)+1,y1(i)+1)-EY1_DJX_R);
    % G channel
    COVXY1_SP_G=COVXY1_SP_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i),y1(i)+1)-EY1_SP_G);
    COVXY1_CZ_G=COVXY1_CZ_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i)+1,y1(i))-EY1_CZ_G);
    COVXY1_DJX_G=COVXY1_DJX_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i)+1,y1(i)+1)-EY1_DJX_G);
    % B channel
    COVXY1_SP_B=COVXY1_SP_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i),y1(i)+1)-EY1_SP_B);
    COVXY1_CZ_B=COVXY1_CZ_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i)+1,y1(i))-EY1_CZ_B);
    COVXY1_DJX_B=COVXY1_DJX_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i)+1,y1(i)+1)-EY1_DJX_B);
end
% Normalize the accumulated sample sums
% R channel
DX1_R=DX1_R/NN;
DY1_SP_R=DY1_SP_R/NN;
DY1_CZ_R=DY1_CZ_R/NN;
DY1_DJX_R=DY1_DJX_R/NN;
COVXY1_SP_R=COVXY1_SP_R/NN;
COVXY1_CZ_R=COVXY1_CZ_R/NN;
COVXY1_DJX_R=COVXY1_DJX_R/NN;
% G channel
DX1_G=DX1_G/NN;
DY1_SP_G=DY1_SP_G/NN;
DY1_CZ_G=DY1_CZ_G/NN;
DY1_DJX_G=DY1_DJX_G/NN;
COVXY1_SP_G=COVXY1_SP_G/NN;
COVXY1_CZ_G=COVXY1_CZ_G/NN;
COVXY1_DJX_G=COVXY1_DJX_G/NN;
% B channel
DX1_B=DX1_B/NN;
DY1_SP_B=DY1_SP_B/NN;
DY1_CZ_B=DY1_CZ_B/NN;
DY1_DJX_B=DY1_DJX_B/NN;
COVXY1_SP_B=COVXY1_SP_B/NN;
COVXY1_CZ_B=COVXY1_CZ_B/NN;
COVXY1_DJX_B=COVXY1_DJX_B/NN;
% Correlation coefficients in the horizontal, vertical, and diagonal directions
% R channel
RXY1_SP_R=COVXY1_SP_R/sqrt(DX1_R*DY1_SP_R);
RXY1_CZ_R=COVXY1_CZ_R/sqrt(DX1_R*DY1_CZ_R);
RXY1_DJX_R=COVXY1_DJX_R/sqrt(DX1_R*DY1_DJX_R);
% G channel
RXY1_SP_G=COVXY1_SP_G/sqrt(DX1_G*DY1_SP_G);
RXY1_CZ_G=COVXY1_CZ_G/sqrt(DX1_G*DY1_CZ_G);
RXY1_DJX_G=COVXY1_DJX_G/sqrt(DX1_G*DY1_DJX_G);
% B channel
RXY1_SP_B=COVXY1_SP_B/sqrt(DX1_B*DY1_SP_B);
RXY1_CZ_B=COVXY1_CZ_B/sqrt(DX1_B*DY1_CZ_B);
RXY1_DJX_B=COVXY1_DJX_B/sqrt(DX1_B*DY1_DJX_B);

end