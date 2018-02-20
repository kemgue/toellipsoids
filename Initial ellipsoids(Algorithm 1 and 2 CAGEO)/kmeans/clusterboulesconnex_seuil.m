function clusterboulesconnex_seuil() 


% Dans cette versio, j'execute clusterboulesconnex_seuil normalement, mais
% je ne garde que les ellipsoide dont l'erreur d'approximation verifie le
% seuilApp. Err=min(sommeVolBoules/volEllipsoide;
% volEllipsoide/sommeVolBoules) et Err > seuilApp et 0<=seuilApp<=1
clc
% Variation des angle phi et theta pour echantilloner les points sur les
% boules.
[phi, theta]=meshgrid([0:0.9:pi], [0:0.9:2*pi]);
k=150
seuilApp=0.7;
seuilpts=0.01;
% seuilApprox=0.5;
% nbptsvisual=30;
 epsdist=0;
 
chemin='D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lmax\64x64.bmax'; 
% chemin='D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\OlivierBmaxEllipsoides\p1l.bmaxd';
fidfileellip = fopen('fichellip.txt', 'w');
fidellip_init = fopen('ellip_init.txt', 'w');
 
Pts=[];
Ray=[];
Vol=[];
% Lecture du fichier des points, centre des boules à approximer
% fid = fopen('D:\al\raz\all\boule1.txt', 'rt');
 fid = fopen(chemin, 'rt');
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


% Calcul du sous regroupement en utilisant les k-means personnalisé avec le
% calcul du barycentre et non de la moyenne usuelle.
[idx,C]=kmeansperso(Pts,k,Vol,Ray,'distance','madist');
% [idx,C]=kmeansperso_r2015a(Pts,k,Vol,Ray,'distance','madist');
% Affiche des boules de chaque sous ensemble.
% sousEns=[];
% sousRay=[];


for i = 1:k
    members = (i == idx);
     disp(strcat('Cluster <',num2str(i),'>'));
 
     sousEns=Pts(members,:);
      if(isempty(sousEns)==1)
      
      continue
      end
     sousRay=Ray(members);
%        disp('De Centroid');
%      disp(C(i,:));
     


     PtsCom=[sousEns sousRay];
     tailleCluster=size(PtsCom,1);
     
      if(tailleCluster > 1)
     [nbcomp,EnsComp]=connexConponent(PtsCom,tailleCluster,epsdist) ;
       %pour chaque sous ensemble de cluster, on determine les composantes connexes. C'est ces sous ensemble qu'on va approximé  
        for j = 1:nbcomp
         memb = (j == EnsComp);
         disp(strcat('Composante connex numero <',num2str(j),'>'));
         comp=PtsCom(memb,:) ;
         tailcomp=size(comp,1);
          if(tailcomp > 1)
             [ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(comp(1:tailcomp,1:3),comp(1:tailcomp,4),seuilpts,phi,theta);
                ApproxError 
               if(ApproxError > seuilApp) % On garde l'ellipsoide
                
                   fprintf(fidfileellip,['1',' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);

                fprintf(fidellip_init,[num2str(tailcomp),' ',num2str(ApproxError),' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);
                for t=1:tailcomp
                fprintf(fidellip_init,[num2str(comp(t,1)),' ',num2str(comp(t,2)),' ',num2str(comp(t,3)),' ',num2str(comp(t,4)),'\n']);
                end
                
               else % On garde quand même les boules.
                fprintf(fidellip_init,[num2str(tailcomp),' ',num2str(ApproxError),' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);
                for t=1:tailcomp
                fprintf(fidellip_init,[num2str(comp(t,1)),' ',num2str(comp(t,2)),' ',num2str(comp(t,3)),' ',num2str(comp(t,4)),'\n']);
                end
               end
          else    
           fprintf(fidfileellip,['0',' ',num2str(comp(1)),' ',num2str(comp(2)),' ',num2str(comp(3)),' ',num2str(comp(4)),'\n']);
           fprintf(fidellip_init,['1 0 0','\n']);
           fprintf(fidellip_init,[num2str(comp(1)),' ',num2str(comp(2)),' ',num2str(comp(3)),' ',num2str(comp(4)),'\n']);
      
          end
         
        end
      else
          fprintf(fidfileellip,['0',' ',num2str(PtsCom(1)),' ',num2str(PtsCom(2)),' ',num2str(PtsCom(3)),' ',num2str(PtsCom(4)),'\n']);
           fprintf(fidellip_init,['1 0 0','\n']);
           fprintf(fidellip_init,[num2str(PtsCom(1)),' ',num2str(PtsCom(2)),' ',num2str(PtsCom(3)),' ',num2str(PtsCom(4)),'\n']);
          
       continue
      end
  
end

  fclose(fidfileellip); 
  fclose(fidellip_init);

  lireTraceEllipsoides(chemin);
end





