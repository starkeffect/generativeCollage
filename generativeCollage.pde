// list of issues/features:
// 1 - performance issues with cicular segmentation
// 2 - limiting image sizes to a rectangular grid
// 2 - saving frames without interface
// 3 - extra shapes
// 4 - blend + glitch effects
// 5 - saving frames on a separate thread
// 6 - switching segmentation schemes from the interface

import controlP5.*;
ControlP5 cp5;

import themidibus.*;
MidiBus busA; // Midi bus 1
//MidiBus busB; // Midi bus 2


ArrayList<PImage> imageSet;
ArrayList<PImage> frames;
int slider_1, slider_2, slider_3, slider_4; 
float pos_x, pos_y;
float size_x, size_y;
float grid_nx, grid_ny;
float frequency, max_resize_ratio, rotation;
int transmitChannel;
Note note;


void setup() 
{
  // initializing the canvas interface
  //size(1024, 768, P2D);
  noStroke();
  fullScreen(P2D);
  cp5 = new ControlP5(this);
  
  // initializing the image database
  imageSet = new ArrayList<PImage>();
  
  // initializing the frames dump
  frames = new ArrayList<PImage>();
  
  // loading images from the data folder
  loadImageSet();

  // adding sliders to the interface
  cp5.addSlider("grid_nx")
     .setRange(1,10)
     .setValue(3)
     .setPosition(20,20)
     .setSize(200,20);
     
  cp5.addSlider("grid_ny")
     .setRange(1,10)
     .setValue(2)
     .setPosition(20,50)
     .setSize(200,20);
     
   cp5.addSlider("frequency")
     .setRange(0,1)
     .setValue(0.03)
     .setPosition(20,80)
     .setSize(200,20);
     
   cp5.addSlider("rotation")
     .setRange(0,PI/2)
     .setValue(0)
     .setPosition(20,110)
     .setSize(200,20);
     
  // setting background
  background(0,0,0);

  // setting up Midi output
  //MidiBus.list();
  //Create a first new MidiBus attached to the IncommingA Midi input device and the OutgoingA Midi output device. We will name it busA.
  busA = new MidiBus(this, -1, "toAbleton");
}

void draw() 
{
  //pushStyle();
  //fill(255, 5);
  //rect(0, 0, width, height);
  //popStyle();
  //if(random(1) < 0.001) background(slider_1, slider_2, slider_3);
  
  if(random(1) < 0.1) 
  {
    transmitChannel = 1;
    if(random(1) < 0.1) delay(500); 
    thread("sendMidiTrigger");
    background(0);
  }
  
  if(random(1) < frequency)
  {
    //send midi to ableton
    transmitChannel = 0;
    thread("sendMidiTrigger");
    
    int i = int(random(imageSet.size())); 
    // randomly choosing position on the canvas
    //pos_x = int(random(-width/4, width/4));
    //pos_y = int(random(-width/4, width/4));
    pos_x = int(int(random(0, grid_nx)) * width/grid_nx);
    pos_y = int(int(random(0, grid_ny)) * height/grid_ny);
 
    if(random(1) < 0.7) blendMode(REPLACE);
    else blendMode(SUBTRACT);
    //else if (random(1) < 0.8) blendMode(SUBTRACT);
    //else blendMode(DARKEST);
    
    imageMode(CENTER);   
    PImage img = imageSet.get(i);
    //float resizeRatio = random(0.2, max_resize_ratio);
    //int img_w = img.width; int img_h = img.height;
    //img.resize(int(img_w * resizeRatio), int(img_w * resizeRatio));
    displayRectSegment(img, pos_x, pos_y);
  }
  
  if(random(1) < 0.1) displayShape();
  
  //saveFrame("output/####.tif");
  //println(frameRate);
  //thread("saveFrames");
  
}

// function to save individual frames
void saveFrames()
{
  saveFrame("output/####.tif");
}

// function to load all images from the data folder
void loadImageSet()
{
  File dir; 
  File[] files;
  
  dir = new File(dataPath("bw"));
  files = dir.listFiles();
  
  println(dir.getAbsolutePath().toLowerCase());
  
  // loading images
  println("loading images ...");
  PImage img;
  float resizeRatio;
  for(int i=0; i <= files.length - 1; i++)
  {
    String path = files[i].getAbsolutePath();
    if (path.toLowerCase().endsWith(".jpg") || path.toLowerCase().endsWith(".png"))
    {
      println(path.toLowerCase());
      img = loadImage(path);
      resizeRatio = random(0.3, 0.7);
      img.resize(int(img.width * resizeRatio), int(img.height * resizeRatio));
      imageSet.add(img);
    }
  }
}

// function to extract and display a rectangular segment from the image
void displayRectSegment(PImage img, float pos_x, float pos_y)
{
  // computing texture coordinates
  float u1, u2, u3, u4;
  float v1, v2, v3, v4;
  float ratio_x = pos_x/width;
  float ratio_y = pos_y/height;
  
  
  size_x = img.width * (1 - ratio_x);
  size_x = random(size_x/2, size_x);
  size_y = img.height * (1 - ratio_y);
  size_y = random(size_y/2, size_y);
  
  u1 = ratio_x * img.width; v1 = ratio_y * img.height;
  u2 = u1 + size_x; v2 = v1;
  u3 = u1 + size_x; v3 = v1 + size_y;
  u4 = u1; v4 = v1 + size_y;
  
  pushMatrix();
  translate(width/2, height/2);
  if(random(1) < 0.8) rotate(-rotation);
  else rotate(rotation);
  translate(-width/2, -height/2);
  tint(255, random(150, 255));
  beginShape();
  texture(img);
  vertex(pos_x, pos_y, u1, v1);
  vertex(pos_x + size_x, pos_y, u2, v2);
  vertex(pos_x + size_x, pos_y + size_y, u3, v3);
  vertex(pos_x, pos_y + size_y, u4, v4);
  endShape(); 
  popMatrix();
}


void displayShape()
{
  float cell_size_x, cell_size_y;
  float pos_x1, pos_x2, pos_y1, pos_y2;
  
  cell_size_x = width/grid_nx;
  cell_size_y = height/grid_ny;

  pos_x1 = int(int(random(0, grid_nx)) * cell_size_x) + random(cell_size_x);
  pos_y1 = int(int(random(0, grid_ny)) * cell_size_y) + random(cell_size_y);
  
  pos_x2 = int(int(random(0, grid_nx)) * cell_size_x) + random(cell_size_x);
  pos_y2 = int(int(random(0, grid_ny)) * cell_size_y) + random(cell_size_y);
  
  pushMatrix();
  translate(width/2, height/2);
  rotate(rotation);
  pushStyle();
  strokeCap(SQUARE);
  strokeWeight(random(35));
  if(random(1) > 0.5) stroke(255);
  else stroke(0);
  line(pos_x1, pos_y1, pos_x1 + random(cell_size_x * 2), pos_y1);
  line(pos_x2, pos_y2, pos_x2, pos_y2 + random(cell_size_y * 2));
  popStyle();
  popMatrix();
}


void sendMidiTrigger()
{
  note = new Note(transmitChannel, int(random(50, 70)), 127);
  busA.sendNoteOn(note);
  delay(10);
  busA.sendNoteOff(note);
}