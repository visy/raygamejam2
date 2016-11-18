
//import android.view.MotionEvent;

float sw, sh, touchX, touchY;
ArrayList points;
PFont f;

void setup() {
  size(displayWidth, displayHeight);  

  sw = displayWidth;  
  sh = displayHeight;
  points = new ArrayList();
  
  f = createFont("Arial", 16);  

}

void drawbg() {

  color pastel1 = color(237,109,121);
  color pastel2 = color(218,151,224);
  color pastel3 = color(255,137,181);
  color pastel4 = color(137,140,255);
  color[] colors = {pastel1,pastel2,pastel3,pastel4};
  background(colors[0]);

}

void draw() {
  drawbg();
  
    noFill();  
  stroke(255,0,0);  
  strokeWeight(2);  
  textFont(f);
  for(int i=0; i<points.size(); i++) {
    PVector tempPoint = (PVector) points.get(i);
    ellipse(tempPoint.x, tempPoint.y, 50, 50);
    text(tempPoint.x+", "+tempPoint.y, tempPoint.x+10, tempPoint.y-10);
  }

}

/*
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
*/