import sys
sys.path.append("/home/tom")  # התאמת הנתיב למיקום הקובץ ev3motor.py שלך

from ev3motor import EV3Motor

ENC1 = 8
ENC2 = 25
IN1  = 18
IN2  = 13

motor = EV3Motor(ENC1, ENC2, IN1, IN2)

try:
    motor.reset_encoder()
    print("Moving motor 90 clicks...")
    motor.goto_degrees(360, kp=5, ki=0.2, kd=1, timeout=5)
finally:
    motor.stop()
