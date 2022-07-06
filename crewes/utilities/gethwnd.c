/*
  GETHWND - Get the Windows handle (HWND) of a windows.
    hwnd = gethwnd('<Begining of name of a window>')

  Compiled with MEX :
    mex gethwnd.c user32.lib shell32.lib

  Based on code by Jérôme Lacaille @ Miriad Technologies (october 2002)
  http://lacaille.jerome.online.fr
  mailto:lacaille.jerome@online.fr
*/


#include "windows.h"
#include <math.h>
#include "mex.h"

static char name[256] ;
static unsigned long adr = 0 ;

/*****************************************************************************
 * A callback called for each open windows (visible or not).
 *****************************************************************************/
BOOL CALLBACK ForEachWindow( HWND hwnd, LPARAM lParam)
{
  char windName[256];

  GetWindowText(hwnd, windName, sizeof(windName));

  if (!adr && (strlen(name)<=strlen(windName)) && !strncmp(name,windName,strlen(name)))
    {
      void *ptr = hwnd ;
      adr = (unsigned long) ptr ;
      return FALSE ; // Fini.
    }
  return TRUE ; // Encore.
}
 

/*****************************************************************************
 * The mex entry point.
 *****************************************************************************/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if ((nrhs != 1)  || !mxIsChar(prhs[0])) {
    mexErrMsgTxt("gethwnd -- supply window name as argument 1.") ;
  }

  adr = 0 ;

  mxGetString(prhs[0], name, sizeof(name));
  if (name[0]) {
      EnumWindows(ForEachWindow, (LPARAM) 0) ;
  }

  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, 0);
  *((unsigned int *) mxGetData(plhs[0])) = adr;
}

