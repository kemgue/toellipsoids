function [nbreVoxel] = voxelEnsBoules(Pts)

dim=round(max(max(bsxfun(@plus,Pts(:,1:3),Pts(:,4)))));
dimx=dim;
dimy=dim;
dimz=dim;
intVide=0;
  img=ones(dimx,dimy,dimz)*intVide;
  [x, y, z] = meshgrid(1:dimx, 1:dimy,1:dimz);
  Npts=size(Pts,1);
 for j = 1:Npts

     % prendre l'image comme étant les point qui sont dans la sphere
    clear ind;
    center=Pts(j,1:3);
    ray=Pts(j,4);
    d=ray^2;
    ind=find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= d);
    img(ind)=1;
     
     
 end
nbreVoxel=nnz(img==1);
clear img

end   