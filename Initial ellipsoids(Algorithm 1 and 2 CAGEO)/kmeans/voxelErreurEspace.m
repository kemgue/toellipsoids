function [volespace,volellip]=voxelErreurEspace(center,Rayons,MatRot)


volespace=0;
volellip=0;
% MatRot
% center
 img=evalin('base','IMGBOULE');
x=evalin('base','meshx');
y=evalin('base','meshy');
z=evalin('base','meshz');
         clear ind;
         clear lig;
         clear col;
         clear lz;
         raymax=max(Rayons);
        % coordonnees dans la matrice reelle meshgrid x,y z.
        [lig,col,lz]=ind2sub(size(x),find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= raymax^2));

                  for k=1:size(lig,1)
                    %Extraction des coordonnees du point
                       ptinit=[x(lig(k),col(k),lz(k)); y(lig(k),col(k),lz(k));z(lig(k),col(k),lz(k))];
                       pt= MatRot' * (ptinit-center);

                     eq=(pt(1)/Rayons(1))^2+(pt(2)/Rayons(2))^2+(pt(3)/Rayons(3))^2;
                      if(eq <= 1) %Voxel de la boule dans l'ellipsoide.
                         volellip=volellip+1;
                          if(img(lig(k),col(k),lz(k))==0) % dans l'espace poral
                              volespace=volespace+1;
                          end
                          
                      
                      end

                   end
            
           
     
end 
