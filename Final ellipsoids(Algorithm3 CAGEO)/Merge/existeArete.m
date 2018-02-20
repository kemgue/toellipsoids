function reponse = existeArete(R1,R2,eps) 

N1=size(R1,1);
N2=size(R2,1);
reponse=0;
  for i=1:N1
	  for j=1:N2

            b1=R1(i,1:3);
            b2=R2(j,1:3);
            dist_euclide=norm( b1 - b2);
    %         message=[num2str(i,'%2d'), ' et ', num2str(j,'%2d'),' Distance : ' num2str(dist_euclide)]
            if(dist_euclide<=(R1(i,4)+R2(j,4))+eps)
             reponse=1;
             return
            end

    end
  end

end
