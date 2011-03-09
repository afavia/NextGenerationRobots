/*
 * WiFly UART-SPI bridge Example
 * Copyright (c) 2010 SparkFun Electronics.  All right reserved.
 * Written by Chris Taylor
 *
 * This code was written to demonstrate the WiFly Shield from SparkFun Electronics
 * 
 * This code will initialize and test the SC16IS750 UART-SPI bridge, and allow
 * transparent communication with the device from a terminal.
 *
 * http://www.sparkfun.com
 */

#include <string.h> // Required for strlen()

// SCI16IS750 Registers 
#define THR        0x00 << 3
#define RHR        0x00 << 3
#define IER        0x01 << 3
#define FCR        0x02 << 3
#define IIR        0x02 << 3
#define LCR        0x03 << 3
#define MCR        0x04 << 3
#define LSR        0x05 << 3
#define MSR        0x06 << 3
#define SPR        0x07 << 3
#define TXFIFO     0x08 << 3
#define RXFIFO     0x09 << 3
#define DLAB       0x80 << 3
#define IODIR      0x0A << 3
#define IOSTATE    0x0B << 3
#define IOINTMSK   0x0C << 3
#define IOCTRL     0x0E << 3
#define EFCR       0x0F << 3

#define DLL        0x00 << 3
#define DLM        0x01 << 3
#define EFR        0x02 << 3
#define XON1       0x04 << 3  
#define XON2       0x05 << 3
#define XOFF1      0x06 << 3
#define XOFF2      0x07 << 3

// Arduino SPI pins
//#define CS         10
//#define MOSI       11
//#define MISO       12
//#define SCK        13

// Arduino SPI pins
#define CS         53
#define MOSI       51
#define MISO       50
#define SCK        52

// Communication flags and variables
char incoming_data; 
char TX_Fifo_Address = THR; 

char clr = 0;
char polling = 0;

// SC16IS750 Configuration Parameters
struct SPI_UART_cfg
{
  char DivL,DivM,DataFormat,Flow;
};

struct SPI_UART_cfg SPI_Uart_config = {
  0x50,0x00,0x03,0x10};

void setup()
{
  // Initialize SPI pins
  pinMode(MOSI, OUTPUT);
  pinMode(MISO, INPUT);
  pinMode(SCK,OUTPUT);
  pinMode(CS,OUTPUT);
  digitalWrite(CS,HIGH); //disable device 

  SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR1)|(1<<SPR0);
  clr=SPSR;
  clr=SPDR;
  delay(10); 

  Serial.begin(9600);
  Serial.println("\n\r\n\rWiFly Shield Terminal Routine");

  // Test SPI communication
  if(SPI_Uart_Init()){ 
    Serial.println("Bridge initialized successfully!"); 
  }
  else{ 
    Serial.println("Could not initialize bridge, locking up.\n\r"); 
    while(1); 
  }
}

void loop()
{
  // Poll for new data in SC16IS750 Recieve buffer 
  if(SPI_Uart_ReadByte(LSR) & 0x01)
  { 
    polling = 1;
    while(polling)
    {
      if((SPI_Uart_ReadByte(LSR) & 0x01))
      {
        incoming_data = SPI_Uart_ReadByte(RHR);
        Serial.print(incoming_data,BYTE);
      }  
      else
      {
        polling = 0;
      }
    }

  }
  // Otherwise, send chars from terminal to SC16IS750
  else if(Serial.available())
  {
    incoming_data = Serial.read();
    select();
    spi_transfer(0x00); // Transmit command
    spi_transfer(incoming_data);
    deselect();
  }

}



char SPI_Uart_Init(void)
// Initialize SC16IS750
{
  char data = 0;

  SPI_Uart_WriteByte(LCR,0x80); // 0x80 to program baudrate
  SPI_Uart_WriteByte(DLL,SPI_Uart_config.DivL); //0x50 = 9600 with Xtal = 12.288MHz
  SPI_Uart_WriteByte(DLM,SPI_Uart_config.DivM); 

  SPI_Uart_WriteByte(LCR, 0xBF); // access EFR register
  SPI_Uart_WriteByte(EFR, SPI_Uart_config.Flow); // enable enhanced registers
  SPI_Uart_WriteByte(LCR, SPI_Uart_config.DataFormat); // 8 data bit, 1 stop bit, no parity
  SPI_Uart_WriteByte(FCR, 0x06); // reset TXFIFO, reset RXFIFO, non FIFO mode
  SPI_Uart_WriteByte(FCR, 0x01); // enable FIFO mode

  // Perform read/write test to check if UART is working
  SPI_Uart_WriteByte(SPR,'H');
  data = SPI_Uart_ReadByte(SPR);

  if(data == 'H'){ 
    return 1; 
  }
  else{ 
    return 0; 
  }

}

void SPI_Uart_WriteByte(char address, char data)
// Write byte to register address on SC16IS750
{
  long int length;
  char senddata[2];
  senddata[0] = address;
  senddata[1] = data;

  select();
  length = SPI_Write(senddata, 2);
  deselect();
}

long int SPI_Write(char* srcptr, long int length)
// Send entire string to SC16IS750
{
  for(long int i = 0; i < length; i++)
  {
    spi_transfer(srcptr[i]);
  }
  return length; 
}

void SPI_Uart_WriteArray(char *data, long int NumBytes)
// Send entire string to THR of SC16IS750
{
  long int length;
  select();
  length = SPI_Write(&TX_Fifo_Address,1);

  while(NumBytes > 16) // Split array into 16 character chunks
  {
    length = SPI_Write(data,16);
    NumBytes -= 16;
    data += 16;
  }
  length = SPI_Write(data,NumBytes);

  deselect();
}

char SPI_Uart_ReadByte(char address)
// Read from SC16IS750 register
{
  char data;

  address = (address | 0x80);

  select();
  spi_transfer(address);
  data = spi_transfer(0xFF);
  deselect();
  return data;  
}

void SPI_Uart_println(char *data)
// Write string to SC16IS750 followed by a carriage return
{
  SPI_Uart_WriteArray(data,strlen(data));
  SPI_Uart_WriteByte(THR, 0x0d);
}

void SPI_Uart_print(char *data)
// Write string to SC16IS750, no carriage return
{
  SPI_Uart_WriteArray(data,strlen(data));
}

char spi_transfer(volatile char data)
{
  SPDR = data;                    // Start the transmission
  while (!(SPSR & (1<<SPIF)))     // Wait for the end of the transmission
  {
  };
  return SPDR;                    // return the received byte
}

void select(void) 
{
  digitalWrite(CS,LOW);
}

void deselect(void)
{
  digitalWrite(CS,HIGH);
}



