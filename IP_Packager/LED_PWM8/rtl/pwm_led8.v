module apb_pwm_led (
    // APB Interface
    input  wire        pclk,
    input  wire        presetn,
    input  wire [31:0] paddr,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [31:0] pwdata,
    output reg  [31:0] prdata,
    output reg         pready,
    output wire        pslverr,

    // LED Outputs
    output reg  [7:0]  led_out
);

    // Register Map Constants
    localparam [31:0] ID_CODE = 32'hB00BDEAD; 
    reg [31:0] data_reg;

    // FSM States
    localparam ST_IDLE   = 2'b00;
    localparam ST_WRITE  = 2'b01;
    localparam ST_WAIT   = 2'b10; // The extra wait cycle for Read
    localparam ST_ACCESS = 2'b11; 

    reg [1:0] state;

    assign pslverr = 1'b0; // No error logic needed here

    // --- APB State Machine & Register Access ---
    

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            state    <= ST_IDLE;
            pready   <= 1'b0;
            prdata   <= 32'h0;
            data_reg <= 32'h0;
        end else begin
            case (state)
                ST_IDLE: begin
                    pready <= 1'b0;
                    if (psel && !penable) begin
                        if (pwrite) state <= ST_WRITE;
                        else        state <= ST_WAIT; // Force wait state for reads
                    end
                end

                ST_WRITE: begin
                    // Write happens immediately in the Setup->Access transition
                    if (psel && penable) begin
                        if (paddr[2]) data_reg <= pwdata; 
                        pready <= 1'b1;
                        state  <= ST_IDLE;
                    end
                end

                ST_WAIT: begin
                    // This cycle stalls the bus: PREADY remains 0
                    state <= ST_ACCESS;
                end

                ST_ACCESS: begin
                    // Now we provide the data and pull PREADY high
                    pready <= 1'b1;
                    case (paddr[2])
                        1'b0:    prdata <= ID_CODE;
                        1'b1:    prdata <= data_reg;
                        default: prdata <= 32'h0;
                    endcase
                    state <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

    // --- PWM Logic ---
      reg [15:0] pwm_cnt;

    // 1. Clock Prescaler & Counter
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            pwm_cnt   <= 16'd0;
        end 
		else begin
             pwm_cnt <= pwm_cnt + 1'b1;
        end
    end

    // 2. 8-Channel PWM Modulation
    // Formula: Output = (Counter < Duty_Cycle_Nibble)
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            case (data_reg[i*4 +: 4])
            4'h0 : led_out[i] = 1;
            4'h1 : led_out[i] = ~(pwm_cnt < 16'h0001);
            4'h2 : led_out[i] = ~(pwm_cnt < 16'h0002);
            4'h3 : led_out[i] = ~(pwm_cnt < 16'h0004);
            4'h4 : led_out[i] = ~(pwm_cnt < 16'h0008);  
            4'h5 : led_out[i] = ~(pwm_cnt < 16'h0010);
            4'h6 : led_out[i] = ~(pwm_cnt < 16'h0020);
            4'h7 : led_out[i] = ~(pwm_cnt < 16'h0040);
            4'h8 : led_out[i] = ~(pwm_cnt < 16'h0080);        
            4'h9 : led_out[i] = ~(pwm_cnt < 16'h0100);
            4'hA : led_out[i] = ~(pwm_cnt < 16'h0200);
            4'hB : led_out[i] = ~(pwm_cnt < 16'h0400);
            4'hC : led_out[i] = ~(pwm_cnt < 16'h0800);  
            4'hD : led_out[i] = ~(pwm_cnt < 16'h1000);
            4'hE : led_out[i] = ~(pwm_cnt < 16'h4000);
            4'hF : led_out[i] = ~(pwm_cnt < 16'h8000);
			endcase
		end
    end

endmodule