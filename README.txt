Copyright (c) 2012, Wouter Verweirder
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



This AIR Native Extension exposes HAAR cascade executions with OpenCV to Adobe AIR. It's implemented as an asynchronous library and uses a separate thread for the OpenCV execution. This way your AIR application doesn't lock up during the image processing.

First of all, you’ll create an instance of the extension, add a detection listener and load a haar cascade xml file:

///
openCV = new OpenCV();
openCV.addEventListener(DetectionEvent.DETECTION_UPDATE, detectionUpdateHandler);
openCV.loadCascade("/Users/wouter/haarcascades/haarcascade_frontalface_alt2.xml");
///

You will also need to send bitmap data to the extension. In this example, I’m sending a bitmap snapshot of the webcam image to the extension, using the updateImage method. You can also set minimum & maximum sizes for the detection area’s, so area’s smaller then the mnimum size of larger then the maximum size are ignored. I recommend supplying a minimum size for the detection (for example: face must be at least 40×40 pixels), as this will improve performance of the application:

///
bmpData.draw(video);
openCV.updateImage(bmpData, minSize, maxSize);
///

In the event handler, you’ll get the detected area’s with the event object that is provided:

///
protected function detectionUpdateHandler(event:DetectionEvent):void
{
	for each(var r:Rectangle in event.rectangles)
	{
		//draw rectangles here
	}
}
///