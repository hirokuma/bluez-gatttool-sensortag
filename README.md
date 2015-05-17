# bluez-gatttool-sensortag

This sources is based on BlueZ 5.30.  
http://www.bluez.org/

## need
- BlueZ to use below internal libraries.  
  - lib/.libs/libbluetooth-internal.a
  - src/.libs/libshared-glib.a
- GLib  
- readline  

## makefile
- *BLUEZ_PATH* : to your BlueZ directory.

## gatttool.c
- *opt_src* : BLE interface
- *opt_dst* : SensorTag Address (or -b)

## interactive.c
- *events_handler()* : Notification analyze
- *idling_func()* :
  - SET_NFY : write characteristics for notification enabling


## command
- sudo ./gatool
- "st"
  - connect
  - primary
  - write characteristics : button and IR Temp

