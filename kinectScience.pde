import org.openkinect.processing.*;
import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;
import ddf.minim.*;

int takemin = 10;
int takemax = 15;
int freezemin = 10;
int freezemax = 15;


Minim minim;
AudioPlayer player; 

SyphonServer server;
Kinect2 kinect2;

PImage img, dImg;

OscP5 oscP5;
NetAddress myRemoteLocation;

boolean photoFlag;
int waitSec;


void settings() {
  size(512, 424, P3D);
  PJOGL.profile=1;
  minim = new Minim(this);
  player = minim.loadFile("camera.mp3");  //groove.mp3をロードする
}

void setup() {
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  //kinect2.initVideo();
  //kinect2.initIR();
  kinect2.initRegistered();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  dImg = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  server = new SyphonServer(this, "Processing Syphon");
  oscP5 = new OscP5(this, 9200);
  myRemoteLocation = new NetAddress("127.0.0.1",9200);
  photoFlag = true;
  waitSec = 0;
  player.play();
}

void draw(){
  img.loadPixels();
  dImg = kinect2.getRegisteredImage();
  int[] depth = kinect2.getRawDepth();
  
  int record = img.height;
  int rx = 0;
  int ry = 0;
  
  //int sumX = 0;
  //int sumY = 0;
  //int totalPixels = 1;
  
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];

      if (d > 3350 && d <3550 && y > 170 && y < 300 && x > 170 && x < 350) {
        img.pixels[y*img.width + img.width-x-1] = color(255, 0, 150);

        //sumX += x;
        //sumY += y;
        //totalPixels++;

        if (y < record) {
          record = y;
          rx = x;
          ry = y;
        }
      } else {
        img.pixels[y*img.width + img.width-x-1] = dImg.pixels[offset];
      }
    }
  }
  img.updatePixels();
  image(img, 0, 0);
  //if(rx > 0&& ry > 0 && rx < 450){
  //  fill(255);
  //  ellipse(rx, ry, 25, 25);
  //}
  
  
  if(photoFlag == true){
    int wait = int(random(takemin, takemax));
    waitSec = ( wait + second())% 60;
    println(wait);
    photoFlag = false;
  }
  
  if(waitSec == second()){
    takePhoto();
  }
  
  //if(rx > 0 && ry > 0){
  //OscMessage msgx = new OscMessage("/position/x");
  //msgx.add(rx); //X座標の位置を追加

  //OscMessage msgy = new OscMessage("/position/y");
  //msgy.add(ry); //Y座標の位置を追加

  ////OSCメッセージ送信
  //oscP5.send(msgx, myRemoteLocation);
  //oscP5.send(msgy, myRemoteLocation);
  //}
  
  
  server.sendScreen();
 
}

void takePhoto(){
  player.pause();
  PImage saveImage = get(0, 0, img.width, img.height);
  saveImage.save(day()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  int wait = int(random(freezemin,freezemax)*1000);
  println(wait/1000);
  delay(wait);
  photoFlag = true; 
  player.play(0);
}

void keyPressed(){
  if(key == ' ' ){
    takePhoto();
  }
}


void stop()
{
  player.close(); 
  minim.stop();
  super.stop();
}