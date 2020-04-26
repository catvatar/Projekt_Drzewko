//To Do:

//Code
//better named variables

//Build

//UI
//choose better colors


//*********************************************************************
//                          ****WAZNE****                            **
//** Przed czytaniem kodu polecam uruchomic najpier aplikacje        **
//** zapewni to kontekst dla komentarzy w kodzie i rozjasnie wiele   **
//** niejasnosci ktore w przeciwnym wypadku mogly bu sie pojawic     **
//** zip ze skompilowanym kodem znajduje sie w tym samym folderze    **
//** co ten plik nalezy go pobrac jesli jeszcze nie jest pobrany     **
//** wypakowac a nastepnie w wypakowanym folderze wizualizator       **
//** znajduje sie Data_plotter.exe ktory uruchomi program            **
//** Data_plotter.exe nie jest wirusem, jest to dokladnie ten kod    **
//** tyle ze juz skompilowany do formy Executable                    **
//** zadziala on jedynie gdy bedzie w folderze wizualizator          **
//** razem z java, lib i source                                      **
//*********************************************************************

Table data;  //Lista do której zostanie wczytany plik

color cAir_Temperature,cAir_Humidity,cSoil_Humidity,cLight_Level;  //zmienne by kolory mi się nie plątały
float[] Air_Temperature,Air_Humidity,Soil_Humidity,Light_Level;  //Tablica do której zostaną zaimportowane dane z listy data
String[] Time,Date;  //To samo tylko z datą

int[] Index;  //zmienna konieczna by odczytywanie czasu z pozycji myszy działało prawidłowo


//deklaracja stałych wybranych empirycznie
static int yrange = 100;
static int xoff = 50,yoff = 50;


// zmienne używane w kodzie
int mlen; 
int len;
int mov = 0;

void axis(int l,int off){  //funkcja tworząca osie X,Y jak i odczytująca wartość z pozycji myszy i wyświetlająca ją w parym i lewym górnym rogu
  int ftime = TimeDiff(Date[off],Date[off + l - 1]); //globalna skala czasu dla obecnie wyswietlanych danych
  float xdiv = (width-xoff)/(ftime*1.); //podziałka dla osi x
  float ydiv = (height-yoff)/yrange; //podziałka dla osi y
  
  int x = xoff; 
  int y = yoff;
  
  int pp = round(l/20.);  //ilość danych podpisanych na ekranie 
  if(pp == 0){
    pp = 1;
  }
  
  float lx = xoff; //zmienna by uwzględnić w obliczeniach offset osi x
  Index[floor(lx)] = off;
  
  //ustalanie parametrów pendzla
  strokeWeight(1);
  stroke(0);
  //===
  
  //tworzenie osi x,Y
  line(x*2/3.,0,x*2/3.,height - y*2/3.);
  line(x*2/3.,height - y*2/3.,width,height - y*2/3.);
  //=====
  
  //podpisanie osi Y
  strokeWeight(2);
  for(int i = 0;i <= yrange;i += 5){
    //ustawienie pedzla
    stroke(0);
    point(x*2/3.,height - (i*ydiv + yoff));
    stroke(255);
    textAlign(RIGHT,TOP);
    //====
    //wlasciwy tekst
    text(str(i),0,height - (i*ydiv + yoff + 10),x*1/2.,20);
    //====
  }
  
  //podpisanie dat na osi X
  for(int i = off + 1;i < off + l;i++){
    lx += TimeDiff(Date[i-1],Date[i]) * xdiv; //obliczenie pozycji na ekranie każdej daty
    Index[floor(lx)-1] = i; //zapisanie pozycji na ekranie do późniejszego odzyskania
    if(i % pp == 0){ //maksymalnie 20 dat jest podpisanych reszta nie jest wyswietlana
      pushMatrix();
      //pandzel
      point(lx,height - yoff*2/3.);
      textAlign(LEFT,TOP);
      translate(lx,height - yoff*2/3.);
      rotate(PI/5);
      //====
      //tekst
      text(Time[i],0,0,200,200);
      //====
      popMatrix();
     }
  }
}
  
void Plot(float[] a,int l,int off,color c){ //narysuj graf funkcji 
  int ftime = TimeDiff(Date[off],Date[off + l - 1]);  //globalna skala czasu dla obecnie wyswietlanych danych
  float xdiv = (width-xoff)/(ftime*1.); //podzialka dla osi X
  
  //float xdiv = (width-xoff)/(l*1.);
  float ydiv = (height-yoff)/yrange; //podzialka dla osi Y
  
  //pendzel
  noFill(); 
  stroke(c);
  strokeWeight(2);
  //=====
  
  float lx = xoff;
  
  beginShape(); //funkcja laczaca kropki 
  vertex(lx,height - (a[off]*ydiv + yoff)); //stawianie kropki
  for(int i = off + 1;i < off + l;i++){
    lx += TimeDiff(Date[i-1],Date[i]) * xdiv;
    vertex(lx,height - (a[i]*ydiv + yoff));   //stawianie kropki
  }
  endShape(); //zfinalizowanie obiektu
}

