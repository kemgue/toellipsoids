function lireTraceEllipsoides(chemin1)

%  chemin1='D:\al\raz\all\boule1.txt';
% chemin1='D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lbr\64x64.bmax';
% chemin1='D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lmax\64x64.bmax'
%  chemin1='/home/kemgue/Documents/al/raz/tout mes TPs/Amuse/Boule Max Drainage/Olivier Bmax Ellipsoides/p1l.bmaxd';
 chemin1='D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Olivier Bmax Ellipsoides\p1l.bmaxd';
%   chemin1='D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\DrainageValerieSpot\p1l.br';
% chemin1='D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Olivier Bmax Ellipsoides\p1l.bmaxd';
fid = fopen('fichellip_final.txt', 'rt');
nbptsvisual=30;

i=0;
figure

   
while feof(fid) == 0
tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');

if length(TargetVar)>2
  i=i+1;
[type, reste] =strtok(tline, ' ');
if(str2double(type)==1)
  
[chcentre1, reste] =strtok(reste, ' ');
[chcentre2, reste] =strtok(reste, ' ');
[chcentre3, reste] =strtok(reste, ' ');
[chRx, reste] =strtok(reste, ' ');
[chRy, reste] =strtok(reste, ' ');
[chRz, reste] =strtok(reste, ' ');
[chB11, reste] =strtok(reste, ' ');
[chB12, reste] =strtok(reste, ' ');
[chB13, reste] =strtok(reste, ' ');
[chB21, reste] =strtok(reste, ' ');
[chB22, reste] =strtok(reste, ' ');
[chB23, reste] =strtok(reste, ' ');
[chB31, reste] =strtok(reste, ' ');
[chB32, reste] =strtok(reste, ' ');
[chB33, reste] =strtok(reste, ' ');

centre=[str2double(chcentre1) str2double(chcentre2) str2double(chcentre3)];

Rx=str2double(chRx);
Ry=str2double(chRy);
Rz=str2double(chRz);

base1=[str2double(chB11) str2double(chB12) str2double(chB13)];
base2=[str2double(chB21) str2double(chB22) str2double(chB23)];
base3=[str2double(chB31) str2double(chB32) str2double(chB33)];

MatRot=[base1;base2 ;base3];

 %-----------Debut trace ellipsoide------------------------------------
          
            [u v] = meshgrid(linspace(0,2*pi,nbptsvisual),linspace(-pi/2,pi/2,nbptsvisual));

            x1 = Rx*cos(u').*cos(v');
            y1 = Ry*sin(u').*cos(v');
            z1 = Rz*sin(v');

            % Rotation des points de l'ellipsoide pour l'afficher dans le repere de
            % depart.

            for indx = 1:nbptsvisual
                for indy = 1:nbptsvisual
                    poin = [x1(indx,indy) y1(indx,indy) z1(indx,indy)]';
                    Pt = MatRot * poin;
                    x1(indx,indy) = Pt(1)+centre(1);
                    y1(indx,indy) = Pt(2)+centre(2);
                    z1(indx,indy) = Pt(3)+centre(3);
                end
            end

             hold on;
            mesh(x1,y1,z1,'facecolor','none','edgecolor','r')
           % colormap hsv
               
          
          
          
          %-------------Fin trace ellipsoide-------------------------------------   


else
[chcentre1, reste] =strtok(reste, ' ');
[chcentre2, reste] =strtok(reste, ' ');
[chcentre3, reste] =strtok(reste, ' ');
[chRx, reste] =strtok(reste, ' ');

center = [str2num(chcentre1) str2num(chcentre2) str2num(chcentre3)];
ray=str2num(chRx);   
d=1;
[xu,yu,zu] = sphere;

  x = xu*ray + center(1);
  y = yu*ray + center(2);
  z = zu*ray + center(3);
  c = ones(size(z))*d;
   mesh(x,y,z,'facecolor','none','edgecolor','r')

end


end 

end

%    visualiseBoules(chemin1);
 
 img=evalin('base','IMGBOULE');
plotMatrixVoxels(img)
 
 
 
end