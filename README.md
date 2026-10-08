# Neon Blaster

FPGA-based arcade shooting game implemented in VHDL, featuring VGA graphics, random enemy generation, collision detection, score tracking, and real-time gameplay.

## Overview

Neon Blaster is a hardware-based arcade shooting game designed and implemented in VHDL for the Altera DE0 FPGA development board.

The game is displayed through a VGA monitor and controlled using the board's push buttons. The player controls a shooter located at the bottom of the screen and can move horizontally while continuously firing projectiles at incoming enemies.

Enemies appear from the top of the screen with pseudo-random positions and trajectories. The objective is to destroy enemies, accumulate points, and survive until meeting the game's win conditions.

This project demonstrates the implementation of real-time game logic, VGA graphics generation, collision detection, pseudo-random number generation, timing circuits, and FPGA hardware interfacing using digital design techniques.

---

## Features

- VHDL-based FPGA implementation
- Real-time VGA graphics output
- Player movement using push buttons
- Continuous projectile firing
- Pseudo-random enemy generation using LFSR
- Variable enemy trajectories
- Projectile-enemy collision detection
- Player-enemy collision detection
- Real-time score tracking
- Game timer implementation
- Win and lose state management
- 7-segment display integration
- LED status indicators
- Hardware-based real-time gameplay

---

## Gameplay

### Player

The player controls a shooter positioned at the bottom of the screen.

Available actions:

- Move left
- Move right

The shooter continuously fires projectiles upward at a fixed rate and remains within the game boundaries.

### Enemies

Enemies enter the game from the upper region of the screen.

Their behavior includes:

- Random spawn positions
- Random movement angles
- Dynamic trajectories throughout gameplay

The player earns points by destroying enemies before they reach the lower area of the screen.

### Collision Detection

The game continuously monitors:

- Projectile-enemy collisions
- Player-enemy collisions

Successful hits increase the player's score, while direct collisions with the player immediately end the game.

---

## Game States

The game operates through several states:

- Idle
- Playing
- Win
- Lose (Game Over)

The timer begins counting when the player starts the game.

### Win Conditions

The player wins when:

- Score reaches **10**
- Time reaches **60 seconds**

When a win condition is met, gameplay stops and board LEDs indicate the result.

### Lose Condition

The player loses when an enemy collides with the player.

In this state:

- Gameplay stops
- Timer stops
- LEDs indicate game over

---

## VGA Graphics System

The VGA interface is used to display all game elements in real time.

The design combines:

- VGA timing generation
- Pixel coordinate generation
- Object rendering
- Position update logic
- Collision detection
- Game-state control

to create a fully hardware-based graphical game environment on an FPGA platform.

---

## Random Enemy Generation

Pseudo-random values are generated using a 32-bit Linear Feedback Shift Register (LFSR).

These values determine:

- Enemy spawn positions
- Initial movement directions
- Enemy trajectories

This approach provides gameplay variation while maintaining a fully hardware-based implementation.

---

## Hardware Platform

- Altera DE0 FPGA Development Board
- VGA Monitor
- Push Buttons
- 7-Segment Displays
- LEDs

### Inputs

- Push buttons for player movement
- Reset button

### Outputs

- VGA display
- Score display
- Time display
- Status LEDs

---

## Technologies & Concepts

- VHDL
- FPGA Design
- Quartus II
- VGA Interface
- Finite State Machines (FSM)
- Digital System Design
- LFSR Random Number Generation
- Collision Detection
- Real-Time Game Logic
- Counters and Timers
- Hardware I/O Interfacing
- 7-Segment Displays

---

## Development Environment

- VHDL
- Intel/Altera Quartus II
- Altera DE0 FPGA Development Board
- VGA Monitor
