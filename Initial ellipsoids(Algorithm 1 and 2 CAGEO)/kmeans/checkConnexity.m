function reponse = checkConnexity(Pts,n,eps) 



tab1=[];
tab2=[];
for i=1:n-1
    for j=(i+1):n
        b1=Pts(i,1:3);
        b2=Pts(j,1:3);
        dist_euclide=norm( b1 - b2);
%         message=[num2str(i,'%2d'), ' et ', num2str(j,'%2d'),' Distance : ' num2str(dist_euclide)]
        if(dist_euclide<=(Pts(i,4)+Pts(j,4))+eps)
          tab1=[tab1 i j] ;
          tab2=[tab2 j i] ;
        end
    
    end
end

 g = sparse(tab1, tab2,true,n,n);
[S1,C1] = graphconncomp(g,'DIRECTED',true);
% [S2,C2] = conncomp(g)
 reponse=range(C1);  %range==0 signifie connexe, range!=0 signifie non connexe
