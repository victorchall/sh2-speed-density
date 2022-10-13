sh2-speed-density
=================

Hitachi SH2 ASM Speed Density algorithm for Subaru/Renesas/Denso SH-2 ECU

I wrote this a number of years ago while hacking on my 2004 WRX STI and adding a bigger turbo and exceeding the airflow limit of the mass airflow sensor.

This is a code example for the AJ243 revision ECU, Renesas 7055 SOC based on Hitachi SH2, built by Renesas and used by Subaru cars from the mid-2000s to operate the engine.

It calculates an airflow based on a speed-density algorithm and 3D map of volumetric efficiency and engine RPM, and intake air temperature.

The code can be assembled to machine code with the KPIT SH2 toolkit and appended into an "empty" area of the flash ROM, along with hacking the new code location where the MAF sensor is read, pointing it to the SD code instead.

The Renesas 7055 chip comes with a 512KB embedded flash rom and 32kb RAM, operating with a single core 40mhz processor and a bunch of GPIO pins to talk to all the engine sensors and a simple serial bus over OBD2. 

This was a fun project so I could cram a GT3076R turbo in my car and reach well over 400hp.

This is long abandoned but posting on Github for those interested. 
