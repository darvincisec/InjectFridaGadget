# InjectFridaGadget
Script for injecting Frida gadget into the APK so that frida hooking can be done on non-rooted devices.
This is based on the concept as described -> https://lief.quarkslab.com/doc/latest/tutorials/09_frida_lief.html
Frida Gadget can be renamed to any random name to avoid apps detecting frida by name.

# Usage
Create keystore file and modify the alias, password before using the script
'''Shell
#To generate APK for all architectures(arm64,armv7,x86,x86_64)
sh hooktest.sh <your_app.apk> <your.so> libfrida.so
#To generate APK for specific architecture say arm64
./hooktest.sh <your.apk> <your.so> libfrida.so arm64
adb install <your_app>_hook_test.apk
#Push the frida script (myscript.js) file onto the device.
adb push myscript.js /data/local/tmp
#Pls note the name of the js can be changed, provided you change it accordingly in libgadget.config.so.
#In the device, make the myscript.js as executable
adb shell chmod +x /data/local/tmp/myscript.js
'''

Open the App and when app loads its own native library, frida gadget will also be loaded
and hooking would have started already. You can check the logcat with tag "frida-gadget"

# Constraint
There should be atleast 1 native library in the app for this script to work. Alternatively this can be 
done by tampering the smali file to load the frida gadget library. 
