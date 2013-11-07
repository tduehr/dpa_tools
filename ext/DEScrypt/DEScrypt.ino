#include <DES.h>

// char Data[16];
volatile char key[8] = {0xda, 0xff, 0x37, 0x8c, 0x02, 0x46, 0x10, 0xfb};
// char key1[8] = {0xda, 0xff, 0x37, 0x8c, 0x02, 0x46, 0x10, 0xfb};
// char key2[8] = {0x01,0x23,0x45,0x67,0x89,0xab,0xdc,0xfe};
volatile char plain[8] = {0x41,0x41,0x41,0x41,0x41,0x41,0x41,0x41};
// char x[24] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8b, 0xe9, 0xed, 0xb5, 0x00, 0x00, 0x00}; //enc(RndB
// char v[] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14,0x15,0x16}; 
// char y[8] = {0x05, 0x3F, 0x41,0xDA, 0x27, 0x26, 0xE4, 0x29};//RnadA
volatile char temp[8];
// char rb[] = {0x51, 0x5f, 0xbc, 0x06,0x10, 0xf4,0xaf,0x03};
// char ra[] = {0x79, 0xd4, 0x66, 0x29,0xf7,0xe1,0x12,0xc3};
// char IV[8];
// char IV2[8];
// char t1,t2;
volatile int debug = 0;
// const int buttonPin = PUSH2;     // the number of the pushbutton pin
// static const int GREEN_LED =  GREEN_LED;      // the number of the LED pin
// int buttonState = 0;         // variable for reading the pushbutton status
// byte ledState = LOW;         // the current state of the output pin
// int lastButtonState = LOW;   // the previous reading from the input pin
// long lastDebounceTime = 0;  // the last time the output pin was toggled
// long debounceDelay = 50;    // the debounce time; increase if the output flickers

int read8(volatile char* buf){
  return Serial.readBytes((char*)buf, 8);
}

void print8(volatile char* buf){
  for (int i = 0; i < 8; i++){
    if ((unsigned char)buf[i] < 16)
      Serial.print("0");
    Serial.print((unsigned char)buf[i], HEX);
    if (debug && i < 7)
      Serial.print(":");
  }
  Serial.print("\r\n");
}

void copy_to_temp(volatile char* buf){
  for (int i = 0; i < 8; i++)
    temp[i] = buf[i];
}

void encrypt(volatile char* buf, volatile char* ckey){
  des_ctx dc;
  Des_Key(&dc, (unsigned char*)ckey, ENDE);
  Des_Enc(&dc, (unsigned char*)buf, 1);
}

void setup()
{
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  digitalWrite(RED_LED, HIGH);
  delay(500);
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(RED_LED, LOW);
  Serial.begin(9600); // msp430g2231 must use 4800
  while (Serial.available() <= 0) {
    Serial.print('A'); // send a capital A
    digitalWrite(RED_LED, HIGH);
    delay(300);
    digitalWrite(RED_LED, LOW);
    delay(300);
  }
  Serial.println('A');
  delay(100);
  Serial.flush();
  srand(millis());
}

void loop()
{
  char command;
  if (Serial.available() > 0) {
    digitalWrite(RED_LED, HIGH);
    command = Serial.read();
    if (debug)
      Serial.println(command);
    switch (command) {
    case 'E':
      copy_to_temp(plain);
      if (debug)
        print8(temp);
      digitalWrite(GREEN_LED, HIGH);
      encrypt(temp, key);
      digitalWrite(GREEN_LED, LOW);
      print8(temp);
      break;
    case 'D':
      debug = Serial.read();
      break;
    case 'R':
      for(int i = 0; i < 8; i++) {
        unsigned char rnd = (((unsigned char)rand()) % (unsigned char)26);
        Serial.print(rnd, HEX);
        if (i < 7)
          Serial.print(":");
        else
          Serial.print("|");
        plain[i] = (unsigned char)((unsigned char)(rnd % (unsigned char)26) + (unsigned char)0x41);
      }
      if (debug)
        print8(plain);
      break;
    case 'r':
      for(int i = 0; i < 8; i++) {
        key[i] = (rand() % 256);
      }
      if (debug)
        print8(key);
      break;
    case 'C':
      for(int i = 0; i < 8; i++) {
        plain[i] = (rand() % 26) + 0x41;
      }
      if (debug)
        print8(plain);

      copy_to_temp(plain);
      digitalWrite(GREEN_LED, HIGH);
      encrypt(temp, key);
      digitalWrite(GREEN_LED, LOW);
      print8(temp);
      break;
    case 'K':
      print8(key);
      break;
    case 'k':
      read8(key);
      break;
    case 'P':
      print8(plain);
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
    digitalWrite(RED_LED, LOW);
  }
  delay(300);
}
