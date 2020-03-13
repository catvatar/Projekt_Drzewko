import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class DataPlotter extends PApplet {

//To Do:
//Functionality

//Code
//add comments in code 
//better named variables

//Build

//UI
//choose better colors

Table data;

int cAir_Temperature,cAir_Humidity,cSoil_Humidity,cLight_Level;
float[] Air_Temperature,Air_Humidity,Soil_Humidity,Light_Level;
String[] Time,Date;

int[] Index;

static int yrange = 100;
static int xoff = 50,yoff = 50;

int mlen;
int len;
int mov = 0;

public void axis(int l,int off){
  int ftime = TimeDiff(Date[off],Date[off + l - 1]);
  float xdiv = (width-xoff)/(ftime*1.f);
  float ydiv = (height-yoff)/yrange;
  
  int x = xoff;
  int y = yoff;
  
  int pp = round(l/20.f);
  if(pp == 0){
    pp = 1;
  }
  
  float lx = xoff;
  Index[floor(lx)] = off;
  
  strokeWeight(1);
  stroke(0);
  line(x*2/3.f,0,x*2/3.f,height - y*2/3.f);
  line(x*2/3.f,height - y*2/3.f,width,height - y*2/3.f);
  
  strokeWeight(2);
  for(int i = 0;i <= yrange;i += 5){
    stroke(0);
    point(x*2/3.f,height - (i*ydiv + yoff));
    stroke(255);
    textAlign(RIGHT,TOP);
    text(str(i),0,height - (i*ydiv + yoff + 10),x*1/2.f,20);
  }
  
  for(int i = off + 1;i < off + l;i++){
    lx += TimeDiff(Date[i-1],Date[i]) * xdiv;
     Index[floor(lx)-1] = i;
     if(i % pp == 0){
      pushMatrix();
      point(lx,height - yoff*2/3.f);
      textAlign(LEFT,TOP);
      translate(lx,height - yoff*2/3.f);
      rotate(PI/5);
      text(Time[i],0,0,200,200);
      popMatrix();
     }
  }
}
  
public void Plot(float[] a,int l,int off,int c){
  int ftime = TimeDiff(Date[off],Date[off + l - 1]);
  float xdiv = (width-xoff)/(ftime*1.f);
  
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

public void drawCursor(int x,int y){
  stroke(0);
  strokeWeight(.5f);
  line(xoff*2/3.f,y,width,y);
  line(x,0,x,height-(yoff*2/3.f));
}

public void Legend(int x,int y){
  float ydiv = (height-yoff)/yrange;
  
  //height - (a[i]*ydiv + yoff) = y
  //a[i]*ydiv + yoff = height - y
  //a[i] = (height - y - yoff)/ydiv
  float yi = (height - y - yoff)/ydiv;
  
  int ypos = round(yi*ydiv + yoff);
  
  if(yi >= 0 && yi <= 100){
    text(str(yi),xoff*3/4.f,height - ypos - 16,30,16);
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
  translate(width*4/5.f,0);
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
  point(0.47f*lenx,leny/3);
  stroke(cSoil_Humidity);
  point(0.47f*lenx,leny*2/3.f);
  stroke(cAir_Humidity);
  point(0.93f*lenx,leny/3);
  stroke(cLight_Level);
  point(0.93f*lenx,leny*2/3.f);
  popMatrix();
  
}

String file = "none";
boolean run = true;

public void fileSelected(File selection) {
  if (selection == null) {
    run = false;
  } else {
    file = selection.getAbsolutePath();
    println("User selected " + selection.getAbsolutePath());
  }
}

int standby = 0;

public void setup(){
  //size(900,600);
  
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
  
  cAir_Temperature = color(0xff4828aa);
  cAir_Humidity = color(0xffffa228);
  cSoil_Humidity = color(0xffdfff28);
  cLight_Level = color(0xffff28df);

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

public void keyPressed(){
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

public void draw(){
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
//http://www.sunshine2k.de/articles/coding/datediffindays/calcdiffofdatesindates.html
int[] daysUpToMonth = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };
int[] daysUpToMonthLeapYear = { 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 };

public static boolean IsLeapYear(int y){
  return (y%4 == 0 ? (y%100 == 0 ? (y%400 == 0 ? true : false) : true) : false);
}

public static boolean IsDate1BeforeThanDate2(int y1, int m1, int d1, int y2, int m2, int d2)
{
  return (y1 < y2 ? true : (y1 == y2 ? (m1 < m2 ? true : (m1 == m2 ? (d1 < d2 ? true : false) : false)):false));
}
public int GetRemainingDaysInYear(int month, int day, boolean isLeapYear){
  if (isLeapYear){
    return 366 - (daysUpToMonthLeapYear[month - 1] + day);
  }else{
    return 365 - (daysUpToMonth[month - 1] + day);
  }
}

public int GetDaysInYearTillDate(int month, int day, boolean isLeapYear){
  if (isLeapYear){
    return daysUpToMonthLeapYear[month - 1] + day;
  }else{
    return daysUpToMonth[month - 1] + day;
  }
}

public int GetDiffInDaysInSameYear(int month1, int day1, int month2, int day2, boolean isLeapYear){
  if (isLeapYear){
    return daysUpToMonthLeapYear[month2 - 1] - daysUpToMonthLeapYear[month1 - 1] + (day2 - day1);
  }else{
    return daysUpToMonth[month2 - 1] - daysUpToMonth[month1 - 1] + (day2 - day1);
  }
}

public int GetDifference(int yearPreceding,int monthPreceding, int dayPreceding, int yearSubsequent, int monthSubsequent, int daySubsequent){
  if (yearPreceding == yearSubsequent){ /* same year, easy special case */
    return GetDiffInDaysInSameYear(monthPreceding, dayPreceding, monthSubsequent, daySubsequent, IsLeapYear(yearPreceding));
  }else{
    int resultDays = 0;
    /* Step 1: handle first (incomplete) year */
    resultDays = GetRemainingDaysInYear(monthPreceding, dayPreceding, IsLeapYear(yearPreceding));
    /* first year is now handled */
    yearPreceding++;
    /* Step 2: handle 'full' years */
    while (yearPreceding < yearSubsequent){
      resultDays += IsLeapYear(yearPreceding) ? 366 : 365;
      yearPreceding++;
    }
    /* Step 3: handle last (incomplete) year */
    resultDays += GetDaysInYearTillDate(monthSubsequent, daySubsequent, IsLeapYear(yearSubsequent));
    return resultDays;
  }
}

public int TimeDiff(String date1, String date2){
  
  String[] dt1 = split(date1,' ');
  String[] dt2 = split(date2,' ');
  String[] T1 = split(dt1[1],':');
  String[] T2 = split(dt2[1],':');
  String[] D1 = split(dt1[2],'.');
  String[] D2 = split(dt2[2],'.');
  
  int y1 = PApplet.parseInt(D1[2]);
  int y2 = PApplet.parseInt(D2[2]);
  int m1 = PApplet.parseInt(D1[1]);
  int m2 = PApplet.parseInt(D2[1]);
  int d1 = PApplet.parseInt(D1[0]);
  int d2 = PApplet.parseInt(D2[0]);
  
  int h1 = PApplet.parseInt(T1[0]);
  int h2 = PApplet.parseInt(T2[0]);
  int mi1 = PApplet.parseInt(T1[1]);
  int mi2 = PApplet.parseInt(T2[1]);
  
  int dayd = GetDifference(y1,m1,d1,y2,m2,d2);
  
  if(dayd == 0){
    return (60*(h2 - h1) + (mi2 - mi1));
  }else {
    dayd--;
    return (60*(24-h1+h2) + mi2 - mi1 + (dayd * 1440));
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#505050", "--stop-color=#FF1216", "DataPlotter" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