void drawCursor(int x,int y){ //trywialne rysowanie kursowa
  stroke(0);
  strokeWeight(.5);
  line(xoff*2/3.,y,width,y);
  line(x,0,x,height-(yoff*2/3.));
}

void Legend(int x,int y){ //user interface malo funkcjonalnosci duzo wyswietlania tego co juz policzone wiekszosc z funkcji tu pomine gdzyz sa czysto grafincze i z tego powodu nie ciekawe technicznie
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
    int xi = Index[x];  //dzieki temu ze przy tworzeniu podzialki indeksowalismy czasy w tablicy teraz odzyskanie czasu dla pozycji jest bardzo proste 
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


//ten kod jest kodem przykladowym wczytywania plikow w jezyku java zostal wziety ze strony ponizej  
//dzieje sie tu dziwne mumbo jumbo z funkcjami niezsynchronizowanymi dlatego sam nie jestem w stanie ich wytlumaczyc
//na szczescie wszystko dzialalo tak jak to wkleilem z niewielkimi poprawkami i nie musialem sie w to bardziej zaglebiac 
//nazwilmy to kolejnym poziomem abstrakcji
//https://processing.org/reference/selectInput_.html
//zrudlo kodu do wczytania pliku /\
//                               ||

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

int standby = 0; //niewielkie zmiany wynikajace z tego ze wczytanie pliku jest funkcja async czyli kod przestaje byc wykonywany w po koleji 

//====================

void setup(){ //to jest odwolywane raz na poczatku kodu
  //size(900,600);
  fullScreen();
  
  //dalej mumbo jumbo wczytywania pliku
  selectInput("Select data file to plot","fileSelected");
  while(file == "none"){
    println(standby++); //wypisanie danych do konsoli wymusza wstrzymanie programu dzieki czemu jestem w stanie wstrzymac kod na czas gdy uzytkownik wybiera plik ktory bedzie grafowany
    if(!run){
      return;
    }
    if(standby > 999999){
      println("time_out");
      file = "exit";
    }
  }
  //koniec
  
  
  //wczytanie pliku csv
  data = loadTable(file, "header");
  
  
  //okreslenie ilosci wczytanych danych
  len = data.getRowCount();
  mlen = len;
  
  //deklaracja kazdej tablicy
  Air_Temperature = new float[len];
  Air_Humidity = new float[len];
  Soil_Humidity = new float[len];
  Light_Level = new float[len];
  Time = new String[len];
  Date = new String[len];
  
  Index = new int[width];
  
  //deklaracja kolorow (jestem otwarty na propozycje nie jest ze mnie niestety artysta)
  cAir_Temperature = color(#4828aa);
  cAir_Humidity = color(#ffa228);
  cSoil_Humidity = color(#dfff28);
  cLight_Level = color(#ff28df);


  //wczytanie danych do tablic z pliku 
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


//deklaracja zmiennych koniecznych by przemieszczenia sie po grafie dzialalo oraz by przytrzymywanie klawisza przyspieszalo przyblizanie
int DezoomS = 15;
int zS = 15;
int DescrollS = 10;
int sS = 10;
int zsl = 100;
int ssl = 40;

void keyPressed(){
  zS *= 1.0668;
  sS *= 1.1;
  //println(keyCode);
  switch(keyCode){  //switch statement w celu okreslenia ktory klawisz zostal wcisniety
    case(38):
    //up - zoom in
    len -= zS;
    break;
    case(40):
    //down - zoom out
    len += zS;
    break;
    case(37):
    //left - move left
    mov -= sS;
    break;
    case(39):
    //right - move right
    mov += sS;
    break;
  }
  
  //ograniczenia by nie wyjsc poza zbior 
  len = constrain(len,5,mlen-1);
  mov = constrain(mov,0,mlen-len-1);
  zS = constrain(zS,15,zsl);
  sS = constrain(sS,10,ssl);
}


//zakonczenie przyspieszania i reset do wartosci bazowych
void keyReleased(){
  zS = DezoomS;
  sS = DescrollS;
}


void draw(){ //petla odwolywana 60 razy na sekunde
  
  //jesli nie udalo sie wczytac pliku zamknij program
  if(!run){
    exit();
  }else{
    background(80);
    
    
    //dalej odwoluje wczesniej zadeklarowane funkcje
    Plot(Air_Temperature,len,mov,cAir_Temperature);
    Plot(Air_Humidity,len,mov,cAir_Humidity);
    Plot(Soil_Humidity,len,mov,cSoil_Humidity);
    Plot(Light_Level,len,mov,cLight_Level);
    
    
    axis(len,mov);
    
    //przepisanie indeksow aby (500300700200) ==> (555333777222) ma to znaczenie dla wygody urzytkowania
    for(int i = 1;i < width;i++){
      if(Index[i] == 0){
        Index[i] = Index[i-1];
      }
    }
    
    drawCursor(mouseX,mouseY);
    
    Legend(mouseX,mouseY);
    
    
    //wyzerowanie indeksow przed rysowaniem nastepnej klatki animacji
    for(int i = 0;i < width;i++){
      Index[i] = 0;
    }
    //println(frameRate);
  }
}
