function clusterboulesconnex_seuilpercentk() 
clc
% chemin='/home/kemgue/Documents/al/raz/tout mes TPs/Amuse/Boule Max Drainage/Olivier Bmax Ellipsoides/p1l.bmaxd';
chemin='D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Olivier Bmax Ellipsoides\p3l.bmax';
% chemin='D:\al\raz\tout mes TPs\Amuse\Boule Max Drainage\Drainage Valerie Spot\p4l.br';
% chemin='D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lmax\64x64.bmax';
fidfileellip = fopen('fichellip.txt', 'w');
fidellip_init = fopen('ellip_init.txt', 'w');
[phi, theta]=meshgrid([0:0.9:pi], [0:0.9:2*pi]);
Mau=[];
percent=40 % X pourcent de du nombre de boules
percentfin=50 % pourcentage de K pour extraire les derniere regions des l'ensemble des mauvais
epsdist=0;
seuilApp=0.75;
seuilFin=0.6;
seuilpts=0.01; 

 
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
Pts(h,1:4)= [str2num(xc) str2num(yc) str2num(zc) str2num(Rayon)] ;
Ray(h,1)=str2num(Rayon);



end

end


Mau=Pts;
n=size(Mau,1);
bool=0  
k=round((percent*n)/100)
 iterationkmeans=0;
 nbreellipsoide=0;
while((isempty(Mau)==0)&&(k > 2)&&(bool == 0))
  iterationkmeans=iterationkmeans+1  
 Vol=((4/3)*pi)*(Mau(:,4).^3);       
 cardavant=n;   
% Calcul du sous regroupement en utilisant les k-means personnalis� avec le
% calcul du barycentre et non de la moyenne usuelle.
[idx,C]=kmeansperso(Mau(:,1:3),k,Vol,Mau(:,4),'distance','madist','Emptyaction','drop');
% [idx,C]=kmeansperso_r2015a(Pts,k,Vol,Ray,'distance','madist');
% Affiche des boules de chaque sous ensemble.
% sousEns=[];
% sousRay=[];

 cumuleindicesupp=[];
 cumulerestecluster=[];
        for i = 1:k
            members = (i == idx);
%              disp(strcat('Cluster <',num2str(i),'>'));

             sousEns=Mau(members,:);
              if(isempty(sousEns)==1)

              continue
              end
        %      sousRay=Mau(members,4);


        %     PtsCom=[sousEns sousRay];
             tailleCluster=size(sousEns,1);

              if(tailleCluster > 1)
              indiceeltcluster = find(idx==i);
              cumuleindicesupp=[cumuleindicesupp;indiceeltcluster];
             [nbcomp,EnsComp]=connexConponent(sousEns,tailleCluster,epsdist) ;
               %pour chaque sous ensemble de cluster, on determine les composantes connexes. C'est ces sous ensemble qu'on va approxim�  
               cumuleclustersupp=[];
               for j = 1:nbcomp
                 memb = (j == EnsComp);
