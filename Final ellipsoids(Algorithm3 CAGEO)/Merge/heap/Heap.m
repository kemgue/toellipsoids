classdef Heap < handle
%
% Abstract superclass for all heap classes
%
% Note: You cannot instantiate Heap objects directly; use MaxHeap or
%       MinHeap
%

    %
    % Protected properties
    %
    properties (Access = protected)
        k;                  % current number of elements
        n;                  % heap capacity
        x;                  % heap array of n X 3 where x(i,1)= key,x(i,2)= id1,x(i,3)= id2 of element i
                            % id1-id2 is arete and key is error obtain by
                            % fitting region of id1 and region of id2
    end
    
    %
    % Public methods
    %
    methods (Access = public)
        %
        % Constructor
        %
        function this = Heap(x0)
                k0 = size(x0,1);
             this.x = nan(k0,3);
            if (~isempty(x0))
               this.x(1:k0,:) = x0;
               this.SetLength(k0);
               
            else
                % Empty heap
                this.Clear();
            end
        end
        
        %
        % Return number of elements in heap
        %
        function count = Count(this)
            %-------------------------- Count -----------------------------
            % Syntax:       count = H.Count();
            %               
            % Outputs:      count is the number of values in H
            %               
            % Description:  Returns the number of values in H
            %--------------------------------------------------------------
            
            count = this.k;
        end
        
              
        %
        % Check for empty heap
        %
        function bool = IsEmpty(this)
            %------------------------- IsEmpty ----------------------------
            % Syntax:       bool = H.IsEmpty();
            %               
            % Outputs:      bool = {true,false}
            %               
            % Description:  Determines if H is empty
            %--------------------------------------------------------------
            
            if (this.k == 0)
                bool = true;
            else
                bool = false;
            end
        end
        
       
        
        %
        % Clear the heap
        %
        function Clear(this)
            %-------------------------- Clear -----------------------------
            % Syntax:       H.Clear();
            %               
            % Description:  Removes all values from H
            %--------------------------------------------------------------
            
            this.SetLength(0);
            this.x=[];
        end
    end
    
    %
    % Abstract methods
    %
    methods (Abstract)
        %
        % Sort elements
        %
        Sort(this);
        
        %
        % Insert key
        %
        InsertKey(this,key);
    end
    
    %
    % Protected methods
    %
    methods (Access = protected)
        %
        % Swap elements
        %
        function Swap(this,i,j)
            val = this.x(i,:);
            this.x(i,:) = this.x(j,:);
            this.x(j,:) = val;
        end
        
        %
        % Set length
        %
        function SetLength(this,k)
            if (k < 0)
                Heap.UnderflowError();
            end
            this.k = k;
        end
    end
    
    %
    % Protected static methods
    %
    methods (Access = protected, Static = true)
        %
        % Parent node
        %
        function p = parent(i)
            p = floor(i / 2);
        end
        
        %
        % Left child node
        %
        function l = left(i)
            l = 2 * i;
        end
        
        % Right child node
        function r = right(i)
            r = 2 * i + 1;
        end
        
             
        %
        % Underflow error
        %
        function UnderflowError()
            error('Heap underflow');
        end
     
    end
end
