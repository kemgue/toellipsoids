function [Bon,Mau,nbreBon]=calculMeilleurRegroupement(Pts,seuilpts,seuilApprox,nbptsvisual,epsdist) 

% fidfileellip = fopen('fichellip.txt', 'a+');
fidfileellip = fopen('fichellip.txt', 'w');
fidellip_init = fopen('ellip_init.txt', 'w');
[phi, theta]=meshgrid([0:0.9:pi], [0:0.9:2*pi]);
Mau=[];
Bon=[];
k=1;

nbreBon=0;
n=size(Pts,1);


rep=checkConnexity(Pts,n,epsdist)
[ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(Pts(1:n,1:3),Pts(1:n,4),seuilpts,seuilApprox,phi,theta);
premierErreur=ApproxError

if((rep==0) && (ApproxError<=seuilApprox))
   Bon=Pts;
   
else
    Mau=Pts;
    cardMau=size(Mau,1);
    while((isempty(Mau)==0)&&(cardMau > k))
    k=k+1
    PtsMau=[];
    RayMau=[];
    IDRegionMau=[];
    n=size(Mau,1);
    PtsMau=Mau(1:n,1:3);
    RayMau=Mau(1:n,4);
    IDRegionMau=Mau(1:n,5);
    cumuleindicesupp=[];
    
    Vol=((4/3)*pi)*(RayMau.^3);
    [idx,C]=kmeansperso_r2015a(PtsMau,k,Vol,RayMau,'distance','madist')
     for i = 1:k
        members = (i == idx);
         disp(strcat('Cluster numero <',num2str(i),'>'));
         sousEns=PtsMau(members,:)
          if(isempty(sousEns)==1)
      
          continue
          end
         sousRay=RayMau(members)
         sousIDRegion=IDRegionMau(members);
         indexSousEns = find(idx==i)
%          if(size(sousEns,1)==1)
%           disp('1 boule,Annuler')
%           
%          cumuleindicesupp=[cumuleindicesupp;indexSousEns]
%             nbreBon=nbreBon+1
%             sousIDRegion(:)=nbreBon;
%            Aux=[sousEns sousRay sousIDRegion];
%            Bon=[Bon;Aux]; 
% %            Mau(indexSousEns, :) = []
%             continue
%          end

         if(size(sousEns,1)==1)
%           disp('1 boule,Annuler')
          
%          cumuleindicesupp=[cumuleindicesupp;indexSousEns]
%             nbreBon=nbreBon+1
%             sousIDRegion(:)=nbreBon;
%            Aux=[sousEns sousRay sousIDRegion];
%            Bon=[Bon;Aux]; 
% %            Mau(indexSousEns, :) = []
            continue
         end
         
         
         
%            disp('De Centroid');
%            disp(C(i,:))
           cardSousEns=size(sousEns,1);
           rep=checkConnexity([sousEns sousRay],cardSousEns,epsdist)
        [ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(sousEns,sousRay,seuilpts,seuilApprox,phi,theta)
        deuxiemeErreur=ApproxError
%         seuil=seuilApprox
%       vraiouFaux=(ApproxError<=seuilApprox)
        if((rep==0) && (ApproxError<=seuilApprox))
            disp('Condition regroupement OK et sauvegarde dans fichier')
%          type(0=sphere,1=ellipsoide) R1 R2 R3 C1 C2 C3 Rot11 Rot12 Rot13 Rot21 Rot22 Rot23 Rot31 Rot32 Rot33  

fprintf(fidfileellip,['1',' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);

fprintf(fidellip_init,[num2str(cardSousEns),' ',num2str(ApproxError),' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);
for t=1:cardSousEns
fprintf(fidellip_init,[num2str(sousEns(t,1)),' ',num2str(sousEns(t,2)),' ',num2str(sousEns(t,3)),' ',num2str(sousRay(t)),'\n']);
end

            
             cumuleindicesupp=[cumuleindicesupp;indexSousEns]
            nbreBon=nbreBon+1
%              indRegion=ones(5,1)*nbreBon;
            sousIDRegion(:)=nbreBon;
           Aux=[sousEns sousRay sousIDRegion];
%            Ajouter les boules du cluster à Bon
           Bon=[Bon;Aux]; 
%            Supprimer les boules du cluster formant un bon ellipsoide dans
%            Mauvais.
% TA=Mau
%               Mau(indexSousEns, :) = []
              
%           %-----------Debut trace ellipsoide------------------------------------
%           
%             [u v] = meshgrid(linspace(0,2*pi,nbptsvisual),linspace(-pi/2,pi/2,nbptsvisual));
% 
%             x1 = Rayons(1)*cos(u').*cos(v');
%             y1 = Rayons(2)*sin(u').*cos(v');
%             z1 = Rayons(3)*sin(v');
% 
%             % Rotation des points de l'ellipsoide pour l'afficher dans le repere de
%             % depart.
% 
%             for indx = 1:nbptsvisual
%                 for indy = 1:nbptsvisual
%                     poin = [x1(indx,indy) y1(indx,indy) z1(indx,indy)]';
%                     Pt = MatRot * poin;
%                     x1(indx,indy) = Pt(1)+centre(1);
%                     y1(indx,indy) = Pt(2)+centre(2);
%                     z1(indx,indy) = Pt(3)+centre(3);
%                 end
%             end
% 
%              hold on;
%             mesh(x1,y1,z1,'facecolor','none');
%                
%           
%           
%           
%           %-------------Fin trace ellipsoide-------------------------------------   
              
              
              
              
              
        end

     end
     
%      Supprimer tous les cluster qui donnent une bonne approximation de mauvais et les
%      mettre dans Bons. les indices des boules à supprimer sont dans la
%      variable cumuleindicesupp
      if((isempty(cumuleindicesupp)==0))
          Mau(cumuleindicesupp, :) = []
            cardMau=size(Mau,1);
             k=2;
      end

    end
 
 
   disp('Condition regroupement OK et sauvegarde dans fichier')
%          type(0=sphere,1=ellipsoide) C1 C2 C3 Rayon

        for j = 1:size(Mau,1)    
       fprintf(fidfileellip,['0',' ',num2str(Mau(j,1)),' ',num2str(Mau(j,2)),' ',num2str(Mau(j,3)),' ',num2str(Mau(j,4)),'\n']);
       fprintf(fidellip_init,['1 0 0','\n']);
       fprintf(fidellip_init,[num2str(Mau(j,1)),' ',num2str(Mau(j,2)),' ',num2str(Mau(j,3)),' ',num2str(Mau(j,4)),'\n']);
         end

  fclose(fidfileellip); 
  fclose(fidellip_init); 
end