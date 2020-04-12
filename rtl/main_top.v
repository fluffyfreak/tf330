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

module main_top(

           input			RESET,
           output  			HALT,

           inout            DISABLE,

           // all clock lines.
           input   			CLK14M,
           input   			CLK100M,
           output   		CLKCPU,
           output  			CLKRAM,

           input [31:0]    	A,
           inout [31:24]   	D,

           //  SDRAM Control
           output			CLKRAME,
           output [12:0]    ARAM,
           output [1:0] 	BA,
           output			CAS,
           output [3:0] 	DQM,
           output			RAMWE,
           output			RAS,
           output			RAMCS,
           output			RAMOE,

           // transfer control lines
           input [1:0] 		SIZ,
           input [2:0] 		FC,
           output[2:0] 		IPL,

           // cache control lines.
           input			CBREQ,
           output			CBACK,
           output			CIIN,

           // 68030 control lines
           input			AS30,
           input			DS30,
           input			RW30,

           output [1:0] 	DS30ACK,
           output			STERM,

           output			BGACK30,
           output			BR30,
           input			BG30,

           // CD32 / 68020 control lines
           output			AS20,
           output			DS20,
           output			RW20,

           output			BR20,
           input			BG20,
           input			BGACK20,

           input [1:0] 		DSACK,

           output			IOW,
           output           IOR,

           input			IDEINT,
           input			IDEWAIT,
           output [1:0] 	IDECS,
           output			PUNT,
           output			BERR,

           input            EXP_BR,
           output           EXP_BG,

           output			INT2,
           input			IDELED,
           output			ACTIVE,

           output			RXD,
           output			RXD_EXT,

           input			TXD,
           input			TXD_EXT
       );

reg HIGHZ;
reg BGACK_INT;

