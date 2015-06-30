/* --------------------------------------------------------------------------
 * SimpleOpenNI Multi Camera piped via Syphon servers so I can usein VDMX.
 * --------------------------------------------------------------------------
 * MSP HACKED FROM: Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * Be aware that you shouln't put the cameras at the same usb bus !!!!!!!!!!!!!!!!!
 * On linux/OSX  you can use the command 'lsusb' to see on which bus the camera is
 * ----------------------------------------------------------------------------
 */

import processing.opengl.*;
import SimpleOpenNI.*;
import codeanticode.syphon.*;

SyphonServer server;
SyphonServer server2;
SimpleOpenNI  cam1;
SimpleOpenNI  cam2;
PGraphics VDMXCanvas;
PGraphics VDMXCanvas2;

int kinectWidth  = 640;
int kinectHeight = 480;
int padding      = 10;

int[] userMap;

color grey       = color(160, 160, 160);
color lightBlue  = color(204, 255, 255);
color green      = color(0, 255, 0);
color black      = color(0, 0, 0);

void setup() {
  size(kinectWidth * 2 + padding, kinectHeight * 2 + padding, P3D);
  VDMXCanvas   = createGraphics(kinectWidth, kinectHeight, P3D);
  VDMXCanvas2  = createGraphics(kinectWidth, kinectHeight, P3D);  

  SimpleOpenNI.start();  
  printAndValidateNumberOfKinects();
  
  initialiseKinects();  
  initialiseSyphonServers(); 
}

void draw() {
  background(0);
  SimpleOpenNI.updateAll();
  
  detectAndColourUsers(cam1, VDMXCanvas, grey);
  detectAndColourUsers(cam2, VDMXCanvas2, green);
  
  server.sendImage(VDMXCanvas);
  server2.sendImage(VDMXCanvas2);
  
  image(VDMXCanvas,0, 0);
  image(cam1.depthImage(), 0, kinectHeight + padding);
  
  image(VDMXCanvas2, kinectWidth + padding, 0);
  image(cam2.depthImage(), kinectWidth + padding, kinectHeight + padding);  
}

void detectAndColourUsers(SimpleOpenNI cam, PGraphics canvas, color userColor) {
  int[] userList = cam.getUsers();  
  println("users: "+userList.length);
  
  for(int i=0;i<userList.length;i++) {
    canvas.loadPixels();
    
    userMap = cam.userMap();    
    // println("userMap: "+userMap.length);
    
    for (int j = 0; j < userMap.length; j++) {
      // if the current pixel is on a user
      if (userMap[j] != 0) {
        // colour the user        
        canvas.pixels[j] = userColor;        
      } else {
        canvas.pixels[j] = black;
      }
      
      // display the changed pixel array
      canvas.updatePixels();        
    }    
  }
}

void printAndValidateNumberOfKinects() { 
  StrVector kinectList = new StrVector();
  SimpleOpenNI.deviceNames(kinectList);
  for(int i=0;i<kinectList.size();i++)
    println(i + ":" + kinectList.get(i));
   
  // check if there are enough cams  
  if(kinectList.size() < 2) {
    println("only works with 2 cams");
    exit();
    return;
  }  
}

void initialiseKinects() {
  cam1 = new SimpleOpenNI(0,this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  cam2 = new SimpleOpenNI(1,this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);

  if(cam1.isInit() == false || cam2.isInit() == false) {
     println("Verify that you have two connected cameras on two different usb-busses!"); 
     exit();
     return;  
  }
  
  // set the camera generators
  // enable depthMap generation 
  cam1.enableDepth();
  cam1.enableUser();
  cam1.enableRGB();
 
  // enable depthMap generation 
  cam2.enableDepth();
  cam2.enableUser();
  cam2.enableRGB();  
}

void initialiseSyphonServers() {
  // Create syhpon server to send frames out.
  server  = new SyphonServer(this, "Processing Syphon - Kinect 1 Depth Cam ");
  server2 = new SyphonServer(this, "Processing Syphon - Kinect 2 Depth Cam");
}
