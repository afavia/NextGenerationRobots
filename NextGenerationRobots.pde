
#include <SPI.h>

// set pin 10 as the slave select for the digital pot:
const int slaveSelectPin = 10;

void setup()
{
  // set the slaveSelectPin as an output:
  pinMode (slaveSelectPin, OUTPUT);
  // initialize SPI:
  SPI.begin(); 
}

void loop()
{
  getEthernet();
  sendToCar();
}

//ethernet to arduino code
void getEthernet()
{
}

//arduino to car code
void sendToCar()
{
}


