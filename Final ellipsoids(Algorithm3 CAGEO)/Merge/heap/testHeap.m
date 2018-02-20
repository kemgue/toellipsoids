function testHeap() 
H=[]
clc
x0=[23,1,2;
    2,5,6;
    4,7,8;
    5,9,10;
    44,3,4;
    1,11,12;
    20,21,22]

% H = MinHeap(x0);
%  H.dispheapinfo;
% H.InsertKey([1.5,0,0]);
%  H.dispheapinfo;
%  min=H.ExtractMin()
%  H.dispheapinfo;
%   H.Clear(); 
%  H.dispheapinfo;

H = MaxHeap(x0);
%H.sort();
 H.dispheapinfo();
H.InsertKey([1.5,0,0]);
 H.dispheapinfo;
 max=H.ExtractMax()
 H.dispheapinfo;
  max=H.ExtractMax()
 H.dispheapinfo;
  H.Clear(); 
 H.dispheapinfo;
 
 

