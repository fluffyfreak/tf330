


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
