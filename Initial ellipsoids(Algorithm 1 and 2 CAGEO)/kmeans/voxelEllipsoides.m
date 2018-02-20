function voxelEllipsoides()

% chemin='D:\al\raz\tout mes TPs\Amuse\fenp4l\fenp4lmax\64x64.bmax';
fid = fopen('fichellip.txt', 'rt');

dim=64;
 img=zeros(dim,dim,dim);
 [x, y, z] = meshgrid(1:dim, 1:dim, 1:dim);

h=0;
   
while feof(fid) == 0
tline = fgetl(fid);
TargetVar = regexp(tline,' ','split');

if length(TargetVar)>2
  h=h+1;
[type, reste] =strtok(tline, ' '); 
if(str2double(type)==1)
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


center=[str2double(chcentre1) str2double(chcentre2) str2double(chcentre3)];

Rx=str2double(chRx);
Ry=str2double(chRy);
Rz=str2double(chRz);

base1=[str2double(chB11) str2double(chB12) str2double(chB13)];
base2=[str2double(chB21) str2double(chB22) str2double(chB23)];
base3=[str2double(chB31) str2double(chB32) str2double(chB33)];

MatRot=[base1;base2 ;base3];
% INVMat=inv(MatRot)
% TRA=MatRot'
 %-----------Debut trace ellipsoide------------------------------------
          

%  disp('Elipsoide : ')
%  disp(h);
 clear ind;
 clear lig;
 clear col;
 clear lz;
 raymax=max([Rx Ry Rz]);
%   taille=[size(x),size(y),size(z)]
% coordonnees dans la matrice r�elle meshgrid x,y z.
[lig,col,lz]=ind2sub(size(x),find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= raymax^2));
% [lig,col,lz]
[tab]=ind2sub(size(x),find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= raymax^2));
coord=[x(tab),y(tab),z(tab)]'
coordf= MatRot' * (bsxfun(@minus,coord,center'))

for k=1:size(lig,1)
%Extraction des coordonn�es du point
   ptinit=[x(lig(k),col(k),lz(k)); y(lig(k),col(k),lz(k));z(lig(k),col(k),lz(k))]
   pt= MatRot' * (ptinit-center')
% eq=(pt(1)^2)+(pt(2)^2)+(pt(3)^2)-raymax^2;
%    if(eq <=0)
 eq=(pt(1)/Rx)^2+(pt(2)/Ry)^2+(pt(3)/Rz)^2;
    if(eq <= 1)
       disp('Je suis verifier')
%      img(ptinit(1),ptinit(2),ptinit(3))=1;
  img(lig(k),col(k),lz(k))=1;
   end
 
end
% 
% for i=1:size(matpts,2)
%      ptinit=matpts(:,i);
% %     img(ptinit(1),ptinit(2),ptinit(3))=1;
% %       img(ptinit(1),ptinit(2),ptinit(3))=1;  
%  pt= MatRot' * (ptinit-center');
% %  pt= MatRot' * ptinit;
% %  pt=pt-center';
% %  eq=((pt(1)-0)^2)/Rx^2+((pt(2)-0)^2)/Ry^2+((pt(3)-0)^2)/Rz^2
% %  eq=(pt(1)^2/raymax^2)+(pt(2)^2/raymax^2)+(pt(3)^2/raymax^2);
% %  eq=(pt(1)/Rx)^2+(pt(2)/Ry)^2+(pt(3)/Rz)^2;
% %     if(eq <= 1)
% eq=(pt(1)^2)+(pt(2)^2)+(pt(3)^2)-raymax^2;
%    if(eq <=0)
%        disp('Je suis verifier')
%      img(ptinit(1),ptinit(2),ptinit(3))=1;  
%    end
% 
% end


%  clear ind;
% [lig,col,lz]=ind2sub(size(x),find(((x-centre(1)).^2)/Rx^2+((y-centre(2)).^2)/Ry^2+((z-centre(3)).^2)/Rz^2 <= 1));
% matpts=[lig col lz]'
% 
%  ind1 = MatRot * [lig col lz]';
% for i=1:size(matpts,2)
% pt= ceil(MatRot * matpts(:,1));
% img(pt(1),pt(2),pt(3))=1;
% end


 
%             [u v] = meshgrid(linspace(0,2*pi,nbptsvisual),linspace(-pi/2,pi/2,nbptsvisual));
% 
%             x1 = Rx*cos(u').*cos(v');
%             y1 = Ry*sin(u').*cos(v');
%             z1 = Rz*sin(v');
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
          
          
          %-------------Fin trace ellipsoide-------------------------------------   

else
[chcentre1, reste] =strtok(reste, ' ');
[chcentre2, reste] =strtok(reste, ' ');
[chcentre3, reste] =strtok(reste, ' ');
[chRx, reste] =strtok(reste, ' ');

center = [str2num(chcentre1) str2num(chcentre2) str2num(chcentre3)];
ray=str2num(chRx);
clear ind;
ind=find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= ray^2);

img(ind)=1;


end

end

end
fclose(fid);

assignin('base','IMGBOULE',img);
% lireTraceEllipsoides()
hold on
vol3d('cdata',img,'texture','3D');
% image3forum(img,'b')
% VoxelPlotter(img,1,'b');


view(3);
axis equal;
end 
