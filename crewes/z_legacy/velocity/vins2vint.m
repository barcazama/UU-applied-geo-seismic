function [vrms,vave]=vins2vint(v,z,zout)% [vrms,vave]=vins2vint(v,z,zout)%% Given instantaneaous velocity at a set of discrete z % levels, develop an rms interval velocity function and% an average interval velocity function%	v ... vector of instantaneous velocities%	z ... vector of depths to match v%	zout ... vector of depths at which to output interval%		velocities% note that the depths in zount must fall within the bounds of%	z%% G.F. Margrave Oct 1996, CREWES Project%% NOTE: It is illegal for you to use this software for a purpose other% than non-profit education or research UNLESS you are employed by a CREWES% Project sponsor. By using this software, you are agreeing to the terms% detailed in this software's Matlab source file. % BEGIN TERMS OF USE LICENSE%% This SOFTWARE is maintained by the CREWES Project at the Department% of Geology and Geophysics of the University of Calgary, Calgary,% Alberta, Canada.  The copyright and ownership is jointly held by % its author (identified above) and the CREWES Project.  The CREWES % project may be contacted via email at:  crewesinfo@crewes.org% % The term 'SOFTWARE' refers to the Matlab source code, translations to% any other computer language, or object code%% Terms of use of this SOFTWARE%% 1) Use of this SOFTWARE by any for-profit commercial organization is%    expressly forbidden unless said organization is a CREWES Project%    Sponsor.%% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the %    CREWES Project Sponsorship agreement.%% 3) A student or employee of a non-profit educational institution may %    use this SOFTWARE subject to the following terms and conditions:%    - this SOFTWARE is for teaching or research purposes only.%    - this SOFTWARE may be distributed to other students or researchers %      provided that these license terms are included.%    - reselling the SOFTWARE, or including it or any portion of it, in any%      software that will be resold is expressly forbidden.%    - transfering the SOFTWARE in any form to a commercial firm or any %      other for-profit organization is expressly forbidden.%% END TERMS OF USE LICENSEif(nargin<3)	error('three arguments required');endv=v(:)'; z=z(:)'; zout=zout(:)';% initilize variablesvrms=zeros(size(zout));vave=zeros(size(zout));nz=length(z);i1=1:nz-1;i2=2:nz;delz=diff(z);va=.5*(v(i1)+v(i2)); %midoint velocitydelt= va./delz;t=[0 cumsum(delt)];%loop over zfor k=1:nz 	%make sure zout is monotonic 	test=sum(sign(diff(zout))); 	if(abs(test)<length(zout)-1)		error('zout must be monotonic'); 	end	%	% strategy: 	%	- form a finely layered v defined at the union of	%	the depths z and zout. 	%	- compute interval velocities at the fine layering	%	- loop over the zout depths and composite the appropriate	%	finely layered velocities into a coarser set	%	%expand the input function to contain the requested depths	vout=interp1(z,v,zout);	nz=length(z);	znew=[z(:);zout(:)];	vnew=[v(:);vout(:)];	[znew,iz]=sort(znew);	vnew=vnew(iz);	%eliminate duplicates	test=diff(znew);	it=find(test==0);	if( ~isempty(it) )		znew(it)=[];		vnew(it)=[];	end	nv=length(vnew);	v1=vnew(1:nv-1);	v2=vnew(2:nv);	z1=znew(1:nv-1);	z2=znew(2:nv);	vv=v2-v1;	zz=z2-z1;			%compute the finely layered velocities	%compute the traveltimes through the layers	alpha=vv./zz;	vo=v1-alpha.*z1;	ind=find(alpha==0.0);	if(~isempty(ind))		%constant velocity layers cause alpha to be zero which later		%results in a zero divide. Here is a fudge around the problem		%This will undoubtedly come back to haunt me some day		ind2=find(alpha~=0.0);		am=min(abs(alpha(ind2)));		alpha(ind)=(1.e-03)*am*ones(size(ind));	end	t1=log(1+(alpha.*z1)./vo)./alpha;	t2=log(1+(alpha.*z2)./vo)./alpha;	tint=t2-t1;	t2=cumsum(tint);	t1=t2-tint;	vrms2=vo.*sqrt((exp(2*alpha.*t2)-exp(2*alpha.*t1))./(...		2*alpha.*tint));	vave2=vo.*(exp(alpha.*t2)-exp(alpha.*t1))./...		(alpha.*tint);	t2=cumsum(tint);	t1=t2-tint;	vrms2=[vrms2;vnew(nv)];	vave2=[vave2;vnew(nv)];	% composite the finely layered set	vrms2=vrms2.^2;	for k=1:length(zout)-1		j1=find(znew==zout(k));		j2=find(znew==zout(k+1));		jj=j1:j2-1;		tmp=sum(vrms2(jj).*tint(jj));		vrms(k)=sqrt(tmp/sum(tint(jj)));		vave(k)=sum(vave2(jj).*tint(jj))/sum(tint(jj));	end	%do last point	ilast=find(zout(length(zout))==znew);	if(ilast==nv)		vrms(length(vrms))=sqrt(vrms2(nv));		vave(length(vave))=vave2(nv);	else		jj=ilast:nv-1;		tmp=sum(vrms2(jj).*tint(jj));		vrms(length(vrms))=sqrt(tmp/sum(tint(jj)));		vave(length(vave))=sum(vave2(jj).*tint(jj))/sum(tint(jj));	endend
