// https://www.microchip.com
//https://github.com/greiman/SdFat-beta


//==================================
//Inicjalizyję wszystkie biblioteki
#include "RTClib.h"               //Zegar czasu rzeczywistego
#include "SdFs.h"                 //Czytnik karty SD
#include <DHT.h>                  //Czyjnik wilgotności i temperatury
#include <LiquidCrystal_I2C.h>    //Wyświetlacz LCD
#include <Wire.h>                 //BUS I2C
//==================================


//==================================
//Definiuje wszystkie wartości niezmienne
#define SD_CS_PIN 4                       //Chip select pin kardty SD
#define LED_ERROR_PIN 2                   //Pin LED'a błędu
#define LCD_Button 6                      //Przycisk włączania ekrany LCD
//==================================

//==================================
//Inicjalizuję wszytkie struktury układów zintegrowanych
LiquidCrystal_I2C lcd(0x27, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE); //LCD
RTC_DS1307 rtc;                                                //Zegar czasu rzeczywistego
DHT dht(9, DHT11);                                             //Czujnik wilgotności i temperatury
SdExFat sd;                                                    //Karta SD
ExFile cs;                                                     //Plik na karcie SD
//==================================

//==================================
//Definiuję wszystkie zmienne 
char *csvName = "data.csv"; //String z nazwą pliku na karcie SD
long modPrintData = 600000; //jak często następują pomiary na kartę SD w milisekundach (10 minut)
bool showing = 0;           //informacja czy LCD w tym momencie ma coś pokazywać
//==================================


//==================================
//Inicjaliuję wszystkie rutyny 
void lcdturn(bool a);                                               //Włączenie LCD
float getLight();                                                   //Pobranie wartości nasłonecznienia
float getHumidity();                                                //Pobranie wartości wilgotności
void printToLCD(float Hum, float Temp, float SoilH, float Light);   //Wypisanie na LCD
void printToSD(float Hum, float Temp, float SoilH, float Light);    //Wypisanie do karty SD
String parseTime();                                                 //Pobranie godziny z Zegara
String parseDate();                                                 //Pobraniae pełnej daty z Zegara
void blinkLed(int pin, int num);                                    //Mrógnięcie LEDem n razy
float mapfloat(float x, float in_min, float in_max, float out_min,  //zmiana zakresu zmiennej zmiennoprzecinkowej
               float out_max);
//===================================


//===================================
//rutyna startu arduino uruchamiana raz przy uruchomieniu kontrolera
void setup() {
  //  Serial.begin(9600); //Debugging
  
  pinMode(LCD_Button, INPUT);       //Ustawienie pinu przycisku ekranu jako wejście
  pinMode(LED_ERROR_PIN, OUTPUT);   //Ustawienie pinu LEDu błędu jako wyjście

  digitalWrite(LED_ERROR_PIN, LOW); //Włączenie LEDu błędu

  if (!sd.begin(SD_CS_PIN)) {           //jeżeli nie udało się uruchomić czytnika karty SD zaświeć LED
    digitalWrite(LED_ERROR_PIN, HIGH);
  }
  
  dht.begin();   //uruchaom czujnik temperatury i wilgotności

  if (!rtc.begin()) {                  //jeżeli nie udało się uruchomić zegara czasu rzeczywistego zaświeć LED
    digitalWrite(LED_ERROR_PIN, HIGH);
  }

  if (!rtc.isrunning()) {              //Debugging 
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    blinkLed(LED_ERROR_PIN, 10);
    digitalWrite(LED_ERROR_PIN, HIGH);
  }

  lcd.begin(16, 2);     //  }
  lcd.noBacklight();    //  } uruchomienie i zgaszenie wyświetlacza LCD   
  lcd.setCursor(0, 0);  //  }
}
//===================================

//===================================
//pętla wykonawcza arduino
void loop() {
  if (digitalRead(LCD_Button)) {           //jeżeli wciśniesz przycisk ekranu LCD włącz ekran LCD
    showing = !showing;
    lcdturn(showing);
  }
  
  if ((millis() % modPrintData) < 300) {  //co 10 minut pobierz dane z czujników i zapisz je na karcie SD
    float h = dht.readHumidity();
    float t = dht.readTemperature();
    float sh = getSHumidity();
    float ll = getLight();
    blinkLed(LED_ERROR_PIN, 3);
    printToSD(h, t, sh, ll);
  }

  if (showing) {                          //jeżeli masz wyświetlać na LCD, zbierz dane i je wyświetl
    float h = dht.readHumidity();
    float t = dht.readTemperature();
    float sh = getSHumidity();
    float ll = getLight();
    printToLCD(h, t, sh, ll);
    delay(100);
  }
}
//===================================


//===================================
//Dokładne zadeklarowanie rutyn użytych w kodzie
void lcdturn(bool a) {
  if (a) {
    lcd.display();
    lcd.backlight();
  } else {
    lcd.noDisplay();
    lcd.noBacklight();
  }
  delay(500);
}

String parseTime() {
  DateTime now = rtc.now();
  String ret;
  if (now.hour() < 10) {
    ret += 0;
  }
  ret += now.hour();
  ret += ":";
  if (now.minute() < 10) {
    ret += 0;
  }
  ret += now.minute();
  return ret;
}

String parseDate() {
  DateTime now = rtc.now();
  String ret;
  if (now.hour() < 10) {
    ret += 0;
  }
  ret += now.hour();
  ret += ":";
  if (now.minute() < 10) {
    ret += 0;
  }
  ret += now.minute();
  ret += " ";
  ret += now.day();
  ret += ".";
  ret += now.month();
  ret += ".";
  ret += now.year();

  return ret;
}

float getLight() {
  float rawL = 0;
  for (int i = 0; i < 50; i++) {
    rawL = rawL + (analogRead(A1) / 50.);
    delay(1);
  }
  return mapfloat(rawL, 0., 1028., 0., 100.);
}

float getSHumidity() {
  int rawH = 0;
  for (int i = 0; i < 50; i++) {
    rawH = rawH + (analogRead(A0) / 50.);
    delay(1);
  }
  return mapfloat(rawH, 0., 1028., 0., 100.);
}

void printToLCD(float Hum, float Temp, float SoilH, float Light) {
  String printh = "H:";
  printh += Hum;
  printh += " sH:";
  printh += SoilH;
  String printt = "T:";
  printt += Temp;
  printt += "  L:";
  printt += Light;
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(printh);
  lcd.setCursor(0, 1);
  lcd.print(printt);
}

void blinkLed(int pin, int num) {
  for (int i = 0; i < num; i++) {
    digitalWrite(pin, HIGH);
    delay(30);
    digitalWrite(pin, LOW);
    delay(70);
  }
}

void printToSD(float Hum, float Temp, float SoilH, float Light) {
  String _time = parseTime();
  String _date = parseDate();
  if (!cs.open(csvName, FILE_WRITE)) {
    digitalWrite(LED_ERROR_PIN, HIGH);
  }
  String toSD;
  toSD += Temp;
  toSD += ", ";
  toSD += Hum;
  toSD += ", ";
  toSD += SoilH;
  toSD += ", ";
  toSD += Light;
  toSD += ", ";
  toSD += _time;
  toSD += ", ";
  toSD += _date;
  //  Serial.println(toSD);
  cs.println(toSD);
  cs.close();
}

float mapfloat(float x, float in_min, float in_max, float out_min,
               float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
//===================================
