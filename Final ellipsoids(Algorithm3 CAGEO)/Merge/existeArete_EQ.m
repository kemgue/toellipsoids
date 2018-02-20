function reponse = existeArete_EQ(R1,R2,eps)

N1=size(R1,1);
N2=size(R2,1);
reponse=0;

if(R1(1)>1 && R2(1)>1)  % Les deux region sont des ellipsoides
    b1=R1(3:5);
    b2=R2(3:5);
    dist_euclide=norm(b1 - b2);
    
    if(dist_euclide >(max(R1(6:8))+max(R2(6:8)))+eps)
        %Si les deux sphere circonscrite ne d'intercepte pas, alors on conclut qu'il n'y a pas de relation de connexite entre les deux ellipsoides
        reponse=0;
        return
        
    else
        
        if(dist_euclide<=(min(R1(6:8))+min(R2(6:8)))+eps)
            %Si les deux sphere inscrite s'intercepte, alors on conclut qu'il y a une relation de connexite entre les deux ellipsoides
            reponse=1;
            return
            
        else
            %             on ecrit les deux equations des ellipsoides dans le repere d'origine ou de l'image.
            % On prends les voxels du premier ellipsoide grace à son equation générale, Si un voxel point du premier ellipsoide verifie l'équation generale
            % du second ellipsoide, alors on conclut qu'il y a une relation de connexite entre les deux ellipsoides.
            % Sinon, on conclut qu'il n'y a pas de relation de connexite entre les deux
            % ellipsoides.
            
            % Recuperer les points du premier ellipsoide à partir de son équation generale et mettre dans une matrice M1 où les
            % colonnes sont des points qui vérifient l'équation de l'éllipsoide, puis  recupérer les points du second ellipsoide et
            % mettre dans M2. Puis recherche ensuite l'intersection de M1 et M2 pour savoir s'il y a des colonne similaires dans les deux.
            % Si on trouve aumoins une colonne qui apparait dans les 2 matrices, alors il y a intersection(donc ellipsoides E1 et E2 sont connexe)
            % sinon il y a pas d'intersection(E1 et E2 ne sont pas connexes).
            
            % C=bsxfun(@plus, 2*ones(5,3),(A.*B)) <=> C=2*ones(5,3)+(A.*B) avec A et B 5X3
            
            Coef1 = calculEquationGeneral(R1);
            Coef2 = calculEquationGeneral(R2)
            
            dim1=max(R1(6:8));
            dim2=max(R2(6:8))
            img=zeros(dim1,dim1,dim1);
            [x, y, z] = meshgrid(1:dim1, 1:dim1,1:dim1);
            % (A/J)x^2+(B/J)y^2+(C/J)z^2+(D/J)xy+(E/J)xz+(F/J)yz+(G/J)x+(H/J)y+(I/J)z+1=0
            [tab]=ind2sub(size(x),find(Coef1(1)*(x.^2)+Coef1(2)*(y.^2)+Coef1(3)*(z.^2)+Coef1(4)*(x.*y)+Coef1(5)*(x.*z)+Coef1(6)*(y.*z)+Coef1(7)*x+Coef1(8)*y+Coef1(9)*z+1*ones(size(x))<=0))
            coord1=[x(tab),y(tab),z(tab)]'
            clear(tab);
            clear(img);
            clear(x);
            clear(y);
            clear(z);
            
            img=zeros(dim2,dim2,dim2);
            [x, y, z] = meshgrid(1:dim2, 1:dim2,1:dim2);
            [tab]=ind2sub(size(x),find(Coef2(1)*(x.^2)+Coef2(2)*(y.^2)+Coef2(3)*(z.^2)+Coef2(4)*(x.*y)+Coef2(5)*(x.*z)+Coef2(6)*(y.*z)+Coef2(7)*x+Coef2(8)*y+Coef2(9)*z+1*ones(size(x))<=0))
            coord2=[x(tab),y(tab),z(tab)]'
            clear(tab);
            clear(img);
            clear(x);
            clear(y);
            clear(z);
            [Inter] = intersect(coord1',coord2','rows')
            % [C,ia] = setdiff(A,B,'rows')
            
            if(isempty(Inter)==1) % Il n y a pas d'intersection
                reponse=0;
                return
            else % Il y a intersection
                reponse=1;
                return
            end
            
            
        end
        
    end
    
else % On à faire à un cercle et un ellipsoide
    
   Boule=[];
   Ellip=[];
   
  if(R1(1)<=1 && R2(1)>1)
      Boule=R1
      Ellip=R2
  else
      Boule=R2
      Ellip=R1
  end
   
    b1=Ellip(3:5);
    b2=Cercle(3:5);
    dist_euclide=norm(b1 - b2);
    
    if(dist_euclide >(max(Ellip(6:8))+Cercle(6))+eps)
        %Si les deux sphere circonscrite ne d'intercepte pas, alors on
        %conclut qu'il n'y a pas de relation de connexite entre l'ellisoide
        %et la boule
        reponse=0;
        return
        
    else
        
         Coef1 = calculEquationGeneral(Ellip);
            
            
            dim1=max(Ellip(6:8));
            dim2=Cercle(6)
            img=zeros(dim1,dim1,dim1);
            [x, y, z] = meshgrid(1:dim1, 1:dim1,1:dim1);
            % (A/J)x^2+(B/J)y^2+(C/J)z^2+(D/J)xy+(E/J)xz+(F/J)yz+(G/J)x+(H/J)y+(I/J)z+1=0
            [tab]=ind2sub(size(x),find(Coef1(1)*(x.^2)+Coef1(2)*(y.^2)+Coef1(3)*(z.^2)+Coef1(4)*(x.*y)+Coef1(5)*(x.*z)+Coef1(6)*(y.*z)+Coef1(7)*x+Coef1(8)*y+Coef1(9)*z+1*ones(size(x))<=0))
            coord1=[x(tab),y(tab),z(tab)]'
            clear(tab);
            clear(img);
            clear(x);
            clear(y);
            clear(z);
            
            img=zeros(dim2,dim2,dim2);
            [x, y, z] = meshgrid(1:dim2, 1:dim2,1:dim2);
            % (x-x0)^2+(y-y0)^2+(z-z0)^2-R^2=0
            [tab]=ind2sub(size(x),find(((x-Cercle(3)*ones(size(x))).^2)+((y-Cercle(4)*ones(size(y))).^2)+((z-Cercle(5)*ones(size(z))).^2)-(Cercle(6)^2)*ones(size(x))<=0))
            coord2=[x(tab),y(tab),z(tab)]'
            clear(tab);
            clear(img);
            clear(x);
            clear(y);
            clear(z);
            [Inter] = intersect(coord1',coord2','rows')
            % [C,ia] = setdiff(A,B,'rows')
            
            if(isempty(Inter)==1) % Il n y a pas d'intersection
                reponse=0;
                return
            else % Il y a intersection
                reponse=1;
                return
            end
        
        
    end
  
    
    
end
end

