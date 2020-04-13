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


module clocks(
              input      CLK100M,
              input      CLK14M,
              input      SPEED, 
              output     CLKCPU
);

reg CLK50MI;
reg [3:0] CLK14M_D;

always @(posedge CLK100M) begin 

        CLK14M_D <= {CLK14M_D[2:0], ~CLK14M};

        if (SPEED) begin
            CLK50MI <=  CLK14M_D[1];
        end else begin 
            CLK50MI <= ~CLK50MI;
        end 

end 

assign CLKCPU = CLK50MI;

endmodule
