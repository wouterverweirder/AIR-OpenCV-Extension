//
//  OpenCVHandler.h
//  OpenCVExtension
//
//  Created by Wouter Verweirder on 24/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef OpenCVExtension_OpenCVHandler_h
#define OpenCVExtension_OpenCVHandler_h

#include <Adobe AIR/Adobe AIR.h>
#include <boost/thread.hpp>
#include <boost/date_time.hpp>  
#include <opencv/cv.h>
#include <opencv2/opencv.hpp>

struct DetectedRectangle
{
    int             x;
    int             y;
    int             width;
    int             height;
};

class OpenCVHandler
{
private:
    static void     run(OpenCVHandler *instance);
public:
    OpenCVHandler(FREContext freContext);
    ~OpenCVHandler(void);
    
    void            start();
    void            stop();
    
    void            dispose();
    
    void            loadCascade(const char* sCascadePath);
    void            updateImage(FREObject argv[]);
    FREObject       getDetectedRectangles();
    
private:
    
    FREContext      freContext;
    
    bool            isRunning;
    boost::thread   thread;
    boost::mutex    updateImageMutex;
    boost::mutex    detectionMutex;
    boost::mutex    cascadeMutex;
    
    CvHaarClassifierCascade* cascade;
    IplImage*       iplImage;
    
    CvSize          minSize;
    CvSize          maxSize;
    
    int             numDetectedRectangles;
    DetectedRectangle detectedRectangles[10];
    
    void            setDefaults();
    void            cleanup();
    void            processHandler();
    
};

#endif
