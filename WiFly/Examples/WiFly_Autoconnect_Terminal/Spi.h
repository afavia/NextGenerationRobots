
#ifndef __SPI_H__
#define __SPI_H__

#include <WProgram.h>

// SPI Pin definitions
#define CS         53
#define MOSI       51
#define MISO       50
#define SCK        52


// TODO: Do we want to use this instead: <http://www.arduino.cc/playground/Code/Spi>
class SpiDevice {
  public:
    SpiDevice();
    
    void begin();
    void begin(byte selectPin);

    // TODO: Make these private (or protected) in the final library?
    void deselect();
    void select();

    byte transfer(volatile byte data);
    void transfer_bulk(const uint8_t* srcptr, unsigned long int length);

    
  private:
    void _initPins();
    void _initSpi();    
  
    byte _selectPin;
    
};

#endif

