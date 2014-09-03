#include <VirtualWire.h> // Libraries to import
#include <ServoTimer2.h>
#include <SD.h>
#include <Time.h>  

#define TIME_MSG_LEN  11   // time sync to PC is HEADER followed by unix time_t as ten ascii digits
#define TIME_HEADER  'T'   // Header tag for serial time sync message
#define TIME_REQUEST  7    // ASCII bell character requests a time sync message 

int servoPin = 9;
ServoTimer2 myServo;
boolean servoLocked = true;
File myFile;

String correctPassword = "0000";

void setup() {
  Serial.begin(9600); //Start serial connection
  myServo.attach(servoPin);
  if (myServo.read()!=1250) myServo.write(1250); // Servo starts out locked
  
  //Initialise the IO and ISR
  vw_set_ptt_inverted(true);    // Required for RX Link Module
  vw_setup(1200);              // Bits per sec
  vw_set_rx_pin(3);           // We will be receiving on pin 3 () ie the RX pin from the module connects to this pin.
  vw_rx_start();              // Start the receiver
  
  Serial.print("Initializing SD card...");
  // On the Ethernet Shield, CS is pin 4. It's set as an output by default.
  // Note that even if it's not used as the CS pin, the hardware SS pin 
  // (10 on most Arduino boards, 53 on the Mega) must be left as an output 
  // or the SD library functions will not work. 
   pinMode(53, OUTPUT);
   
  if (!SD.begin(53)) {
    Serial.println("initialization failed!");
    return;
  }
  Serial.println("initialization done.");
  
  myFile = SD.open("password.txt");
  if (myFile) {
    char file_contents[256];           //This is a data buffer that holds data read from a file
    
    int index=0;  //Create a variable to keep track of our position in the data buffer.
    file_contents[index]=myFile.read(); //Get the first byte in the file.
    //Keep reading characters from the file until we  get an error or reach the end of the file. (This will output the entire contents of the file).
    while(file_contents[index] >=0 && index < 256){
      //If the value of the character is less than 0 we've reached the end of the file. If index is 256 than our buffer is full.
      index+=1;                 //Move to the next position in the data buffer.
      file_contents[index]=myFile.read(); //Get the next character
    }
    correctPassword[0]=file_contents[0]; //Set the password variable to the contents of the file
    correctPassword[1]=file_contents[1];
    correctPassword[2]=file_contents[2];
    correctPassword[3]=file_contents[3];
    
    // close the file:
    myFile.close();
  } else {
     // if the file didn't open, print an error:
     Serial.println("error opening password.txt");
  }
  
  setSyncProvider( requestSync);  //set function to call when sync required
  Serial.println("Waiting for sync message");
}

void loop() {
  if(Serial.available() ) 
  {
    processSyncMessage(); // Sets the time on the Arduino
  }
  if(timeStatus()!= timeNotSet)   
  {
    digitalWrite(13,timeStatus() == timeSet); // on if synced, off if needs refresh   
  }
  delay(1000);
  
  uint8_t buf[VW_MAX_MESSAGE_LEN]; // The buffer that contains the message
  uint8_t buflen = VW_MAX_MESSAGE_LEN; // The length of the buffer

  if (vw_get_message(buf, &buflen)) // check to see if anything has been received
  {
    int i;
    String message;
    // Message with a good checksum received.
        
    for (i = 0; i < buflen; i++)
    {
      Serial.print(buf[i]);  // the received data is stored in buffer
      message+=buf[i];
    }
    Serial.println("");
    if (message.indexOf(correctPassword)==0&&servoLocked==true) {
      myServo.write(2249); // Unlocks the safe
      Serial.println("Unlocked");
      servoLocked=false; //Variable stores state of motor
      writeToLog("Unlocked"); //Log file on microSD card is written to
      delay(2000); //Delays so duplicate message is not accidentally read
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
    }
    else if (message.indexOf("lock")==0&&servoLocked==false) {
      myServo.write(1250); // Locks the safe
      Serial.println("Locked");
      servoLocked=true;
      writeToLog("Locked");
      delay(2000);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
    }
    else if (servoLocked==false&&message[4]=='c') {
      Serial.println("Password Changed");
      myFile = SD.open("password.txt", FILE_WRITE);
      myFile.seek(0); //Moves cursor of file to beginning, in order to change the password in the beginning of the file
      myFile.println(message.substring(0,4)); //Writes new password to file
      myFile.close();
      correctPassword=message.substring(0,4);
      writeToLog("Password Changed to: "+correctPassword);
      delay(2000);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
    }
    else if (servoLocked==true&&message[0]!='l') {
      writeToLog("Incorrect Password Entered: "+message.substring(0,4)); //Incorrect password entered, logged
      delay(2000);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
      vw_get_message(buf, &buflen);
    }
    delay(200);
  }
  delay(500);
}

void writeToLog(String message){
  //This function writes to the log file on the sd card, outputs the time and a message
  myFile = SD.open("log.csv", FILE_WRITE);
  myFile.print(month());
  myFile.print("/");
  myFile.print(day());
  myFile.print("/");
  myFile.print(year());
  myFile.print(" ");
  myFile.print(hourFormat12());
  myFile.print(":");
  if(minute() < 10)
    myFile.print('0');
  myFile.print(minute());
  myFile.print(":");
  if(second() < 10)
    myFile.print('0');
  myFile.print(second());
  if (isAM()) myFile.print(" AM");
  else myFile.print(" PM");
  myFile.print(",");
  myFile.println(message);
  myFile.close();
}

void processSyncMessage() {
  // if time sync available from serial port, update time and return true
  while(Serial.available() >=  TIME_MSG_LEN ){  // time message consists of a header and ten ascii digits
    char c = Serial.read() ; 
    Serial.print(c);  
    if( c == TIME_HEADER ) {       
      time_t pctime = 0;
      for(int i=0; i < TIME_MSG_LEN -1; i++){   
        c = Serial.read();          
        if( c >= '0' && c <= '9'){   
          pctime = (10 * pctime) + (c - '0') ; // convert digits to a number    
        }
      }   
      setTime(pctime);   // Sync Arduino clock to the time received on the serial port
    }  
  }
}

time_t requestSync()
{
  Serial.print(TIME_REQUEST,BYTE);  
  return 0; // the time will be sent later in response to serial mesg
}

