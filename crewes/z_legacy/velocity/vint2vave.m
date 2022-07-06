function vave=vint2vave(vint,t,tout)% vave=vint2vave(vint,t,tout)% vave=vint2vave(vint,t)%% VINS2VAVE computes average velocity as a function of time% given interval velocity as a function of time.%% vint = input interval velocity vector% t = input time vecot to go with vint% tout = vector of output times at which vave estimates are%	desired. Requirement tout >= t(1)%*********** default tout=t *********%%% G.F. Margrave June 1995, CREWES Project%% NOTE: It is illegal for you to use this software for a purpose other% than non-profit education or research UNLESS you are employed by a CREWES% Project sponsor. By using this software, you are agreeing to the terms% detailed in this software's Matlab source file. % BEGIN TERMS OF USE LICENSE%% This SOFTWARE is maintained by the CREWES Project at the Department% of Geology and Geophysics of the University of Calgary, Calgary,% Alberta, Canada.  The copyright and ownership is jointly held by % its author (identified above) and the CREWES Project.  The CREWES % project may be contacted via email at:  crewesinfo@crewes.org% % The term 'SOFTWARE' refers to the Matlab source code, translations to% any other computer language, or object code%% Terms of use of this SOFTWARE%% 1) Use of this SOFTWARE by any for-profit commercial organization is%    expressly forbidden unless said organization is a CREWES Project%    Sponsor.%% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the %    CREWES Project Sponsorship agreement.%% 3) A student or employee of a non-profit educational institution may %    use this SOFTWARE subject to the following terms and conditions:%    - this SOFTWARE is for teaching or research purposes only.%    - this SOFTWARE may be distributed to other students or researchers %      provided that these license terms are included.%    - reselling the SOFTWARE, or including it or any portion of it, in any%      software that will be resold is expressly forbidden.%    - transfering the SOFTWARE in any form to a commercial firm or any %      other for-profit organization is expressly forbidden.%% END TERMS OF USE LICENSE%test input argumentsif(length(vint)~=length(t))	error('vint and t must have same lengths')endif(nargin < 3)	%integrate vint	dt=diff(t);	vave=zeros(size(vint));	nt=length(t);	i1=2:nt;	vave(i1)=cumsum(dt.*vint(i1-1));	vave(i1)=vave(i1)./(t(i1)-t(1));	vave(1)=vint(1);else ind=find(tout<t(1)); if(~isempty(ind))		error('tout must be greater than t(1)');	end	vintout=pcint(t,vint,tout);	nt=length(t);	tnew=[t(:);tout(:)];	vnew=[vint(:);vintout(:)];	[tnew,it]=sort(tnew);	vnew=vnew(it);	nt2=length(tnew);	dt=diff(tnew);	vave=zeros(size(vnew));	i1=2:nt2;	vave(i1)=cumsum(dt.*vnew(i1-1));	vave(i1)=vave(i1)./(tnew(i1)-tnew(1));	ind=find(tnew==t(1));	vave(ind)=vint(1)*ones(size(ind));	vave(it)=vave;	vave=vave(nt+1:length(vave));end
