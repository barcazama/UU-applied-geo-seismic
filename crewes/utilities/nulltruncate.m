function trimmed=nulltruncate(arraywithnulls)
% 
% NULLTRUNCATE
% 
% trimmed = nulltruncate(arraywithnulls);
%
% This function takes an array, and chops it off at the first occurence of
% a NULL (integer 0). It does NOT call DEBLANK or STRUNPAD.
%
% Chad Hogan, 2004.

% $Id: nulltruncate.m,v 1.3 2004/07/30 21:24:34 kwhall Exp $

nullindex = find(~arraywithnulls);
index = nullindex(1);
trimmed = arraywithnulls(1:index - 1);
