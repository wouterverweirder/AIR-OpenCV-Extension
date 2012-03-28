// ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
// NOTICE: Adobe permits you to use, modify, and distribute this file in accordance with the
// terms of the Adobe license agreement accompanying it.  If you have received this file from a
// source other than Adobe, then your use, modification, or distribution of it requires the prior
// written permission of Adobe.

#include <stdlib.h>
#include <stdio.h>

#include "OpenCVExtension.h"
#include "OpenCVHandler.h"
#include <opencv/cv.h>
#include <opencv2/opencv.hpp>

// Symbols tagged with EXPORT are externally visible.
// Must use the -fvisibility=hidden gcc option.
#define EXPORT __attribute__((visibility("default")))

extern "C"
{
    FREObject OpenCV_loadCascade(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        OpenCVHandler *openCVHandler;
        FREGetContextNativeData(ctx, (void**)&openCVHandler);
        
        uint32_t iCascadePathLength;
        const uint8_t *sCascadePath;
        FREGetObjectAsUTF8(argv[0], &iCascadePathLength, &sCascadePath);
        
        openCVHandler->loadCascade((const char*) sCascadePath);
        
        return NULL;
    }
    
    FREObject OpenCV_updateImage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        OpenCVHandler *openCVHandler;
        FREGetContextNativeData(ctx, (void**)&openCVHandler);
        
        openCVHandler->updateImage(argv);
        
        return NULL;
    }
    
    FREObject OpenCV_getDetectedRectangles(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        OpenCVHandler *openCVHandler;
        FREGetContextNativeData(ctx, (void**)&openCVHandler);
        return openCVHandler->getDetectedRectangles();
    }
    
    FREObject OpenCV_dispose(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        OpenCVHandler *openCVHandler;
        FREGetContextNativeData(ctx, (void**)&openCVHandler);
        openCVHandler->dispose();
        return NULL;
    }
    
    FRENamedFunction _functionMap[] = {
		{ (const uint8_t*) "loadCascade", 0, OpenCV_loadCascade},
		{ (const uint8_t*) "updateImage", 0, OpenCV_updateImage},
        { (const uint8_t*) "getDetectedRectangles", 0, OpenCV_getDetectedRectangles},
        { (const uint8_t*) "dispose", 0, OpenCV_dispose}
    };
    
    void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
    {
        *numFunctions = sizeof( _functionMap ) / sizeof( FRENamedFunction );
        *functions = _functionMap;
        
        OpenCVHandler *openCVHandler = new OpenCVHandler(ctx);
        FRESetContextNativeData(ctx, (void *)openCVHandler);
        openCVHandler->start();
	}
    
	void contextFinalizer(FREContext ctx)
    {
        OpenCVHandler *openCVHandler;
        FREGetContextNativeData(ctx, (void**)&openCVHandler);
        openCVHandler->dispose();
		return;
	}
    
    EXPORT
	void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
    {
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}
    
    EXPORT
	void finalizer(void* extData)
    {
		return;
	}
}