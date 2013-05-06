export TERM=xterm-256color

PATH=$HOME/bin:$PATH

QMAKESPEC=/home/nalderso/ti-sdk-am335x-evm-05.05.00.00/linux-devkit/arm-arago-linux-gnueabi/usr/share/qtopia/mkspecs/linux-g++;export QMAKESPEC; # ADDED BY INSTALLER - DO NOT EDIT OR DELETE THIS COMMENT - AB1C36D0-2B62-930A-B1CF-1B15CF69BE47 9B1E1286-CA5E-0571-9A51-1DADDA88C6F8

if [ -r .bashrc-local ]; then
    source .bashrc-local
fi
