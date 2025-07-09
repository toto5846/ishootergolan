import sys
import threading
from time import sleep
from flask import Flask, render_template, request, redirect

sys.path.append('/home/tom')

from RPLCD.i2c import CharLCD
from motor_driver import DualDCMotorDriver
import manual_mode
import hovering  


lcd = CharLCD('PCF8574', 0x27)
lcd.clear()
driver = DualDCMotorDriver(in1_pin=18, in2_pin=13, in3_pin=24, in4_pin=23)


manual = manual_mode.ManualMode(driver, lcd)

app = Flask(__name__)


current_mode = "manual"
hovering_thread = None
stop_hovering = False

def set_lcd_hovering():
    lcd.clear()
    lcd.write_string("Hovering Mode")

def run_hovering():
    set_lcd_hovering()
    while not stop_hovering:
        hovering.hover_pattern(driver)

def update_lcd_mode():
    lcd.clear()
    if current_mode == "manual":
        lcd.write_string("Manual Mode")
    else:
        lcd.write_string("Auto Mode")

@app.route("/", methods=["GET", "POST"])
def index():
    global current_mode, hovering_thread, stop_hovering

    if request.method == "POST":
        if "mode" in request.form:
            new_mode = request.form["mode"]
            if new_mode != current_mode:
                current_mode = new_mode

                if current_mode == "auto":
                    update_lcd_mode()
                    stop_hovering = False
                    hovering_thread = threading.Thread(target=run_hovering)
                    hovering_thread.start()

                elif current_mode == "manual":
                    stop_hovering = True
                    if hovering_thread and hovering_thread.is_alive():
                        hovering_thread.join()
                    driver.stop_all()  
                    update_lcd_mode()

            return redirect("/")

        if current_mode == "manual":
            action = request.form.get("action")
            manual.handle_action(action)

    return render_template("index.html", mode=current_mode)

if __name__ == "__main__":
    update_lcd_mode()  
    app.run(host="0.0.0.0", port=5000)
