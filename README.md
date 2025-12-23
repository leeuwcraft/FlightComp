# FlightComp
A mobile based flight computer based on the godot engine, can also be used on your computer for a UDP connection with condor or xplane

AHRS Artificial horizon System, Built on IMU or UPD data from Condor or Xplane
<img width="1023" height="1023" alt="Schermafbeelding 2025-12-23 122725" src="https://github.com/user-attachments/assets/1bea180b-a8d7-4d3f-8f1c-2cf3c1973a11" />

I work on this project in my free time, The goal is to create an flight computer for gliding and maybe also for other purpoces. As of right now i've got a simple artificial horizon and map system set up

**Connecting to a simulator**

Xplane: 
launch the simulator in flight and go to the data tab, select the port 49003 and local ip 127.0.0.1

Condor:
Go to the condor files under C:\Condor3\Settings\UDP.ini and enable the default UDP on Host=127.0.0.1 Port=55278

Check connection:
go to the settings tab and there should be an indicator if the udp is connected
