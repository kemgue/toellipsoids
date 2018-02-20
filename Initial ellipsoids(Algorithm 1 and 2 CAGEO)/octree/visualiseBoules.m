function visualiseBoules()



%fid = fopen('C:\all\sand2.bmax', 'rt');
fid = fopen('C:\all\boule1.txt', 'rt');
%fid = fopen('..\Nouvelles\p1l.bmax', 'rt');
%   fid = fopen('D:\tout mes TPs\Amuse\fenp4l\fenp4lbr\64x64.bmax', 'rt');
%   fid = fopen('D:\tout mes TPs\Amuse\fenp4l\test64.txt', 'rt');
i=0;
while feof(fid) == 0
tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');

if length(TargetVar)>2
  
 [xc, reste] =strtok(tline, ' ');
[yc, reste] =strtok(reste, ' ');
[zc, reste] =strtok(reste, ' ');
[Rayon, reste] =strtok(reste, ' ');

i=i+1;

center(i,1:3) = [str2num(xc) str2num(yc) str2num(zc)];
ray(i)=str2num(Rayon);
d(i)=1;
end
end
fclose(fid);

disp(center)

figure;
axes;
hold on;

[xu,yu,zu] = sphere;
for j = 1:size(center)
  x = xu*ray(j) + center(j,1);
  y = yu*ray(j) + center(j,2);
  z = zu*ray(j) + center(j,3);
  c = ones(size(z))*d(j);
  surf(x,y,z,c);
end
view(size(center));
axis equal;



end  

% function visualiseBoules()
% 
% % fid = fopen('C:\all\sand2.bmax', 'rt');
% % fid = fopen('C:\all\boule1.txt', 'rt');
% %  fid = fopen('..\Nouvelles\p1l.bmax', 'rt');
%  fid = fopen('D:\tout mes TPs\Amuse\fenp4l\fenp4lbr\64x64.bmax', 'rt');
% i=0;
% figure
% axes
% while feof(fid) == 0
% tline = fgetl(fid);
% TargetVar = regexp(tline,' ','split');
% 
% if length(TargetVar)>2
%   
%  [xc, reste] =strtok(tline, ' ');
% [yc, reste] =strtok(reste, ' ');
% [zc, reste] =strtok(reste, ' ');
% [Rayon, reste] =strtok(reste, ' ');
% 
% i=i+1;
% 
% 
% center = [str2num(xc) str2num(yc) str2num(zc)];
% ray=str2num(Rayon);
% d=1;
% hold on;
% 
% [xu,yu,zu] = sphere;
% 
%   x = xu*ray + center(1);
%   y = yu*ray + center(2);
%   z = zu*ray + center(3);
%   c = ones(size(z))*d;
%   surf(x,y,z,c);
% 
% 
% end
% 
% clear x;
% clear y;
% clear z;
% clear c;
% clear center;
% clear ind;
% 
% end
% fclose(fid);
% 
% 
% view(3);
% axis equal;
% end 



 