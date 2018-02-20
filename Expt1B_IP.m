% b. Zooming and Shrinking

% Shrinking
clc;
clear all;
close all;
A=imread('cameraman.tif');
display('Input Image ==> cameraman.tif');
f=input('Enter the shrinking factor of the image: ');
s=size(A);
s1=s/f;
k=1;
l=1;
for i=1:s1
    for j=1:s1
        B(i,j)=A(k,l);
        l=l+f;
    end
    l=1;
    k=k+f;
end
figure,imshow(A)
title('Original Image');
figure,imshow(B)
title('Shrinked Version');

% Zooming
        
f1=input('Enter the factor by which the image is to be Zoomed: ');
s2=s*f1;
k=1;
l=1;
for (i=1:f1:s2)
    for( j=1:f1:s2)
        C(i,j)= A(k,l);
        l=l+1;
    end
    l=1;
    k=k+1;
end

for (i=1:f1:s2)
    for (j=2:f1:s2-1)
        C(i,j)= [C(i,j-1)+ C(i, j+1)]*0.5;
    end
end

for(j=1:f1:s2)
    for(i=2:f1:s2-1)
        C(i,j)=[C(i-1,j)+C(i+1,j)]*0.5;
    end
end

for (i=2:f1:s2-1)
    for (j=2:f1:s2-1)
        C(i,j)= [C(i,j-1)+ C(i, j+1)]*0.5;
    end
end
figure,imshow(C)
title('Zoomed Image')