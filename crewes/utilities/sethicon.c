/*
  SETHICON - Set a new icon for the windows specified by it's handle (HWND).
  The icon is given by the HICON handle obtainedwith GETHICON.
    hicon = sethicon( hwnd, hicon, [(small=0)|big=1|all=2])

  Compiled with MEX :
    mex sethicon.c user32.lib shell32.lib

  Based on code by Jérôme Lacaille @ Miriad Technologies (october 2002)
  http://lacaille.jerome.online.fr
  mailto:lacaille.jerome@online.fr
*/


#include "windows.h"
#include <math.h>
#include "mex.h"

/*****************************************************************************
 * The cppmex entry point.
 *****************************************************************************/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  HWND hwnd;
  HICON hicon,hicon1=0,hicon2=0;
  unsigned long adr;
  int num;


  if (nrhs < 2) {
    mexErrMsgTxt("sethicon -- need two arguments") ;
  }
  if (!mxIsNumeric(prhs[0])) {
    mexErrMsgTxt("sethicon -- argument 1 must be numeric");
  }
  if (!mxIsNumeric(prhs[1])) {
    mexErrMsgTxt("sethicon -- argument 2 must be numeric");
  }

  if (mxGetClassID(prhs[0]) != mxUINT32_CLASS) {
    mexErrMsgTxt("sethicon -- first argument must be window handle returned by gethwnd function");
  }

  if (mxGetClassID(prhs[1]) != mxUINT32_CLASS) {
    mexErrMsgTxt("sethicon -- second argument must be icon handle returned from gethicon function");
  }


  num = 0 ;
  if ((nrhs==3) && mxIsNumeric(prhs[2])) {
    num = (int) (mxGetScalar(prhs[2]) + .5); /* round */
  }

  adr = *((unsigned long *) mxGetData(prhs[0]));
  if (adr == 0) {
    mexErrMsgTxt("sethicon -- Invalid window handle supplied as argument 1");
  }

  hwnd = (HWND) adr ;

  adr = *((unsigned long *) mxGetData(prhs[1]));
  hicon = (HICON) adr ;
  if (adr == 0) {
    mexErrMsgTxt("sethicon -- Invalid icon handle supplied as argument 2");
  }

  if ((num==1) || (num==2)) {
    hicon1 = (HICON) SendMessage(hwnd, WM_SETICON, true, (LPARAM)hicon) ;
  }
  if ((num==0) || (num==2)) {
    hicon2 = (HICON) SendMessage(hwnd, WM_SETICON, false, (LPARAM)hicon) ;
  }
  plhs[0] = mxCreateNumericMatrix(1,1,mxUINT32_CLASS,0);
  *((unsigned long *) mxGetData(plhs[0])) = (unsigned long) hicon1;
  if (!hicon1) {
    *((unsigned long *) mxGetData(plhs[0])) = (unsigned long) hicon2;
  }
}

