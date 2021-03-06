[edited 04-may-2015]

This file elaborates on the Quick Start guide in the [README.md](http://github.com/jks-prv/5370_proc/blob/master/README.md) file.

### Powering the BBB from the USB-mini port

One solution to the annoyance of having to halt the BBB before the instrument is powered off is simply to keep the BBB running by providing it a secondary source of power via the USB-mini port. The BBB already understands how to select between two sources of power: the USB-mini and +5V barrel connectors (the latter of which is actually being delivered from the 5370 via the board expansion connectors). The app detects when the instrument has powered down and resumes running when power is restored. USB power could come from an external USB hub or charger. You may have to obtain a longer USB cable than the one supplied. Be certain to only use the USB-mini connector that is adjacent to the Ethernet RJ45 connector. Do not use the USB-A connector on the other end of the board as that port will not accept input power.

Some of you might even figure out how to derive +5V for the USB-mini cable from the portion of the 5370 power supply that is always powered on if the instrument is off but the line cord is plugged in (hint: big filter caps -- see schematic). The planned USB/Ethernet connector card that replaces the current HPIB one at the back-panel could host a voltage regulator and hold-up capacitor.


### Front panel menu interface

There is a simple menu interface that uses the front panel keys and display to quickly change a few parameters without having to access the BBB. Most importantly you can use this method to set the IP address of the BBB Ethernet interface.

To enter menu mode hold down the 'reset' key, and keep holding, until you see the message 'ready' on the display. Do this after: an instrument power-on, a manual start of the app from the BBB or anytime while the app is running. To simply do a reset (and not enter menu mode) while the app is running don't hold the key down for more than one second.

Once 'ready' is displayed let go of the reset key and the display will show 'chg settings'. The keys that are valid in menu mode will now have their LEDs lit. The two keys in the 'function' column (TI, FREQ) will scroll the menu list up and down. The other keys change the menu item contents.

Currently the menu items displayed are:

    cancel         don't make any changes
    halt           halt the BBB in preparation for power-off
    dhcp           use DHCP to set the Ethernet IP address
    ip             set the IP address manually
    nm             set the netmask manually
    gw             set the gateway manually

For setting the numerical values of ip, nm and gw use the lit keys in the 5370 'statistics' and 'sample size' columns to increment and decrement the values. Holding the key down will auto-repeat.

To exit menu mode, and/or invoke the menu action, press the reset key after displaying the relevant menu item (e.g. 'cancel' or 'halt'). For the IP addressing modes leave 'dhcp' displayed or one of the three manual IP address values depending on if you want the Ethernet to use DHCP or manual IP addressing going forward. If you made a change the message 'config changed' will appear. Then the message 'using dhcp mode' or 'using ip mode'. After a few seconds the message 'saving config' will appear. The instrument will then reset. For 'halt' the message 'halting...' will appear and it will be safe to power-off the instrument after the display goes blank.

### Manually running the app

Disabling app auto-start at boot time:
You'll probably want to stop the app from auto-starting at boot time while
running it manually during development. To do this use these "make" command variants:

	"m disable"     prevent future auto-starting of app
	"m enable"      allow future auto-starting of app
	"m stop"        stop the currently auto-started app (if there is one)
	"m start"       start the app using auto-start mechanism (for testing)
	"m status"      show auto-start status and log from last activation

If auto-starting is enabled the app will run in the background at the next boot.

After running 'make' (m) two versions of the app are compiled: 'hd' has debugging checks enabled and 'h' is fully optimized for speed. You can also say 'm bc' to build the HPIB-over-Ethernet client app.

There are a few command line arguments for 'hd' and 'h':

    -rcl|-recall [name]   load key settings from named profile
    -hpib-hard		use the original HPIB hardware interface (if installed)
    -hpib-sim		simulate the HPIB interface in software (debug mode)
    -hpib-net		simulate and re-direct transfers over the Ethernet
    -ip				show IP address of Ethernet interface and exit

For the store/recall commands a key is considered "pushed" if the corresponding LED is lit. The current key state is saved in the file ~/.5370.[profile_name].keys every 5 seconds or so. If no profile name is given "default" is used. Thanks to John Miles for suggesting this feature.


### Keyboard commands

When the app has been started manually it responds to several commands (type "?" or "help" for a list). These are primarily to assist development when you're not sitting in the same room as the noisy beast:

    d               show instrument display including units and key LEDs
    h <HPIB cmd>    emulate HPIB command input, e.g. "h md2"
    h?              prints reminder list of HPIB commands
    k <fn1 .. fn4>  emulate function key 1-4 press, e.g. "k fn1" is TI key
    k <gt1 .. gt4>  emulate gate time key 1-4 press
    k <st1 .. st8>  emulate statistics key 1-8 press
    k <ss1 .. ss5>  emulate sample size key 1-5 press
    k <m1 .. m6>    emulate "misc" key 1-6 press (see code for mapping)
                    1 TI only, 2 +/- TI, 3 ext h.off,
                    4 per compl, 5 ext arm, 6 man rate
    m               run measurement extension example code
    s               show measurement statistics
    rc              show values of count-chain registers (one sample)
    rcl|recall [name]   load key settings from current or named profile
    sto|store name      save key settings to named profile
    r               reset instrument
    q               quit

For the debug version of the app ("hd" command) there are some others (see code).

It is also possible to connect to the app when it is running in the background after being auto-started. Use telnet (note: not ssh) to make a simple terminal-based connection:

    telnet ip_address|hostname|localhost 5371

Note that the port number 5371 is different from port 5370 used by the HPIB-over-Ethernet service and port 5372 used for the instrument web interface (see below).

An example run from the instrument's own BBB (hence 'localhost'). Note that '~^\' (tilda followed by control-backslash) is the escape sequence to exit telnet. This is different than the '~.' needed to exit the ssh you're probably using to connect to the BBB.

    root@my-5370:telnet localhost 5371
    d
    display:             99 .63     ns
    keys: ti mean 1 ti_only 
    ~^\Quit
    root@my-5370:

The app also contains a small web server that listens for browser connections to port 5372. The resulting web page shows a scrollable list of all the output messages from the app and allows keyboard commands to be sent to the app. In your browser use a URL of the form:

    ip_address|hostname|localhost:5372

e.g.

    192.168.0.101:5372
    my-5370:5372

Port 5372 is used because the Angstrom/Debian distributions on the Beagle already have another web server listening on port 80 (the default port for browser connections). Although it is possible to disable this other web server and change the define 'WEBSERVER_PORT' in web.h and re-install.


### Software versions
To see what version of the software is in your build directory, go there ('cd ~/5370') and type 'm v' or 'm version'. The version is also shown on the instrument display when the app starts.


### Using git to track software changes

The BBB is delivered with (or you have installed) the software in the /home/root/5370 build directory. But it might be a good idea to use the version control system "git" to track changes made on the GitHub repository [github.com/jks-prv/5370_proc](http://github.com/jks-prv/5370_proc) where the latest changes are always available. There are several ways to configure git depending on your goals. If you expect to contribute changes to the software then you should setup an account on [github.com](http://github.com) and configure git on the BBB with your account information. You should also do this if you want to be notified by email when changes are made to the repository. There is info on the web about how to setup git and it won't be repeated here.

If you just want to use git to manually get changes then only a few commands are needed. To clone the repository initially:

	cd
	git clone git://github.com/jks-prv/5370_proc.git

To periodically update your copy with changes on GitHub:

	cd ~/5370_proc
	git pull

If you have made local changes to the software then pulling updates like this will fail if you have changed a file git is trying to update. In this case you must first configure git to establish a proper "branch" of the repository rather than just a simple clone (see web info). After that git will try to merge repository changes with your local changes and complain if it is unable to do so.

Note that the build directory '5370' is in ~/5370_proc/firmware/ of the git clone.


### Notes about the beaglebone black

BBB resources:
There are many resources on the web with info about the BBB.

[BBB Wiki: elinux.org/Beagleboard:BeagleBoneBlack](http://elinux.org/Beagleboard:BeagleBoneBlack)  
[Adafruit tutorials: learn.adafruit.com/category/beaglebone](http://learn.adafruit.com/category/beaglebone)  
[List of BBB distributors: beagleboard.org/Products](http://beagleboard.org/Products)  
[BBB login help: elinux.org/Beagleboard:Terminal_Shells](http://elinux.org/Beagleboard:Terminal_Shells)  
[ssh using USB: learn.adafruit.com/ssh-to-beaglebone-black-over-usb](http://learn.adafruit.com/ssh-to-beaglebone-black-over-usb)

USB ad-hoc networking:
One way to ssh to the BBB is by using a USB cable as an ad-hoc network connection. This is useful because the BBB will appear at a fixed address of 192.168.7.2 on the USB attached computer. You can then simply say "ssh root@192.168.7.2" to login. A driver usually must be installed on the computer to use USB in this way. See [learn.adafruit.com/ssh-to-beaglebone-black-over-usb](http://learn.adafruit.com/ssh-to-beaglebone-black-over-usb) for details. Note that you must use the USB-mini connector next to the Ethernet RJ45 for networking, not the USB-A connector on the other end of the board.

Once logged-in you can use the "ifconfig eth0" command to see what IP address was assigned to the Ethernet connection (the number after "inet addr"). Note that this USB networking cannot be used to give the BBB an Internet connection because the attached computer isn't acting as a router (although there are supposed to be ways of doing this). The BBB doesn't get confused by having two network connections (Ethernet and USB) because they have different IP addresses and the default routing for Internet traffic should be automatically set to the Ethernet connection.

Using a serial port:
Another possibility for connecting is using a USB-to-serial-port cable. That is, serial port on the BBB-side and a virtual serial port via USB on an attached computer. The BBB has a 6-pin header for this purpose. However, when plugged into the 5370 board there in not sufficient clearance for the usual adapter cable mentioned on the BBB Wiki. Instead use the low-profile adapter sold by Tindie: [tindie.com/products/spirilis/beaglebone-black-ftdi-friction-fit](https://www.tindie.com/products/spirilis/beaglebone-black-ftdi-friction-fit) The USB cable that comes with the Tindie product is short, but necessary because it is a special small size, so a USB-A-to-USB-A extension cable may be required. On a serial connection login as "root" with no password just as with ssh.

WiFi:
It is possible to use a USB WiFi dongle under Angstrom/Debian but commentary on the net says this may be difficult to get working. You probably don't want a WiFi adapter radiating inside the 5370 anyway. We suppose it would be okay to run the dongle outside the 5370 on the end of a USB extension cable.

Setting a fixed IP address:
Your DHCP server likely has a mechanism to associate a fixed IP address with the unique Ethernet "MAC" address of the BBB. This is very convenient as DHCP servers don't always assign the same IP address each time the BBB boots. Run the "ifconfig eth0" command and note the string after "HWaddr" (e.g. 56:32:BD:B6:0F:DB). This is the MAC address. Add an entry to the DHCP server that has this address and the IP address you want to use.

Another way is to tell the BBB what IP address to use. Tutorial is here: http://derekmolloy.ie/set-ip-address-to-be-static-on-the-beaglebone-black/ Note that you should use an IP address that is outside the range of addresses assigned by your DHCP server to prevent a conflict.

No HDMI:
To decrease boot time, and reduce interference with the 5370 app, the Gnome Display Manager (gdm) is disabled. This means if you were to hook-up a monitor to the HDMI port of the BBB you wouldn't see anything. The command used to do this was: "systemctl disable gdm". Replace "disable" with "enable" if you want to re-enable gdm.

Command shortcuts:
There are a bunch of shortcut command aliases in the file /home/root/.bashrc Of course these can't be used until the 5370 software is installed for the first time, which will be true if you purchased the board with the BBB installed. So you can just type "m" instead of "make", "mi" for "make install" etc.

Random BBB annoyances:
There are a number of small, but irritating, problems with the BBB. Here are some suggestions for dealing with them.

Ethernet appears deaf:
The Ethernet port doesn't seem to reliably get an IP address from the DHCP server. Instead it will default to one of those self-assigned 169.xxx addresses which won't work. This seems to be true occasionally for USB networking as well. We don't know any other solution than to reboot.

BBB doesn't power-up:
It is well known that older BBBs will occasionally not power-up even after external power is applied. You can verify this has happened by checking for the blue LEDs on the BBB after the instrument is powered on. An instrument power-cycle should clear the problem.

"port 22: Connection refused":
If you're logged in but notice additional attempts to connect with ssh or scp give this error then restart "dropbear" (the ssh server) by typing the command alias "db" via your working connection (or via the serial port, etc.) No need to reboot.

"ssh_exchange_identification: Connection closed by remote host":
This means the file "/etc/dropbear/dropbear_rsa_host_key" on the BBB has been corrupted or needs to be removed because of incompatibility with the keys in the ~/.ssh/known_hosts file on the machine you're trying to connect from. If you have this problem please email us as the fix is a little involved.

BBB bricked:
In the (hopefully unlikely) event that your BBB becomes "bricked" the BBB wiki link above shows how to re-flash an Angstrom/Debian distribution onto the eMMC. You would of course then need to re-install the 5370 software as well.

Versionitis:
We all know stuff breaks when using different versions of things. All the BBBs used in testing have been hardware revision "A5C", "A6", "A6A", "B" and "C" boards. The software distribution of Angstrom Linux used was "2013.06.20" and "2013.09.04", or "2014-04-23" for Debian, found by doing:

    more /etc/dogtag
    
Or by looking at the ID.txt file in the "BEAGLEBONE" virtual USB drive that appears when you connect the BBB to a computer with a USB cable. These distributions use a Linux 3.8 kernel.


### Files

The files on the github repository and on the BBB are organized as follows. The BBB only has the files from the firmware sub-directory of the repository installed (i.e. /home/root/5370)

    firmware/<version>/     C code that runs on the BBB.
    pcb/<version>/          Complete documentation for replicating or 
                            modifying the PCB.
    docs/                   Relevant documentation. 
        
    firmware/5370[AB].ROM   Just for reference, packed-binary format copies
                            of the ROM code from version A and B 
                            instruments. The .h files of the ROM code 
                            compiled with the code were derived from these.
        
    firmware/<version>
        6800/6800*          The Motorola MC6800 microprocessor interpreter.
        5370/5370*          Called from the interpreter for 5370 bus I/O.
        5370/hpib*          The HPIB board emulator.
        arch/sitara/*       Mapping from 5370 bus to BBB GPIO.
        pru/*				PRU program and tools for generating bus cycles
            				and measuring N0/N3 counter overflows.
        support/*           Code to support the 7-seg display, LEDs, etc.
        user/*              An example of code to extend the capabilities of
                            the instrument.
        unix_env/*          A few customization files for the Linux distribution
                            including the device-tree file necessary to 
                            setup the GPIO lines.
        
    pcb/<version>/
        5370.schematic.pdf  schematic as a PDF
        5370.pro            KiCAD project file
        5370.sch            KiCAD schematic source
        5370.brd            KiCAD PCB layout source
        5370.gvp            Gerbv (Gerber viewer) project file
        5370.BOM.*          Bill-of-materials file: prices, part notes.
        plot/5370-*.*       Gerber plots from KiCAD: 2-layer board, mask, 
                            silkscreen and edge cut files.
        plot/5370.drl       KiCAD drill file: Excellon format, inches,
                            keep zeros, minimal header, absolute origin, 2:4
        plot/makefile       Will zip all the files together.
        test_fixture/       Files to support the test fixture built for use
                            by the board assembly company.
        
    pcb/data.sheets/        Cut sheets for all components.
        
    pcb/libraries.v1/       KiCAD-format library (schematic) and module 
    pcb/modules.v1/         (footprint) files for all the components used. 
                            No references are made to outside libraries to
                            keep things simple.


### Design overview

The idea is to run the unmodified instrument rom firmware by emulating the Motorola MC6800 processor used on the original 5370 processor board. The assumption is that the BeagleBone Black processor will be able to run the 5370 firmware, with the MC6800 interpreter, fast enough to outperform the original 1.5 MHz MC6800. This turns out to be the case, even with bit-banging the 5370 bus cycles using the BBB's GPIOs.

A superior solution would be to disassemble the rom code and re-code it in a higher level language. This can be done in a mechanical way or with a complete understanding of the underlying hardware in order to make the resulting code more understandable. Successful disassembly also depends on the amount of firmware involved and whether the firmware and processor architecture are well known. In this case the emulation solution was used to see if the technique would work and also be applied to other situations.

The same philosophy was applied to the 5370's HPIB controller. Rather than disassembling the associated firmware and contents of the ROM on the HPIB board, the bus cycles transferring data to and from the board were observed, an understanding of the board hardware obtained from looking at the schematics and then a software emulator was constructed. Now the HPIB board can be removed. The software then fools the unchanged 5370 firmware into thinking the HPIB board is still present even though the data now comes from the Ethernet, USB or the keyboard and display.

As mentioned before 5370 bus cycles are created by the bit-banged GPIO technique. There are some moderately complex macros, e.g. FAST_READ_CYCLE(), in the sitara.h file that carefully manipulate the GPIO registers. To support the new fast HPIB binary-mode there are a number of specially optimized macros that support the inner loop of these types of transfers. When there are no bus cycles occurring the 5370 bus clock is generated by a hardware timer. But this is stopped so the bus clock signal can be bit-banged along with the other signals.

The "device tree" mechanism must be used to configure the properties of the GPIO signals rather than from code in the app. This is handled by a combination of files installed by the "make install" command and also the "h.sh" script that is run whenever the "h" or "hd" command is used to start the app. Basically a .dts must be moved into the /lib/firmware directory, compiled to a binary blob and loaded into Linux. All this must occur once per boot before the app is run. The "slots" command shortcut can be used to view the device trees loaded that represent expansion boards ("capes") on the BBB.

Linux process scheduling can pause the execution of the app for arbitrary amounts of time. This is a serious problem during a long measurement when the firmware normally expects to run continuously to properly account for overflows of the 16-bit hardware N0 and N3 (event) counters. This problem is solved by using one of the integrated "programmable real-time unit" (PRU) sub-systems on the AM3335 processor chip of the BBB. A small program on the PRU generates all 5370 bus cycles and counter overflow measurements independently of Linux on the main CPU. See the "pru/" directory for the source.


### Transferring measurements over the network

A client-side example program 5370/hpib_client.c can be run on another computer to connect to the 5370 over a network connection and do HPIB-style transfers including regular (12K meas/sec) and the new fast (39K meas/sec) binary mode. The program is written in standard C and meant to be built with a "make bc" command on a generic Unix/Linux system. It uses ordinary TCP-based socket I/O found in support/net.c to connect to, not surprisingly, port number 5370.

It is also possible to use telnet (note: not ssh) to make a simple terminal-based connection to the port:

    telnet ip_address|hostname|localhost 5370

An example run from the instrument's own BBB (hence 'localhost'). Note that '~^\' (tilda followed by control-backslash) is the escape sequence to exit telnet. This is different than the '~.' needed to exit the ssh you're probably using to connect to the BBB.

    root@my-5370:telnet localhost 5370
    md2
    TI = 9.95700000000E-08
    st9
    TI = 9.95280000000E-08, STD= 2.94000000000E-11, MIN= 9.94700000000E-08
    MAX= 9.96100000000E-08, REF= 0.00000000000E-08, EVT= 1.00000000000E+02
    ~^\Quit
    root@my-5370:


### Expanding instrument functionality

In the file user/example.c is an example of how you might add some code to be called when a certain combination of front-panel keys are pressed. The routine meas_extend_example_init() is called from main.c at app startup time. It calls register_key_callback() to have the routine meas_extend_example() called whenever the MEAN and MIN keys are pressed together (or MEAN when LCL/RMT is used as a "shift"-style key).

Your extension code is being called when the instrument firmware is at the point of polling for new key presses. This means that theoretically nothing bad should happen with your code taking over control of the instrument. You have access to the routines in support/front_panel.[ch] to control the display and of course can read and write to the registers of the instrument (see 5370/5370_regs.h).

The example shows how to perform a TI measurement using the same technique as found in the disassembled HPIB binary mode transfer firmware. The code assumes you're measuring the internal 10 MHz reference against itself by running a cable from the freq std output jack at the back of the unit to the start input on the front and using the "START COM" front panel switch position.

This code doesn't handle large TI values where the 16-bit N0 counter overflows (64K @ 200 MHz (5 nS) = ~320us = ~3KHz). But it's a simple matter to sample the overflow flag in N0ST and compensate (a message is printed currently). Note that the original HPIB binary mode doesn't support TI measurements longer than ~320us for this very reason (see "TB1" command description in the 5370 manual).

[ end of document ]
