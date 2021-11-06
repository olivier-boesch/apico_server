import logging
import busio
import board
from digitalio import DigitalInOut
import adafruit_rfm9x
import json

RADIO_FREQ = 433.0  # MHz
SERVER_NODE_ADDRESS = 254


class Radio:
    def __init__(self, node_address=SERVER_NODE_ADDRESS, freq=RADIO_FREQ):
        self.data = None
        self.rssi = -127  # lowest rssi
        try:
            self.logger = logging.getLogger(name="radio_server")
            spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
            cs_pin = DigitalInOut(board.CE1)
            reset_pin = DigitalInOut(board.D25)
            self.rfm9x = adafruit_rfm9x.RFM9x(spi=spi, cs=cs_pin, reset=reset_pin, frequency=freq, crc=True)
            self.rfm9x.node = node_address
            self.rfm9x.tx_power = 23  # max power: 23dB
            self.logger.info('RFM9x detected')
        except RuntimeError as error:
            # Thrown on version mismatch
            self.logger.error(f"RFM9x Error: {error}")
            exit(1)

    def wait_for_receive(self):
        self.logger.info("Waiting to receive packet")
        self.data = self.rfm9x.receive(keep_listening=True, with_ack=True, with_header=True)
        if self.data is not None:
            self.logger.debug(f"Data Packet Received: {self.data!r}")
            self.rssi = self.rfm9x.rssi

    def process_packet(self):
        if self.data is None:
            return None
        try:
            node_from = self.data[1]
            payload = self.data[4:].decode()
            self.logger.info(f"Data from {node_from}")
            self.logger.debug(f"Received RSSI: {self.rssi}")
            self.logger.debug(f"Data Packet payload: {payload}")
            node_data = json.loads(payload)
            node_data['node'] = node_from
            # transform values to get back floats
            node_data["H"] = node_data["H"] / 10.0
            node_data["T"] = node_data["T"] / 10.0
            node_data["M"] = node_data["M"] / 100.0
            node_data['rssi'] = self.rssi
            return node_data
        except (UnicodeError, json.JSONDecodeError) as e:
            self.logger.error(f"Error while decoding packet: {e}")
            return None


