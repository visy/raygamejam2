import android.view.MotionEvent;
import cassette.audiofiles.SoundFile;
import java.lang.reflect.Field;
import android.media.MediaPlayer;

float sw, sh, touchX, touchY;
ArrayList points;
PFont f;

int level = 0;
SoundFile music = null;

PImage image_bomb;
PImage image_coin;
PImage image_heart;

PImage image_kisu11;
PImage image_kisu12;

float level_starttime = 0.0;
float level_time = 0.0;
float music_time = 0.0;

float dt = 0.0;

float beat_starttime = 0.0;
float next_beat = 0.0;
int level_beatcounter = 0;
int life = 0;
int score = 0;

float sport_song_bpm = 175.0;
float sport_song_bps = 60. /sport_song_bpm;

float bg_flash = 1.0;
int dmg_flash = 0;

static int TYPE_BUBBLE = 0;
static int TYPE_BOMB = 1;
static int TYPE_COIN = 2;
static int TYPE_HEART = 3;
static int TYPE_HALF11 = 4;
static int TYPE_HALF12 = 5;

  
class Entity {
  float x;
  float y;
  float xs;
  float ys;
  float last_tx;
  float last_ty;
  float poptimer;
  float exptimer;
  boolean drag = false;
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
    if (_contains == TYPE_HALF11 && x > width/2) _contains = TYPE_HALF12;
    if (_contains == TYPE_HALF12 && x < width/2) _contains = TYPE_HALF11;

    if (type == TYPE_BUBBLE) contains = _contains;
    
    exptimer = 5.0;
    drag = false;
  }

  boolean hit(float tx, float ty) {
    if (alive == false) return false;

    if (drag == true) return false;
    last_tx = 0.0;
    last_ty = 0.0;

    if (type == TYPE_BUBBLE && dist(x,y,tx,ty)<height/8) return true;
    if (type != TYPE_BUBBLE && type < TYPE_HALF11 && dist(x,y,tx,ty)<height/10) { return true; }
    if (type >= TYPE_HALF11 && dist(x,y,tx,ty)<height/8) { last_tx = tx; last_ty = ty; drag = true; return true; }
    
    
    return false;
  }
  
  void die() {
    alive = false;
  }

  boolean pop() {
    if (alive == false) return false;
    if (poptimer > 0.) return false;

    poptimer = 5.;

    if (type == TYPE_BUBBLE) {
      type = contains;
    } else {
      if (type == TYPE_BOMB) {
        life--;
        bg_flash = 2.0;
        dmg_flash = 1;

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
        if (life >= 3) life = 3;
        die();        
        return true;
      }
      else if (type >= TYPE_HALF11) {
        x = last_tx;
        y = last_ty;
      }
    }
    
    return false;
  }

  void update() {
    if (alive == false) return;
    if (type == TYPE_BUBBLE) {
      x+=xs;
      y+=ys;
    }
    
    if (exptimer > 0. && type != TYPE_BUBBLE) exptimer -= dt*0.001;
    if (exptimer <= 0.) alive = false;
    
    if (poptimer > 0.) poptimer -= dt*0.02;
  }
  
  void render() {
    if (alive == false) return;

    if (type == TYPE_BUBBLE) {
      stroke(255);
      strokeWeight(3);
      color pastel1 = color(237*1.3,109*1.3,121*1.3);
      color pastel2 = color(218*1.3,151*1.3,224*1.3);
      color pastel3 = color(255*1.3,137*1.3,181*1.3);
      color pastel4 = color(137*1.3,140*1.3,255*1.3);
      color[] colors = {pastel1,pastel2,pastel3,pastel4};

      if (x<=width/2) fill(colors[level]);
      else fill(colors[(level+1)%colors.length]);

      ellipse(x,y,height/4+sin(millis()*0.004+x)*16,height/4+cos(millis()*0.0052+x)*16);
    }

    imageMode(CENTER);

    float xo = 0.0;
    float yo = 0.0;
    
    pushMatrix();
    if (type == TYPE_BUBBLE) {
      yo = cos(millis()*0.002)*16;
    } else {
      translate(x,y);
      rotate(cos(millis()*0.004)*PI/16);
      translate(-x,-y);
    }
    
    tint(255,(1.0-((5.0-exptimer)*0.2))*255);
    
    if (contains == TYPE_BOMB) image(image_bomb,x+xo,y+yo);
    else if (contains == TYPE_COIN) image(image_coin,x+xo,y+yo);
    else if (contains == TYPE_HEART) image(image_heart,x+xo,y+yo);
    else if (contains == TYPE_HALF11) image(image_kisu11,x+xo,y+yo);
    else if (contains == TYPE_HALF12) image(image_kisu12,x+xo,y+yo);
    popMatrix();
  
    tint(255,255);
  }
}

ArrayList<Entity> ents;

