#include <Adobe AIR/Adobe AIR.h>

extern "C"
{
    void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
    void contextFinalizer(FREContext ctx);
    
    void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	void finalizer(void* extData);
    
    FREObject OpenCV_loadCascade(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    FREObject OpenCV_updateImage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    FREObject OpenCV_getDetectedRectangles(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
    FREObject OpenCV_dispose(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
}