function seulsphere7pts()



fid = fopen('C:\all\ptssphere.txt', 'rt');
i=0;
while feof(fid) == 0
tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');

if length(TargetVar)>2
  
 [chxc, reste] =strtok(tline, ' ');
[chyc, reste] =strtok(reste, ' ');
[chzc, reste] =strtok(reste, ' ');
[chR, reste] =strtok(reste, ' ');

i=i+1;
A(i,1:3)=[str2num(chxc) str2num(chyc) str2num(chzc)];
A(i+1,1:3)=[str2num(chR)+str2num(chxc) 0+str2num(chyc) 0+str2num(chzc)];
A(i+2,1:3)=[-str2num(chR)+str2num(chxc) 0+str2num(chyc) 0+str2num(chzc)];
A(i+3,1:3)=[0+str2num(chxc) str2num(chR)+str2num(chyc) 0+str2num(chzc)];
A(i+4,1:3)=[0+str2num(chxc) -str2num(chR)+str2num(chyc) 0+str2num(chzc)];
A(i+5,1:3)=[0+str2num(chxc) 0+str2num(chyc) str2num(chR)+str2num(chzc)];
A(i+6,1:3)=[0+str2num(chxc) 0+str2num(chyc) -str2num(chR)+str2num(chzc)];


break;
end
end
fclose(fid);

xc=str2num(chxc);
yc=str2num(chyc);
zc=str2num(chzc);
R=str2num(chR);

% trace des points


figure;
axes;
hold on;
  [x,y,z] = ellipsoid(xc,yc,zc,R,R,R);
   mesh(x,y,z);

xlabel('x');
ylabel('y');
zlabel('z');
title('Chaine Boule');

hold on;
% Mes 7 points de bord la sphere.
scatter3(A(:,1),A(:,2),A(:,3),'filled');
axis equal;




end   