//
//
// Hex to 7Seg decoder wrapped for APB interface
//
// Jay Vos - 2026
//
// Read : Reg0 : ID, Reg1: Hex input, Reg2 : Seg7 output
//
// Write: Reg1 : Hex input
//

module apb_slave (
    input  wire        PCLK,    // Clock
    input  wire        RST_N,   // Active low reset
	
    input  wire [3:0] PADDR,   // Address bus : 3 lower bits, covering 2 full 32bit memory locations 4'h0 and 4'h4
    input  wire        PSEL,    // Peripheral select
    input  wire        PENABLE, // Enable signal
    input  wire        PWRITE,  // Write/Read control
    input  wire [31:0] PWDATA,  // Write data bus
    output reg  [31:0] PRDATA,  // Read data bus
    output reg         PREADY,	// Peripheral ready
	output reg         PSLVERR,  // Error messaging
	
    output wire   [7:0] SEG7_OUT  // 7 segment data	
);

hex_to_7seg my_decoder (
        .clk(PCLK),
        .reset_n(RST_N),
        .hex_val(control_reg[7:0]),
        .seg(SEG7_OUT[7:0])
    );
	

    // State Encoding
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ACCESS = 2'b10;

    reg [1:0] current_state, next_state;
    
    // Internal Memory-Mapped Register (Example)
    reg [31:0] control_reg;

    // 1. State Transition Logic
    always @(posedge PCLK or negedge RST_N) begin
        if (!RST_N)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // 2. Next State Logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (PSEL) next_state = SETUP;
                else      next_state = IDLE;
            end
            SETUP: begin
                next_state = ACCESS;
            end
            ACCESS: begin
                if (PREADY) next_state = IDLE;
                else        next_state = ACCESS;
            end
            default: next_state = IDLE;
        endcase
    end

    // 3. APB Output and Register Logic
    always @(posedge PCLK or negedge RST_N) begin
        if (!RST_N) begin
			PSLVERR     <= 1'b0;
            PREADY      <= 1'b0;
            PRDATA      <= 32'h0;
            control_reg <= 32'h0;
        end else begin
            case (current_state)
                SETUP: begin
                    PREADY <= 1'b0; 								// Preparing for access
                end
                
                ACCESS: begin
                    PREADY <= 1'b1; 								// In this simple example, we are always ready
                    
                    if (PWRITE) begin
                        // Write Operation
                        case (PADDR)
                            4'h4:	begin 							// only 32 bit adress 1 (0x04) can be written
										control_reg <= PWDATA; 		// bit7:0 is the hex input for the Seg7 converter
									end
						
                            default: ; // Ignore unknown addresses
                        endcase
                    end else begin
                        // Read Operation
                        case (PADDR)
                            4'h0:	begin
										PRDATA <= 32'hDEADBEEF; // adress 0 = ID
									end							
                            4'h4:	begin
										PRDATA <= control_reg; // adress 1 = Hex input data
									end
                            4'h8:	begin
										PRDATA <= {24'h0,SEG7_OUT[7:0]}; // adress 2 = 7Seg output data
									end									
                            default:	PRDATA <= 32'hDEADBEEF;
                        endcase
                    end
                end
                
                default: begin
                    PREADY <= 1'b0;
                end
            endcase
        end
    end

endmodule