//To Do:
//Functionality

//Code
//add comments in code 
//better named variables

//Build

//UI
//choose better colors

Table data;

color cAir_Temperature,cAir_Humidity,cSoil_Humidity,cLight_Level;
float[] Air_Temperature,Air_Humidity,Soil_Humidity,Light_Level;
String[] Time,Date;

int[] Index;

static int yrange = 100;
static int xoff = 50,yoff = 50;

int mlen;
int len;
int mov = 0;

void axis(int l,int off){
  int ftime = TimeDiff(Date[off],Date[off + l - 1]);
  float xdiv = (width-xoff)/(ftime*1.);
  float ydiv = (height-yoff)/yrange;
  
  int x = xoff;
  int y = yoff;
  
  int pp = round(l/20.);
  if(pp == 0){
    pp = 1;
  }
  
  float lx = xoff;
  Index[floor(lx)] = off;
  
  strokeWeight(1);
  stroke(0);
  line(x*2/3.,0,x*2/3.,height - y*2/3.);
  line(x*2/3.,height - y*2/3.,width,height - y*2/3.);
  
  strokeWeight(2);
  for(int i = 0;i <= yrange;i += 5){
    stroke(0);
    point(x*2/3.,height - (i*ydiv + yoff));
    stroke(255);
    textAlign(RIGHT,TOP);
    text(str(i),0,height - (i*ydiv + yoff + 10),x*1/2.,20);
  }
  
  for(int i = off + 1;i < off + l;i++){
    lx += TimeDiff(Date[i-1],Date[i]) * xdiv;
     Index[floor(lx)-1] = i;
     if(i % pp == 0){
      pushMatrix();
      point(lx,height - yoff*2/3.);
      textAlign(LEFT,TOP);
      translate(lx,height - yoff*2/3.);
      rotate(PI/5);
      text(Time[i],0,0,200,200);
      popMatrix();
     }
  }
}
  
void Plot(float[] a,int l,int off,color c){
  int ftime = TimeDiff(Date[off],Date[off + l - 1]);
  float xdiv = (width-xoff)/(ftime*1.);
  
  //float xdiv = (width-xoff)/(l*1.);
  float ydiv = (height-yoff)/yrange;
  
  noFill();
  stroke(c);
  strokeWeight(2);

  float lx = xoff;
  
  beginShape();
  vertex(lx,height - (a[off]*ydiv + yoff));
  for(int i = off + 1;i < off + l;i++){
    lx += TimeDiff(Date[i-1],Date[i]) * xdiv;
    vertex(lx,height - (a[i]*ydiv + yoff));   
  }
  endShape();
}

void drawCursor(int x,int y){
  stroke(0);
  strokeWeight(.5);
  line(xoff*2/3.,y,width,y);
  line(x,0,x,height-(yoff*2/3.));
}

void Legend(int x,int y){
  float ydiv = (height-yoff)/yrange;
  
  //height - (a[i]*ydiv + yoff) = y
  //a[i]*ydiv + yoff = height - y
  //a[i] = (height - y - yoff)/ydiv
  float yi = (height - y - yoff)/ydiv;
  
  int ypos = round(yi*ydiv + yoff);
  
  if(yi >= 0 && yi <= 100){
    text(str(yi),xoff*3/4.,height - ypos - 16,30,16);
  }
  
  pushMatrix();
  textAlign(LEFT,TOP);
  scale(width/900);
  if(x >= xoff && x < width){
    int xi = Index[x];
    //println(x,xi);
    String texttoprint = "Date: " + Date[xi] + "\n";
    texttoprint += "Air Temperature: " + str(Air_Temperature[xi]) + "  Air Humidity: " + str(Air_Humidity[xi]) + "\n";
    texttoprint += "Soil Humidity: " + str(Soil_Humidity[xi]) + "  Light Level: " + str(Light_Level[xi]);
    rectMode(CORNER);
    text(texttoprint,xoff,0,300,100);
  }
  popMatrix();
  
  pushMatrix();
  translate(width*4/5.,0);
  scale(width/900);
  int lenx = 900/5-5;
  int leny = 600/15;
  noFill();
  strokeWeight(2);
  stroke(0);
  //rect(0,0,lenx,leny);
  text("Air Temp : \nSoil Humid :      ",5,5,lenx/2,leny);
  text("Air Humid :    \nLight Level:      ",lenx/2,5,lenx/2,leny);
  strokeWeight(7);
  stroke(cAir_Temperature);
  point(0.47*lenx,leny/3);
  stroke(cSoil_Humidity);
  point(0.47*lenx,leny*2/3.);
  stroke(cAir_Humidity);
  point(0.93*lenx,leny/3);
  stroke(cLight_Level);
  point(0.93*lenx,leny*2/3.);
  popMatrix();
  
}

String file = "none";
boolean run = true;

void fileSelected(File selection) {
  if (selection == null) {
    run = false;
  } else {
    file = selection.getAbsolutePath();
    println("User selected " + selection.getAbsolutePath());
  }
}

int standby = 0;

void setup(){
  //size(900,600);
  fullScreen();
  selectInput("Select data file to plot","fileSelected");
  while(file == "none"){
    println(standby++);
    if(!run){
      return;
    }
    if(standby > 999999){
      println("time_out");
      file = "exit";
    }
  }
  
  data = loadTable(file, "header");
  
  len = data.getRowCount();
  mlen = len;
  
  Air_Temperature = new float[len];
  Air_Humidity = new float[len];
  Soil_Humidity = new float[len];
  Light_Level = new float[len];
  Time = new String[len];
  Date = new String[len];
  
  Index = new int[width];
  
  cAir_Temperature = color(#4828aa);
  cAir_Humidity = color(#ffa228);
  cSoil_Humidity = color(#dfff28);
  cLight_Level = color(#ff28df);

  for(int i = 0;i < len;i++){
    TableRow row = data.getRow(i);
    
    Air_Temperature[i] = row.getFloat(0);
    Air_Humidity[i] = row.getFloat(1);
    Soil_Humidity[i] = row.getFloat(2);
    Light_Level[i] = row.getFloat(3);
    Time[i] = row.getString(4);
    Date[i] = row.getString(5);
  }
}

void keyPressed(){
  //println(keyCode);
  switch(keyCode){
    case(38):
    //up - zoom in
    len -= 10;
    break;
    case(40):
    //down - zoom out
    len += 10;
    break;
    case(37):
    //left - move left
    mov -= 5;
    break;
    case(39):
    //right - move right
    mov += 5;
    break;
  }
  len = constrain(len,5,mlen-1);
  mov = constrain(mov,0,mlen-len-1);
}

void draw(){
  if(!run){
    exit();
  }else{
    background(80);
    
    Plot(Air_Temperature,len,mov,cAir_Temperature);
    Plot(Air_Humidity,len,mov,cAir_Humidity);
    Plot(Soil_Humidity,len,mov,cSoil_Humidity);
    Plot(Light_Level,len,mov,cLight_Level);
    
    axis(len,mov);
    
    for(int i = 1;i < width;i++){
      if(Index[i] == 0){
        Index[i] = Index[i-1];
      }
    }
    
    drawCursor(mouseX,mouseY);
    
    Legend(mouseX,mouseY);
    
    for(int i = 0;i < width;i++){
      Index[i] = 0;
    }
    //println(frameRate);
  }
}
