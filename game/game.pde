import android.view.MotionEvent;

float sw, sh, touchX, touchY;
ArrayList points;
PFont f;

int level = 0;

void setup() {
  size(displayWidth, displayHeight);  

  sw = displayWidth;  
  sh = displayHeight;
  points = new ArrayList();
  
  f = createFont("System", 72);  

  resetGame();
}

void resetGame() {
  level = 0;
  points.clear();
}

void touchEmu() {
  points.clear();
  if (mousePressed == true) {
    points.add(new PVector(mouseX,mouseY));
  } else {
  }
}

void touchLogic() {
  fill(255,0,0,64);  
  stroke(0,64);
  for(int i=0; i<points.size(); i++) {
    PVector tempPoint = (PVector) points.get(i);
    ellipse(tempPoint.x, tempPoint.y, 50, 50);
  }
}

/* 
 * Draw a dashed line with given set of dashes and gap lengths. 
 * x0 starting x-coordinate of line. 
 * y0 starting y-coordinate of line. 
 * x1 ending x-coordinate of line. 
 * y1 ending y-coordinate of line. 
 * spacing array giving lengths of dashes and gaps in pixels; 
 *  an array with values {5, 3, 9, 4} will draw a line with a 
 *  5-pixel dash, 3-pixel gap, 9-pixel dash, and 4-pixel gap. 
 *  if the array has an odd number of entries, the values are 
 *  recycled, so an array of {5, 3, 2} will draw a line with a 
 *  5-pixel dash, 3-pixel gap, 2-pixel dash, 5-pixel gap, 
 *  3-pixel dash, and 2-pixel gap, then repeat. 
 */ 
void dashline(float x0, float y0, float x1, float y1, float[ ] spacing) 
{ 
  float distance = dist(x0, y0, x1, y1); 
  float [ ] xSpacing = new float[spacing.length]; 
  float [ ] ySpacing = new float[spacing.length]; 
  float drawn = 0.0;  // amount of distance drawn 
 
  if (distance > 0) 
  { 
    int i; 
    boolean drawLine = true; // alternate between dashes and gaps 
 
    /* 
      Figure out x and y distances for each of the spacing values 
      I decided to trade memory for time; I'd rather allocate 
      a few dozen bytes than have to do a calculation every time 
      I draw. 
    */ 
    for (i = 0; i < spacing.length; i++) 
    { 
      xSpacing[i] = lerp(0, (x1 - x0), spacing[i] / distance); 
      ySpacing[i] = lerp(0, (y1 - y0), spacing[i] / distance); 
    } 
 
    i = 0; 
    while (drawn < distance) 
    { 
      if (drawLine) 
      { 
        line(x0, y0, x0 + xSpacing[i], y0 + ySpacing[i]); 
      } 
      x0 += xSpacing[i]; 
      y0 += ySpacing[i]; 
      /* Add distance "drawn" by this line or gap */ 
      drawn = drawn + mag(xSpacing[i], ySpacing[i]); 
      i = (i + 1) % spacing.length;  // cycle through array 
      drawLine = !drawLine;  // switch between dash and gap 
    } 
  } 
} 
 
void drawBG() {

  color pastel1 = color(237,109,121);
  color pastel2 = color(218,151,224);
  color pastel3 = color(255,137,181);
  color pastel4 = color(137,140,255);
  color[] colors = {pastel1,pastel2,pastel3,pastel4};

  noStroke();

  fill(colors[level]);
  rect(0,0,width/2,height);

  fill(colors[(level+1)%colors.length]);
  rect(width/2,0,width/2,height);

  stroke(255);
  noFill();
  strokeWeight(8);
  float[] dsh = {5, 15, 9, 4};
  float offy = int(millis()*0.1) % 34 ;
  dashline(width/2,-32+offy,width/2,height+32+offy,dsh);

  

}

void drawShapes() {
  
  for (int i = 0; i < 16; i+=8) {
    noStroke();
    fill(0,255,0);
    ellipse(width/1.25+sin(millis()*0.001+i)*width/8,height/2+sin(millis()*0.0002+i)*height/1.5,height/4,height/4);
  }

  for (int i = 0; i < 16; i+=8) {
    noStroke();
    fill(0,255,255);
    ellipse(width/4+cos(millis()*0.0012+i)*width/8,height/2+cos(millis()*0.00021+i)*height/1.5,height/4,height/4);
  }
}

void drawText() {
  pushMatrix();
  noStroke();
  textAlign(CENTER,CENTER);
  textSize(160);
  translate(width/2,height/2);
  scale(1.0+cos(millis()*0.01)*0.2);
  fill(0);
  text("LEVEL 1",2,2);
  fill(230);
  text("LEVEL 1",0,0);
  translate(-width/2,-height/2);
  popMatrix();  
}

void draw() {
//  touchEmu();
  drawBG();
  drawShapes();
  drawText();
  
  touchLogic();
  

}


public boolean surfaceTouchEvent(MotionEvent event) {
  int pointerCount = event.getPointerCount();
  points.clear();
  for(int i=1; i<=pointerCount; i++) {
    points.add(new PVector(event.getX(i-1), event.getY(i-1)));
  }
  
  //if the event is a pressed gesture finishing, 
  // it means the lifting the last touch point
  if(event.getActionMasked() == MotionEvent.ACTION_UP) points.clear();
  
  // if you want the variables for motionX/motionY, mouseX/mouseY etc.
  // to work properly, you'll need to call super.surfaceTouchEvent().
  return super.surfaceTouchEvent(event);

}