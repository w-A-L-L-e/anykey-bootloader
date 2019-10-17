/*====================================== AnyKey testing sketch   ============================
 * Author: Walter Schreppers
 * Description: Allows to test if bootloader is secured and locking back from 186 to 187 and 
 * disabling writes when locked.
 * ==========================================================================================*/



#include <avr/eeprom.h>
#include <Keyboard.h>
#define LEDPIN 13

#define CONFIG_BYTE_ADDRESS   255
#define KEY_TYPE_DEFAULT       255 //factory setting uses password.h PASSWORD_LINE string to type
#define SERIAL_RUN_CMD         254 //allow other settings (this is used for other commands now!)


void setup();
void loop();


void ledOn(){
  digitalWrite(LEDPIN, HIGH);
}

void ledOff(){
  digitalWrite(LEDPIN, LOW);
}

//notice here we can write up to 255 max here!
void saveToEeprom( uint16_t address, uint8_t value ){
  eeprom_update_byte ( address, value ); //write to eeprom!
}


void showVersionAndConfiguration(){
  Serial.print(F("version=1.0.1")); //this is the testing sketch version
  
  Serial.print(F("; kbd_conf="));
  Serial.print( eeprom_read_byte(255) );

  Serial.print(F("; kbd_delay_start="));  
  Serial.print( eeprom_read_byte( 1022 ) );

  Serial.print(F("; kbd_delay_key="));
  Serial.print( eeprom_read_byte( 1020 ) );

  Serial.print(F("; kbd_layout="));
  Serial.print( eeprom_read_byte( 1021 ) );

  Serial.print(F("; bootlock="));
  int bootcode = eeprom_read_byte(1023);

  Serial.print( eeprom_read_byte( 1023 ) );
  if( bootcode == 187 ){
    Serial.println("\n\nCongratulations! Bootloader is secured."); 
  }
  else{
    Serial.println("\n\nWARNING unsafe bootloader code detected!");  
  }
}

void serialCmd(uint8_t c=0){

  if(c==0){
    if( !Serial.available() ) return;
    c = Serial.read();
  }

  if( c == 'V' ){ 
      showVersionAndConfiguration(); 
      return;
  }
  else if( c == 'X' ){  // Unlock bootloader (once value 186) -> after flash its reset to 187/killed
      Serial.print(F("Unlocking..."));
      delay(20);
      saveToEeprom(1023, 186); //1023 is used by bootloader
      Serial.println(F("done"));
      delay(20);
      return;
  }
  else if( c == 'U' ){  
      Serial.print(F("Full unlock..."));
      delay(20);
      saveToEeprom(1023, 255); //1023 is used by bootloader
      Serial.println(F("done"));
      delay(20);
      return;
  }
  
  else{
    Serial.println("ERROR: Unknown command!");
  }
}

void detectCommand(){
  if( !Serial.available() ) return;

  uint8_t c = Serial.read();

  if( c == CONFIG_BYTE_ADDRESS ){
    if( Serial.available() && (Serial.read() == SERIAL_RUN_CMD )){
      serialCmd();
      delay(100); //500 was stable
      Serial.flush();
    } 
  }
  else{
    serialCmd(c);
  }
  delay(10);
}


// watch programming now does not work instead device resets and typeswww.anykey.shop


/* Init function */
void setup()
{
  pinMode(LEDPIN, OUTPUT);
  Keyboard.begin();
  Serial.begin(9600); //during typing we ignore all serial coms (this is for the non-CP setting)

 // LOOK : www.anykey.shop 

  ledOn();
  delay(800);
  Keyboard.print("www.anykey.shop");
  Keyboard.write(13);
  ledOff();
  delay(400);
  ledOn();
  delay(800);
  ledOff();

  Serial.println("AnyKey factory testing image configuration=");
  showVersionAndConfiguration();
  Serial.println("In serial type 'X' to unlock once, 'U' for full unlock, 'L' to lock, 'V' to show config info");

}

/* Unused endless loop */
void loop() {
  ledOn();
  if( Serial.available() ){
    detectCommand();
  }
  delay(100);

  ledOff();
  delay(100);

}
