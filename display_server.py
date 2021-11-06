#!/usr/bin/python3
"""
ApiCo - Display Server

Code: Olivier Boesch (c) 2021

"""
import json
import signal
import queue
import socket
import threading
import time
from display import DisplayHardware
import logging
from settings import *

stop_threads = False

# logging
LOG_LEVEL = logging.DEBUG
logger = logging.getLogger(name="display_server")
logger.setLevel(LOG_LEVEL)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
logger.addHandler(ch)
formatter = logging.Formatter('%(levelname)s - %(asctime)s - %(name)s - %(message)s')
ch.setFormatter(formatter)

message_queue = queue.Queue()

display = DisplayHardware()
display.intro()


def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('192.168.5.1', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP


def display_messages(stop, messages_queue, display):
    while not stop():
        try:
            message = messages_queue.get(timeout=0.5)
            data_log = message[1].replace("\n", " ")
            logger.info(f"Display message: {data_log} from {message[0]}")
            display.show_message(message)
        except queue.Empty:
            pass


def wait_message_from_clients(stop, queue):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0.5)
    s.bind(DISPLAT_ADDRESS)
    while not stop():
        try:
            json_data = s.recv(1024)
            json_data = json_data.decode()
            node, data = json.loads(json_data)
            data_log = data.replace("\n", " ")
            logger.info(f"Received message: {data_log}")
            queue.put((node, data))
        except socket.timeout:
            pass


def buttons_and_display(stop: bool, messages_queue: queue.Queue, display: DisplayHardware):
    while not stop():
        a, b, c = display.check_buttons()
        if a:
            logger.info("Button A pressed: show IP")
            ip = get_ip()
            messages_queue.put((None, f"IP is:\n{ip}"))
            time.sleep(1)
        if c:
            logger.info("Button C pressed: recall last message")
            messages_queue.put((None, display.last_message))
            time.sleep(1)
        if b:
            logger.info("Button B pressed: Check ping stations")
            time.sleep(1)
            messages_queue.put((None, display.get_ping()))
        time.sleep(0.1)


def clean_finish(signum, frame):
    logger.info("Stopping Server")
    global stop_threads
    stop_threads = True
    network_thread.join()
    button_thread.join()
    display_thread.join()
    display.clean()
    logger.info("Server Stopped")


display_thread = threading.Thread(target=display_messages, args=(lambda: stop_threads, message_queue, display))
display_thread.start()
network_thread = threading.Thread(target=wait_message_from_clients, args=(lambda: stop_threads, message_queue))
network_thread.start()
button_thread = threading.Thread(target=buttons_and_display, args=(lambda: stop_threads, message_queue, display))
button_thread.start()
signal.signal(signal.SIGTERM, clean_finish)
signal.signal(signal.SIGHUP, clean_finish)
network_thread.join()
button_thread.join()
display_thread.join()
