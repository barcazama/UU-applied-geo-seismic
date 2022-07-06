/*
  GETHICON - Get a icon handle (HICON) of a windows or of a .exe, .dll or .ico file.
    hicon = gethicon( hwnd, [(small=0)|big=1])
    hicon = gethicon( '<Filename>', number_of_icon_in_file)

  Compiled with MEX :
    mex gethicon.c user32.lib shell32.lib

  Based on code by Jérôme Lacaille @ Miriad Technologies (october 2002)
  http://lacaille.jerome.online.fr
  mailto:lacaille.jerome@online.fr
*/


#include "windows.h"
#include <math.h>
#include "mex.h"


extern void _main();

/*****************************************************************************
 * The cppmex entry point.
 *****************************************************************************/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if ((nrhs == 1) || (nrhs == 2))  {
        if (mxIsChar(prhs[0])) {
            char filename[_MAX_PATH] ;
        	int num = 0 ;
        	HICON hicon;
        	mxGetString(prhs[0], filename, _MAX_PATH-1);


        	if ((nrhs==2) && mxIsNumeric(prhs[1])) {
        	  num = (int) mxGetScalar(prhs[1]);
            }

        	hicon = ExtractIcon(GetModuleHandle(NULL),filename,num) ;
            if (hicon == 0) {
              mexErrMsgTxt("gethicon -- unable to load icon file");
            }

        	plhs[0] = mxCreateNumericMatrix(1,1,mxUINT32_CLASS,0);
            *((unsigned long *) mxGetData(plhs[0])) = (unsigned long) hicon;
            return ;
        }

        if (mxIsNumeric(prhs[0])) {
            HWND hwnd;
            HICON hicon;
            bool bigIcon = false ;
            unsigned long adr;
            if ((nrhs==2) && mxIsNumeric(prhs[1]) && mxGetScalar(prhs[1]) >= 1) {
                bigIcon = true ;
            }

            adr = *((unsigned long *) mxGetData(plhs[0]));
            hwnd = (HWND) adr;

            hicon = (HICON) SendMessage(hwnd, WM_GETICON, bigIcon, 0);
            plhs[0] = mxCreateNumericMatrix(1,1,mxUINT32_CLASS,0);
            *((unsigned long *) mxGetData(plhs[0])) = (unsigned long) hicon;
            return ;
        }
    }

    // We don't get the good arguments.
    mexErrMsgTxt("Usage:\n\thicon = gethicon( hwnd, [(small=0)|big=1)]\n\thicon = gethicon( '<iconfile>', [num=0])") ;
}

