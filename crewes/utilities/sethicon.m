%  SETHICON - Set a new icon for the windows specified by it's handle (HWND).
%  The icon is given by the HICON handle obtainedwith GETHICON.
%    hicon = sethicon( hwnd, hicon, [(small=0)|big=1|all=2])
%
%  Compiled with CPPMEX :
%    cppmex sethicon user32.lib
%
%  Example:
%   hfig = figure('name','Unique Figure Name');
%   hwnd = gethwnd('Unique Figure Name');
%   hicon = gethicon('C:\Foo\bar\baz.ico',0);
%   sethicon(hwnd, hicon, 2);
%
