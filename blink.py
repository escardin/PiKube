#!/usr/bin/env python 3

from flask import Flask, jsonify
from time import sleep
import threading

app = Flask(__name__)

ON = "1"
OFF = "0"

def ledSet(targetState):
    with open('/sys/class/leds/led1/brightness','w') as f:
        f.write(targetState)

def blink():
    t = threading.currentThread()
    while getattr(t, "run_b", True):
        if getattr(t, "blink", False):
            ledSet(ON)
            sleep(0.5)
            ledSet(OFF)
            sleep(0.5)


proc = threading.Thread(target=blink,args=())
proc.run_b = True
proc.blink = False
proc.start()


@app.route("/on", methods=['GET'])
def ledOn():
    proc.blink = True
    return jsonify({'message': 'turning on'})


@app.route("/off", methods=['GET'])
def ledOff():
    proc.blink = False
    ledSet(OFF)
    return jsonify({'message': 'turning off'})


app.run(host='0.0.0.0')

proc.run_b = False
proc.join(3)
ledSet(OFF)
