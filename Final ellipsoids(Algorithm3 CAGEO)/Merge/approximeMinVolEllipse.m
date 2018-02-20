% By Alain Tresor Kemgue. Thesis Project 
function [RapportErreur,Rayons,Centre,MatRot] = approximeMinVolEllipse(Echan,sommeVol,seuilpts) 


RapportErreur=0;
Rayons=[];
Centre=[];
[envConvex,vol]=convhull(Echan,'simplify',true);

Ptsapp=unique(Echan(envConvex,:),'rows');

[A1,cent] = MinVolEllipse(Ptsapp',seuilpts);

[~, D1, V1] = svd(A1);

rx = 1/sqrt(D1(1,1));
ry = 1/sqrt(D1(2,2));
rz = 1/sqrt(D1(3,3));

MatRot=V1;
Rayons=[rx,ry,rz];
Centre=cent;

% volEll=(4/3)*pi*rx*ry*rz
volEll=((4/3)*pi)*rx*ry*rz; 
%  RapportErreur=sommeVolBoule/volEll;
% RapportErreur=min(volEll/sommeVolBoule,sommeVolBoule/volEll);
% RapportErreur=abs(sommeVolBoule-volEll);
% [volespace,volellip]= voxelErreurEspace(Centre,Rayons,MatRot);         
% [volespace,volellip]= voxelErreurEspace_rap(Centre,Rayons,MatRot);
%                RapportErreur=volespace/volellip;
%Rapport somme des deux ellipsoide approximé sur le volume de ellipsoide
%qui approxime les deux.
RapportErreur=min(volEll/sommeVol,sommeVol/volEll);
end