reg ram_access;
reg PUNT_INT;
wire CPUSPACE = &FC;
wire FPUOP = CPUSPACE & ({A[19:16]} === {4'b0010});
wire ram_decode = ({A[31:26]} != {6'b0100_00});

wire GAYLE_IDE;
wire DTACK_IDE;

reg SPEED_D;

clocks CLOCKS(
    .CLK100M ( CLK100M ),
    .CLK14M  ( CLK14M  ),
    .SPEED   ( SPEED_D ),
    .CLKCPU  ( CLKCPU  )
);


arb ARB (
    
    .CLK	    ( CLKCPU    ),
    .CLK100M    ( CLK100M   ),
    .DISABLE    ( DISABLE   ),

    .AS30       ( AS30      ),

    .BR20       ( BR20      ),
    .BG20       ( BG20      ),

    .BG30       ( BG30      ),
    .BR30       ( BR30      ),
    .BGACK30    ( BGACK30   ),

    .EXP_BG     ( EXP_BG    ),
    .EXP_BR     ( EXP_BR    )
    
);


// module to control IDE timings. 
ata ATA (

	.CLK	( CLKCPU	), 
	.AS	    ( AS30      ),
	.RW	    ( RW30	    ),
	.A		( A		    ),
	// IDEWait not connected on TF328.
	.WAIT	( 1'b1	    ),  
	
	.IDECS  ( IDECS	    ),
	.IOR	( IOR		),
	.IOW	( IOW		),
	.DTACK  ( DTACK_IDE	),
    .ACCESS ( GAYLE_IDE )
	
);


// produce an internal data strobe
wire GAYLE_INT2;
wire GAYLE_ACCESS;

wire gayle_dout;
   
reg   GAYLE_DS;

gayle GAYLE(

    .CLKCPU ( CLKCPU        ),
    .RESET  ( RESET         ),

    .AS20   ( AS30          ),
    .DS20   ( GAYLE_DS      ),
    .RW     ( RW30          ),

    .A      ( A             ),

    .IDE_INT( IDEINT        ),
    .INT2   ( GAYLE_INT2    ),
    .DIN    ( D[31]         ),

    .DOUT   ( gayle_dout    ),
    .ACCESS ( GAYLE_ACCESS  )

);


wire [7:4] zii_dout;
wire zii_decode;

autoconfig AUTOCONFIG(

    .RESET  ( RESET         ),

    .AS20   ( AS30          ),
    .DS20   ( DS30          ),
    .RW20   ( RW30          ),

    .A      ( A             ),

    .DOUT   ( zii_dout[7:4] ),

    .ACCESS ( zii_decode	)
    //.DECODE ( ram_decode    )
);

wire WAIT;


sdram SDRAM (

    .RESET(RESET),

    .CLKCPU (CLKCPU),
    .CLK    (~CLKRAM),
    .CLKRAME(CLKRAME),

    .ACCESS(ram_access),

    .A(A),
    .SIZ(SIZ),

    .AS30(AS30),
    .RW30(RW30),
    .DS30(DS30),

    .CBACK(CBACK),
    .CIIN(CIIN), 
    .CBREQ(CBREQ),

    .STERM(STERM),

    .ARAM(ARAM),
    .BA(BA),

    .CAS(CAS),
    .RAS(RAS),

    .DQM(DQM),

    .RAMWE(RAMWE),

    .WAIT   ( WAIT      ),
    .RAMCS(RAMCS)
    //.RAMOE(RAMOE)
);


reg intcycle_dout = 1'b0;
reg fastcycle_int;
reg FASTCYCLE;

always @(negedge CLKCPU or posedge AS30) begin	

    if (AS30 == 1'b1) begin 
        
        intcycle_dout <= 1'b0;
        fastcycle_int <= 1'b1;
        FASTCYCLE <= 1'b1;

    end else begin 

        intcycle_dout <= ~(GAYLE_ACCESS & zii_decode) & RW30; 
        fastcycle_int <= GAYLE_ACCESS & zii_decode;
        FASTCYCLE <= fastcycle_int;

    end
end

reg AS20_D;
reg DS20_D;

always @(negedge CLK100M or posedge AS30) begin	

    if (AS30 == 1'b1) begin 

        AS20_D <= 1'b1;
        DS20_D <= 1'b1;
        ram_access <= 1'b1;

    end else begin 

        ram_access <= AS30 | ram_decode;
        AS20_D <= AS30 | ~SPEED_D;
        DS20_D <= DS30 | ~SPEED_D;
        GAYLE_DS <= DS30 | GAYLE_ACCESS | AS30;
    
    end 

end

wire PUNT_COMB = GAYLE_ACCESS & ram_access & GAYLE_IDE & zii_decode;

always @(posedge CLK100M) begin 

    BGACK_INT <= (BG30 | ~AS30) & (BGACK_INT | EXP_BR) | EXP_BR;
    HIGHZ <= PUNT_INT & BGACK30;
    PUNT_INT <= PUNT_COMB;
    SPEED_D <= ~AS30 & ram_decode & GAYLE_IDE & GAYLE_ACCESS;

end 

assign PUNT = PUNT_INT ? 1'bz : 1'b0;
assign INT2 = GAYLE_INT2 ? 1'bz : 1'b0;

wire [7:4] data_out = GAYLE_ACCESS ?  (zii_decode ? 4'b1111 : {zii_dout})
                                    : {gayle_dout,3'b000};

assign D[31:24] = (intcycle_dout) ? {data_out[7:4], 4'h0} : 8'bzzzzzzzz;   

assign CLKRAM = CLK100M;
assign DS30ACK = {FASTCYCLE  & DTACK_IDE, 1'b1} & DSACK ;

assign AS20 = HIGHZ ? AS20_D : 1'bz;
assign DS20 = HIGHZ ? DS20_D : 1'bz;
assign RW20 = HIGHZ ? RW30 : 1'bz;

assign HALT = 1'b1;
assign BERR = 1'bz;

// setup the serial port pass through
assign RXD_EXT = TXD;
assign RXD = TXD_EXT ? 1'bz : 1'b0;

assign D[31:24] = 8'bzzzzzzzz;
assign IPL = 3'bzzz;

assign RAMOE = ram_access;
assign ACTIVE = IDELED ? 1'bz : 1'b0;

endmodule
