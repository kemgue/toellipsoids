function [volespace,volellip]=voxelErreurEspace_rap(center,Rayons,MatRot)


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
         
         [tab]=ind2sub(size(x),find((x-center(1)).^2+(y-center(2)).^2+(z-center(3)).^2 <= raymax^2));
          coord=[x(tab),y(tab),z(tab)]';
            coordtrans= MatRot' * (bsxfun(@minus,coord,center));
Col = num2cell(coordtrans,1); %# Collect the columns into cells
columnEllipsoide = cellfun(@(xin1,yin) (xin1(1)/Rayons(1))^2+(xin1(2)/Rayons(2))^2+(xin1(3)/Rayons(3))^2 <=1,Col); 
vind=find(columnEllipsoide==1);
volellip=nnz(vind);

colok=coord(:,vind);
volespace=nnz(find(img(sub2ind(size(img),colok(2,:),colok(1,:),colok(3,:)))==0));
         
       
            
           
     
end 
