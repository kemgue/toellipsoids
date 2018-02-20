function [S1,C1] = connexConponent(Pts,n,eps) 
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

%     for j = 1:S1
%      comp = (j == C1)
%      disp(strcat('Composante connex numero <',num2str(j),'>'));
%      sousEns=Pts(comp,:)   
%      end