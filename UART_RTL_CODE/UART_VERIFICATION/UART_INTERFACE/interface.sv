interface uart_if(input logic clk);

  logic reset;

  // TX
  logic [7:0] data_in;
  logic send;
  logic parity_en;
  logic parity_odd;
  logic tx;
  logic busy;

  // RX
  logic [7:0] data_out;
  logic data_valid;
  logic parity_error;

endinterface
