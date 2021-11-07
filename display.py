import time

import busio
from digitalio import DigitalInOut, Direction, Pull
import board
# Import the SSD1306 module.
import adafruit_ssd1306
from settings import *


class DisplayHardware:
    def __init__(self):
        # Button A
        self.btnA = DigitalInOut(board.D5)
        self.btnA.direction = Direction.INPUT
        self.btnA.pull = Pull.UP

        # Button B
        self.btnB = DigitalInOut(board.D6)
        self.btnB.direction = Direction.INPUT
        self.btnB.pull = Pull.UP

        # Button C
        self.btnC = DigitalInOut(board.D12)
        self.btnC.direction = Direction.INPUT
        self.btnC.pull = Pull.UP

        # Create the I2C interface.
        i2c = busio.I2C(board.SCL, board.SDA)

        # 128x32 OLED Display
        reset_pin = DigitalInOut(board.D4)
        self._display = adafruit_ssd1306.SSD1306_I2C(128, 32, i2c, reset=reset_pin)
        # Clear the display.
        self.clean()
        # last message
        self.last_message = ""
        # pings of stations
        self._pings = [None for _ in range(HIVES_NUMBER)]

    def check_buttons(self):
        return not self.btnA.value, not self.btnB.value, not self.btnC.value

    def clean(self):
        self._display.fill(0)
        self._display.show()

    def intro(self, timeout=5):
        self.show_message(data=(None, "Apico Server\nSaint Ex (c) 2021"), timeout=timeout)

    def show_message(self, data=(None, ""), timeout=5):
        node, message = data
        self.last_message = message
        if node is not None:
            self._pings[node-1] = time.monotonic()
        lines = message.split('\n')
        lines = lines[:3]
        for i in range(len(lines)):
            self._display.text(lines[i], 0, i*11, 1)
        self._display.show()
        time.sleep(timeout)
        self.clean()

    def get_ping(self, time_limit=1200):
        s = "Ping (alive stations):\n"
        s += '  |'.join([str(i+1)  for i in range(HIVES_NUMBER)]) + '\n'
        for i in range(HIVES_NUMBER):
            if (self._pings[i] is None) or (self._pings[i] + time_limit < time.monotonic()):
                s += "   |"
            else:
                s += "x  |"
        return s[:-1]
