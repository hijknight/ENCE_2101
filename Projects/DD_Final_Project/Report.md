# Digital Design Final Project -- Traffic Light

## Introduction
Our project is to design an intersection that has two traffic lights, and a pedestrian button. We can setup a nicely formatted simulation in logisim, but Dr. Martin provided an html file that acts as a simulation.

<div align="center">
    <img src="images/Screenshot 2026-11-04 at 9.18.50 AM.png" width="280">
</div>


### Logic
The idea is that every three seconds, a change of state will occur. Each of the traffic lights will have opposite initial states (ie. East-West will init. to red, and North-South will init. to green). The catch is that we cant have two yellows at the same time, so we can only allow East-West to go to green after North-South has cycled from green to yellow, and then yellow to red.

### Timing
In the grand scheme of things, at least one change of state will occur every 3 seconds, as long as the pedestrian button is not pressed. If the ped. button is pressed, then the circuit will take the required time to bring both lights to red, and then count down for ten for the pedestrians to cross.

## Starting with just the traffic lights

### Hardware needed

The hardware we need includes pretty much everything we learned about this quarter. Seven segment displays, registers, combinational logic, multiplexers, etc.

### The FSM

For Lab 07, we designed a simple traffic light, that changed states (cycled) every 3 seconds. For this we used a down counter from 3 -> 0 and a 2hz clock. The FSM used was relatively simple, with just three states.

At first, I thought that we could take the simple FSM from lab 7, duplicate it, and simply reverse the order of the states. Then, I saw the problem. We cant have two yellows. Simply reversing the states would cause this. So, instead, we will use one state machine with more states, that never allows these cases: two yellows, two greens, and two reds. The lattermost case is important right now, but in the future when we add the pedestrian button, we will require two reds.

<div align="center">
<img src="images/FSM_twolights.png" width="300">
</div>

#### Designing this FSM in logisim:

I took a very similar approach to the construction of this FSM as we did during lab 7. I used a multiplexer for each of the 4 states, a state register, and inverters and AND gates to get 4 state outputs (RG, RY, GR, YR).

<div align="center">
<img src="images/FSM_1_logisim.png" width="400">
</div>

Later, we can use this same logic with a larger MUX to add the pedestrian button states.

## Thinking Through the States Needed

For the full intersection, we need to have the two lights, but also the pedestrian button. For the FSM, we can use the four state used above and then also add to new states: `WALK_A` and `WALK_B`, which will both correspond to two Red-Red states. The difference between them is which light will go green after the ten second walking countdown passes. For example, `WALK_B` might follow Road B's yellow, so road A will go green afterward.

| State  | Binary | Light A | Light B |
| ------ | ------ | ------- | ------- |
| RG     | 000    | Red     | Green   |
| RY     | 001    | Red     | Yellow  |
| GR     | 010    | Green   | Red     |
| YR     | 011    | Yellow  | Red     |
| WALK_B | 100    | Red     | Red     |
| WALK_A | 101    | Red     | Red     |

I found a nice tool online to makea finite state machine with labels and arrows [here](https://fsm-builder.vercel.app/). Here is a visualization of the state machine I designed following the table above:


<div align="center">
<img src="images/FSM_ped.png" width = 300>
</div>

We can implement this in logisim with an 8 to 1 3 bit mux, and two 2 to 1 muxes with the pedestrian button as the select bit. 

<div align="center">
<img src="images/FSM_ped_logisim.png" width = 400>
</div>

We have not yet added the combinational logic to decode each state into outputs, so lets do that now.

<div align = "center">
<img src="images/Decoded_FSM_ped.png" width = 400>
</div>

This is a nice implementation of the FSM. After this I shifted gears and made the below circuit, with is a down counter that can select between counting down from 10 and counting down from 3. This will be useful between FSM states, and it is usable because we dont ever need to count from 10 or 3 simultaneously. 

<div align = "center">
<img src="images/SelCoutner&apos;.png" width = 500>
</div>

