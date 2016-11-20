import android.view.MotionEvent;
import cassette.audiofiles.SoundFile;

float sw, sh, touchX, touchY;
ArrayList points;
PFont f;

int level = 0;
float paircount = 0;

SoundFile music = null;
SoundFile meow = null;
SoundFile pop = null;
SoundFile boom = null;
SoundFile coin = null;

boolean isdragging1 = false;
boolean isdragging2 = false;

PImage image_bomb;
PImage image_coin;
PImage image_heart;

PImage image_kisu11;
PImage image_kisu12;

PImage image_logo;
PImage image_title;

float game_starttime = 0.0;
float game_time = 0.0;

float level_starttime = 0.0;
float level_time = 0.0;
float music_time = 0.0;

float dt = 0.0;

float beat_starttime = 0.0;
float next_beat = 0.0;
int level_beatcounter = 0;
int life = 0;
int score = 0;

float sport_song_bpm = 175.0*1.5;
float sport_song_bps = 60. /sport_song_bpm;

float bg_flash = 1.0;
int dmg_flash = 0;

int game_init = 0;

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
  boolean locked = false;
  boolean foundpair = false;
  float pairtimer = 0.0;
  int dragside = -1;
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
    locked = false;
    foundpair = false;
    dragside = -1;
  }

  boolean hit(float tx, float ty) {
    if (alive == false) return false;

    if (drag == true) return false;
    last_tx = 0.0;
    last_ty = 0.0;

    if (type == TYPE_BUBBLE && dist(x,y,tx,ty)<height/8) return true;
    if (type != TYPE_BUBBLE && type < TYPE_HALF11 && dist(x,y,tx,ty)<height/10) { return true; }

    if (isdragging1 && dragside == 0) { 
      return false;
    }
    if (isdragging2 && dragside == 1) { 
      return false;
    }

    if (type >= TYPE_HALF11 && dist(x,y,tx,ty)<height/8) { last_tx = tx; last_ty = ty; drag = true; if (type == TYPE_HALF11) isdragging1 = true; if (type == TYPE_HALF12) isdragging2 = true; if (x < width/2 && dragside == -1) dragside = 0; if (x > width/2 && dragside == -1) dragside = 1; return true; }

    
    
    return false;
  }
  
  void die() {
    if (dragside == 0) isdragging1 = false;
    if (dragside == 1) isdragging2 = false;
    alive = false;
  }

  boolean pop() {
    if (alive == false) return false;
    if (poptimer > 0.) return false;

    poptimer = 5.;

    if (type == TYPE_BUBBLE) {
      type = contains;
      pop.play();
    } else {
      if (type == TYPE_BOMB) {
        life--;
        bg_flash = 2.0;
        dmg_flash = 1;
        boom.play();
        die();
        return true;
      }
      else if (type == TYPE_COIN) {
        score+=100;
        coin.play();
        die();        
        return true;
      }
      else if (type == TYPE_HEART) {
        score+=15;
        life++;
      pop.play();
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

    if (dragside == 0 && x > width/2) x = width/2;
    if (dragside == 1 && x < width/2) x = width/2;
  
    if (foundpair) {
      pairtimer += dt * 0.001;
      if (pairtimer > 1.0) { score += 500; paircount-=0.5; }
      if (paircount <= 0) { level++; resetLevel(); } 
      die();
      return;
    }
    if (exptimer > 0. && type != TYPE_BUBBLE) exptimer -= dt*0.001;
    if (exptimer <= 0.) alive = false;

    if (locked == true) {
      return;
    }
    if (type == TYPE_BUBBLE) {
      x+=xs;
      y+=ys;
    }

    if (drag && dragside == 0 && x >= width/2-16) {drag = false; locked = true; isdragging1 = false; }
    if (drag && dragside == 1 && x <= width/2+16) {drag = false; locked = true; isdragging2 = false; }
    
    if (locked == true) return;    
   
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

    if (drag == true) {
      strokeWeight(6);
      stroke(255,255,0);
      noFill();
      if (foundpair) stroke(0,255,0); 
      ellipse(x,y,height/4,height/4);

    }

    if (foundpair) {
      strokeWeight(12);
      stroke(0,255,0); 
      noFill();
      ellipse(x,y,height/4,height/4);
    }

    imageMode(CENTER);

    float xo = 0.0;
    float yo = 0.0;
    
    pushMatrix();
    if (type == TYPE_BUBBLE) {
      yo = cos(millis()*0.002)*16;
    }

    translate(x,y);
    if (drag == false) rotate(millis()*0.002+x);
    scale(0.5);
    translate(-x,-y);

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
  
  f = loadFont("heinifont-160.vlw");
  
  image_coin = loadImage("coin.png");
  image_bomb = loadImage("bomb.png");
  image_heart = loadImage("heart.png");

  image_kisu11 = loadImage("kisu1_1.png");
  image_kisu12 = loadImage("kisu1_2.png");

  image_logo = loadImage("logo.png");
  image_title = loadImage("title.png");

  meow = new SoundFile(this, "meow.ogg");
  pop = new SoundFile(this, "pop.ogg");
  boom = new SoundFile(this, "boom.ogg");
  coin = new SoundFile(this, "coin.ogg");

  noSmooth();
  resetGame();
}

float gamestarttimer = 0.0;

void resetGame() {
  level = 0;
  gamestarttimer = 0.0;
  game_starttime = millis();
  game_time = 0;
}

void resetLevel() {
  points.clear();
  ents.clear();

  isdragging1 = false;
  isdragging2 = false;

  if (music != null) music.stop();
  if (level == 0) music = new SoundFile(this, "sport.mp3");
  if (level == 1) music = new SoundFile(this, "hydro.mp3");
  if (level == 2) music = new SoundFile(this, "nonsense.mp3");

  music.play();
  level_time = 0.0;
  next_beat = 0.0;
  level_starttime = millis();

  life = 3;
  paircount = 3.0+float(level);
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
          if ((ent.dragside == 0 && ent.x < width/2) || (ent.dragside == 1 && ent.x > width/2)) { 
            if (dist(ent.x,ent.y,tx,ty) > height/6) { 
              ent.drag = false;
              if (ent.dragside == 0) isdragging1 = false;
              if (ent.dragside == 1) isdragging2 = false;
            }
            else {
              ent.x = tx;
              ent.y = ty;
              if (ent.dragside == 0 && ent.x > width/2) ent.x = width/2;
              if (ent.dragside == 1 && ent.x < width/2) ent.x = width/2;
            }
          }
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
  dashbox(width-78-16,height/2-height/4,width-16,(height/2+height/16)+4,dsh);

  imageMode(CENTER);
  for (int i = 0; i < 5; i++) {
    if (i >= life) break;
    image(image_heart,width-56,(height/2-height/4)+76+(i*76),76,76);
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
      textSize(240);
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
      textSize(240);
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
 

  textSize(100);
  textAlign(CENTER,CENTER);
  text(int(paircount),80,80);  

  imageMode(CENTER);

  // logo
  if (gamestarttimer >= 0.0 && gamestarttimer < 2.5) {
    background(255);
    image(image_logo,width/2,height/2);

    stroke(0);
    fill(0);
    
    textSize(80);
    text("designed by Heini Natri and Visa-Valtteri Pimiä",width/2,height-200);
    text("code by visy",width/2,height-160);
    text("graphics by Heini",width/2,height-120);
    text("music by mathgrant (CC)",width/2,height-80);
  }

  if (gamestarttimer >= 2.5 && gamestarttimer < 5.0) {
    background(255);
    image(image_title,width/2,height/2);
  }
}

int spawnside = -1;
float spawntime = 0.0;

void levelLogic() {
  level_time = millis()-level_starttime;

  for(int j=0; j<ents.size(); j++) {
    Entity ent = (Entity) ents.get(j);
    ent.update();

    for(int k=0; k<ents.size(); k++) {
      Entity ent2 = (Entity) ents.get(k);
      
      if (!ent.foundpair && !ent2.foundpair && ent.locked && ent2.locked && dist(ent.x,ent.y,ent2.x,ent2.y) < 100 && ent.alive && ent2.alive && ent.type != ent2.type) {
        ent.foundpair = true;
        ent2.foundpair = true;
        ent.drag = false;
        ent2.drag = false;
        meow.play();
      }
    }  


  }  
  
  spawntime += dt*0.005;

  // beat trig
  if (spawntime > abs((5.0-(level*0.5)))) {
    spawntime = 0.;
    beat_starttime = music_time;
    next_beat = beat_starttime+(sport_song_bps*16.*512.);

    spawnside = -spawnside;
    int toporbottom = int(random(0,2));
    
    if (spawnside == 1) {
      if (toporbottom == 0) ents.add(new Entity(width/8+random(0,width/4),-160+random(0,10),0,2+random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,5))));
      else ents.add(new Entity(width/8+random(0,width/4),height+120+random(0,10),0,-2-random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,5))));
    } else {
      if (toporbottom == 0) ents.add(new Entity(width/2+width/4+random(0,width/8),-160+random(0,10),0,2+random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,5))));
      else ents.add(new Entity(width/2+width/8+random(0,width/4),height+120+random(0,10),0,-2-random(0,2+level),TYPE_BUBBLE,TYPE_BOMB+int(random(0,5))));
    }

  }
}

void draw() {
  
  dt = (millis()-game_starttime)-game_time;

  if (gamestarttimer < 5.0) {
    drawText();
    gamestarttimer+=dt*0.00001;
    return;
  }
  
  if (game_init == 0) { resetLevel(); game_init = 1; }
  
  if (life >= 0) {
    levelLogic(); 
    touchLogic();
  }

  drawBG();
  drawShapes();
  drawText();
  
  game_time = millis()-game_starttime;
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