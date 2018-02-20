function tracechaine(cen,a,b,c,bases,N)

    [X,Y,Z] = ellipsoid(0,0,0,a,b,c,N);
    
    %  rotate and center the ellipsoid to the actual center point
    %------------------------------------------------------------
    XX = zeros(N+1,N+1);
    YY = zeros(N+1,N+1);
    ZZ = zeros(N+1,N+1);
    
    
   mat=[];
   for j=1:length(X)
   mat=[X(:,j) Y(:,j) Z(:,j)];
   
   for k=1:length(X)
       
   
     
     
   mat(k,:)=((bases*mat(k,:)')+cen')';
   end
   
  % disp(mat)
   
   XX(:,j)=mat(:,1);
   YY(:,j)=mat(:,2);
   ZZ(:,j)=mat(:,3);
   % TT=XX
   end
    
  

    
    
    
%     for k = 1:length(X),
%         for j = 1:length(X),
%             point = [X(k,j) Y(k,j) Z(k,j)]';
%             P = bases * point;
%             XX(k,j) = P(1)+cen(1);
%             YY(k,j) = P(2)+cen(2);
%             ZZ(k,j) = P(3)+cen(3);
%         end
%     end


% Plot the ellipse
%----------------------------------------
    mesh(XX,YY,ZZ);
    axis equal
    hidden off
end
