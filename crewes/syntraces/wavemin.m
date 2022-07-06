function [w,tw]=wavemin(dt,fdom,tlength,m)
% WAVEMIN: creates a minimum phase w for impulsive sources
%
% [w,tw]=wavemin(dt,fdom,tlength,m)
% [w,tw]=wavemin(dt,fdom,tlength)
% [w,tw]=wavemin(dt,fdom) 
% [w,tw]=wavemin(dt) 
% 
% WAVEMIN returns a minimum phase w which simulates a 
% possible noise free impulsive source. Function uses TNTAMP and 
% LEVREC
%
% dt= desired temporal sample rate (seconds)
% fdom= dominant frequency in Hz
%  ******** default: 15 Hz *******
% tlength= w length in seconds 
%  ******** default: 127*dt (ie a power of 2) *******
% m = exponent controlling spectral shape. See tntamp for a description
% ************ default 2 ************
% 
% The w is generated from an analog expression for a nice
% amplitude spectrum. The corresponding autocorrelogram is 
% computed and input into LEVREC. The final w is the
% frequency domain inverse of the output from LEVREC.
% 
% by G.F. Margrave, May 1991
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

 if(nargin<4) m=2; end
 if(nargin<3)
   tlength=127.*dt;
 end
 if(nargin<2)
   fdom=15.; 
 end
% create a time vector
  nt=round(2.*tlength/dt)+1;
  nt=2.^nextpow2(nt);
  tmax=dt*(nt-1);
  tw= 0.:dt:tmax;
% create a frequency vector
  fnyq=1./(2*(tw(2)-tw(1)));
  f=linspace(0.,fnyq,length(tw)/2+1);
% create the power spectrum
  tmp=tntamp(fdom,f,m);
  %tmp=(tmp/max(tmp)).^4;
  powspec=tmp.^2;
% create the autocorrelation
  auto=ifftrl(powspec,f);
% run this through Levinson
  nlags=round(tlength/dt)+1;
  b=[1.0 zeros(1,nlags-1)]';
  winv=levrec(auto(1:nlags),b);
% invert the winv
  w=real(ifft(1. ./(fft(winv))));
  tw=(dt*(0:length(w)-1))'; 
% now normalize the w
  w=wavenorm(w,tw,2);
