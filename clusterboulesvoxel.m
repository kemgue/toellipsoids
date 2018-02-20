function clusterboulesvoxel() 
clc
clear
% Variation des angle phi et theta pour echantilloner les points sur les
% boules.
[phi, theta]=meshgrid([0:0.9:pi], [0:0.9:2*pi]);
[phi1, theta1]=meshgrid([0:0.2:pi], [0:0.2:2*pi]);
dimen=64;
img=zeros(dimen,dimen,dimen);

Pts=[];
Ray=[];
Vol=[];
% Lecture du fichier des points, centre des boules à approximer
% fid = fopen('C:\all\boule1.txt', 'rt');
fid = fopen('D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lmax\64x64.bmax', 'rt');
% fid = fopen('D:\tout mes TPs\Amuse\fenp4l\test64.txt', 'rt');
h=0;
while feof(fid) == 0
tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');

if length(TargetVar)>2
  
[xc, reste] =strtok(tline, ' ');
[yc, reste] =strtok(reste, ' ');
[zc, reste] =strtok(reste, ' ');
[Rayon, reste] =strtok(reste, ' ');

h=h+1;
Pts(h,1:3)= [str2num(xc) str2num(yc) str2num(zc)] ;
Ray(h,1)=str2num(Rayon);
Vol(h,1)=((4/3)*pi)*(Ray(h)^3);


end

end

% P=Pts
% R=Ray
% V=Vol
k=4

% Calcul du sous regroupement en utilisant les k-means personnalisé avec le
% calcul du barycentre et non de la moyenne usuelle.
[idx,C]=kmeansperso(Pts,k,Vol,Ray,'distance','madist')

% Affiche des boules de chaque sous ensemble.
% sousEns=[];
% sousRay=[];

figure
axis equal;
title(sprintf('Visualisation du sous ensemble'));

for i = 1:k
    members = (i == idx);
     disp(strcat('Cluster numero <',num2str(i),'>'));
     sousEns=Pts(members,:)
     sousRay=Ray(members)
       disp('De Centroid');
     disp(C(i,:))
Echan=[];

%    Sur chaque boule d'un sous ensemble, on échantillons un ensemble de points devant permettre de calculer l'enveloppe convexe.
for j = 1:size(sousEns,1)
       
xx=[];
yy=[];
zz=[];
% échantillonnage d'un ensemble de points sur une boule en fonction des angles phi et théta plus haut
xx=sousRay(j)*sin(phi).*cos(theta)+sousEns(j,1);
yy=sousRay(j)*sin(phi).*sin(theta)+sousEns(j,2);
zz=sousRay(j)*cos(phi)+sousEns(j,3);
hold on
% img=zeros(sousRay(j)*2,sousRay(j)*2,sousRay(j)*2);
% pp=round(xx(:))

xxo=round(xx(:))
yyo=round(yy(:))
zzo=round(zz(:))

img([round(xx(:)),round(yy(:)),round(zz(:))])=1;
% plot3(xx(:),yy(:),zz(:),'.');
disp('OOOKKKKK')

% echantillon des voxel

% xx1=[];
% yy1=[];
% zz1=[];
% xx1=sousRay(j)*sin(phi1).*cos(theta1)+sousEns(j,1);
% yy1=sousRay(j)*sin(phi1).*sin(theta1)+sousEns(j,2);
% zz1=sousRay(j)*cos(phi1)+sousEns(j,3);
% hold on
% plot3(xx1(:),yy1(:),zz1(:),'.');


n=size(xx(:),1);
Echan2=[];
Echan2(1:n,1)=xx(:);
Echan2(1:n,2)=yy(:);
Echan2(1:n,3)=zz(:);

Echan=[Echan2;Echan];


%    Ajout de la boule sur le dessin de visualisation du sous ensemble.
      [xu,yu,zu] = sphere;
  x = xu*sousRay(j) + sousEns(j,1);
  y = yu*sousRay(j) + sousEns(j,2);
  z = zu*sousRay(j) + sousEns(j,3);
  c = ones(size(z))*1;
  hold on;
%   surf(x,y,z,c,'FaceColor',[1 0 0]);
surf(x,y,z,c);
% mesh(x,y,z);
  

end
   
% envConvex=[]
% Echan
     
hold on
%       disp('Echantillons');
%         disp(Echan);
%      Calcul de l'enveloppe convexe du sous ensemble de boule

     [envConvex,vol]=convhull(Echan,'simplify',true);
     
%      Ajout de l'enveloppe convexe du sous ensemble sur le dessin
%         trisurf(envConvex,Echan(:,1),Echan(:,2),Echan(:,3), 'Facecolor','cyan'); axis equal;

col1=Echan(:,1);
col2=Echan(:,2);
col3=Echan(:,3);

% trisurf(envConvex,col1,col2,col3, 'Facecolor','cyan'); 



% Ajout des points echantionné d'un sous ensemble sur la figure de
% visualisation.% hold on
% plot3(Echan(:,1),Echan(:,2),Echan(:,3),'.');


% Trace de l'ellipsoide qui approxime l'envesloppe convexe.

% plot3(col1(envConvex(:,1)),col2(envConvex(:,2)),col3(envConvex(:,3)),'.');

% Ptsapp=[];
% Ptsapp=[col1 col2 col3];
%  hold on;
% nbptsvisual=10;
% [A1 centro] = MinVolEllipse(Ptsapp',0.01)
% 
% [~, D1, V1] = svd(A1);
% 
% rx = 1/sqrt(D1(1,1));
% ry = 1/sqrt(D1(2,2));
% rz = 1/sqrt(D1(3,3));
% 
% [u v] = meshgrid(linspace(0,2*pi,nbptsvisual),linspace(-pi/2,pi/2,nbptsvisual));
% 
% x1 = rx*cos(u').*cos(v');
% y1 = ry*sin(u').*cos(v');
% z1 = rz*sin(v');
% 
% % Rotation des points de l'ellipsoide pour l'afficher dans le repere de
% % depart.
% 
% for indx = 1:nbptsvisual
%     for indy = 1:nbptsvisual
%         poin = [x1(indx,indy) y1(indx,indy) z1(indx,indy)]';
%         Pt = V1 * poin;
%         x1(indx,indy) = Pt(1)+centro(1);
%         y1(indx,indy) = Pt(2)+centro(2);
%         z1(indx,indy) = Pt(3)+centro(3);
%     end
% end
% 
% me=mesh(x1,y1,z1);
% set(me,'facecolor','none');
% surf(x1,y1,z1);


     
end
% figure
% disp(img)
% VoxelPlotter(img,0.1,'b');
 H = vol3d('CData',img)
% vol3d('cdata',img,'texture','3D');
end





