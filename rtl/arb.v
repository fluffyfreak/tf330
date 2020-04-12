`timescale 1ns / 1ps
/*
    Copyright (C) 2019, Stephen J. Leary
    All rights reserved.
    
    This file is part of  TF530 (Terrible Fire 030 Accelerator).

    TF530 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    TF530 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with TF530. If not, see <http://www.gnu.org/licenses/>.
*/

module arb(

    input           CLK,
    input           CLK100M, 
    input           DISABLE, 

    input           AS30,

    // 020 ARB
    output			BR20,
    input			BG20,

    // 030 ARB
    output	reg		BR30,
    output	reg		BGACK30,
    input			BG30,

    // AKIKO ARB
    input           EXP_BR,
    output          EXP_BG

);

reg BGACK_INT;

always @(posedge CLK) begin 

    BGACK_INT <= ((BG30 | ~AS30) & (BGACK_INT | EXP_BR) | EXP_BR) & ~DISABLE;

end

always @(posedge CLK100M) begin 

    BR30 <= EXP_BR & ~DISABLE;
    BGACK30 <= BGACK_INT;

end

assign BR20     = DISABLE;
assign EXP_BG   = DISABLE ? 1'bz : BGACK_INT;

endmodule
