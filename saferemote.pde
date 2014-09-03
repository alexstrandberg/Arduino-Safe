#include <VirtualWire.h>  // you must download and install the VirtualWire.h to your hardware/libraries folder
#include <Keypad.h> //needs to be in the library folder (Arduino/Libraries)

#undef int
#undef abs
#undef double
#undef float
#undef round

boolean isLocked=true;
String password;
int passwordPosition = 0; //Is the user entering the first number of the code, second, third, etc...
boolean isChangingPassword = false;

int redPin = 5; //RGB LED pins
int greenPin = 6;
int bluePin = 10;

int redValue = 0; //Values of the LEDS; used to increment their value by a certain amount
int greenValue = 0;
int blueValue = 0;


const byte ROWS = 4; //four rows
const byte COLS = 3; //three columns
char keys[ROWS][COLS] = {
 {'1','2','3'},
 {'4','5','6'},
 {'7','8','9'},
 {'*','0','#'}
};
byte rowPins[ROWS] = {8, 7, 9, 11}; //connect to the row pinouts of the keypad
byte colPins[COLS] = {2, 3, 4}; //connect to the column pinouts of the keypad

Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS );


void setup()
{
     // Initialise the IO and ISR
    vw_set_ptt_inverted(true);       // Required for RF Link module
    vw_setup(1200);                  // Bits per sec
    vw_set_tx_pin(12);                // pin 3 is used as the transmit data out into the TX Link module, change this to suit your needs.
    vw_set_rx_pin(13); //Pin is not used, only set to change the default pin which is in use (11)
    Serial.begin(9600); //Start a serial connection
    pinMode(13,OUTPUT); //Pin 13 defaults to an input, it needs to be set as an output.
    analogWrite(bluePin,0); //VirtualWire uses timer1, and so does PWM for pins 9 and 10. As a result, the blue LED blinks every time data is sent through the VirtualWire library
    analogWrite(redPin,255); //Red LED indicates that the safe is locked
}

