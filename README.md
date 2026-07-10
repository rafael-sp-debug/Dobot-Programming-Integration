# Dobot Programming and Integration Practices

A comprehensive repository containing various hardware and software integration practices for collaborative robots Dobots CR3 . This project demonstrates the progression from basic pick-and-place operations to complex dual-robot collaboration and remote execution via TCP sockets.

> Developed for the "Integración de robótica y sistemas inteligentes" module at Tecnológico de Monterrey.

![Lua](https://img.shields.io/badge/Lua-5.3.5-2C2D72?logo=lua&logoColor=white)
![Python](https://img.shields.io/badge/Python-3-3776AB?logo=python&logoColor=white)
![Robotics](https://img.shields.io/badge/Robotics-Dobot_CR3%2FCR5-FF6C37)
![TCP](https://img.shields.io/badge/Comms-TCP%2FIP-5C3EE8)

---

## Overview

This repository contains a series of incremental practices programming collaborative robots. The scripts leverage Lua for the internal Dobot controller and Python for external client interactions, executing tasks such as the Towers of Hanoi, Domino Effects, and remote teleoperation.

---

## Domino EffectDescription: 

* Precision programming in Lua to strategically place blocks in a calculated sequence to create a domino effect.
* Technical Approach: Relies on exact Cartesian coordinates and joint angles to ensure high-precision placement of each piece.
* Demo video: 

## Towers of HanoiDescription: 
* Algorithmic cobot manipulation to solve the Towers of Hanoi puzzle.  
* Technical Approach: Focuses on the execution and collaborative programming of the CR3 robot. The CR3 is programmed with calculated execution delays (Sleep) to safely share the workspace and interact with objects.
* Demo video: 

## Vertical StackingDescription: 
* Advanced manipulation logic for safely stacking and unstacking cubic objects.
* Technical Approach: Utilizes precise Z-axis coordinate adjustments, configuring the routines to dynamically update the height for stacking pieces measuring exactly 70mm.
* Demo video: 

## TCP Socket Remote ControlDescription: 
* Implementation of a Lua-based TCP server on the cobot and a Python client to remotely trigger custom routines (e.g., WAVE, CAPY, PICK).
* Technical Approach: Features a non-blocking TCP server in Lua that interprets string buffers into exact commands (such as HOME, ABRIR, DEMO). This server is paired with a Python command-line interface running externally with a 30-second timeout configuration.

* Demo video: https://www.canva.com/design/DAHI6L2jT-4/e1tTzp-EFi3vPf6vC2Fi9g/watch  

[Screencast from 07-09-2026 09:01:31 PM.webm](https://github.com/user-attachments/assets/3f5b2517-7135-4658-b058-881408ee27bb)

[Screencast from 07-09-2026 08:55:19 PM.webm](https://github.com/user-attachments/assets/613941e4-7b1b-441a-a4eb-8de4599239de)

---

##  Authors

* **Iker Gonzalez Aragon Rodriguez** 
* **Leyberth Jaaziel Castillo Guerra** 
* **Maximiliano De La Cruz Lima** 
* **Rafael Soto Padilla**
