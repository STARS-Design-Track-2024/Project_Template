/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

/*
	IO Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Observes counter value through the MPRJ lower 8 IO pins (in the testbench)
*/

// Team 05
#define reg_team_05_EN (*(volatile uint32_t*)0x30050000)

// GPIO Control
#define reg_gpio_PIN_0TO7 (*(volatile uint32_t*)0x32000000)
#define reg_gpio_PIN_8TO15 (*(volatile uint32_t*)0x32000004)
#define reg_gpio_PIN_16TO23 (*(volatile uint32_t*)0x32000008)
#define reg_gpio_PIN_24TO31 (*(volatile uint32_t*)0x3200000C)
#define reg_gpio_PIN_32TO37 (*(volatile uint32_t*)0x32000010)

// LA Control
#define reg_la_sel (*(volatile uint32_t*)0x31000000)


#define sram_space (*(volatile uint32_t*)0x33000000)

void main()
{
	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |

	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |

	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	// reg_spi_enable = 1;
	// reg_spimaster_cs = 0x10001;
	// reg_spimaster_control = 0x0801;

	// reg_spimaster_control = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

	// Configure lower 8-IOs as user output
	// Observe counter value in the testbench
	reg_spi_enable = 1;
    reg_wb_enable = 1;

	// //Keypad
	// //reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_NOPULL;
	// // DON"T TOUCH PINS: between 0-5
	// // reg_mprj_io_1 = GPIO_MODE_USER_STD_INPUT_NOPULL; 
	// // reg_mprj_io_2 = GPIO_MODE_USER_STD_INPUT_NOPULL;
	// // reg_mprj_io_3 = GPIO_MODE_USER_STD_INPUT_NOPULL;   
	// // reg_mprj_io_4 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_5 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_6 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_7 =  GPIO_MODE_USER_STD_OUTPUT;

	// //Temp Sensor // CHANGE TO BIDIR
	// reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT;

	// //LCD screen
	// reg_mprj_io_9  =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_10 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_11 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_12 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_13 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_14 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_15 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_16 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_17 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_18 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_19 =  GPIO_MODE_USER_STD_OUTPUT;

	// //reg_mprj_io_20  =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	// //reg_mprj_io_21 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	// //reg_mprj_io_22 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	// //reg_mprj_io_23 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	// reg_mprj_io_24 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_25 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_26 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_27 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_28 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_29 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_30 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_31 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_32 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_33 =  GPIO_MODE_USER_STD_OUTPUT;
	// reg_mprj_io_34 =  GPIO_MODE_USER_STD_OUTPUT;
    // reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
    // reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
    // reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;
	
	reg_mprj_io_0 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_5 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;

	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	// Configure GPIOs outputs to be selected by sample project
	reg_gpio_PIN_0TO7 = 0x55555555;
	reg_gpio_PIN_8TO15 = 0x55555555;
	reg_gpio_PIN_16TO23 = 0x55555555;
	reg_gpio_PIN_24TO31 = 0x55555555;
	reg_gpio_PIN_32TO37 = 0x555555;

	// Enable the design
	sram_space = 0x3e800093;
    *(&sram_space + 1) = 0x7d000113;
    *(&sram_space + 2) = 0x002081b3;
	*(&sram_space + 3) = 0x33000237;
	*(&sram_space + 4) = 0x00420213;
	*(&sram_space + 5) = 0x00022283;

	/**
	*(&sram_space + 6) = 0xfe0302e3;
	*(&sram_space + 7) = 0x00230633;
	*(&sram_space + 8) = 0xfddff06f;
	*(&sram_space + 9) = 0x3e828513;
	*/


	reg_team_05_EN = 1;
}





