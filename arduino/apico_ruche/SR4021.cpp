/*
 * ShiftRegister4021BP.cpp - Arduino library for simple control of 4021BP shift registers
 * Written by Thomas Robinson, May 2018
 * Released into the public domain
 */

 #include "Arduino.h"
 #include "SR4021.h"

  //Shift Register constructor
 ShiftRegister4021BP::ShiftRegister4021BP(int numberOfRegisters, int dataPin, int clockPin, int latchPin) {

    //constructor attributes
    _numberOfRegisters = numberOfRegisters;
    _clockPin = clockPin;
    _dataPin = dataPin;
    _latchPin = latchPin;

    //define pins as i/o
    pinMode(clockPin, OUTPUT);
    pinMode(dataPin, INPUT);
    pinMode(latchPin, OUTPUT);

    //set pins low
    digitalWrite(clockPin, LOW);
    digitalWrite(dataPin, LOW);
    digitalWrite(latchPin, LOW);
 }

//reads shift register pins and writes to registerValues, an uint8_t array equal to the number of shift registers
void ShiftRegister4021BP::getAll(uint8_t * buf) {
    digitalWrite(_latchPin, HIGH);
    delayMicroseconds(20);
    digitalWrite(_latchPin, LOW);

    for (int8_t b = _numberOfRegisters - 1; b >= 0; b--) {
      buf[b] = shiftIn(_dataPin, _clockPin, MSBFIRST);
      digitalWrite(_clockPin, LOW);
      delayMicroseconds(1);
      digitalWrite(_clockPin, HIGH);
    }
}
