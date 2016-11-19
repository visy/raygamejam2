package processing.test.game;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import android.view.MotionEvent; 
import cassette.audiofiles.SoundFile; 
import java.lang.reflect.Field; 
import android.media.MediaPlayer; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class game extends PApplet {






float sw, sh, touchX, touchY;
ArrayList points;
PFont f;

int level = 0;
SoundFile music = null;

PImage image_bomb;
PImage image_coin;
PImage image_heart;

float level_starttime = 0.0f;
float level_time = 0.0f;
float music_time = 0.0f;

float dt = 0.0f;

float beat_starttime = 0.0f;
float next_beat = 0.0f;
int level_beatcounter = 0;
int life = 0;
int score = 0;

float sport_song_bpm = 175.0f;
float sport_song_bps = 60.f /sport_song_bpm;

float bg_flash = 1.0f;

static int TYPE_BUBBLE = 0;
static int TYPE_BOMB = 1;
static int TYPE_COIN = 2;
static int TYPE_HEART = 3;
static int TYPE_HALF1 = 4;
static int TYPE_HALF2 = 5;
static int TYPE_HALF3 = 6;

int pastel1 = color(237*bg_flash,109*bg_flash,121*bg_flash);
int pastel2 = color(218*bg_flash,151*bg_flash,224*bg_flash);
int pastel3 = color(255*bg_flash,137*bg_flash,181*bg_flash);
int pastel4 = color(137*bg_flash,140*bg_flash,255*bg_flash);
int[] colors = {pastel1,pastel2,pastel3,pastel4};
  
class Entity {
  float x;
  float y;
  float xs;
  float ys;
  float poptimer;
  int type = 0;
  int contains; // -1 = nothing, ie. not a bubble!
  boolean alive;

  Entity(float _x, float _y, float _xs, float _ys, int _type, int _contains) {
    x = _x;
    y = _y;
    xs = _xs;
    ys = _ys;
    type = _type;
    alive = true;
    if (type == TYPE_BUBBLE) contains = _contains;
  }

  public boolean hit(float tx, float ty) {
    if (alive == false) return false;

    if (tx >= x-180 && tx <= x+180) {
      if (ty >= y-180 && ty <= y+180) {
        return true;
      }
    }
    return false;
  }
  
  public void die() {
    alive = false;
  }

  public boolean pop() {
    if (alive == false) return false;
    if (poptimer > 0.f) return false;

    poptimer = 5.f;

    if (type == TYPE_BUBBLE) {
      type = contains;
    } else {
      if (type == TYPE_BOMB) {
        life--;
        die();
        return true;
      }
      else if (type == TYPE_COIN) {
        score+=100;
        die();        
        return true;
      }
      else if (type == TYPE_HEART) {
        score+=15;
        life++;
        die();        
        return true;
      }
    }
    
    return false;
  }

  public void update() {
    if (alive == false) return;
    if (type == TYPE_BUBBLE) {
      x+=xs;
      y+=ys;
    }
    
    if (poptimer > 0.f) poptimer -=dt*0.01f;
  }
  
  public void render() {
    if (alive == false) return;

    if (type == TYPE_BUBBLE) {
      stroke(0);
      strokeWeight(1);
      if (x<=width/2) fill(colors[level]);
      else fill(colors[(level+1)%colors.length]);

      ellipse(x,y,height/4,height/4);
    }

    imageMode(CENTER);
    if (contains == TYPE_BOMB) image(image_bomb,x,y);
    else if (contains == TYPE_COIN) image(image_coin,x,y);
    else if (contains == TYPE_HEART) image(image_heart,x,y);

  }
}

ArrayList<Entity> ents;

public void setup() {
    

  sw = displayWidth;  
  sh = displayHeight;
  points = new ArrayList();
  ents = new ArrayList<Entity>();
  
  f = loadFont("heinifont-80.vlw");
  
  image_coin = loadImage("coin.png");
  image_bomb = loadImage("bomb.png");
  image_heart = loadImage("heart.png");

  resetGame();
}

public void resetGame() {
  level = 0;
  points.clear();
  ents.clear();
  resetLevel();
}

public void resetLevel() {
  if (music != null) music.stop();
  music = new SoundFile(this, "sport.mp3");
  music.play();
  level_time = 0.0f;
  next_beat = 0.0f;
  level_starttime = millis();

  life = 5;
}

public void touchEmu() {
  points.clear();
  if (mousePressed == true) {
    points.add(new PVector(mouseX,mouseY));
  } else {
  }
}

public void touchLogic() {
  // touch debug
  fill(255,0,0,64);  
  stroke(0,64);
  for(int i=0; i<points.size(); i++) {
    PVector tempPoint = (PVector) points.get(i);
    ellipse(tempPoint.x, tempPoint.y, 50, 50);
  }

  // touches active
  if (points.size() > 0) {
    for(int i=0; i<points.size(); i++) {
      PVector tp = (PVector) points.get(i);
      float tx = tp.x;
      float ty = tp.y;
      
      for(int j=0; j<ents.size(); j++) {
        Entity ent = (Entity) ents.get(j);
        if (ent.hit(tx,ty)) {
          ent.pop();
        }
      }
      
    }
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
 
 
public void dashbox(float x0, float y0, float x1, float y1, float[ ] spacing) {
  dashline(x0,y0,x1,y0,spacing);
  dashline(x1,y0,x1,y1,spacing);
  dashline(x0,y1,x1,y1,spacing);
  dashline(x0,y0,x0,y1,spacing);
}
 
public void dashline(float x0, float y0, float x1, float y1, float[ ] spacing) 
{ 
  float distance = dist(x0, y0, x1, y1); 
  float [ ] xSpacing = new float[spacing.length]; 
  float [ ] ySpacing = new float[spacing.length]; 
  float drawn = 0.0f;  // amount of distance drawn 
 
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
 
public void drawBG() {

  if (bg_flash > 1.0f) bg_flash-=dt*0.005f;
  if (bg_flash <= 1.0f) bg_flash = 1.0f;


  noStroke();

  
  fill(colors[level]);
  rect(0,0,width/2,height);

  fill(colors[(level+1)%colors.length]);
  rect(width/2,0,width/2,height);

  stroke(255);
  noFill();
  strokeWeight(8);
  float[] dsh = {5, 15, 9, 4};
  float offy = PApplet.parseInt(millis()*0.1f) % 34 ;
  dashline(width/2,-32+offy,width/2,height+32+offy,dsh);

  dashbox(16,height/2-height/4,80,(height/2+height/4)+4,dsh); 
  dashbox(width-78-16,height/2-height/4,width-16,(height/2+height/4)+4,dsh);

  imageMode(CENTER);
  for (int i = 0; i < 5; i++) {
    if (i >= life) break;
    image(image_heart,width-56,(height/2-height/4)+64+(i*64),64,64);
  }

}

public void drawShapes() {
  for(int i=0; i<ents.size(); i++) {
    Entity ent = (Entity) ents.get(i);
    ent.render();
  }

}

public void drawText() {
      textFont(f);
  
  // intro text on level
  if (level_time > 1000.f && level_time < 4000.f) {
    pushMatrix();
      noStroke();
      textAlign(CENTER,CENTER);
      textSize(160);
      translate(width/2,height/2);
      scale(1.0f+cos(millis()*0.005f)*0.1f);
      fill(0);
      text("LEVEL 1",4,4);
      fill(230);
      text("LEVEL 1",0,0);
      translate(-width/2,-height/2);
    popMatrix();  
  }

  // score
  
  noStroke();
  fill(255);
   
  textAlign(CENTER,BOTTOM);
  textSize(62);
  pushMatrix();
  translate(64,height/2);
  rotate(-HALF_PI);
  text(score,0,0);
  popMatrix();
 

  // debug
  pushMatrix();
    noStroke();
    textAlign(CENTER,CENTER);
    textSize(60);
    translate(width/2,height-100);
    fill(0);
    text(""+music_time,4,4);
    fill(230);
    text(""+music_time,0,0);
    translate(-width/2,-height-100);
  popMatrix();  
}

int spawnside = -1;

public void levelLogic() {
  level_time = millis()-level_starttime;

  for(int j=0; j<ents.size(); j++) {
    Entity ent = (Entity) ents.get(j);
    ent.update();
  }  
  
  try {
    Field f = music.getClass().getDeclaredField("player"); //NoSuchFieldException
    f.setAccessible(true);
    MediaPlayer mp = (MediaPlayer) f.get(music);
    music_time = mp.getCurrentPosition() * 1.0f;
    if (music_time > 0.f && next_beat == 0.0f) {
      next_beat = sport_song_bps*16.f*512.f;
    }
} catch (Exception e) {}

  // beat trig
  if (music_time >= next_beat && next_beat != 0.0f) {
    beat_starttime = music_time;
    next_beat = beat_starttime+(sport_song_bps*16.f*512.f);
    bg_flash = 1.8f;

    spawnside = -spawnside;
    int toporbottom = PApplet.parseInt(random(0,2));
    
    if (spawnside == 1) {
      if (toporbottom == 0) ents.add(new Entity(width/8+random(0,width/8),-160+random(0,10),0,1+random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+PApplet.parseInt(random(0,3))));
      else ents.add(new Entity(width/8+random(0,width/8),height+80+random(0,10),0,-1-random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+PApplet.parseInt(random(0,3))));
    } else {
      if (toporbottom == 0) ents.add(new Entity(width/2+width/8+random(0,width/8),-160+random(0,10),0,1+random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+PApplet.parseInt(random(0,3))));
      else ents.add(new Entity(width/2+width/8+random(0,width/8),height+80+random(0,10),0,-1-random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+PApplet.parseInt(random(0,3))));
    }

}
}

public void draw() {
  dt = (millis()-level_starttime)-level_time;
  if (life >= 0) {
    levelLogic(); 
    touchLogic();
  }

  //  touchEmu();
  drawBG();
  drawShapes();
  drawText();
  


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
  public void settings() {  size(displayWidth, displayHeight); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "game" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
