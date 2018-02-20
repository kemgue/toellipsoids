function test_gros_ellipsoide()
clc
clear

% Pts tableau n ligne (boule) et m colonne.
%col1=x,col2=y,col3=z, col4=rayon,col5=ID Region,col6=indice de la boule
%dans le tableau Pts de tous les point
tabregioninfo=[];
tabboule=[];
% Les seuils d'approximation
seuilpts=0.01;
%chemin='/home/kemgue/Documents/al/raz/tout mes TPs/Amuse/fenp4l/fenp4lmax/64x64.bmax';
% chemin='/home/kemgue/Documents/al/raz/tout mes TPs/Amuse/Boule Max Drainage/Olivier Bmax Ellipsoides/p1l.bmaxd'

fid = fopen('gros_ellip.txt', 'rt');

[phi, theta]=meshgrid([0:0.9:pi], [0:0.9:2*pi]);


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
  indreg=indreg+1;
 
    if (nbretoken> 6)
  
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
   
    else
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
%  tabregioninfo


indboule
% tabboule

ind1 = ( tabboule(:,5)== indreg );
Region1= tabboule(ind1, :); 
tailR1=size(Region1,1);
R=[Region1(1:tailR1,1:3)]
Ray=[Region1(1:tailR1,4)]
size(R)

[ApproxError,Rayons,centre,MatRot]= approximeMinVolEllipse(R,Ray,seuilpts,phi,theta);
% [ApproxError,Rayons,centre,MatRot] = approximeMinVolEllipse(Echan,0,seuilpts);
               ApproxError
 
% %Trace image de voxel               
%  img=evalin('base','IMGBOULE');
%   size(img)
% % vol3d('cdata',img,'texture','3D');
% h = vol3d('cdata',img);
% view(3);  
% axis equal; 
% % daspect([1 1 .4])
% %rampdown, vup
% alphamap('rampdown');
%  alphamap(.50 .* alphamap);              
%                
%  
             hold on;
             
% Trace boules

for i=1:size(R,1)
d=1;
hold on;

[xu,yu,zu] = sphere;

  x = xu*Ray(i) + R(i,1);
  y = yu*Ray(i) + R(i,2);
  z = zu*Ray(i) + R(i,3);
  c = ones(size(z))*d;
  surf(x,y,z,c);


end
             
             
%Trace ellipsoide
%-----------Debut trace ellipsoide------------------------------------
   nbptsvisual=60;  
   Rx=Rayons(1)
   Ry=Rayons(2)
   Rz=Rayons(3)
            [u v] = meshgrid(linspace(0,2*pi,nbptsvisual),linspace(-pi/2,pi/2,nbptsvisual));

            x1 = Rx*cos(u').*cos(v');
            y1 = Ry*sin(u').*cos(v');
            z1 = Rz*sin(v');

            % Rotation des points de l'ellipsoide pour l'afficher dans le repere de
            % depart.

            for indx = 1:nbptsvisual
                for indy = 1:nbptsvisual
                    poin = [x1(indx,indy) y1(indx,indy) z1(indx,indy)]';
                    Pt = MatRot * poin;
                    x1(indx,indy) = Pt(1)+centre(1);
                    y1(indx,indy) = Pt(2)+centre(2);
                    z1(indx,indy) = Pt(3)+centre(3);
                end
            end

            mesh(x1,y1,z1,'facecolor','none','edgecolor','r')
               
               

end