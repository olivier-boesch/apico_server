#!/usr/bin/python3
"""
ApiCo - Radio Server

Code: Olivier Boesch (c) 2021

"""
import json
import logging
import logging.handlers
import socket
import signal
import radio
import threading
import queue
import pymysql
from settings import *

LOG_LEVEL = logging.INFO
logger = logging.getLogger(name="radio_server")
logger.setLevel(LOG_LEVEL)

# logging
ch = logging.StreamHandler()
fh = logging.handlers.TimedRotatingFileHandler(filename="/var/log/apico/apico_radio.log", when="D", interval=1, backupCount=7)
ch.setLevel(logging.DEBUG)
logger.addHandler(ch)
logger.addHandler(fh)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch.setFormatter(formatter)
fh.setFormatter(formatter)

# rfm9x radio
radio = radio.Radio()
radio_queue = queue.Queue()

# display socket
display_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# db connection
"""
db = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            db=DB_DB,
            charset=DB_CHARSET,
            cursorclass=pymysql.cursors.DictCursor)
"""


def display_message(data):
    mess = f"Node {data['node']};S: {data['rssi']}dB\nI:{data['I']};O:{data['O']};T:{data['T']}C\nCO2:{data['C']}ppm;RH:{data['H']}%"
    data = [data['node'], mess]
    json_data = json.dumps(data)
    return json_data.encode('utf8')


def db_save(message):
    # db.ping(reconnect=True)
    logger.info(f"Saving Message to DB: {message}")
    # with db.cursor() as cursor:
    #    sql_req = "INSERT INTO"
    #    cursor.execute(sql_req)


def radio_message_process(stop, messages_queue):
    while not stop():
        radio.wait_for_receive()
        data = radio.process_packet()
        if data is not None:
            messages_queue.put(data)


def message_to_db(stop, messages_queue):
    while not stop():
        try:
            message = messages_queue.get(timeout=0.1)
            logger.debug(f"Passing Data to Db: {message}")
            log_display = display_message(message)
            display_socket.sendto(log_display, DISPLAT_ADDRESS)
            db_save(message)
        except queue.Empty:
            pass


def clean_finish(signum, frame):
    logger.info("Stopping Server")
    global stop_threads
    stop_threads = True
    radio_thread.join()
    db_thread.join()
    logger.info("Server Stopped")


stop_threads = False
signal.signal(signal.SIGTERM, clean_finish)
signal.signal(signal.SIGHUP, clean_finish)
radio_thread = threading.Thread(target=radio_message_process, args=(lambda: stop_threads, radio_queue))
radio_thread.start()
db_thread = threading.Thread(target=message_to_db, args=(lambda: stop_threads, radio_queue))
db_thread.start()
radio_thread.join()
db_thread.join()
