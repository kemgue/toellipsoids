function lectureDonneeRegionInit()

clc
clear

% Pts tableau n ligne (boule) et m colonne.
%col1=x,col2=y,col3=z, col4=rayon,col5=ID Region,col6=indice de la boule
%dans le tableau Pts de tous les point
tabregioninfo=[];
tabboule=[];
tabregionechan=[];
%chemin='/home/kemgue/Documents/al/raz/tout mes TPs/Amuse/fenp4l/fenp4lmax/64x64.bmax';
% chemin='/home/kemgue/Documents/al/raz/tout mes TPs/Amuse/Boule Max Drainage/Olivier Bmax Ellipsoides/p1l.bmaxd'

fid = fopen('../connexcompon/ellip_init.txt', 'rt');
fidfileellip = fopen('fichellip_final.txt', 'w');
fidellip_init = fopen('ellip_fin.txt', 'w');

% Les seuils d'approximation
seuilpts=0.01;
seuilApprox=0;
nbreboulemin=5
seuilRegroupe=0.87;
[phi, theta]=meshgrid([0:0.9:pi], [0:0.9:2*pi]);
dimx=132;
dimy=157;
dimz=90;
% dimx=64;
% dimy=64;
% dimz=64;
dim=max([dimx,dimy,dimz]);
img=zeros(dim,dim,dim);
[x, y, z] = meshgrid(1:dim, 1:dim,1:dim);

h=0;
indreg=0;
indboule=0;
while feof(fid) == 0
    tline = fgetl(fid);
    TargetVar = regexp(tline,' ','split');
    h=h+1;
    nbretoken=length(TargetVar);
    if ((nbretoken==5)||(nbretoken>6)) %nouvelle region
        %if (nbretoken>4) %nouvelle region
        indreg=indreg+1
        
        if (nbretoken> 6) %ellipsoide
            
            [chnbre, reste] =strtok(tline, ' ');
            [cherreurapp, reste] =strtok(reste, ' ');
            [chcentre1, reste] =strtok(reste, ' ');
            [chcentre2, reste] =strtok(reste, ' ');
            [chcentre3, reste] =strtok(reste, ' ');
            [chRx, reste] =strtok(reste, ' ');
            [chRy, reste] =strtok(reste, ' ');
            [chRz, reste] =strtok(reste, ' ');
            [chB11, reste] =strtok(reste, ' ');
            [chB12, reste] =strtok(reste, ' ');
            [chB13, reste] =strtok(reste, ' ');
            [chB21, reste] =strtok(reste, ' ');
            [chB22, reste] =strtok(reste, ' ');
            [chB23, reste] =strtok(reste, ' ');
            [chB31, reste] =strtok(reste, ' ');
            [chB32, reste] =strtok(reste, ' ');
            [chB33, reste] =strtok(reste, ' ');
            
            tabregioninfo(indreg,1:17)= [str2double(chnbre) str2double(cherreurapp) str2double(chcentre1) str2double(chcentre2) str2double(chcentre3) str2double(chRx) str2double(chRy) str2double(chRz) str2double(chB11) str2double(chB12) str2double(chB13) str2double(chB21) str2double(chB22) str2double(chB23) str2double(chB31) str2double(chB32) str2double(chB33)] ;
            
        else %Boule d'un ellipsoide
            [chnbre, reste] =strtok(tline, ' ');
            [chcentre1, reste] =strtok(reste, ' ');
            [chcentre2, reste] =strtok(reste, ' ');
            [chcentre3, reste] =strtok(reste, ' ');
            [chR, reste] =strtok(reste, ' ');
            
            tabregioninfo(indreg,1:17)= [1 str2double(chcentre1) str2double(chcentre2) str2double(chcentre3) str2double(chR) 0 0 0 0 0 0 0 0 0 0 0 0] ;
        end
    else % Cest une boule d'une region
        indboule=indboule+1;
        [chcentreb1, reste] =strtok(tline, ' ');
        [chcentreb2, reste] =strtok(reste, ' ');
        [chcentreb3, reste] =strtok(reste, ' ');
        [chrayonb, reste] =strtok(reste, ' ');
        tabboule(indboule,1:5)= [str2double(chcentreb1) str2double(chcentreb2) str2double(chcentreb3) str2double(chrayonb) indreg] ;
        
        
    end
    
