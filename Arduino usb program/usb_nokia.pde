#include <Spi.h>
#include <Max3421e.h>
#include <Usb.h>
#include <avr/pgmspace.h>
#include "nokia.h"

#define CONTROL_PIPE 0
#define OUTPUT_PIPE 12
#define CONTIF_PIPE 11
#define DEVADDR 1
#define CONFVALUE 1
prog_char TransferBuffer;

void setup();
void loop();
 
MAX3421E Max;
USB Usb;
char buf[ 64 ];  
EP_RECORD ep_record[15];


int ledPin = 6; 
void setup()
{
    Serial.begin( 115200);
    Serial.println("Start");
    Max.powerOn();
    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, LOW);
    delay( 200 );
}
 
void loop()
{
  int i;
 byte rcode;

    
    Max.Task();
    Usb.Task();
    if( Usb.getUsbTaskState() == USB_STATE_CONFIGURING ) {  
        Nokia_init();
    }//if( Usb.getUsbTaskState() == USB_STATE_CONFIGURING...
    if( Usb.getUsbTaskState() == USB_STATE_RUNNING) {  //poll the keyboard  
        Nokia_poll();  
    }//if( Usb.getUsbTaskState() == USB_STATE_RUNNING...
    
      
}
/* Initialize mouse */
void Nokia_init( void )
{
 byte rcode = 0;  //return code
 char buf[64]={0};
 int i;
  

  ep_record[ CONTROL_PIPE ] = *( Usb.getDevTableEntry( 0,0 ));  //copy endpoint 0 parameters
  
  ep_record[ OUTPUT_PIPE ].epAddr = 0x0c;    // PS3 output endpoint
  ep_record[ OUTPUT_PIPE ].Attr  = 0x02;
  ep_record[ OUTPUT_PIPE ].MaxPktSize = 64;
  ep_record[ OUTPUT_PIPE ].Interval  = 0x00;
  ep_record[ OUTPUT_PIPE ].sndToggle = bmSNDTOG0;
  ep_record[ OUTPUT_PIPE ].rcvToggle = bmRCVTOG0;
  

    
  Usb.setDevTableEntry( 1, ep_record ); 

  //copy device 0 endpoint information to device 1
  /* Configure device */
  
  /*Usb.setConf(1,ep_record[ CONTROL_PIPE ].epAddr,0);
  
  
  Serial.println("Get Descriptor...");
  Usb_request(0x80,0x06,0x00,0x01,0x00,0x00,0x12,0x00,buf);
  
  */

  
  
  Serial.println("Set Config...   ");
  Usb.setConf(1,ep_record[ CONTROL_PIPE ].epAddr,1);
   
  Serial.println("Set interface...   ");
  //Usb_request(0x01,0x0b,0x01,0x00,interface,0x00,0x00,0x00,buf);
  
  //request estranho

 Serial.println("Configure Data Class Interface...");
 Usb_request(0x21,0x22,0x02,0x00,0x0c,0x00,0x00,0x00,buf);
  
  
 
 /*
  
  
  Serial.println("Configure Data Class Interface...");
  Usb_request(0x21,0x22,0x03,0x00,0x0c,0x00,0x00,0x00,buf);*/
  
  Usb.setUsbTaskState( USB_STATE_RUNNING );
  Serial.println("Inicialized");
  return;
}

/* Poll mouse using Get Report and print result */
byte Nokia_poll( void )
{
  byte rcode,i;
    /* poll mouse */
    rcode=Usb.inTransfer(1,0x0c,1,buf);
    
    if( rcode ) {  //error
    Serial.print("Rcode:");
    Serial.println(rcode,HEX);
    return(0);
    }
    
      if(int(buf[0])=='a')digitalWrite(ledPin, HIGH);
      if(int(buf[0])=='d')digitalWrite(ledPin, LOW);
      
  Serial.print(int(buf[0]));
    Serial.println(buf[0]);

}

void Usb_request(byte Reqtype,byte req,byte val_lo,byte val_hi,byte ind_lo,byte ind_hi,byte len_lo,byte len_hi, char *data){
   byte rcode = 0;  //return code

 int i;
 byte Length=(len_hi|len_lo);
 byte Index= (ind_hi|ind_lo);
 rcode = Usb.ctrlReq( 1, ep_record[ CONTROL_PIPE ].epAddr,Reqtype,req,val_lo,val_hi,int(Index),int(Length),data);
 if( rcode ) {
        Serial.print("Request error: ");
        Serial.println( rcode, HEX );
    }
}
