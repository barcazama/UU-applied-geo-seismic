function s=slicemat(a,traj,hwid,flag)
% SLICEMAT slices a matrix along a trajectory
%
% s=slicemat(a,traj,hwid,flag)
%
% SLICEMAT slices through a matrix along a certain trajectory.
% The trajectory must be specified in terms of a row index for
% each column and may not be double valued. The width of the slice
% is prescribed by its half width. The output matrix will contain 
% the slice with the matrix elements on the trajectory being on the
% central row. Whereever the half width of the slice prescribes
% values outside the bounds of the input martix, zeros are returned.
%
%	a = input matrix
%	traj = trajectory of the slice. Must be a vector with one 
%		entry per column of a. Each entry specifies a row index.
%	hwid = half width of the slice specified in rows. The output
%		slice will have 2*hwid + 1 rows. This can be a single integer
%     or it can have one entry per column if the half width is 
%     variable.
%	flag = 1 ... When the slice excedes the bounds of a return 0
%			 2 ... When the slice excedes the bounds of a return NaN
%   ********* default = 1 **********
%	s = output matrix containing the slice of a. If [m,n]=size(a),
%		then the size of s is 2*hwid+1 rows and n columns.
%
% 	example a= ((1:5)')*(ones(1,10))
%		traj=[1:5 5:-1:1];
%		s=slicemat(a,traj,1)
%		s =
%		0     1     2     3     4     4     3     2     1     0
%		1     2     3     4     5     5     4     3     2     1
%		2     3     4     5     0     0     5     4     3     2
%
% G.F. Margrave, Feb. 1995

if(nargin< 4)
	flag=1;
end
if(length(hwid)==1)
	hwid=hwid*ones(1,size(a,2));
end

[m,n]=size(a);
hmx=max(hwid);
if(flag==1)
	s=zeros(2*hmx+1,n);
else
	s=nan*zeros(2*hmx+1,n);
end

for k=1:n
	hw=round(hwid(k));
	i1=max(1,traj(k)-hw);
	i2=min(m,traj(k)+hw);

	ind=(i1:i2)-traj(k)+hmx+1;

	s(ind,k) = a(i1:i2,k);
end
