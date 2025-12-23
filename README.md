# FlightComp
A mobile based flight computer based on the Godot engine, can also be used on your computer for a UDP connection with Condor or X-Plane

AHRS Artificial horizon System, Built on IMU or UPD data from Condor or X-Plane
<img width="1023" height="1023" alt="Schermafbeelding 2025-12-23 122725" src="https://github.com/user-attachments/assets/1bea180b-a8d7-4d3f-8f1c-2cf3c1973a11" />

I work on this project in my free time. The goal is to create a flight computer for gliding and maybe also for other purposes. As of right now I've got a simple artificial horizon and map system set up

## **Connecting to a simulator**

### **X-Plane:**
launch the simulator in flight and go to the Data tab, select the port 49003 and local IP 127.0.0.1

### **Condor:**
Go to the Condor files under C:\Condor3\Settings\UDP.ini and enable the default UDP on Host=127.0.0.1 Port=55278

### **Check connection:**
go to the settings tab and there should be an indicator if the udp is connected
