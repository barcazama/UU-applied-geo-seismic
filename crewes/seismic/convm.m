function s = convm(r,w)
% CONVM: convolution followed by truncation for min phase filters
%
% s= convm(r,w)
%
% convm is a modification of the 'conv' routine from the MATLAB
% toolbox. The changes make it more convenient for seismic purposes
% in that the output vector, s, has a length equal to the first
% input vector,  r. Thus, 'r' might correspond to a reflectivity
% estimate to be convolved with a wavelet contained in 'w' to
% produce a synthetic seismic response 's'. It is assumed that
% the wavelet in w is causal and that the first sample occurs at time zero.
% For non-causal wavelets, use 'convz'. An abort will occur if
% w is longer than r. CONVM will correctly handle an ensemble matrix.
%
%
% modified to 'convm' by G.F. Margrave, May 1991
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

% 
%convert to column vectors
[a,b]=size(r);
if(a==1) r=r.'; end
w=w(:);
[nsamps,ntr]=size(r);
if(length(w)>nsamps) error('second argument must be shorter than first'); end

temp=conv(r,w);
s=temp(1:nsamps,1:ntr);

if(a==1)
	s=s.';
end