void setup() {
  size(displayWidth, displayHeight);  

  sw = displayWidth;  
  sh = displayHeight;
  points = new ArrayList();
  ents = new ArrayList<Entity>();
  
  f = loadFont("heinifont-80.vlw");
  
  image_coin = loadImage("coin.png");
  image_bomb = loadImage("bomb.png");
  image_heart = loadImage("heart.png");

  image_kisu11 = loadImage("kisu1_1.png");
  image_kisu12 = loadImage("kisu1_2.png");

  smooth();
  resetGame();
}

void resetGame() {
  level = 0;
  points.clear();
  ents.clear();
  resetLevel();
}

void resetLevel() {
  if (music != null) music.stop();
  music = new SoundFile(this, "sport.mp3");
  music.play();
  level_time = 0.0;
  next_beat = 0.0;
  level_starttime = millis();

  life = 3;
  frameRate(60);
}

void touchEmu() {
  points.clear();
  if (mousePressed == true) {
    points.add(new PVector(mouseX,mouseY));
  } else {
  }
}

void touchLogic() {
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
        
        if (ent.drag) {
          ent.x = tx;
          ent.y = ty;
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
 
 
void dashbox(float x0, float y0, float x1, float y1, float[ ] spacing) {
  dashline(x0,y0,x1,y0,spacing);
  dashline(x1,y0,x1,y1,spacing);
  dashline(x0,y1,x1,y1,spacing);
  dashline(x0,y0,x0,y1,spacing);
}
 
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
  color pastel1 = color(237*bg_flash,109*bg_flash,121*bg_flash);
  color pastel2 = color(218*bg_flash,151*bg_flash,224*bg_flash);
  color pastel3 = color(255*bg_flash,137*bg_flash,181*bg_flash);
  color pastel4 = color(137*bg_flash,140*bg_flash,255*bg_flash);

  if (dmg_flash == 1) {
    pastel1 = color(237*bg_flash,0,0);
    pastel2 = color(218*bg_flash,0,0);
    pastel3 = color(255*bg_flash,0,0);
    pastel4 = color(137*bg_flash,0,0);
  }

  color[] colors = {pastel1,pastel2,pastel3,pastel4};

  if (bg_flash > 1.0) bg_flash-=dt*0.005;
  if (bg_flash <= 1.0) { bg_flash = 1.0; dmg_flash = 0; }


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

  dashbox(16,height/2-height/4,80,(height/2+height/4)+4,dsh); 
  dashbox(width-78-16,height/2-height/4,width-16,(height/2+height/4)+4,dsh);

  imageMode(CENTER);
  for (int i = 0; i < 5; i++) {
    if (i >= life) break;
    image(image_heart,width-56,(height/2-height/4)+64+(i*64),64,64);
  }

}

void drawShapes() {
  for(int i=0; i<ents.size(); i++) {
    Entity ent = (Entity) ents.get(i);
    ent.render();
  }

}

void drawText() {
      textFont(f);
  
  // intro text on level
  if (level_time > 1000. && level_time < 4000.) {
    pushMatrix();
      noStroke();
      textAlign(CENTER,CENTER);
      textSize(160);
      translate(width/2,height/2);
      scale(1.0+cos(millis()*0.005)*0.1);
      fill(0);
      text("LEVEL " + (level+1),4,4);
      fill(255);
      text("LEVEL " + (level+1),0,0);
      translate(-width/2,-height/2);
    popMatrix();  
  }

  // GAME OVER
  if (life < 0) {
    pushMatrix();
      noStroke();
      textAlign(CENTER,CENTER);
      textSize(160);
      translate(width/2,height/2);
      scale(1.0+cos(millis()*0.005)*0.1);
      fill(0);
      text("GAME OVER",4,4);
      fill(255);
      text("GAME OVER",0,0);
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
 

}

int spawnside = -1;

void levelLogic() {
  level_time = millis()-level_starttime;

  for(int j=0; j<ents.size(); j++) {
    Entity ent = (Entity) ents.get(j);
    ent.update();
  }  
  
  try {
    Field f = music.getClass().getDeclaredField("player"); //NoSuchFieldException
    f.setAccessible(true);
    MediaPlayer mp = (MediaPlayer) f.get(music);
    music_time = mp.getCurrentPosition() * 1.0;
    if (music_time > 0. && next_beat == 0.0) {
      next_beat = sport_song_bps*16.*512.;
    }
} catch (Exception e) {}

  // beat trig
  if (music_time >= next_beat && next_beat != 0.0) {
    beat_starttime = music_time;
    next_beat = beat_starttime+(sport_song_bps*16.*512.);

    spawnside = -spawnside;
    int toporbottom = int(random(0,2));
    
    if (spawnside == 1) {
      if (toporbottom == 0) ents.add(new Entity(width/8+random(0,width/4),-160+random(0,10),0,2+random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,4))));
      else ents.add(new Entity(width/8+random(0,width/4),height+120+random(0,10),0,-2-random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,4))));
    } else {
      if (toporbottom == 0) ents.add(new Entity(width/2+width/4+random(0,width/8),-160+random(0,10),0,2+random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,4))));
      else ents.add(new Entity(width/2+width/8+random(0,width/4),height+120+random(0,10),0,-2-random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,4))));
    }

}
}

void draw() {
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