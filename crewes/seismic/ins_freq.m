function ifreq = ins_freq(s,t,n)
% INS_FREQ Compute the instantaneous frequency useing complex trace theory
%
% ifreq=INS_FREQ(s,t)
%
% s ... real seismic trace (or matrix)
% t ... time coordinate vector for s (or time sample interval)
% n ... length of a boxcar smoother (in samples) to be convolved with the result
%  ************* default n=1 **********
% ifreq ... instantaneous frequency of the complex trace corresponding to s
%
% G.F. Margrave, CREWES, 2000
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

if(nargin<3) n=1; end

iph=ins_phase(s);
ifreq=zeros(size(iph));
ntr=size(iph,2);
if(length(t)>1)
	dt=t(2)-t(1);
else
	dt=t;
end
if(n==1)
   for k=1:ntr
	   ifreq(:,k)=gradient(unwrap(iph(:,k)),dt);
   end
else
   for k=1:ntr
	   ifreq(:,k)=convz(gradient(unwrap(iph(:,k)),dt),ones(n,1))/n;
   end
end
