`timescale 1ns / 1ps
/*
    Copyright (C) 2019, Stephen J. Leary
    All rights reserved.
    
    This file is part of  TF330 (Terrible Fire 030 Accelerator).

    TF330 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    TF330 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with TF330. If not, see <http://www.gnu.org/licenses/>.
*/

module bus(

           input 	    CLKCPU,
           input 	    CLK14M,

           output       HALT,

           input [31:0] A,

           input [2:0]  FC,
           input [1:0]  SIZ,

           input 	    AS30,
           input 	    DS30,
           input 	    RW30,
           output[1:0]  DS30ACK,
           
           output 	    AS20,
           output 	    DS20,
           output 	    RW20,
           input [1:0]  DSACK,

           input        INTCYCLE,

           output 	    BERR

       );

reg     AS30DLY = 1'b1;

reg     RW20_INT = 1'b1;
reg     DS20_INT = 1'b1;
reg     AS20_INT = 1'b1;

wire    CPUSPACE = &FC;

wire    FPUOP = CPUSPACE & ({A[19:16]} === {4'b0010});
wire    BKPT = CPUSPACE & ({A[19:16]} === {4'b0000});
wire    IACK = CPUSPACE & ({A[19:16]} === {4'b1111});

wire    HIGHZ = ~INTCYCLE;

reg     [1:0] DS30ACK_LATCHED;

reg     CANSTART = 1'b1;

wire AS_AMIGA = AS30 | FPUOP | ~INTCYCLE | (~CANSTART & AS20_INT);

// This block ensures that we see at least
// 1 falling edge of the slow clock before
// starting a new slow bus cycle.
always @(posedge CLK14M or negedge AS20) begin

    if (AS20 == 1'b0) begin

        CANSTART <= 1'b0;

    end else begin

        CANSTART <= 1'b1;

    end

end

always @(posedge CLK14M or posedge AS30) begin

    if (AS30 == 1'b1) begin

        DS30ACK_LATCHED <= 2'b11;

    end else begin


        DS30ACK_LATCHED <= {2{DS20_INT}} | DSACK; 

    end

end

always @(negedge CLK14M or posedge AS30) begin

    if (AS30 == 1'b1) begin

        AS20_INT <= 1'b1;        
        RW20_INT <= 1'b1;
        DS20_INT <= 1'b1;
  
    end else begin

        // assert these lines in S1
        // the 68030 assert them one half clock early.
        AS20_INT    <= AS_AMIGA;  // Low in S1
        RW20_INT    <= RW30 | AS_AMIGA;

        if (RW30 == 1'b1) begin

            // reading when reading the signals are asserted in 7Mhz S1
            DS20_INT <=  AS_AMIGA;

        end else begin

            // when writing the the signals are asserted in 14Mhz S3
            DS20_INT <=  AS20_INT | AS_AMIGA;

        end

    end

end

assign HALT = 1'b1; 

assign RW20 =   HIGHZ ? 1'bz : RW20_INT;
assign AS20 =   HIGHZ ? 1'bz : AS20_INT;
assign DS20 =   HIGHZ ? 1'bz : DS20_INT | DS30;

assign DS30ACK = DS30ACK_LATCHED;
assign BERR = (~FPUOP | AS30) ? 1'b1 : 1'b0;

endmodule
