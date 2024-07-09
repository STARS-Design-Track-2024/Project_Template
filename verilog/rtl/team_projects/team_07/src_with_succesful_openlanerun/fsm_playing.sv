/*
    Module: playing_fsm
    Description: 
        Control the plaing state between MOD and sub-module (MAZE, etc.)
    Keep tract of the sub-module clear to output the game_clear signal.

*/
`define MENU 3'b000
`define PLAY 3'b001
`define LOST 3'b010
`define WON 3'b011

`define MOD 3'b000
`define MAZE 3'b001

`define SELECT 6'b000001
`define UP 6'b000010
`define RIGHT 6'b000100
`define DOWN 6'b001000
`define LEFT 6'b010000
`define BACK 6'b100000
`define NO_PRESS 6'b000000

module fsm_playing(
    input logic nrst,
    input logic clk,
    input logic strobe,
    input logic [5:0] button,
    input logic [2:0] game_state_in,
    input logic [2:0] mod_num,
    input logic mod_row,
    input logic mod_col,
    input logic submodule_clear_edge,
    output logic [2:0] playing_state_out,
    output logic game_clear
);
    typedef enum logic [2:0] { 
        MENU = 3'd0, PLAY = 3'd1, LOST = 3'd2, WON = 3'd3
    } game_state_t;

    typedef enum logic [2:0] {
        MOD = 3'd0, MAZE = 3'd1 
    } playing_state_t;

    playing_state_t next_playing_state, playing_state;
    logic [2:0] num_clear, next_num_clear;

    assign playing_state_out = playing_state;

    playing_state_t mod_select[2][2];
    assign mod_select[0][0] = MAZE;
    assign mod_select[0][1] = MAZE;
    assign mod_select[1][0] = MAZE;
    assign mod_select[1][1] = MAZE;

    always_ff @(negedge nrst, posedge clk) begin
        if (!nrst) begin
            playing_state <= MOD;
            num_clear <= 3'd0;
        end else begin
            playing_state <= next_playing_state;
            num_clear <= next_num_clear;
        end
    end

    always_comb begin
        // logic for next_playing_state and next_num_clear
        next_playing_state = playing_state;
        next_num_clear = num_clear;
        if (game_state_in == `MENU) begin
            next_num_clear = 3'd0;
            next_playing_state = MOD;
        end else if (game_state_in == PLAY) begin
            case (playing_state)
                MOD: begin
                    if (strobe && (button == `SELECT)) begin    // condition to go into MAZE game, but for rn, set to SELECT button
                        next_playing_state = mod_select[mod_row][mod_col];
                    end
                end
                MAZE: begin
                    if (strobe && (button == `BACK)) begin        // press BACK to move from SUB to MOD
                        next_playing_state = MOD;
                    end else if (submodule_clear_edge) begin    // if submodule_clear_edge, add num_clear by one
                        next_num_clear = num_clear + 1;
                    end
                end
                default:;
            endcase
        end

        // logic for game_clear signal        
        if (num_clear == mod_num) begin // if all modules are cleared, send game_clear signal
            game_clear = 1'b1;
        end else begin
            game_clear = 1'b0;
        end
    end
endmodule