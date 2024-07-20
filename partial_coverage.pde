PImage img;
int w = 200;

int upper_leftx, upper_lefty ;

//states by boolean
boolean set_uppercoordinates = false;
//boolean pixelate_image;
boolean draw_newimg = false;
boolean movement = false;

PImage smallerImage;

// It's possible to perform a convolution
// the image with different matrices

float[][] matrix = {
  { -1, -1, -1 },
  { -1, 9, -1 },
  { -1, -1, -1 }
};

int cellsize = 2; // Dimensions of each cell in the grid
int cols, rows;   // Number of columns and rows in our system

void setup() {
  size(700, 700, P3D);
  frameRate(30);
  img = loadImage("sunflowerlandscape.jpg");
  img.resize(700, 700);


  cols = width/cellsize;
  rows = height/cellsize;
  //pixelate_image = true;
  //isSetupComplete = true;
}

void draw() {

  if (!draw_newimg) {
    // We're only going to process a portion of the image
    // so let's set the whole image as the background first
    image(img, 0, 0);
    // Where is the small rectangle we will process
    int xstart = constrain(mouseX-w/2, 0, img.width);
    int ystart = constrain(mouseY-w/2, 0, img.height);
    int xend = constrain(mouseX+w/2, 0, img.width);
    int yend = constrain(mouseY+w/2, 0, img.height);
    int matrixsize = 3;
    loadPixels();
    // Begin our loop for every pixel
    for (int x = xstart; x < xend; x++) {
      for (int y = ystart; y < yend; y++ ) {
        // Each pixel location (x,y) gets passed into a function called convolution()
        // which returns a new color value to be displayed.
        color c = convolution(x, y, matrix, matrixsize, img);
        int loc = x + y*img.width;
        pixels[loc] = c;
      }
    }
    updatePixels();

    //stroke(0);
    //noFill();
    //rect(xstart, ystart, w, w);

    if (set_uppercoordinates == true)
    {
      upper_leftx =xstart;
      upper_lefty = ystart;
      set_uppercoordinates = false;
      print(upper_leftx, upper_lefty);
      draw_newimg = true;
    }
  } else {

    zoomImage(upper_leftx, upper_lefty, w);
  }
}

color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  // Loop through convolution matrix
  for (int i = 0; i < matrixsize; i++) {
    for (int j= 0; j < matrixsize; j++) {
      // What pixel are we testing
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      // Make sure we have not walked off the edge of the pixel array
      loc = constrain(loc, 0, img.pixels.length-1);
      // Calculate the convolution
      // We sum all the neighboring pixels multiplied by the values in the convolution matrix.
      rtotal += (red(img.pixels[loc]) * matrix[i][j]);
      gtotal += (green(img.pixels[loc]) * matrix[i][j]);
      btotal += (blue(img.pixels[loc]) * matrix[i][j]);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  // Return the resulting color
  return color(rtotal, gtotal, btotal);
}

// store area


void mousePressed() {
  set_uppercoordinates = true;
  //draw_newimg = true;
}

void zoomImage(int x, int y, int w) {
  PImage cropped = img.get(x, y, w, w);
  cropped.resize(width, height);
  background(0);

  //loadPixels();
  //// Begin loop for columns
  for ( int i = 0; i < cols; i++) {
    // Begin loop for rows
    for ( int j = 0; j < rows; j++) {
      int x_mat = i*cellsize + cellsize/2; // x position
      int y_mat = j*cellsize + cellsize/2; // y position
      int loc = x_mat+ y_mat*width;           // Pixel array location
      color c = cropped.pixels[loc];       // Grab the color
      // Calculate a z position as a function of mouseX and pixel brightness
      float z = (mouseX/(float)width) * brightness(img.pixels[loc]) - 100.0;
      // Translate to the location, set fill and stroke, and draw the rect
      pushMatrix();
      translate(x_mat, y_mat, z);
      fill(c);
      noStroke();
      rectMode(CENTER);
      rect(0, 0, cellsize, cellsize);
      popMatrix();
    }
  }
}
