# Arduino-Safe

The code, schematic file, and SD Card files for a safe I built using an Arduino Uno and an Arduino Mega.

- When the correct password is entered on the keypad outside the safe, the servo motor inside moves and the safe is unlocked.
- A RF transmitter and a RF receiver are used to communicate between the two Arduinos.
- The entered password is sent over RF.
- An RGB LED is on the outside of the safe to indicate the status.
- Each time the safe is locked or unlocked, or when a password is changed or entered incorrectly, it is logged on a microSD card in a microSD breakout board connected to the Arduino Mega.
- Every time the safe is turned on, the current date and time is sent over serial to the Arduino in order for the datalogging to work.

Check out the video for this project: http://youtu.be/RarfW9cGWJ8

The code was written by Alex Strandberg and is licensed under the MIT License, check LICENSE for more information

[Fritzing](http://fritzing.org/home/) is needed to view the schematic file

## Arduino Libraries

- [Keypad](http://playground.arduino.cc/code/Keypad)
- [SD](http://arduino.cc/en/Reference/SD)
- [ServoTimer2](http://forum.arduino.cc/index.php/topic,21975.0.html)
- [Time](http://playground.arduino.cc/code/time)
- [VirtualWire](http://www.airspayce.com/mikem/arduino/VirtualWire/)
