# STARS 2024 Design Final Project

## CPU TEAM 5
* Ainsley Strothkamp
* Alex Tauriainen
* Berin Celik
* Medha Shinde
* Shrienidhi Gopalakrishnan
* Peer Mentor: Pranav Wadhwa

## Project Type
Our project was to create a 32-bit single-cycle RISC-V CPU. We integrated this with a 4x4 keypad for inputs and a 16x2 LCD screen for outputs. 

## Pin Layout
Note that on the final chip, there are 38 gpio of which you have access to 4.
The first number represents the GPIO on the physical board. The second number
in brackets represents the number in your verilog code.

### Inputs
* [33:30] keypad_in

### Outputs
* [00] lcd_rw
* [01] lcd_rs
* [02] lcd_en
* [10:3] lcd_data
* [14:11] keypad_out


## Supporting Equipment

#### 4x4 keypad
![keypad](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/io_components/keypad.jpeg)

#### 16x2 GDM1602K LCD screen
![lcd_screen](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/io_components/lcd_screen.jpg)

## RTL Diagrams

### Top level RTLs

#### General
![top_general](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/top_level/top_general.png)

#### Detailed
![top_detail](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/top_level/top_detail.jpg)

### Sub-Modules

#### Control Unit
![control_unit](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/control_unit.png)

![tb_control_unit](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/tb_sub_modules/tb_control_unit.png)

#### Register File
![reg_file](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/reg_file.png)

![tb_reg_file](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/tb_sub_modules/tb_reg_file.png)

#### PC
![pc_1](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/pc_1.png)

![pc_2](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/pc_2.png)

![tb_pc](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/tb_sub_modules/tb_pc.png)

#### ALU
![alu](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/alu.png)

![tb_alu](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/tb_sub_modules/tb_alu.png)

#### Memory control (request unit)
![mem_control](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/mem_control.png)

![tb_mem_control](https://github.com/STARS-Design-Track-2024/nebula-ii-team-05/blob/main/docs/team_05/sub_modules/tb_sub_modules/tb_memcontrol.png)

## Statement from Purdue
Pending

