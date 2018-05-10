import controlP5.*;
ControlP5 cp5;

ArrayList<PImage> imageSet;
int slider_1, slider_2, slider_3, slider_4; 
float pos_x, pos_y;
float size_x, size_y;
float grid_nx, grid_ny;
float frequency, max_resize_ratio, rotation;


void setup() 
{
  // initializing the canvas interface
  size(1024, 768, P2D);
  noStroke();
  cp5 = new ControlP5(this);
  
  // initializing the image database
  imageSet = new ArrayList<PImage>();
  
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
  //grid_nx = 3; 
  //grid_ny = 2;
}

void draw() 
{
  //pushStyle();
  //fill(255, 5);
  //rect(0, 0, width, height);
  //popStyle();
  //if(random(1) < 0.001) background(slider_1, slider_2, slider_3);
  
  if(random(1) < frequency)
  {
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
    
    //imageMode(CENTER);   
    PImage img = imageSet.get(i);
    //float resizeRatio = random(0.2, max_resize_ratio);
    //int img_w = img.width; int img_h = img.height;
    //img.resize(int(img_w * resizeRatio), int(img_w * resizeRatio));
    displaySegment(img, pos_x, pos_y);
    //img.resize(img_w, img_h);
  }
  
  //saveFrame("output/####.tif");
  //println(frameRate);
  
}

// function to load all images from the data folder
void loadImageSet()
{
  File dir; 
  File[] files;
  
  dir = new File(dataPath("textures"));
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
void displaySegment(PImage img, float pos_x, float pos_y)
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