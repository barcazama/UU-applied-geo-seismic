function E = gridobj(name,data,dataname,delx,dely,xnot,ynot,datatype)

% E = gridobj( name, data, dataname, delx, dely, xnot, ynot, datatype)
% E = gridobj( name, data, dataname, delx, dely, xnot, ynot)
% E = gridobj( name, data, dataname, delx, dely, xnot)
% E = gridobj( name, data, dataname, delx, dely)
% E = gridobj( name, data, dataname, delx)
% E = gridobj( name, data, dataname)
% E = gridobj( name, data)
%
% GRIDOBJ creates an EarthObject designed to store earth science
% data sampled at regular grid locations. The matrix dimensions
% of 'data' define the grid while 'delx' and 'dely' specify the
% physical distance between columns and rows respectively. 
% The returned EarthObject, E, should NEVER be used directly in 
% computations because it is designed as a general data storage 
% object. Instead, use the appropriate OBJGET and OBJSET calls to 
% get and set the items in E.
%
% name = string vector specifying the object's name 
%        requirement: length(name) <= length(data(:))
% data = matrix containing the gridded data
% dataname = string of ten chars or less giving the name of the data
%        ************ default = 'data' *************
% delx = physical distance between columns in the matrix
%        ************ default = 1.0 ****************
% dely = physical distance between rows in the matrix
%        ************ default = 1.0 ****************
% xnot = first column coordinate
%        ************ default = 0.0 ****************
% ynot = first row coordinate
%        ************ default = 0.0 ****************
% datatype = string vector specifying the data type
%                    requirement: length(datatype) == 4
%     ******* default = '    ' *********
% E = the returned EarthObject
%
% by G.F. Margrave, March 1993
% Updated July 1997
%
% NOTE: It is illegal for you to use this software for a purpose other
% than non-profit education or research UNLESS you are employed by a CREWES
% Project sponsor. By using this software, you are agreeing to the terms
% detailed in this software's Matlab source file.
 
% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by 
% its author (identified above) and the CREWES Project.  The CREWES 
% project may be contacted via email at:  crewesinfo@crewes.org
% 
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) Use of this SOFTWARE by any for-profit commercial organization is
%    expressly forbidden unless said organization is a CREWES Project
%    Sponsor.
%
% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the 
%    CREWES Project Sponsorship agreement.
%
% 3) A student or employee of a non-profit educational institution may 
%    use this SOFTWARE subject to the following terms and conditions:
%    - this SOFTWARE is for teaching or research purposes only.
%    - this SOFTWARE may be distributed to other students or researchers 
%      provided that these license terms are included.
%    - reselling the SOFTWARE, or including it or any portion of it, in any
%      software that will be resold is expressly forbidden.
%    - transfering the SOFTWARE in any form to a commercial firm or any 
%      other for-profit organization is expressly forbidden.
%
% END TERMS OF USE LICENSE

if nargin < 8
   datatype = '    ';
end
if nargin < 7
   ynot = 0.0;
end
if nargin < 6
   xnot = 0.0;
end
if nargin < 5
   dely = 1.0;
end
if nargin < 4
   delx = 1.0;
end
if nargin < 3
	dataname = 'data';
end
if nargin < 2
   ' you must supply at least two arguments for gridobj'
   return;
end

[numRows, numCols] = size(data);
dataSize = numRows*numCols;


% declare E
 E= buildobj(dataSize,length(name));

% set object version number
 E.objvernum=1.0;
%set object creation date
 E.objcreate=fix(clock);
% set user field
 E.username='matlab';
%set x axis name
 E.xaxisname='x axis';
%set y axis name
 E.yaxisname='y axis';
%set azimuth of north
 E.north=90.0;
% set Azimuth of east
 E.east=0.0;
% set flag for gridobj
 E.objtype='grid';
% set data type
 E.datatype=datatype;
% set datarows
 E.datarows=numRows;
% set datacols
 E.datacols=numCols;
% set global origin
 E.globorigin=[0.,0.];
% set scale factor
 E.xyscale=1.0;
% set rotation angle
 E.xyrotate=0.;
% set object's name
 E.name=name;
% set the object's x increment 
 E.delx=delx;
% set the object's y increment 
 E.dely=dely;
% set the object's first column coordinate
 E.xnot=xnot;
% set the object's first row coordinate
 E.ynot=ynot;
% set data (protect flag off)
 E.data=setfield(E.data,dataname,data); 
 
% set the data name 
 E.data=setfield(E.data,'dataname',dataname);
% set the data create
 E.data=setfield(E.data,'datacreate',fix(clock));
% set the data modified
 E.data=setfield(E.data,'datamodified',fix(clock));
% set the data
if( length(data)>0 )
 E.data=setfield(E.data,dataname,data);
end
 
 