end

indreg
%tabregioninfo


indboule
%  tabboule
% pause;
disp('Fin de lecture des region dans le fichier');
disp('Debut échantillonage des points et dessin des primitive dans l''image');
%Echantillonnage des boules des regions et dessin des primitives dans une
%image


%Recuperer les identifiant de toute les regions.
idenRegion=unique(tabboule(:,5));

for i=1:size(idenRegion,1)
    Info=tabregioninfo(idenRegion(i),1:17);
    members = ( tabboule(:,5)== idenRegion(i));
    Reg= tabboule(members, :);
    tail=size(Reg,1);
    R=Reg(1:tail,1:3);
    Ray=Reg(1:tail,4);
    Echan = echantillonsBoules(R,Ray,phi,theta);
    [envConvex,vol]=convhull(Echan,'simplify',true);
    Ptsapp=unique(Echan(envConvex,:),'rows');
    Ptsapp(:,4)=idenRegion(i);
    tabregionechan=[tabregionechan;Ptsapp];
    
    %image
    if(tail >1) %Ellipsoide
         disp(strcat('Dessin primitive ellipsoide numero : ',num2str(idenRegion(i))))  
         center=Info(3:5);
        
        Rx=Info(6);
        Ry=Info(7);
        Rz=Info(8);
        
        base1=Info(9:11);
        base2=Info(12:14);
        base3=Info(15:17);
        
        MatRot=[base1;base2 ;base3];
        clear ind;
        clear lig;
        clear col;
        clear lz;
        raymax=max([Rx Ry Rz]);
        [tab]=ind2sub(size(x),find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= raymax^2));
        coord=[x(tab),y(tab),z(tab)]';
        coordtrans= MatRot' * (bsxfun(@minus,coord,center'));
        Col = num2cell(coordtrans,1); %# Collect the columns into cells
        columnEllipsoide = cellfun(@(xin1,yin) (xin1(1)/Rx)^2+(xin1(2)/Ry)^2+(xin1(3)/Rz)^2 <=1,Col); 
        vind=find(columnEllipsoide==1);
        colok=coord(:,vind);
        img(sub2ind(size(img),colok(2,:),colok(1,:),colok(3,:)))=idenRegion(i);
       
    else
        center=Info(2:4);
        ray= Info(5);
        disp(strcat('Dessin primitive boule numero : ',num2str(idenRegion(i))))
        clear ind;
        ind=find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= ray^2);
        img(ind)=idenRegion(i);
        
    end
    
end
disp('Fin échantillonage des points et dessin des primitive dans l''image');



graphe=[];
indgraph=0;

tabTasInit=[];
indtas=0;

% Calcul des relation d'adjacence entre les differentes region.

% Si une arete existe entre, inserer l'arete dans le graphe

% Calculer l'erreur d'un possible regroupement des deux region

