function [fid,line_name,nsamp,dt,ntr,nrec]=segyin_open(filename)

% [fid,line_name,nsamp,dt,ntr,nrec]=segyin_open(filename)
%
% SEGYIN opens a disk file and reads the SEGY master header.
% This is in preparation for SEGYIN to be called once per trace
% to read in the traces.
%
% filename ... full file name of the file to be opened
% 
% fid ... file id of opened file
% line_name ... name of the line
% nsamp ... number of samples per trace
% dt ... sample rate in seconds
% ntr ... total number of traces in any gather
% nrec ... number of gathers in segy dataset
% dt ... time sample rate in seconds
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
% ENR, May 2017: changed 'char' to 'schar' such that file gives consistent
% output with different Operation Systems.

% open the file
fid=fopen(filename,'r');

if( fid== -1)
	error('Unable to open file');
	return;
end

%read reel id header 1
reel_id_header1=fread(fid,3200,'schar');
ind=find(reel_id_header1~=32);

for abc=1:max(ind)
	if reel_id_header1(abc) < 0
		reel_id_header1(abc)=0;
	end
end
line_name=setstr(reel_id_header1(1:max(ind)))';

disp('1st reel header read');
   
%read reel header 2
stuff=fread(fid,3,'int');
jobid=stuff(1); reelid=stuff(3); lineid=stuff(2);
stuff=fread(fid,7,'short');
ntr=stuff(1); nauxtr=stuff(2); dt=stuff(3)/1000000.; dtfield=stuff(4);
nsamp=stuff(5); nsampfield=stuff(6); datafmt=stuff(7);
stuff=fread(fid,374,'schar');
nrec=[]; 
disp('2nd reel header read');
