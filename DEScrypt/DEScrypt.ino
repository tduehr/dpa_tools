#include <DES.h>

des_ctx dc;
unsigned char Data[16];
unsigned char *cp,key[8] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
unsigned char key1[8] = {0xda, 0xff, 0x37, 0x8c, 0x02, 0x46, 0x10, 0xfb};
unsigned char key2[8] = {0x01,0x23,0x45,0x67,0x89,0xab,0xdc,0xfe};
unsigned char plain[9] = {0x41,0x41,0x41,0x41,0x41,0x41,0x41,0x41,0x00};
unsigned char x[24] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8b, 0xe9, 0xed, 0xb5, 0x00, 0x00, 0x00}; //enc(RndB
unsigned char v[] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14,0x15,0x16}; 
unsigned char y[8] = {0x05, 0x3F, 0x41,0xDA, 0x27, 0x26, 0xE4, 0x29};//RnadA
unsigned char temp[8];
unsigned char rb[] = {0x51, 0x5f, 0xbc, 0x06,0x10, 0xf4,0xaf,0x03};
unsigned char ra[] = {0x79, 0xd4, 0x66, 0x29,0xf7,0xe1,0x12,0xc3};
unsigned char IV[8];
unsigned char IV2[8];
unsigned char t1,t2;
int debug = 0;
const int buttonPin = PUSH2;     // the number of the pushbutton pin
const int ledPin =  GREEN_LED;      // the number of the LED pin
int buttonState = 0;         // variable for reading the pushbutton status
int ledState = HIGH;         // the current state of the output pin
int lastButtonState = LOW;   // the previous reading from the input pin
long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 50;    // the debounce time; increase if the output flickers

int read8(char* buf){
  return Serial.readBytes(buf, 8);
}

void print8(char* buf){
  for (int i = 0; i < 8; i++)
    Serial.print(key[i], HEX);
  Serial.print("\n");
}

void copy_to_tmp(char* buf){
  for (int i = 0; i < 8; i++)
    tmp[i] = buf[i];
}

void encrypt(char* buf, char* ckey){
  Des_Key(&dc, ckey, ENDE);
  Des_Enc(&dc, buf, 1);
}

void setup()
{
  pinMode(ledPin, OUTPUT);
  Serial.begin(4800); // msp430g2231 must use 4800
  for(int i = 0; i<8; i++)
    key[i] = key1[i];
}

void loop()
{
  char command;
  int result;
  if (Serial.available()) {
    command = Serial.read();
    switch (command) {
    case 'E':
      copy_to_tmp(plain);
      if (debug)
        print8(tmp);
      digitalWrite(ledPin, HIGH);
      encrypt(tmp);
      digitalWrite(ledPin, LOW);
      print8(tmp);
      break;
    case 'D':
      debug = Serial.read();
      break;
    case 'R':
      for(int i = 0; i < 8; i++) {
        plain[i] = (rand() % 26) + 0x41;
      }
      break;
    case 'r':
      for(int i = 0; i < 8; i++) {
        key[i] = (rand() % 256);
      }
      break;
    case 'C':
      for(int i = 0; i < 8; i++) {
        plain[i] = (rand() % 26) + 0x41;
      }
      if (debug)
        print8(plain);

      copy_to_tmp(plain);
      digitalWrite(ledPin, HIGH);
      encrypt(tmp);
      digitalWrite(ledPin, LOW);
      print8(tmp);
      break;
    case 'K':
      print8(key);
      break;
    case 'k':
      read8(key);
      break;
    case 'P':
      print8(plain)
    case 'p':
      read8(plain);
      break;
    case 'G':
      for(int i = 0; i < 8; i++) {
        key[i] = (rand() % 256);
      }
      if (debug)
        print8(key);
      break;
    }
  }
}
