# InjectFridaGadget
Script for injecting Frida gadget into the APK so that frida hooking can be done on non-rooted devices.
This is based on the concept as described -> https://lief.quarkslab.com/doc/latest/tutorials/09_frida_lief.html

Steps to follow:
a. Copy the apk to be tested into the current folder where the script file is present
b. Create keystore file and modify the alias, password in the script
c. Execute the following script
//To generate APK for all architectures(arm64,armv7,x86,x86_64)
./hooktest.sh <your_app.apk> <your.so> libfrida.so
//To generate APK for specific architecture say arm64
./hooktest.sh <your.apk> <your.so> libfrida.so arm64
d. adb install <your_app>_hook_test.apk
e. Push the frida script (myscript.js) file onto the device.
adb push myscript.js /data/local/tmp
Pls note the name of the js can be changed, provided you change it accordingly in libgadget.config.so.
f. In the device, make the myscript.js as executable
chmod +x myscript.js

Open the App and when app loads its own native library, frida gadget will also be loaded
and hooking would have started already. You can check the logcat with tag "frida-gadget"

Constraint
There should be atleast 1 native library in the app for the scripts to work. Alternatively this can be 
done by tampering the smali file to load the frida gadget library. 
