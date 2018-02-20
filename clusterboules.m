function clusterboules() 
clc
% Variation des angle phi et theta pour echantilloner les points sur les
% boules.
[phi, theta]=meshgrid([0:0.9:pi], [0:0.9:2*pi]);

Pts=[];
Ray=[];
Vol=[];
% Lecture du fichier des points, centre des boules à approximer
fid = fopen('D:\al\raz\all\sand1.bmax', 'rt');
%   fid = fopen('D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lmax\64x64.bmax', 'rt');
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
k=90;

% Calcul du sous regroupement en utilisant les k-means personnalisé avec le
% calcul du barycentre et non de la moyenne usuelle.
% [idx,C]=kmeansperso(Pts,k,Vol,Ray,'distance','madist')
[idx,C]=kmeansperso_r2015a(Pts,k,Vol,Ray,'distance','madist');
% Affiche des boules de chaque sous ensemble.
% sousEns=[];
% sousRay=[];

figure
axis equal;
title(sprintf('Visualisation du sous ensemble'));

for i = 1:k
    members = (i == idx);
     disp(strcat('Cluster numero <',num2str(i),'>'));
 
     sousEns=Pts(members,:);
      if(isempty(sousEns)==1)
      
      continue
      end
     sousRay=Ray(members);
       disp('De Centroid');
     disp(C(i,:));
     Echan=[];
if(size(sousEns,1)>1)
     
%    Sur chaque boule d'un sous ensemble, on échantillons un ensemble de points devant permettre de calculer l'enveloppe convexe.
for j = 1:size(sousEns,1)
       
xx=[];
yy=[];
zz=[];
% échantillonnage d'un ensemble de points sur une boule en fonction des angles phi et théta plus haut
xx=sousRay(j)*sin(phi).*cos(theta)+sousEns(j,1);
yy=sousRay(j)*sin(phi).*sin(theta)+sousEns(j,2);
zz=sousRay(j)*cos(phi)+sousEns(j,3);

% disp('OOOKKKKK')

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
%  surf(x,y,z,c);
% mesh(x,y,z);
  

end
   
% envConvex=[]
% Echan
     
hold on
%       disp('Echantillons');
%         disp(Echan);
%      Calcul de l'enveloppe convexe du sous ensemble de boule

X=Echan(:,1);
Y=Echan(:,2);
Z=Echan(:,3);
     [envConvex,vol]=convhull(X,Y,Z);
     
%      Ajout de l'enveloppe convexe du sous ensemble sur le dessin
%         trisurf(envConvex,Echan(:,1),Echan(:,2),Echan(:,3), 'Facecolor','cyan'); axis equal;

% col1=Echan(:,1);
% col2=Echan(:,2);
% col3=Echan(:,3);

col1=Echan(:,1);
col2=Echan(:,2);
col3=Echan(:,3);
% Echan
% CO1=[Echan(envConvex(:,1),1) Echan(envConvex(:,2),2) Echan(envConvex(:,3),3)]

% take the index of the points on the frontier
% col3(envConvex(:,3))

% P2=[]
% for i=1:size(envConvex,1)
%     for j=1:size(envConvex,2)
%     Pt=[Echan(envConvex(i,j),:)];
%     P2=[P2;Pt];
%     end
%     
% end

P2=Echan(envConvex,:);
% 
CO1=[Echan(envConvex(1),1) Echan(envConvex(1),2) Echan(envConvex(1),3)]
CO2=[Echan(envConvex(2),1) Echan(envConvex(2),2) Echan(envConvex(2),3)]
CO3=[Echan(envConvex(3),1) Echan(envConvex(3),2) Echan(envConvex(3),3)]
Pt=[CO1 ;CO2 ;CO3]
% trisurf(envConvex,col1,col2,col3, 'Facecolor','cyan'); 



% Ajout des points echantionné d'un sous ensemble sur la figure de
% visualisation.% hold on
% plot3(Echan(:,1),Echan(:,2),Echan(:,3),'.');


% Trace de l'ellipsoide qui approxime l'envesloppe convexe.
hold on
% plot3(Pt(:,1),Pt(:,2),Pt(:,3),'*');
% plot3(P2(:,1),P2(:,2),P2(:,3),'*');
% plot3(P2(:,1),P2(:,2),P2(:,3),'*');
% plot3(col1,col2,col3,'*');
% 
Ptsapp=[];
Ptsapp=[col1 col2 col3];
 hold on;
nbptsvisual=40;
[A1 centro] = MinVolEllipse(Ptsapp',0.01);

[~, D1, V1] = svd(A1);

rx = 1/sqrt(D1(1,1));
ry = 1/sqrt(D1(2,2));
rz = 1/sqrt(D1(3,3));

[u v] = meshgrid(linspace(0,2*pi,nbptsvisual),linspace(-pi/2,pi/2,nbptsvisual));

x1 = rx*cos(u').*cos(v');
y1 = ry*sin(u').*cos(v');
z1 = rz*sin(v');

% Rotation des points de l'ellipsoide pour l'afficher dans le repere de
% depart.

for indx = 1:nbptsvisual
    for indy = 1:nbptsvisual
        poin = [x1(indx,indy) y1(indx,indy) z1(indx,indy)]';
        Pt = V1 * poin;
        x1(indx,indy) = Pt(1)+centro(1);
        y1(indx,indy) = Pt(2)+centro(2);
        z1(indx,indy) = Pt(3)+centro(3);
    end
end

mesh(x1,y1,z1,'facecolor','none');
% set(me,'facecolor','none');
% surf(x1,y1,z1);
else
    

%    Ajout de la boule sur le dessin de visualisation du sous ensemble.
      [xu,yu,zu] = sphere;
  x = xu*sousRay(1) + sousEns(1);
  y = yu*sousRay(1) + sousEns(2);
  z = zu*sousRay(1) + sousEns(3);
  c = ones(size(z))*1;
  hold on;
%   surf(x,y,z,c,'FaceColor',[1 0 0]);
surf(x,y,z,c);
% mesh(x,y,z);
  
    
end

end


end





