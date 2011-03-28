#include "WiFly.h"
#include <SPI.h>

char ssid[] = "wifly";
char password[] = "phack111";
byte mac[] = { 0x00, 0x06, 0x66, 0x13, 0xCA, 0x02 };
byte ip[] = { 192,168,1,169 };

// telnet defaults to port 23
Server server(23);
boolean gotAMessage = false; // whether or not you got a message from the client yet

const int fwdPin = 10;
const int revPin = 11;
const int rgtPin = 12;
const int lftPin = 13;

void setup() {
  
  pinMode(fwdPin, OUTPUT); 
  pinMode(revPin, OUTPUT);
  pinMode(rgtPin, OUTPUT);
  pinMode(lftPin, OUTPUT);
  
  Serial.println("Connecting to network");
  // initialize the wifly device
  WiFly.begin();
  if (!WiFly.join(ssid)) {
    Serial.println("Association failed.");
    while (1) {
      // Hang on failure.
    }
  }
  
  Serial.println("Associated!");
  // start listening for clients
  server.begin();
  // open the serial port
  Serial.begin(9600);
  delay(3000);
  Serial.println("Enter Commands");
}

byte temp=0;

void ProcessCMD( byte command ) {
  Serial.print("CMD: ");
  Serial.print((char)command);
  Serial.print("\n");
}

void loop() {
  // wait for a new client:
  Client client = server.available();
  
  if (client) {
    byte b = client.read();
    if ( b <= 122 && b >= 48 ) {
      temp = b;
    }
    else if ( b == 13 ) {
      ProcessCMD2(temp);
    }
  }
}

void ProcessCMD2( byte b ) {
  char command;
  command = char(b);
  
  if (command == 'f')
    ForwardOn();
  else if (command == 'b')
    ReverseOn();
  else if (command == 'r')
    RightOn();
  else if (command == 'l')
    LeftOn();
  else if (command == 'g')
    ForwardOff();
  else if (command == 'n')
    ReverseOff();
  else if (command == 't')
    RightOff();
  else if (command == 'a')
    LeftOff();
  else
    Serial.println("Invalid Command");
}

// these functions are where the motor control 
// will go

//SET HIGHS (PRESS)
void ForwardOn() {
   Serial.println("ForwardOn()");
   digitalWrite(fwdPin, HIGH);
}

void ReverseOn() {
   Serial.println("ReverseOn()");
   digitalWrite(revPin, HIGH);
}

void RightOn() {
   Serial.println("RightOn()");
   digitalWrite(rgtPin, HIGH);
}

void LeftOn() {
   Serial.println("LeftOn()");
   digitalWrite(lftPin, HIGH); 
}


// SET LOWS (RELEASE)
void ForwardOff() {
   Serial.println("ForwardOff()");
   digitalWrite(fwdPin, LOW);
}

void ReverseOff() {
   Serial.println("ReverseOff()");
   digitalWrite(revPin, LOW);
}

void RightOff() {
   Serial.println("RightOff()");
   digitalWrite(rgtPin, LOW);
}

void LeftOff() {
   Serial.println("LeftOff()");
   digitalWrite(lftPin, LOW); 
}


