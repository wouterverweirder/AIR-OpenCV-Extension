//
//  OpenCVHandler.cpp
//  OpenCVExtension
//
//  Created by Wouter Verweirder on 24/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include "OpenCVHandler.h"

OpenCVHandler::OpenCVHandler(FREContext freContext)
{
    this->freContext = freContext;
    setDefaults();
}

OpenCVHandler::~OpenCVHandler(void)
{
    dispose();
}

void OpenCVHandler::setDefaults()
{
    isRunning = false;
    cascade = 0;
    iplImage = 0;
    numDetectedRectangles = 0;
}

void OpenCVHandler::cleanup()
{
    if(cascade != 0)
    {
        cvReleaseHaarClassifierCascade(&cascade);
    }
    if(iplImage != 0)
    {
        cvReleaseImage(&iplImage);
    }
    setDefaults();
}

void OpenCVHandler::start()
{
    FREDispatchStatusEventAsync(freContext, (const uint8_t *) "status", (const uint8_t *) "start");
    if(!isRunning)
    {
        isRunning = true;
        thread = boost::thread(&OpenCVHandler::run, this);
    }
}

void OpenCVHandler::stop()
{
    FREDispatchStatusEventAsync(freContext, (const uint8_t *) "status", (const uint8_t *) "stop");
    if(isRunning)
    {
        isRunning = false;
        thread.join();
        cleanup();
    }
}

void OpenCVHandler::run(OpenCVHandler *instance)
{
    while(instance->isRunning)
    {
        instance->processHandler();
    }
}

void OpenCVHandler::processHandler()
{
    updateImageMutex.lock();
    bool updated = false;
    if(iplImage != 0)
    {
        IplImage *image = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
        cvCvtColor(iplImage, image, CV_RGBA2BGR);
        updateImageMutex.unlock();
        
        if(cascade != 0)
        {
            CvMemStorage* storage = cvCreateMemStorage(0);
            IplImage* small_image = image;
            
            //scale down and blur for faster results
            int scale = 1;
            small_image = cvCreateImage( cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3 );
            cvPyrDown( image, small_image, CV_GAUSSIAN_5x5 );
            scale = 2;
            
            //do the haar detection
            cascadeMutex.lock();
            CvSeq* faces = cvHaarDetectObjects( small_image, cascade, storage, 1.2, 2, CV_HAAR_DO_CANNY_PRUNING, minSize, maxSize);
            cascadeMutex.unlock();
            
            detectionMutex.lock();
            memset(&detectedRectangles, 0, sizeof(detectedRectangles));
            numDetectedRectangles = 0;
            for( int i = 0; i < (faces ? faces->total : 0); i++ )
            {
                CvRect* r = (CvRect*)cvGetSeqElem( faces, i );
                detectedRectangles[i].x = r->x * scale;
                detectedRectangles[i].y = r->y * scale;
                detectedRectangles[i].width = r->width * scale;
                detectedRectangles[i].height = r->height * scale;
                numDetectedRectangles++;
            }
            detectionMutex.unlock();
            cvReleaseMemStorage( &storage );
            cvReleaseImage(&small_image);
            
            //dispatch event
            updated = true;
            FREDispatchStatusEventAsync(freContext, (const uint8_t *) "status", (const uint8_t *) "update");
        }
        //release memory
        cvReleaseImage(&image);
    }
    else
    {
        updateImageMutex.unlock();
    }
    if(!updated)
    {
        //sleep for a little while
        boost::posix_time::milliseconds workTime(100);
        boost::this_thread::sleep(workTime);
    }
}

FREObject OpenCVHandler::getDetectedRectangles()
{
    FREObject freResult, freRectangle;
    FRENewObject((const uint8_t*) "Vector.<flash.geom.Rectangle>", 0, NULL, &freResult, NULL);
    detectionMutex.lock();
    for( int i = 0; i < numDetectedRectangles; i++ )
    {
        // Create a new rectangle for drawing the face
        FREObject freX, freY, freWidth, freHeight;
        FRENewObjectFromInt32(detectedRectangles[i].x, &freX);
        FRENewObjectFromInt32(detectedRectangles[i].y, &freY);
        FRENewObjectFromInt32(detectedRectangles[i].width, &freWidth);
        FRENewObjectFromInt32(detectedRectangles[i].height, &freHeight);
        FREObject rectangleParams[] = {freX, freY, freWidth, freHeight};
        FRENewObject((const uint8_t *) "flash.geom.Rectangle", 4, rectangleParams, &freRectangle, NULL);
        FRESetArrayElementAt(freResult, i, freRectangle);
    }
    detectionMutex.unlock();
    return freResult;
}

void OpenCVHandler::loadCascade(const char* sCascadePath)
{
    cascadeMutex.lock();
    if(cascade != 0)
    {
        cvReleaseHaarClassifierCascade(&cascade);
        cascade = 0;
    }
    cascade = (CvHaarClassifierCascade*)cvLoad( (const char*) sCascadePath, 0, 0, 0 );
    cascadeMutex.unlock();
}

void OpenCVHandler::updateImage(FREObject argv[])
{
    updateImageMutex.lock();
    
    FREBitmapData freBitmapData;
    FREAcquireBitmapData(argv[0], &freBitmapData);
    uint32_t iWidth = freBitmapData.width;
    uint32_t iHeight = freBitmapData.height;
    //release old image
    if(iplImage != 0)
    {
        cvReleaseImage(&iplImage);
    }
    iplImage = cvCreateImage(cvSize(iWidth, iHeight), IPL_DEPTH_8U, 4);
    memcpy(iplImage->imageData, freBitmapData.bits32, iWidth * iHeight * 4);
    FREReleaseBitmapData(argv[0]);
    
    FREObject prop;
    CvSize minSize = cvSize(0, 0);
    CvSize maxSize = cvSize(0, 0);
    if(argv[1] != NULL)
    {
        FREGetObjectProperty(argv[1], (const uint8_t *) "x", &prop, NULL);
        FREGetObjectAsInt32(prop, &minSize.width);
        FREGetObjectProperty(argv[1], (const uint8_t *) "y", &prop, NULL);
        FREGetObjectAsInt32(prop, &minSize.height);
    }
    if(argv[2] != NULL)
    {
        FREGetObjectProperty(argv[2], (const uint8_t *) "x", &prop, NULL);
        FREGetObjectAsInt32(prop, &maxSize.width);
        FREGetObjectProperty(argv[2], (const uint8_t *) "y", &prop, NULL);
        FREGetObjectAsInt32(prop, &maxSize.height);
    }
    
    updateImageMutex.unlock();
}

void OpenCVHandler::dispose()
{
    stop();
}