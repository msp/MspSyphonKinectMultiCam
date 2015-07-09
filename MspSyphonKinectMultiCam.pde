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
SyphonServer server3;

SimpleOpenNI  cam1;

PGraphics VDMXCanvas;
PGraphics VDMXCanvas3;

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
  VDMXCanvas3  = createGraphics(kinectWidth, kinectHeight, P3D);

  SimpleOpenNI.start();  
  printAndValidateNumberOfKinects();
  
  initialiseKinects();  
  initialiseSyphonServers(); 
}

void draw() {
  background(0);
  SimpleOpenNI.updateAll();
  
  detectAndColourUsers(cam1, VDMXCanvas, grey);
  
  drawRGBImage(cam1, VDMXCanvas3);
  
  server.sendImage(VDMXCanvas);
  server3.sendImage(VDMXCanvas3);
  
  image(VDMXCanvas,0, 0);
  image(cam1.rgbImage(), 0, kinectHeight + padding);  
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

void drawRGBImage(SimpleOpenNI cam, PGraphics canvas) {
  canvas.beginDraw();
//  canvas.background(127, 127, 127);
//  canvas.lights();
  canvas.image(cam.rgbImage(), 0, 0);
//  canvas.translate(width/2, height/2);
//  canvas.rotateX(frameCount * 0.01);
//  canvas.rotateY(frameCount * 0.01);  
//  canvas.box(150);
  canvas.endDraw();  
}
void printAndValidateNumberOfKinects() { 
  StrVector kinectList = new StrVector();
  SimpleOpenNI.deviceNames(kinectList);
  for(int i=0;i<kinectList.size();i++)
    println(i + ":" + kinectList.get(i));
   
  // check if there are enough cams  
  if(kinectList.size() < 1) {
    println("only works with 1 cam(s)");
    exit();
    return;
  }  
}

void initialiseKinects() {
  cam1 = new SimpleOpenNI(0,this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);

  if(cam1.isInit() == false) {
     println("Verify that you have two connected cameras on two different usb-busses!"); 
     exit();
     return;  
  }
  
  // set the camera generators
  // enable depthMap generation 
  cam1.enableDepth();
  cam1.enableUser();
  cam1.enableRGB();
}

void initialiseSyphonServers() {
  // Create syhpon server to send frames out.
  server  = new SyphonServer(this, "Processing Syphon - Kinect 1 Depth Cam ");
  server3 = new SyphonServer(this, "Processing Syphon - Kinect 1 RGB Cam");
}
