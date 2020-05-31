
const int GSR = A2;
int threshold = 0;
int sensorValue;

#define USE_ARDUINO_INTERRUPTS true    // Set-up low-level interrupts for most acurate BPM math.
#include <PulseSensorPlayground.h>     // Includes the PulseSensorPlayground Library.   

//  Variables
const int PulseWire = 0;       // PulseSensor PURPLE WIRE connected to ANALOG PIN 0
const int LED13 = 13;          // The on-board Arduino LED, close to PIN 13.
int Threshold = 550;           // Determine which Signal to "count as a beat" and which to ignore.
// Use the "Gettting Started Project" to fine-tune Threshold Value beyond default setting.
// Otherwise leave the default "550" value.

PulseSensorPlayground pulseSensor;  // Creates an instance of the PulseSensorPlayground object called "pulseSensor"
int printSpeed = 50; //1000--> 1초 주기. 빠르게-->낮은 값, 느리게-->높은 값
int myBPM;

void setup() {
  long sum = 0;
  Serial.begin(9600);

  for (int i = 0; i < 500; i++)
  {
    sensorValue = analogRead(GSR);
    sum += sensorValue;
    delay(5);
  }
  threshold = sum / 500;

  pulseSensor.analogInput(PulseWire);
  pulseSensor.blinkOnPulse(LED13);       //auto-magically blink Arduino's LED with heartbeat.
  pulseSensor.setThreshold(Threshold);

  // Double-check the "pulseSensor" object was created and "began" seeing a signal.
  if (pulseSensor.begin()) {
    Serial.println("We created a pulseSensor Object !");  //This prints one time at Arduino power-up,  or on Arduino reset.
  }

}

void loop() {
  int temp;
  sensorValue = analogRead(GSR);

  temp = threshold - sensorValue;
  if (abs(temp) > 50)
  {
    myBPM = pulseSensor.getBeatsPerMinute();
    if (pulseSensor.sawStartOfBeat()) {
      Serial.print(sensorValue);
      Serial.print(",");
      Serial.println(myBPM);
    }
    delay(printSpeed);
  }


}
