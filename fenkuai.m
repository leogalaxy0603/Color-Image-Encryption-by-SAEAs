%% Helper function: block extraction. t is the block side length, I is the image, and num is the block index
function fv=fenkuai(t,I,num)
[~,N]=size(I);
N=N/t;
x=floor(num/N)+1;      % Block row index
y=mod(num,N);           % Block column index
if y==0
    x=x-1;
    y=N;
end
fv=I(t*(x-1)+1:t*x,t*(y-1)+1:t*y);


