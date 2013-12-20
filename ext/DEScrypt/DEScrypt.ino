#include <DES.h>

volatile uint8_t key[8] = {0xda, 0xff, 0x37, 0x8c, 0x02, 0x46, 0x10, 0xfb};
volatile uint8_t plain[8] = {0x41,0x41,0x41,0x41,0x41,0x41,0x41,0x41};
volatile uint8_t temp[8];
volatile uint8_t debug = 0;

int read_buf(volatile uint8_t* buf, size_t len){
  return Serial.readBytes((char*)buf, len);
}

void hex_print(volatile const uint8_t* buf, size_t len){
  for (size_t i = 0; i < len; i++){
    if ((uint8_t)buf[i] < 16)
      Serial.print("0");
    Serial.print(buf[i], HEX);
    if (debug && i < 7)
      Serial.print(":");
  }
  Serial.println("");
}

void copy_to_temp(volatile const uint8_t* buf, size_t len){
  for (size_t i = 0; i < len; i++)
    temp[i] = buf[i];
}

void encrypt(volatile const uint8_t* in, volatile uint8_t* out, volatile uint8_t* ckey){
  digitalWrite(GREEN_LED, HIGH);
  des_enc((void *)out, (const void *)in, (const void *)ckey);
  digitalWrite(GREEN_LED, LOW);
}

void decrypt(volatile const uint8_t* in, volatile uint8_t* out, volatile uint8_t* ckey){
  digitalWrite(GREEN_LED, HIGH);
  des_dec((void *)out, (const void *)in, (const void *)ckey);
  digitalWrite(GREEN_LED, LOW);
}

void randomize_buffer(volatile uint8_t* buf, size_t len){
  for(size_t i = 0; i < len; i++)
    buf[i] = rand() % 256;
}

void setup()
{
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  digitalWrite(RED_LED, HIGH);
  delay(500);
  digitalWrite(RED_LED, LOW);
  delay(500);
  digitalWrite(RED_LED, HIGH);
  delay(400);
  digitalWrite(RED_LED, LOW);
  delay(400);
  digitalWrite(RED_LED, HIGH);
  delay(300);
  digitalWrite(RED_LED, LOW);
  delay(300);
  digitalWrite(RED_LED, HIGH);
  delay(200);
  digitalWrite(RED_LED, LOW);
  delay(200);
  digitalWrite(RED_LED, HIGH);
  delay(100);
  digitalWrite(RED_LED, LOW);
  digitalWrite(GREEN_LED, LOW);
  Serial.begin(9600); // msp430g2231 must use 4800
  delay(100);
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
      if (debug)
        hex_print(temp,8);
      encrypt(plain, temp, key);
      hex_print(temp,8);
      break;
    case 'e':
      // not needed for DES implementation
      decrypt(plain, temp, key);
      hex_print(temp, 8);
      break;
    case 'D':
      Serial.println(debug);
      break;
    case 'd':
      debug = Serial.read() - 0x30;
      Serial.println(debug);
      break;
    case 'G':
    case 'R':
      randomize_buffer(plain, 8);
      hex_print(plain,8);
      break;
    case 'g':
    case 'r':
      randomize_buffer(key, 8);
      hex_print(key,8);
      break;
    case 'C':
      randomize_buffer(plain, 8);
      hex_print(plain,8);

      encrypt(plain, temp, key);
      hex_print(temp,8);
      break;
    case 'K':
      hex_print(key,8);
      break;
    case 'k':
      read_buf(key,8);
      hex_print(key,8);
      break;
    case 'P':
      hex_print(plain,8);
      break;
    case 'p':
      read_buf(plain,8);
      hex_print(plain,8);
      break;
    default:
      Serial.println("");
      break;
    }
    digitalWrite(RED_LED, LOW);
  }
  delay(100);
}