%                  disp(strcat('Composante connex numero <',num2str(j),'>'));
                 comp=sousEns(memb,:) ;
                 tailcomp=size(comp,1);
                  if(tailcomp > 1)
                     [ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(comp(1:tailcomp,1:3),comp(1:tailcomp,4),seuilpts,phi,theta);
%                         ApproxError 
                       if(ApproxError > seuilApp) % On garde l'ellipsoide
                           disp(strcat('Composante connex numero <',num2str(j),'> GARDE'));
                           nbreellipsoide=nbreellipsoide+1;
                           indiceeltcomp = find(j == EnsComp);
                           fprintf(fidfileellip,['1',' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);

                        fprintf(fidellip_init,[num2str(tailcomp),' ',num2str(ApproxError),' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);
                        for t=1:tailcomp
                        fprintf(fidellip_init,[num2str(comp(t,1)),' ',num2str(comp(t,2)),' ',num2str(comp(t,3)),' ',num2str(comp(t,4)),'\n']);
                        end
% cumuleclustersupp
% indiceeltcomp
                        
                         cumuleclustersupp=[cumuleclustersupp,indiceeltcomp];

                       end


                  end

               end
        %        Je supprime les composantes connexe qui sont OK du cluster et garde le reste de compsante connexe non OK que je vais rajouter
        %        dans l'ensemble des mauvais
               sousEns(cumuleclustersupp, :) = [];
                cumulerestecluster=[cumulerestecluster;sousEns];
              else

               continue
              end

        end

        Mau(cumuleindicesupp, :) = [];
        Mau=[Mau;cumulerestecluster];
        n=size(Mau,1);
        if(cardavant==n) % l'application du kmeans et extraction des composante connexe n'a rien chang� sur les donn�es, donc s'arreter
        bool=1;
        end
        nbreellipsoide
        nbreellipsoide=0;
        k=round((percent*n)/100)
        empty=isempty(Mau)
         bool
        
end
  
% On va maintenant parcourir l'ensemble restante des boules "Mauvaise" i.e qui ne donnes pas des bonnes composante connexes donnant de 
% bon ellipsoides qui satisfait le crictere d'approximation. Pour ce mauvais ensemble, on va extraire toute ses composantes connexes. 
% pour chaque composante connexe extraite, on va appliquer un kmeans avec une valeur de K donn� en pourcentage en fonction du nombre de boules
% de la composante. Chaque composante va nous donner un certain nombre de sous ensemble de boules ou cluster. 
% On va parcourir les cluster de chaque composante, ceux qui verifie le crict�re d'approximation seront garder, ceux qui ne v�rifie pas seront laiss�s ou isol�.
% On va ensuite completer notre ensemble de bonne region ou ellipsoides avec les nouveau obtenu apres cette op�ration.


             [nbcomp,EnsComp]=connexConponent(Mau,size(Mau,1),epsdist) ;
                
               
               cumulerestecomp=[];
               cumuleindicesupp=[];
               for j = 1:nbcomp
                 memb = (j == EnsComp);
%                  disp(strcat('Composante connex fin numero <',num2str(j),'>'));
                 comp=Mau(memb,:) ;
                 tailcomp=size(comp,1);
                 
%                   if(tailcomp > 50)
%                        percentfin=30;
%                   else
%                       percentfin=75;
%                       
%                   end
                     
                 
                if(tailcomp > 1) % Faire le k means cette composante connexe avec une valeur de k donn� en poucentage
                      %garder les indices des boules de la composante dans
                      %l'ensemble Mau pour supprimer bien apres.
                     indiceeltcomp = find(j == EnsComp);
                      cumuleindicesupp=[cumuleindicesupp indiceeltcomp] ; 
                    Volconn=((4/3)*pi)*(comp(:,4).^3);  
                      kfin=round((percentfin*tailcomp)/100)
                      if(kfin < 1)
                          continue
                      end
%                       Tab=comp(:,1:3)
%                       TabRay=comp(:,4)
                     
                      [idx,C]=kmeansperso(comp(:,1:3),kfin,Volconn,comp(:,4),'distance','madist','Emptyaction','drop');
                    % [idx,C]=kmeansperso_r2015a(Pts,k,Vol,Ray,'distance','madist');
 
                    cumuleclustersupp=[];
                         for i = 1:kfin
                            members = (i == idx);
                             

                             sousEns=comp(members,:);
                              if(isempty(sousEns)==1)

                              continue
                              end
                              
                              
                             tailleCluster=size(sousEns,1);
                              if(tailleCluster > 1)
                                         [ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(sousEns(1:tailleCluster,1:3),sousEns(1:tailleCluster,4),seuilpts,phi,theta);
                                       ApproxError 
                                       if(ApproxError > seuilFin) % On garde l'ellipsoide cluster
                                           disp(strcat('Cluster Fin <',num2str(i),'> GARDE'));
                                           indiceeltcluster = find(members');
                                           fprintf(fidfileellip,['1',' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);

                                        fprintf(fidellip_init,[num2str(tailleCluster),' ',num2str(ApproxError),' ',num2str(centre(1)),' ',num2str(centre(2)),' ',num2str(centre(3)),' ',num2str(Rayons(1)),' ',num2str(Rayons(2)),' ',num2str(Rayons(3)),' ',num2str(MatRot(1,1)),' ',num2str(MatRot(1,2)),' ',num2str(MatRot(1,3)),' ',num2str(MatRot(2,1)),' ',num2str(MatRot(2,2)),' ',num2str(MatRot(2,3)),' ',num2str(MatRot(3,1)),' ',num2str(MatRot(3,2)),' ',num2str(MatRot(3,3)),'\n']);
                                        for t=1:tailleCluster
                                        fprintf(fidellip_init,[num2str(sousEns(t,1)),' ',num2str(sousEns(t,2)),' ',num2str(sousEns(t,3)),' ',num2str(sousEns(t,4)),'\n']);
                                        end
             

                                         cumuleclustersupp=[cumuleclustersupp indiceeltcluster];

                                       end
%                               else
%                                   continue;

                              end
                         end
                          %        Je supprime les ellipsoides cluster connexe qui sont OK de la compsantes fin et garde le reste de boule de la compsante connexe non OK que je vais rajouter
        %        dans l'ensemble des mauvais
                comp(cumuleclustersupp, :) = [];
                cumulerestecomp=[cumulerestecomp;comp]; 

               end
      
             
               end
               
        Mau(cumuleindicesupp, :) = [];
        Mau=[Mau;cumulerestecomp];


% ===========================Sauvegarde des boules mauvaise les fichiers
       for j = 1:size(Mau,1)    
       fprintf(fidfileellip,['0',' ',num2str(Mau(j,1)),' ',num2str(Mau(j,2)),' ',num2str(Mau(j,3)),' ',num2str(Mau(j,4)),'\n']);
       fprintf(fidellip_init,['1',' ',num2str(Mau(j,1)),' ',num2str(Mau(j,2)),' ',num2str(Mau(j,3)),' ',num2str(Mau(j,4)),'\n']);
       fprintf(fidellip_init,[num2str(Mau(j,1)),' ',num2str(Mau(j,2)),' ',num2str(Mau(j,3)),' ',num2str(Mau(j,4)),'\n']);
       end

  fclose(fidfileellip); 
  fclose(fidellip_init); 
  
    lireTraceEllipsoides(chemin);
end