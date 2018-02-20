function [RapportErreur,Rayons,Centre,MatRot] = approximeMinVolEllipse(sousEns,sousRay,seuilpts,phiEchan,thetaEchan) 

% figure
Echan=[];
RapportErreur=0;
Rayons=[];
Centre=[];
% sousEns
% sousRay
Vol=((4/3)*pi)*(sousRay.^3);
N=size(sousEns,1);

%    On each ball of a subset, we sample a set of points to calculate the convex hull
for j = 1:N
    
xx=[];
yy=[];
zz=[];
% sampling a set of points on a ball according to the angles phi and theta above
xx=sousRay(j)*sin(phiEchan).*cos(thetaEchan)+sousEns(j,1);
yy=sousRay(j)*sin(phiEchan).*sin(thetaEchan)+sousEns(j,2);
zz=sousRay(j)*cos(phiEchan)+sousEns(j,3);


n=size(xx(:),1);
Echan2=[];
Echan2(1:n,1)=xx(:);
Echan2(1:n,2)=yy(:);
Echan2(1:n,3)=zz(:);

Echan=[Echan2;Echan];


end
   
% hold on

     [envConvex,vol]=convhull(Echan,'simplify',true);

% col1=Echan(:,1);
% col2=Echan(:,2);
% col3=Echan(:,3);

%Ptsapp=Echan(envConvex,:);
Ptsapp=unique(Echan(envConvex,:),'rows');

% Ptsapp=[];
% Ptsapp=[col1 col2 col3];

[A1,cent] = MinVolEllipse(Ptsapp',seuilpts);

% [~, D1, V1] = svd(A1);
[V1,D1] = eig(A1);
% [U S] = svd(covPts);

rx = 1/sqrt(D1(1,1));
ry = 1/sqrt(D1(2,2));
rz = 1/sqrt(D1(3,3));

MatRot=V1;
Rayons=[rx,ry,rz];
Centre=cent;

% volEll=(4/3)*pi*rx*ry*rz
volEll=((4/3)*pi)*rx*ry*rz;
sommeVolBoule=round(sum(Vol));
[volespace,volellip]= voxelErreurEspace(Centre,Rayons,MatRot);
RapportErreur=volespace/volellip;


%

end





