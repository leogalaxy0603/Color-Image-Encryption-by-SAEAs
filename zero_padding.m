function [I1,I2,I3,M1,N1]=zero_padding(M,N,I1,I2,I3,t)
M1=mod(M,t);    % Padding remainder used as a fixed key to remove added zeros during decryption
N1=mod(N,t);    % Padding remainder used as a fixed key to remove added zeros during decryption
if M1~=0
    I1(M+1:M+t-M1,:)=0;
    I2(M+1:M+t-M1,:)=0;
    I3(M+1:M+t-M1,:)=0;
end
if N1~=0
    I1(:,N+1:N+t-N1)=0;
    I2(:,N+1:N+t-N1)=0;
    I3(:,N+1:N+t-N1)=0;
end
end