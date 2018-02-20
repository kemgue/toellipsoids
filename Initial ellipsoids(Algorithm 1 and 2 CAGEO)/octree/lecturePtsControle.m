%Cette fonction lit tous les points de controle dans le fichier et les
%execute le changement de repere pour revenir dans notre repere reduit
function [Mat]= lecturePtsControle(cheminfich)

%Fichier de mes points de controle
% fid = fopen('C:/all/controleInertie.txt', 'rt');
fid = fopen(cheminfich, 'rt');
Mat=[];

i=0;
while feof(fid) == 0
tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');


%  if length(TargetVar)>2
% 
%     [xc, reste] =strtok(tline, ' ');
%     [yc, reste] =strtok(reste, ' ');
%     [zc, reste] =strtok(reste, ' ');
%     [Rayon, reste] =strtok(reste, ' ');
% 
%     k=k+1;
%     tabboule(k,1:4)= [str2num(xc) str2num(yc) str2num(zc) str2num(Rayon)] ;
% 
%     end

if length(TargetVar)> 3
  i=i+1;
[chA, reste] =strtok(tline, ' ');
[chB, reste] =strtok(reste, ' ');
[chC, reste] =strtok(reste, ' ');
[chRay, reste] =strtok(reste, ' ');

A=str2double(chA);
B=str2double(chB);
C=str2double(chC);
R=str2double(chRay);


Mat(i,1:4)=[A,B,C,R];

end
end
end

