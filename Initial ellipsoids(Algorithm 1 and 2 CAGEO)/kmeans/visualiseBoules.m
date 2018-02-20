function visualiseBoules(chemin)

% fid = fopen('D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Olivier Bmax Ellipsoides\p1l.bmaxd', 'rt');
fid = fopen('D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Olivier Bmax Ellipsoides\p3l.bmax', 'rt');
% fid = fopen('D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Drainage Valerie Spot\p1l.br', 'rt');
%  fid = fopen('..\Nouvelles\p1l.bmax', 'rt');
%  fid = fopen('D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lbr\64x64.bmax', 'rt');
%    fid = fopen(chemin, 'rt');
% %   fid = fopen('D:\al\raz\tout mes TPs\Amuse\Nouvelles\p1l.br', 'rt');
i=0;
% figure
% axes
while feof(fid) == 0
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
d=1;
hold on;

[xu,yu,zu] = sphere;

  x = xu*ray + center(1);
  y = yu*ray + center(2);
  z = zu*ray + center(3);
  c = ones(size(z))*d;
  surf(x,y,z,c);
%   mesh(x,y,z,'facecolor','none','edgecolor','r')


end

clear x;
clear y;
clear z;
clear c;
clear center;
clear ind;

end
fclose(fid);


view(3);
axis equal;
end 



 