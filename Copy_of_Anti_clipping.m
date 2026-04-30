function [Q_R,Q_G,Q_B,xx0,xx1,Q_jiami]=Copy_of_Anti_clipping(u,M,N,Q_R,Q_G,Q_B,I2,I3,SUM)
xx0=sum(I2(:))/(255*SUM);     % G-channel mean gray value, used as a key
xx0=floor(xx0*10^4)/10^4;     % Keep four decimal places
xx1=sum(I3(:))/(255*SUM);     % B-channel mean gray value, used as a key
xx1=floor(xx1*10^4)/10^4;     % Keep four decimal places
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

for i=1:M
    temp = Q_R(i,:);
    Q_R(i,:) = Q_R(Ux(i),:);
    Q_R(Ux(i),:) = temp;
    temp = Q_G(i,:);
    Q_G(i,:) = Q_G(Ux(i),:);
    Q_G(Ux(i),:) = temp;
    temp = Q_B(i,:);
    Q_B(i,:) = Q_B(Ux(i),:);
    Q_B(Ux(i),:) = temp;
end

for i=1:N
    temp = Q_R(:,i);
    Q_R(:,i) = Q_R(:,Uy(i));
    Q_R(:,Uy(i)) = temp;
    temp = Q_G(:,i);
    Q_G(:,i) = Q_G(:,Uy(i));
    Q_G(:,Uy(i)) = temp;
    temp = Q_B(:,i);
    Q_B(:,i) = Q_B(:,Uy(i));
    Q_B(:,Uy(i)) = temp;
end
%{
figure;imhist(Q_R);title('Encrypted R-channel histogram');
axis([0 255 0 2000]);
figure;imhist(Q_G);title('Encrypted G-channel histogram');
axis([0 255 0 2000]);
figure;imhist(Q_B);title('Encrypted B-channel histogram');
axis([0 255 0 2000]);
%}
Q_jiami(:,:,1)=Q_R;
Q_jiami(:,:,2)=Q_G;
Q_jiami(:,:,3)=Q_B;
% Q=imnoise(Q,'salt & pepper',0.1);   % Add 10% salt-and-pepper noise
%{
imwrite(Q_jiami,'../encrypted_decrypted_images/encrypted_lena.png','png');        
figure;imshow(Q_jiami);title('Encrypted image');
%}
end