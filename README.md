sh2-speed-density
=================

SH Speed Density algorithm for Subaru Denso SH-2 ECU

I wrote this a number of years ago while hacking on my 2004 WRX STI and adding a bigger turbo and exceeding the airflow limit of the mass airflow sensor.

This is a code example for the AJ243 revision ECU, Renesas 7055 SOC used by Subaru/Denso to operate the engine.

It calculates an airflow based on a speed-density algorithm and 3D map of volumetric efficiency and engine RPM, and intake air temperature.

The code can be assembled to machine code with the KPIT SH2 toolkit and appended into an "empty" area of the flash ROM, along with hacking the new code location where the MAF sensor is read, pointing it to the SD code instead.

This is long abandoned but posting on Github for those interested. 