% Inserer l'arete dans le tas minimal en fonction de son erreure.
disp('Debut de calcul des relations de connexité entre les primitives');
for pix=1:dim^3
    v=img(pix);
    if(v~=0)
        [ Iadj , Radj, Nfound] = neighbourND(pix , size(img));
        
        unib=unique(img(Iadj));
        coord=find(unib~=v & unib~=0);
        
        if(isempty(coord)~=1)
            for k=1:size(coord,1)% Il y a une arete entre v et coord(k)
                if (isempty(graphe)==1) %Vide
                    members1 = ( tabregionechan(:,4)== v);
                    members2 = ( tabregionechan(:,4)== coord(k));
                    Echan=[tabregionechan(members1, 1:3);tabregionechan(members2, 1:3)];
                    [envConvex,vol]=convhull(Echan,'simplify',true);
                    Ptsapp=unique(Echan(envConvex,:),'rows');
                    [ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(Ptsapp,0,seuilpts);
                    ApproxError
                    if((ApproxError>0)&&(ApproxError>=seuilRegroupe))
                        
                        disp(strcat('Connexite <',num2str(v),'> et <',num2str(coord(k)),'>'))
                        disp('Insertion arete dans les structure graphe et tas');
                        indgraph=indgraph+1;
                        indtas=indtas+1;
                        
                        %                 Remplissage du tableau initial du tas
                        tabInitTas(indtas,1:3)=[ApproxError,v,coord(k)];
                        
                        graphe(indgraph,1:5)=[v,coord(k),0,0,ApproxError];% id1,id2,Adresse1,Adresse2,ErreurApproId1etId2
                    end
                else
                    %Verifie si l'arete existe dejà dans le graphe
                    indArete=find(((graphe(:,1)== v & graphe(:,2)== coord(k))|(graphe(:,1)== coord(k) & graphe(:,2)== v)));
                    if(isempty(indArete)==1) %l'arete n'existe pas encore dans le graphe
                        % Calculer l'approximation et l'erreur afin d'inserer
                        % dans le tas et le graphe
                        members1 = ( tabregionechan(:,4)== v);
                        members2 = ( tabregionechan(:,4)== coord(k));
                        Echan=[tabregionechan(members1, 1:3);tabregionechan(members2, 1:3)];
                        [envConvex,vol]=convhull(Echan,'simplify',true);
                        Ptsapp=unique(Echan(envConvex,:),'rows');
                        [ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(Ptsapp,0,seuilpts);
                        ApproxError
                         if((ApproxError>0)&&(ApproxError>=seuilRegroupe))
                            
                            disp(strcat('Connexite <',num2str(v),'> et <',num2str(coord(k)),'>'))
                        disp('Insertion arete dans les structure graphe et tas');
                            indgraph=indgraph+1;
                            indtas=indtas+1;
                            
                            
                            % Remplissage du tableau initial du tas
                            tabInitTas(indtas,1:3)=[ApproxError,v,coord(k)];
                            
                            
                            %                 %Recherche de la derniere arete qui contient i dans id1 et dont adresse1 est 0 pour mettre ï¿½ jour avec indgraphe
                            %                 indexMaj1=find((graphe(:,1)== ind1 & graphe(:,3)== 0)==1)
                            %
                            %                 %Recherche de la derniere arete qui contient j dans id1 et dont adresse1 est 0 pour mettre ï¿½ jour avec indgraphe
                            %                 indexMaj1=find((graphe(:,1)== ind1 & graphe(:,3)== 0)==1)
                            
                            % ou mieux. Rechercher dans id1 et id2 de graphe les ligne et  colonne qui contiennent i ou j avec adresse1 ou adresse2 egale ï¿½ 0
                            
                            [row,col]=find(((graphe(:,1:2)== v | graphe(:,1:2)== coord(k)) & graphe(:,3:4)== 0)) ;
                            % Mise ï¿½ jour du graphe en utilisant les colonne adresse1 et adresse2. pour
                            % i ou j trouver, on met l'adresse de son successeur qui est indgraph.
                            if(isempty(col)==0)
                                for t=1:size(col,1)
                                    if(col(t)==1)
                                        graphe(row(t),3)=indgraph;
                                    else
                                        graphe(row(t),4)=indgraph;
                                    end
                                end
                            end
                            %         Inserer maintenant la nouvelle ligne dans le graphe avec son
                            %         indices identifiant
                            graphe(indgraph,1:5)=[v,coord(k),0,0,ApproxError];% id1,id2,Adresse1,Adresse2,ErreurApproId1etId2
                        end
                        
                        
                        % Mise ï¿½ jour du graphe
                    end
                    
                    
                end
            end
        end
    end
end

disp('Fin du calcul des relations de connexité entre les primitives');
disp('Debut processus de regroupement proprement dit');


clear Echan;

% gr=graphe
% Insertion de l'arete dans le tas minimal en fonction de son erreure[]
H = MaxHeap(tabInitTas);
H.dispheapinfo

% Regroupement proprement dit. Depiler du tas l'arrete qui contient la plus
% petite erreure et regrouper ses regions pour en faire id1 et id2 = id1
%Apres avoir dï¿½pilï¿½ le tas et obtenir l'arete donc la clï¿½ erreur est minimale, verifier si l'arete existe dans la structure
%graphe.Si elle n'existe pas, alors continuer ï¿½ depiler le tas. Si elle existe, verifier que l'erreur qui est dans le tas est la mï¿½me que celle
%qui est dans le graphe(erreur rï¿½elle et recente). Si c'est pas ï¿½gale,continuer avec le dï¿½pilement du tas pour passer ï¿½ l'arete suivante. Si
%l'erreure est ï¿½gale, alors faire le regroupement des deux region et mettre ï¿½ jour la structure graphe(identifiant des region voisin et nouvelle erreurs d'approximation) et la structure tas

while(H.IsEmpty() == false)
    arretemin=H.ExtractMax() % tas maximale parce que erreur d'approximation minimal. si c'etait max, alors tas minimale
    
    % Extrait l'arete de cle d'erreur minimal dans le tas et le reorganise pour mettre en tete l'arete suivant qui contient l'erreur min suivante
    
    %verification de l'existance de l'arete depilï¿½e du tas dans le graphe.
    indArete=find(((graphe(:,1)== arretemin(2) & graphe(:,2)== arretemin(3))|(graphe(:,1)== arretemin(3) & graphe(:,2)== arretemin(2))));
    if((isempty(indArete)~=1)&& (arretemin(1)==graphe(indArete(1),5)))
        % existe et erreur du tas est ï¿½gale ï¿½ l'erreur du graphe. Donc OK. On regroupe. Dans le  cas contraire, ne rien faire. Continuer juste ï¿½ depiler le tas.
        
        
        %On verifie si l'erreur de l'arete depilï¿½ verifie le seuil d'erreur, si c'est le cas,je continue avec le depilement, sinon, je sors de la boucle While et je m'arrete
        if(arretemin(1) < seuilRegroupe)
            break;  %On sort de la boucle, car la plus petite erreur de regroupement n'est plus verifiï¿½e
        end
        
       
        clear Echan;
        clear Ptsapp3;
        clear Ptsapp2;
        clear members1
        clear members2
       
        
        % Faire le regroupement. Calculer les proprietes du nouveau regroupement et les mettre ï¿½ jours
        % tabregioninfo, tabboule,graphe,tas H
       
        tailAuxR1=nnz(tabboule(:,5)== arretemin(2) )
        tailAuxR2=nnz(tabboule(:,5)== arretemin(3) )
        %faire regroupement entre region contenant au
        %minimum minim boules.
        minim= min(tailAuxR1,tailAuxR2)
        if(minim >nbreboulemin)
            
            members1 = ( tabregionechan(:,4)== arretemin(2));
            members2 = ( tabregionechan(:,4)== arretemin(3));
            Echan=[tabregionechan(members1, 1:3);tabregionechan(members2, 1:3)];
            [envConvex,vol]=convhull(Echan,'simplify',true);
            Ptsapp3=unique(Echan(envConvex,:),'rows');
            Ptsapp3(:,4)=arretemin(2);
            [ApproxErrorA,RayonsA,centreA,MatRotA] = approximeMinVolEllipse(Ptsapp3(:,1:3),0,seuilpts);
            ApproxRegroup=ApproxErrorA
            
            %Mise à jour des échantillons de la nouvelle region. Il faut supprimer les
            %echantillons lié à id1 et id2, puis prendre les échantillons de la
            %nouvelle regions et les identifier avec id1, id de la nouvelle region
%            tailechan= size(tabregionechan)
            tabregionechan(find(members1), :) = [];
            memb = ( tabregionechan(:,4)== arretemin(3));
            tabregionechan(find(memb), :) = [];
            tabregionechan=[tabregionechan;Ptsapp3];
            
            %  Mise ï¿½ jour des propriï¿½te de la nouvelle region d'id Id1
            tabregioninfo(arretemin(2),1:17)= [tailAuxR1+tailAuxR2 ApproxErrorA centreA(1) centreA(2) centreA(3) RayonsA(1) RayonsA(2) RayonsA(3) MatRotA(1,1) MatRotA(1,2) MatRotA(1,3) MatRotA(2,1) MatRotA(2,2) MatRotA(2,3) MatRotA(3,1) MatRotA(3,2) MatRotA(3,3)] ;
            % Faire disparaitre les proprietes de region d'id Id2
            tabregioninfo(arretemin(3),1)= 0;
            
            % Parcourir tabboule pour rendre les boules de Id2, les boules de Id1
            indAu = ( tabboule(:,5)== arretemin(3) );
            tabboule(indAu,5)= arretemin(2);
            
            %  Supprimer l'arrete dont id1=i et id2=j ou id1=j et id2=i. il suffit pour ces aretes de mettre id1 et id2 ï¿½ 0 pour marquer la suppresion
            row1=find(((graphe(:,1)== arretemin(2) & graphe(:,2)== arretemin(3))|(graphe(:,1)== arretemin(3) & graphe(:,2)== arretemin(2))));
            graphe(row1,1:2)=0;
            
            %Parcourir le graphe et remplacer les arete id2 id3 par id1 id3 ou id3 id2 par id3 id1. celles qui ont deja id1 id3 ou id3 id1, leur laisser comme
            %tel. id3 est n'immporte quelle sommet different de id1 et id2
            col1=find((graphe(:,1)== arretemin(3)));
            col2=find((graphe(:,2)== arretemin(3)));
            graphe(col1,1)=arretemin(2);
            graphe(col2,2)=arretemin(2);
            
            % Parcourir le graphe pour recherche les aretes qui contiennent un element id1 ou id2 comme sommets et une autre sommet id3.
            % Pour de tels aretes, elles deviennent id3 id1 ou id1 id3, on calcul l'erreurApproximation entre id1 et id3,et on met ï¿½ jour l'erreur de la colonne 5
            % Puis on empile id1 et id3 dans le tas avec la nouvelle erreur. comme id1 est l'id de la nouvelle region, rechercher les arete qui sont en relation avec id2 et remplacer id2 par id1.
            
            %                xx  newRegionId1= [RegionAux1;RegionAux2];
            
            
            
            
            
            row1=find(((graphe(:,1)== arretemin(2) | graphe(:,2)== arretemin(2))));
            
            n=size(row1,1);
            
            if(n>1)
                if(graphe(row1(n),1)==arretemin(2))
                    graphe(row1(n),3)=0;
%                     tailId3 = nnz( tabboule(:,5)== graphe(row1(n),2));
                    members2 = ( tabregionechan(:,4)== graphe(row1(n),2));
                    Echan=[tabregionechan(members2, 1:3);Ptsapp3(:,1:3)];
                    
                    [envConvex,vol]=convhull(Echan,'simplify',true);
                    Ptsapp2=unique(Echan(envConvex,:),'rows');
                    [ApproxErrorAux,RayonsA,centreA,MatRotA] = approximeMinVolEllipse(Ptsapp2(:,1:3),0,seuilpts);
                    ApproxErrorAux
                    graphe(row1(n),5)=ApproxErrorAux;
                     if(ApproxErrorAux>=seuilRegroupe)
                    H.InsertKey([ApproxErrorAux,arretemin(2),graphe(row1(n),2)]);
                     end
                else
                    graphe(row1(n),4)=0;
%                     tailId3=nnz( tabboule(:,5)== graphe(row1(n),1));
                    members2 = ( tabregionechan(:,4)== graphe(row1(n),1));
                    Echan=[tabregionechan(members2, 1:3);Ptsapp3(:,1:3)];
                    
                    [envConvex,vol]=convhull(Echan,'simplify',true);
                    Ptsapp2=unique(Echan(envConvex,:),'rows');
                    [ApproxErrorAux,RayonsA,centreA,MatRotA] = approximeMinVolEllipse(Ptsapp2(:,1:3),0,seuilpts);
                    ApproxErrorAux
                    graphe(row1(n),5)=ApproxErrorAux;
                    if(ApproxErrorAux>=seuilRegroupe)
                    H.InsertKey([ApproxErrorAux,graphe(row1(n),2),arretemin(2)]);
                    end
                    end
                
                for i=n-1:-1:1
                    
                    %clear members2;
                    clear Echan;
                    clear envConvex;
                    clear Ptsapp2;
                    if(graphe(row1(i),1)==arretemin(2))
                        graphe(row1(i),3)=row1(i+1);
%                         tailId3 = nnz( tabboule(:,5)== graphe(row1(i),2));
                        members2 = ( tabregionechan(:,4)== graphe(row1(i),2));
                        Echan=[tabregionechan(members2, 1:3);Ptsapp3(:,1:3)];
                        [envConvex,vol]=convhull(Echan,'simplify',true);
                        Ptsapp2=unique(Echan(envConvex,:),'rows');
                        [ApproxErrorAux,RayonsA,centreA,MatRotA] = approximeMinVolEllipse(Ptsapp2(:,1:3),0,seuilpts);
                        ApproxErrorAux
                        
                        graphe(row1(i),5)=ApproxErrorAux;
                        if(ApproxErrorAux>=seuilRegroupe)
                        H.InsertKey([ApproxErrorAux,arretemin(2),graphe(row1(i),2)]);
                        end
                    else
                        graphe(row1(i),4)=row1(i+1);
                        
%                         tailId3 = ( tabboule(:,5)== graphe(row1(i),1));
                        members2 = ( tabregionechan(:,4)== graphe(row1(i),1));
                        Echan=[tabregionechan(members2, 1:3);Ptsapp3(:,1:3)];
                        
                        [envConvex,vol]=convhull(Echan,'simplify',true);
                        Ptsapp2=unique(Echan(envConvex,:),'rows');
                        [ApproxErrorAux,RayonsA,centreA,MatRotA] = approximeMinVolEllipse(Ptsapp2(:,1:3),0,seuilpts);
                        ApproxErrorAux
                        graphe(row1(i),5)=ApproxErrorAux;
                        if(ApproxErrorAux>=seuilRegroupe)
                        H.InsertKey([ApproxErrorAux,graphe(row1(i),1),arretemin(2)]);
                        end
                    end
                end
            end
            
        end
    end
end

disp('Fin du processus de regroupement et debut de mise des primitives dans les fichiers');
indreg
% tabregioninfo


indboule
% tabboule

indgraph
% graphe

%Recuperer les identifiant de toute les regions.
idenRegion=unique(tabboule(:,5));

for i=1:size(idenRegion,1)
    disp(strcat('Region finale numero <',num2str(i),'>'));
    members = ( tabboule(:,5)== idenRegion(i));
    Reg= tabboule(members, :)
    Info=tabregioninfo(idenRegion(i),1:17)
    %  Info(1)==0 pour les regions qui ont disparu
    if(Info(1)==1)
        fprintf(fidfileellip,['0',' ',num2str(Reg(1)),' ',num2str(Reg(2)),' ',num2str(Reg(3)),' ',num2str(Reg(4)),'\n']);
        fprintf(fidellip_init,['1',' ',num2str(Reg(1)),' ',num2str(Reg(2)),' ',num2str(Reg(3)),' ',num2str(Reg(4)),'\n']);
        fprintf(fidellip_init,[num2str(Reg(1)),' ',num2str(Reg(2)),' ',num2str(Reg(3)),' ',num2str(Reg(4)),'\n']);
        
    else
        %tabregioninfo(arretemin(2),1:17)= [tailAuxR1+tailAuxR2 ApproxErrorA centreA(1) centreA(2) centreA(3) RayonsA(1) RayonsA(2) RayonsA(3) MatRotA(1,1) MatRotA(1,2) MatRotA(1,3) MatRotA(2,1) MatRotA(2,2) MatRotA(2,3) MatRotA(3,1) MatRotA(3,2) MatRotA(3,3)] ;
        
        fprintf(fidfileellip,['1',' ',num2str(Info(3)),' ',num2str(Info(4)),' ',num2str(Info(5)),' ',num2str(Info(6)),' ',num2str(Info(7)),' ',num2str(Info(8)),' ',num2str(Info(9)),' ',num2str(Info(10)),' ',num2str(Info(11)),' ',num2str(Info(12)),' ',num2str(Info(13)),' ',num2str(Info(14)),' ',num2str(Info(15)),' ',num2str(Info(16)),' ',num2str(Info(17)),'\n']);
        fprintf(fidellip_init,[num2str(Info(1)),' ',num2str(Info(2)),' ',num2str(Info(3)),' ',num2str(Info(4)),' ',num2str(Info(5)),' ',num2str(Info(6)),' ',num2str(Info(7)),' ',num2str(Info(8)),' ',num2str(Info(9)),' ',num2str(Info(10)),' ',num2str(Info(11)),' ',num2str(Info(12)),' ',num2str(Info(13)),' ',num2str(Info(14)),' ',num2str(Info(15)),' ',num2str(Info(16)),' ',num2str(Info(17)),'\n']);
        for t=1:Info(1)
            fprintf(fidellip_init,[num2str(Reg(t,1)),' ',num2str(Reg(t,2)),' ',num2str(Reg(t,3)),' ',num2str(Reg(t,4)),'\n']);
        end
        
        
        
    end
    
end


fclose(fidfileellip);
fclose(fidellip_init);
lireTraceEllipsoides(chemin);
end