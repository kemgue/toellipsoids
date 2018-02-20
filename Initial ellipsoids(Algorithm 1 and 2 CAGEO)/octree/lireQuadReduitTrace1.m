function lireQuadReduitTrace1()


%fichier des coeficient generaux des ellipsoide
% Pour visualiser les regions initiales
%  fid = fopen('resultat_region_init.txt', 'rt');
% Pour visualiser les regions définitives
  fid = fopen('resultat_region_def.txt', 'rt');


i=0;
figure
% Recuperation des points de controle
%  MatA=lecturePtsControle('C:\all\boule1.txt');
%   MatA=lecturePtsControle('C:\all\sand2.bmax');
%  MatA=lecturePtsControle('..\128x128.bmax');
%   MatA=lecturePtsControle('..\Nouvelles\p4l.bmax');
%  disp(MatA)
%       [xu,yu,zu] = sphere;
%    
%  for j = 1:size(MatA,1);
%   x = xu*MatA(j,4) + MatA(j,1);
%   y = yu*MatA(j,4) + MatA(j,2);
%   z = zu*MatA(j,4) + MatA(j,3);
%   c = ones(size(z))*1;
%   surf(x,y,z,c);
%   hold on;
% end
% for j = 1:size(MatA,1);
%   x = xu*(MatA(j,4)-1) + MatA(j,1);
%   y = yu*(MatA(j,4)-1) + MatA(j,2);
%   z = zu*(MatA(j,4)-1) + MatA(j,3);
%   c = ones(size(z))*1;
%   surf(x,y,z,c);
%   hold on;
% end
 
while feof(fid) == 0
tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');

%  disp(length(TargetVar));
if length(TargetVar)==6
 
[rien, reste] =strtok(tline, ' ');   
[chcentre1, reste] =strtok(reste, ' ');
[chcentre2, reste] =strtok(reste, ' ');
[chcentre3, reste] =strtok(reste, ' ');
[chR, reste] =strtok(reste, ' ');
i=i+1;
C=[str2double(chcentre1) str2double(chcentre2) str2double(chcentre3)];

Rboule=str2double(chR);
hold on
[xu,yu,zu] = sphere;

  x = xu*Rboule + C(1);
  y = yu*Rboule + C(2);
  z = zu*Rboule + C(3);
  c = ones(size(z))*1;
  surf(x,y,z,c);
  hold on;

      
end




if length(TargetVar)==17
%    disp('Ellipsoide');
[rien, reste] =strtok(tline, ' ');   
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

i=i+1;
C=[str2double(chcentre1) str2double(chcentre2) str2double(chcentre3)];

Rx=str2double(chRx);
Ry=str2double(chRy);
Rz=str2double(chRz);

base1=[str2double(chB11);str2double(chB12);str2double(chB13)];
base2=[str2double(chB21);str2double(chB22);str2double(chB23)];
base3=[str2double(chB31);str2double(chB32);str2double(chB33)];

base=[base1 base2 base3];




       hold on
     tracechaine(C,Rx,Ry,Rz,base,30);
      %Ellipse_plot(M,C)
      
end


end 

end