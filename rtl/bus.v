`timescale 1ns / 1ps

/*
Copyright (c) 2018, Stephen J. Leary
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed by the <organization>.
4. Neither the name of the <organization> nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
