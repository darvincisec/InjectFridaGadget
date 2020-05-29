#!/bin/bash

#Dependencies
#This script requires LIEF to inject a library. LIEF is installed as part of this script and used in inject.py script and executed.
#Curl is used to download Frida gadget library for specific architectures. If you require proxy set $HTTPS_PROXY before using it.
#apktool to disassemble apk and apksigner to sign the apk

if [[ ("$1" = "") || ("$2" = "") || ("$3" = "")]];then
    echo "Usage: $0 <.apk file to be tampered> <library to be tampered<libxxx.so>> <frida-library name.so> <optional:architecture-arm64,armv7,x86,x86_64" >&2
    exit 1
fi

if [ ! -x "$(command -v apktool)" ]; then
  echo 'Error: apktool is not configured' >&2
  exit 1
fi
if [ ! -x "$(command -v apksigner)" ]; then
  echo 'Error: apksigner is not configured.Configure $PATH to include this /Users/<username>/Library/Android/sdk/build-tools/<version>' >&2
  exit 1
fi
if [ ! -x "$(command -v pip)" ]; then
  echo 'Error: pip is not configured' >&2
  exit 1
fi
if [ ! -x "$(command -v curl)" ]; then
  echo 'Error: curl is not configured' >&2
  exit 1
fi
if [ ! -x "$(command -v unxz)" ]; then
  echo 'Error: unxz is not configured' >&2
  exit 1
fi
echo "==============Installing LIEF=================="
pip install https://github.com/lief-project/packages/raw/lief-master-latest/pylief-0.9.0.dev.zip

echo "Tampering $1"
HOME_DIR=$PWD

#filename=$($1 | cut -d "." -f 1)
filename=$1
tamperedfile="${filename%.*}"
tamperedfile+="_hook_test.apk"

gadget=$3
gadgetconfig="${gadget%.*}"
gadgetconfig+=".config.so"
gadgetfile="${gadget%.*}"
gadgetfile+=".so.xz"
#echo "$tamperedfile"
cp "$1" "$tamperedfile"

echo "==============Disassembling the apk=================="
apktool d -f --no-res $tamperedfile
if [ $? != 0 ]; then
    echo "apktool error"
    exit 1
fi
directory="${tamperedfile%.*}"
directory+="/lib"

if [ ! -d $directory ]; then
	echo "apktool failed to disassemble"
	exit 1
fi
cd "$directory"
library=$2
echo "==============Tampering Started=================="
for directory in */ ; do
    if [[ ($directory = "arm64-v8a/" ) && ( "$4" = "" || "$4" = "arm64" ) ]];
    then
    	cd $directory
    	echo "Tampering arm64-v8a"
        if [ -f $2 ]
    	then
            echo "==============Downloading frida for arm64=================="
            curl -L -s https://github.com/frida/frida/releases/download/12.8.11/frida-gadget-12.8.11-android-arm64.so.xz --output $gadgetfile
            unxz $gadgetfile
            echo "==============Injecting $3 into $2 for arm64. Wait for few minutes =================="
            python $HOME_DIR/inject.py $2 $3
            cp $HOME_DIR/libgadget.config.so ./$gadgetconfig
        fi &
        P1=$!
        cd ..
    fi
    if [[ ($directory = "armeabi-v7a/") && ( "$4" = "" || "$4" = "armv7" ) ]];
    then
        cd $directory
        echo "Tampering armeabi-v7a"
        if [ -f $2 ]
    	then
            echo "==============Downloading frida for armeabi-v7a=================="
            curl -L -s https://github.com/frida/frida/releases/download/12.8.11/frida-gadget-12.8.11-android-arm.so.xz --output $gadgetfile
            unxz $gadgetfile
            echo "==============Injecting $3 into $2 for armeabi. Wait for few minutes =================="
            python $HOME_DIR/inject.py $2 $3
            cp $HOME_DIR/libgadget.config.so ./$gadgetconfig
        fi &
        P2=$!
        cd ..
    fi
    if [[ ($directory = "x86/") && ( "$4" = "" || "$4" = "x86" ) ]];
    then
    	cd $directory
        echo "Tampering x86"
        if [ -f $2 ]
    	then
            echo "==============Downloading frida for x86=================="
            curl -L -s https://github.com/frida/frida/releases/download/12.8.11/frida-gadget-12.8.11-android-x86.so.xz --output $gadgetfile
            unxz $gadgetfile
            echo "==============Injecting $3 into $2 for x86. Wait for few minutes =================="
            python $HOME_DIR/inject.py $2 $3
            cp $HOME_DIR/libgadget.config.so ./$gadgetconfig
        fi &
        P3=$!
        cd ..
    fi
    if [[ ($directory = "x86_64/") && ( "$4" = "" || "$4" = "x86_64" ) ]];
    then
        cd $directory
        echo "Tampering x86_64"
        if [ -f $2 ]
    	then
            echo "==============Downloading frida for x86-64 =================="
            curl -L -s https://github.com/frida/frida/releases/download/12.8.11/frida-gadget-12.8.11-android-x86_64.so.xz --output $gadgetfile
            unxz $gadgetfile
            echo "==============Injecting $3 into $2 for x86-64. Wait for few minutes =================="
            python $HOME_DIR/inject.py $2 $3
            cp $HOME_DIR/libgadget.config.so ./$gadgetconfig
        fi &
        P4=$!
        cd ..
    fi
done
if [[ "$P1" != "" ]];
then
    wait $P1
fi
if [[ "$P2" != "" ]];
then
    wait $P2
fi
if [[ "$P3" != "" ]];
then
    wait $P3
fi
if [[ "$P4" != "" ]];
then
    wait $P4
fi
echo "==============Tampering Ended================="
cd ..
cd ..

echo "=========Reassembling the apk==============="
apktool b "${tamperedfile%.*}"
directory="${tamperedfile%.*}"
directory+="/dist"

cp "$directory/$tamperedfile" .
echo "=========SIGNING THE APK========="
apksigner sign --ks keystore.jks --ks-key-alias <alias> --ks-pass pass:<pass> --key-pass pass:<pass> $tamperedfile
if [ $? -eq 0 ]; then
    echo "APK -> $tamperedfile for hook test is ready"
    rm -rf "${tamperedfile%.*}"
else
    echo "Create a keystore file and set the alias and password accordingly"
fi
