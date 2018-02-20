function seulsphere()



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


%i=i+1;
%center(i,1:3) = [str2num(xc) str2num(yc) str2num(zc)];
%ray(i)=str2num(Rayon);
%d(i)=1;
break;
end
end
fclose(fid);

xc=str2num(chxc);
yc=str2num(chyc);
zc=str2num(chzc);
R=str2num(chR);

% trace des points

A1=A(:,1);
A2=A(:,2);
A3=A(:,3);

exp=sprintf('(x-%f)^2+(y-%f)^2+(z-%f)^2-(%f)', xc,yc,zc,R);
disp(exp);

%substitution

syms x y z
q=exp;
disp(q);
val=subs(q,{x y z},{2 4 5})
disp(val)
figure;
axes;
hold on;
  [x,y,z] = ellipsoid(xc,yc,zc,R,R,R);
   mesh(x,y,z);

hold on;
% j'Ajoute a la figure mon cercle. Centre yc,zc et rayon R
t = 0 : .1 : 2*pi;
ycer = R * cos(t) + yc;
zcer = R * sin(t) + zc;
xcer = zeros(size(ycer))+xc;
plot3(xcer,ycer, zcer);
% Je vais echantionner quelques points sur mon cercle

pas=pi/9;
i=0;
for ang=0:pas:2*pi
y1 = R * cos(ang) + yc;
z1 = R * sin(ang) + zc;
x1 = 0+xc;
i=i+1;
B(i,1:3)=[x1 y1 z1];
end

B1=B(:,1);
B2=B(:,2);
B3=B(:,3);
scatter3(B1,B2,B3,'filled');


xlabel('x');
ylabel('y');
zlabel('z');
title('Chaine Boule');

hold on;
%scatter3(0+str2num(chxc),0+str2num(chyc),-R+str2num(chzc),'filled');
scatter3(A1,A2,A3,'filled');

axis equal;




end   