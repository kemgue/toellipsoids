function plotMatrixVoxels(matimg)

h = vol3d('cdata',matimg)
view(3);  
axis equal; 
% daspect([1 1 .4])
%rampdown, vup
alphamap('rampdown');
alphamap(.50 .* alphamap);

view(3);
axis equal;



end   