function voxelboules(chemin,dim)



% close all

% fid = fopen('C:\all\sand2.bmax', 'rt');
% fid = fopen('C:\all\boule1.txt', 'rt');
%  fid = fopen('..\Nouvelles\p1l.bmax', 'rt');
%  fid = fopen('D:\tout mes TPs\Amuse\64x64.bmax', 'rt');
chemin='D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Olivier Bmax Ellipsoides\p1l.bmaxd';
 dim=64; 
 fid = fopen(chemin, 'rt');

 img=zeros(dim,dim,dim);
 [x, y, z] = meshgrid(1:dim, 1:dim, 1:dim);
i=0;
% figure
% axes
while feof(fid) == 0
clear ind;
clear center;

tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');

if length(TargetVar)>2
  
 [xc, reste] =strtok(tline, ' ');
[yc, reste] =strtok(reste, ' ');
[zc, reste] =strtok(reste, ' ');
[Rayon, reste] =strtok(reste, ' ');

i=i+1;


center = [str2num(xc) str2num(yc) str2num(zc)];
ray=str2num(Rayon);
d=ray*2;
hold on;


% prendre l'image comme étant les point qui sont dans la sphere

clear ind;
ind=find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= ray^2);

img(ind)=1;



end
end
fclose(fid);

assignin('base','IMGBOULE',img);

vol3d('cdata',img,'texture','3D');
% image3forum(img,'b')
% VoxelPlotter(img,1,'b');

view(3);
axis equal;



end   