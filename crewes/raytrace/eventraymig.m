function eventraymig(figno1,figno2,pts)
% EVENTRAYMIG: raytrace migrate a picked event assuming normal incidence
%
% eventraymig(figno1,figno2,pts)
%
% EVENTRAYMIG uses a velocity model initialized by RAYVELMOD and a
% vector of points picked using GINPUT. For each pair of npoints,
% a normal incidence ray is determined and projected down into the
% velocity model.
%
% figno1 ... figure number to take picks from
% figno2 ... figure number to plot the rays in
% pts ... n x 2 matrix of (x,t) vaues from ginput or equivalent
% ********** default is to use the global PICKS ***************
%
% G.F. Margrave, CREWES, June 2000
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

global PICKS

if(nargin<1)
	error('You must give a figure number for picks')
end
if(nargin<2)
	error('You must give a figure number to plot rays in')
end

%resolve figure numbers
[nfigs,nnn]=size(PICKS);
doit=0;
for kkp=1:nfigs
    pickfig=PICKS{kkp,1};
    if(pickfig==figno1)
        doit=1;
        break
    end
end

if(~doit)
    error('invalid figure number for picks')
end

doit=0;
for kkr=1:nfigs
    rayfig=PICKS{kkr,1};
    if(rayfig==figno2)
        doit=1;
        break
    end
end

if(~doit)
    error('invalid figure number for rays')
end

if(nargin<3)
	global PICKS PICKCOLOR
	pts=PICKS{kkp,2};
end

if(isempty(PICKCOLOR))
	clr='r';
else
	clr=PICKCOLOR;
end

[npts,nc]=size(pts);

for k=1:npts
	%dtdx=(pts(k+1,2)-pts(k,2))/(pts(k+1,1)-pts(k,1));
    dtdx=(pts(k,4)-pts(k,2))/(pts(k,3)-pts(k,1));
	%x0=.5*(pts(k+1,1)+pts(k,1));
    x0=.5*(pts(k,1)+pts(k,3));
	t0=.5*(pts(k,2)+pts(k,4));
	params=[rayfig .004 4];
	normraymig(x0,t0,dtdx,params,clr);
end
