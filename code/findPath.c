/*
 * findPath.c
 *
 * Finds the maximum-scoring path through a matrix via dynamic programming.
 * The calling syntax is:
 *
 *		[xs,ys] = findPath(score, breathingWeight, slopeWeight, searchDistance);
 *
 * This is a MEX-file for MATLAB.
*/

#include "mex.h"
#include <math.h>
#include <stdint.h>

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))
#define MAX(X, Y) (((X) > (Y)) ? (X) : (Y))
#define SQUARE(X) ((X) * (X))

// using zero indexing
#define C2I(X,Y) ((Y) + imageHeight*(X))
#define I2X(IND) ((IND)/imageHeight)
#define I2Y(IND) ((IND)%imageHeight)

// [xs,ys] = bestPath(score, breathingWeight, slopeWeight, searchDistance);

int findMaxPosition(double *array, int length);

/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* variable declarations here */   
    double breathingWeight;
    double slopeWeight;
    int searchDistance; // distance to search up or down

    double *scoreMatrix; // score matrix
    int imageHeight; // height of image
    int imageWidth; // width of image
    
    double *outXs; // output Xs
    double *outYs; // output Ys
    
    /* code here */
    if(nrhs!=4) {
        mexErrMsgIdAndTxt("FigureSeer:findPath:nrhs",
                          "Four inputs required.");
    }

    if(nlhs!=2) {
        mexErrMsgIdAndTxt("FigureSeer:findPath:nlhs",
                          "Two outputs required.");
    }
    
    /* make sure score is doule matrix */
    if( !mxIsDouble(prhs[0]) || 
        mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("FigureSeer:findPath:notDouble",
            "Input score must be type double.");
    }
    scoreMatrix = mxGetPr(prhs[0]);
    
    /* make sure the weights are scalar */
    if( !mxIsDouble(prhs[1]) || 
         mxIsComplex(prhs[1]) ||
         mxGetNumberOfElements(prhs[1])!=1 ) {
        mexErrMsgIdAndTxt("FigureSeer:findPath:notScalar",
                          "Input breathingWeight must be a scalar.");
    }
    breathingWeight = mxGetScalar(prhs[1]);
    if( !mxIsDouble(prhs[2]) || 
         mxIsComplex(prhs[2]) ||
         mxGetNumberOfElements(prhs[2])!=1 ) {
        mexErrMsgIdAndTxt("FigureSeer:findPath:notScalar",
                          "Input slopeWeight must be a scalar.");
    }
    slopeWeight = mxGetScalar(prhs[2]);
    if( !mxIsDouble(prhs[3]) || 
         mxIsComplex(prhs[3]) ||
         mxGetNumberOfElements(prhs[3])!=1 ) {
        mexErrMsgIdAndTxt("FigureSeer:findPath:notScalar",
                          "Input searchDistance must be a scalar.");
    }
    searchDistance = round(mxGetScalar(prhs[3]));
    
    imageHeight = mxGetM(prhs[0]);
    imageWidth = mxGetN(prhs[0]);
    
    if(imageHeight == 0 || imageWidth == 0){
        mexErrMsgIdAndTxt("FigureSeer:findPath:notScalar",
                          "Empty image.");
    }
    
    double *pathScore = mxCalloc(imageWidth*imageHeight, sizeof(double));
    int i;
    for(i=0; i<imageWidth*imageHeight; i++){
        pathScore[i] = scoreMatrix[i] + breathingWeight;
    }
    mexEvalString("drawnow"); // Allow interruption
    
    int *prevNode = mxCalloc(imageWidth*imageHeight, sizeof(int));
    for(i=0; i<imageWidth*imageHeight; i++){
        prevNode[i] = -1; // -1 means source
    }
    mexEvalString("drawnow");
    
    for(int x=1; x<imageWidth; x++){
        for(int y=0; y<imageHeight; y++){
            int bestPrevY = -1;
            double bestScore = 0;
            for(int prevY=MAX(0,y-searchDistance); prevY<=MIN(imageHeight-1,y+searchDistance); prevY++){
                double currentSlopeFeature = SQUARE(y-prevY)*slopeWeight;
                double score = pathScore[C2I(x-1,prevY)] + currentSlopeFeature;
                if (score > bestScore){
                    bestPrevY = C2I(x-1,prevY);
                    bestScore = score;
                }
            }
            pathScore[C2I(x,y)] += bestScore;
            prevNode[C2I(x,y)] = bestPrevY;
        }
    }
    mexEvalString("drawnow");
    
    int endNode = findMaxPosition(pathScore,imageWidth*imageHeight);
    int path[imageWidth];
    int pathLength = 0;
    int currentNode = endNode;
    
    // Find path by backtracking
    do{
        path[pathLength] = currentNode;
        pathLength++;
        if(currentNode < 0 || currentNode > imageWidth*imageHeight){
            mexPrintf("ERROR: %d\n",currentNode);
            return;
        }
        currentNode = prevNode[currentNode];
    } while(currentNode != -1);
    
    // Convert path to (x,y) coordinates
    plhs[0] = mxCreateDoubleMatrix(1,pathLength,mxREAL);
    outXs = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(1,pathLength,mxREAL); 
    outYs = mxGetPr(plhs[1]);
    
    for(int i=0; i<pathLength; i++){
        outXs[pathLength-i-1] = I2X(path[i]);
        outYs[pathLength-i-1] = I2Y(path[i]);
    }
    
    mxFree(pathScore);
    mxFree(prevNode);
}
       
/* Find the index of the largest element in a double array "array" 
 * of length "length"
 */
int findMaxPosition(double *array, int length)
{
    int maxPosition = -1;
    double max = -INFINITY;
    for(int i=0; i<length; i++){
        if (array[i] > max){
            max = array[i];
            maxPosition = i;
        }
    }
    return maxPosition;
}