void loop()
{
  if (isLocked==true) {
    char key = keypad.getKey();
    if (key != NO_KEY){
      Serial.println(key);
      switch(key) { //The * key acts as a backspace key, the # key acts as the enter key (when 4 numbers are entered and it is pressed, the password is sent to the receiver. Each time a number key is pressed, the red LED blinks in increasing brightness each time.
        case '*': if(passwordPosition!=0) { passwordPosition--; password[passwordPosition]=0; redValue-=63; analogWrite(redPin,255); analogWrite(greenPin,255); analogWrite(bluePin,255); delay(300); analogWrite(redPin,0); analogWrite(greenPin,0); analogWrite(bluePin,0); } break;
        case '#': if(passwordPosition==4) passwordPosition=5; break;
        default: if(passwordPosition<4) { password+=key; passwordPosition++; redValue+=63; analogWrite(redPin,redValue); delay(200); analogWrite(redPin,0); } break;
      }
      
      Serial.println(passwordPosition);
      
      if (passwordPosition==5&&key=='#') { //4 digits have been entered and the user presses the pound key
        analogWrite(redPin,0); //Red LED goes off, Green LED flashes 3 times
        analogWrite(greenPin,255);
        delay(200);
        analogWrite(greenPin,0);
        delay(200);
        analogWrite(greenPin,255);
        delay(200);
        analogWrite(greenPin,0);
        delay(200);
        analogWrite(greenPin,255);
        delay(200);
        analogWrite(greenPin,0);
        delay(200);
        char msg[4];
        msg[0]=password[0];
        msg[1]=password[1];
        msg[2]=password[2];
        msg[3]=password[3];
        //const char *msg = "hi";
        vw_send((uint8_t *)msg, strlen(msg));
        vw_wait_tx();  // Wait for message to finish
        delay(200);
        vw_send((uint8_t *)msg, strlen(msg));
        vw_wait_tx();
        delay(200);
        vw_send((uint8_t *)msg, strlen(msg));
        vw_wait_tx();
        delay(200);
        vw_send((uint8_t *)msg, strlen(msg));
        vw_wait_tx();
        delay(200);
        vw_send((uint8_t *)msg, strlen(msg));
        vw_wait_tx();
        delay(200);
        isLocked=false;
        analogWrite(bluePin,0);
        passwordPosition=0;
        password="";
        analogWrite(greenPin,255); //Green LED goes on to indicate that the safe is unlocked
      }
    }
  }
  
  else {
      char key = keypad.getKey();
      if (key != NO_KEY){
        Serial.println(key);
        if (isChangingPassword==false) {
          if (key=='#') { //Sends the signal to lock the safe
            analogWrite(greenPin,0);
            analogWrite(redPin,255);
            delay(200);
            analogWrite(redPin,0);
            delay(200);
            analogWrite(redPin,255);
            delay(200);
            analogWrite(redPin,0);
            delay(200);
            analogWrite(redPin,255);
            delay(200);
            analogWrite(redPin,0);
            delay(200);
            char msg[5] = "lock";
            vw_send((uint8_t *)msg, strlen(msg));
            vw_wait_tx();                                          // Wait for message to finish
            delay(200);
            vw_send((uint8_t *)msg, strlen(msg));
            vw_wait_tx();
            delay(200);
            vw_send((uint8_t *)msg, strlen(msg));
            vw_wait_tx();
            delay(200);
            vw_send((uint8_t *)msg, strlen(msg));
            vw_wait_tx();
            delay(200);
            vw_send((uint8_t *)msg, strlen(msg));
            vw_wait_tx();
            delay(200);
            isLocked=true;
            analogWrite(bluePin,0);
            analogWrite(redPin,255);
          }
          else if (key=='*') { //Starts the change password process
            isChangingPassword=true;
            password="";
            analogWrite(redPin,0);
            analogWrite(greenPin,0);
            analogWrite(bluePin,0);
            analogWrite(redPin,255);
            delay(200);
            analogWrite(redPin,0);
            analogWrite(greenPin,255);
            delay(200);
            analogWrite(greenPin,0);
            analogWrite(bluePin,255);
            delay(200);
            analogWrite(redPin,0);
            analogWrite(greenPin,0);
            analogWrite(bluePin,0);
            analogWrite(redPin,255);
            delay(200);
            analogWrite(redPin,0);
            analogWrite(greenPin,255);
            delay(200);
            analogWrite(greenPin,0);
            analogWrite(bluePin,255);
            delay(200);
            analogWrite(redPin,0);
            analogWrite(greenPin,0);
            analogWrite(bluePin,0);
            analogWrite(redPin,255);
            delay(200);
            analogWrite(redPin,0);
            analogWrite(greenPin,255);
            delay(200);
            analogWrite(greenPin,0);
            analogWrite(bluePin,255);
            delay(200);
            analogWrite(redPin,255);
            analogWrite(greenPin,255);
            analogWrite(bluePin,255);
          }
        }
      else {
        analogWrite(redPin,0);
        analogWrite(greenPin,0);
        analogWrite(bluePin,0);
        switch(key) {
          case '*': if(passwordPosition!=0) { passwordPosition--; password[passwordPosition]=0; redValue-=63; analogWrite(redPin,255); analogWrite(greenPin,255); analogWrite(bluePin,255); delay(300); analogWrite(redPin,0); analogWrite(greenPin,0); analogWrite(bluePin,0); } break;
          case '#': if(passwordPosition==4) passwordPosition=5; break;
          default: if(passwordPosition<4) { password+=key; passwordPosition++; redValue+=63; analogWrite(redPin,redValue); delay(200); analogWrite(redPin,0); } break;
        }
      
        Serial.println(passwordPosition);
      
        if (passwordPosition==5&&key=='#') {
          analogWrite(redPin,0);
          analogWrite(greenPin,255);
          delay(200);
          analogWrite(greenPin,0);
          delay(200);
          analogWrite(greenPin,255);
          delay(200);
          analogWrite(greenPin,0);
          delay(200);
          analogWrite(greenPin,255);
          delay(200);
          analogWrite(greenPin,0);
          delay(200);
          char msg[5];
          msg[0]=password[0];
          msg[1]=password[1];
          msg[2]=password[2];
          msg[3]=password[3];
          msg[4]='c';
          vw_send((uint8_t *)msg, strlen(msg));
          vw_wait_tx(); // Wait for message to finish
          delay(200);
          vw_send((uint8_t *)msg, strlen(msg));
          vw_wait_tx();
          delay(200);
          vw_send((uint8_t *)msg, strlen(msg));
          vw_wait_tx();
          delay(200);
          vw_send((uint8_t *)msg, strlen(msg));
          vw_wait_tx();
          delay(200);
          vw_send((uint8_t *)msg, strlen(msg));
          vw_wait_tx();
          delay(200);
          isChangingPassword=false;
          analogWrite(bluePin,0);
          passwordPosition=0;
          password="";
          analogWrite(greenPin,255);
        }
      }   
    }
  }
}
