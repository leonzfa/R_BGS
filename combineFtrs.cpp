#include <iostream>
#include "mex.h"
#include "float.h"
#include <opencv2/opencv.hpp>
using namespace std;
using namespace cv;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *LUV,  *LUVLUV, *DD, *CE,*DE,*xyc,*xyd;

    LUV    = (double*) mxGetData(prhs[0]);
    LUVLUV = (double*) mxGetData(prhs[1]);
    DD     = (double*) mxGetData(prhs[2]);
    CE     = (double*) mxGetData(prhs[3]);
    DE     = (double*) mxGetData(prhs[4]);
    xyc     = (double*) mxGetData(prhs[5]);
    xyd     = (double*) mxGetData(prhs[6]);
    int height,width,ftrsNumC,ftrsNumD;
    height   = (int) mxGetM(prhs[4]);    
    width    = (int) mxGetN(prhs[4]);
    ftrsNumC = (int) mxGetM(prhs[5]);
    ftrsNumD = (int) mxGetM(prhs[6]);    
 
    plhs[0] = mxCreateDoubleMatrix(ftrsNumC, 9, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(ftrsNumD, 3, mxREAL);//
    
    double* outFtrsC    = (double*) mxGetPr(plhs[0]);
    double* outFtrsD    = (double*) mxGetPr(plhs[1]);
    
    int i,x,y;
    for(i=0;i<ftrsNumC;i++)
    {
        y = xyc[i]-1;x = xyc[ftrsNumC+i]-1;
        outFtrsC[ftrsNumC*0+i] = (double) LUV[height*width*0+x*height+y];
        outFtrsC[ftrsNumC*1+i] = (double) LUV[height*width*1+x*height+y];
        outFtrsC[ftrsNumC*2+i] = (double) LUV[height*width*2+x*height+y];
        outFtrsC[ftrsNumC*3+i] = (double) LUVLUV[height*width*0+x*height+y];
        outFtrsC[ftrsNumC*4+i] = (double) LUVLUV[height*width*1+x*height+y];
        outFtrsC[ftrsNumC*5+i] = (double) LUVLUV[height*width*2+x*height+y];
        outFtrsC[ftrsNumC*6+i] = (double) DD[x*height+y];
        outFtrsC[ftrsNumC*7+i] = (double) CE[x*height+y];
        outFtrsC[ftrsNumC*8+i] = (double) DE[x*height+y];        
    }
    for(i=0;i<ftrsNumD;i++)
    {
        y = xyd[i]-1;x = xyd[ftrsNumD+i]-1;
        outFtrsD[ftrsNumD*0+i] = (double) DD[x*height+y];
        outFtrsD[ftrsNumD*1+i] = (double) CE[x*height+y];
        outFtrsD[ftrsNumD*2+i] = (double) DE[x*height+y]; 
    }
 	return;
}