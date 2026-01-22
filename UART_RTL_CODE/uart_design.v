module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] data_in,
    input  wire       send,
    input  wire       parity_en,   // NEW: parity enable
    input  wire       parity_odd,  // NEW: 0=even, 1=odd
    output reg        tx,
    output wire       busy
);

    parameter IDLE  = 0, 
              START = 1, 
              DATA  = 2, 
              PARITY= 3, 
              STOP  = 4;
    
    reg [2:0] state;
    reg [2:0] bit_count;
    reg [7:0] shift_reg;
    reg [15:0] counter;
    reg        parity_bit;

    parameter BIT_TIME = 434; // 50MHz/115200 ≈ 434
    
    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1'b1;
            bit_count <= 0;
            counter <= 0;
            parity_bit <= 0;
        end else begin
            counter <= counter + 1;
            
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (send) begin
                        shift_reg <= data_in;
                        parity_bit <= parity_odd ? ~^data_in : ^data_in; // odd/even parity
                        state <= START;
                        counter <= 0;
                    end
                end
                
                START: begin
                    tx <= 1'b0;
                    if (counter == BIT_TIME-1) begin
                        state <= DATA;
                        counter <= 0;
                        bit_count <= 0;
                    end
                end
                
                DATA: begin
                    tx <= shift_reg[bit_count];
                    if (counter == BIT_TIME-1) begin
                        if (bit_count == 7) begin
                            if (parity_en)
                                state <= PARITY;
                            else
                                state <= STOP;
                        end else begin
                            bit_count <= bit_count + 1;
                        end
                        counter <= 0;
                    end
                end

                PARITY: begin
                    tx <= parity_bit;
                    if (counter == BIT_TIME-1) begin
                        state <= STOP;
                        counter <= 0;
                    end
                end
                
                STOP: begin
                    tx <= 1'b1;
                    if (counter == BIT_TIME-1) begin
                        state <= IDLE;
                        counter <= 0;
                    end
                end
            endcase
        end
    end

    assign busy = (state != IDLE);

endmodule

// =====================
// UART RECEIVER
// =====================
module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,
    input  wire       parity_en,   // NEW: parity enable
    input  wire       parity_odd,  // NEW: 0=even, 1=odd
    output reg [7:0]  data_out,
    output reg        data_valid,
    output reg        parity_error // NEW: flag if parity fails
);

    parameter IDLE  = 0, 
              START = 1, 
              DATA  = 2, 
              PARITY= 3, 
              STOP  = 4;
    
    reg [2:0] state;
    reg [2:0] bit_count;
    reg [7:0] shift_reg;
    reg [15:0] counter;
    reg        rx_parity;

    parameter BIT_TIME     = 434;
    parameter SAMPLE_POINT = 217;
    
    // Input synchronization
    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            data_out <= 0;
            data_valid <= 0;
            parity_error <= 0;
            bit_count <= 0;
            counter <= 0;
        end else begin
            data_valid <= 0;
            parity_error <= 0;
            counter <= counter + 1;
            
            case (state)
                IDLE: begin
                    counter <= 0;
                    if (rx_sync2 == 1'b0) begin
                        state <= START;
                    end
                end
                
                START: begin
                    if (counter == SAMPLE_POINT) begin
                        if (rx_sync2 == 1'b0) begin
                            state <= DATA;
                            counter <= 0;
                            bit_count <= 0;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end
                
                DATA: begin
                    if (counter == SAMPLE_POINT) begin
                        shift_reg[bit_count] <= rx_sync2;
                    end
                    
                    if (counter == BIT_TIME-1) begin
                        if (bit_count == 7) begin
                            if (parity_en)
                                state <= PARITY;
                            else
                                state <= STOP;
                        end else begin
                            bit_count <= bit_count + 1;
                        end
                        counter <= 0;
                    end
                end

                PARITY: begin
                    if (counter == SAMPLE_POINT) begin
                        rx_parity <= rx_sync2;
                        // Check parity
                        if (rx_parity != (parity_odd ? ~^shift_reg : ^shift_reg)) begin
                            parity_error <= 1;
                        end
                    end
                    if (counter == BIT_TIME-1) begin
                        state <= STOP;
                        counter <= 0;
                    end
                end
                
                STOP: begin
                    if (counter == SAMPLE_POINT) begin
                        data_out <= shift_reg;
                        data_valid <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
