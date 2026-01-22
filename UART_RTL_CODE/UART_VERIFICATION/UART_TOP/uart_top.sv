module top;

  bit clk = 0;
  always #10 clk = ~clk;

  uart_if vif(clk);

  uart_tx u_tx (
    .clk(clk),
    .reset(vif.reset),
    .data_in(vif.data_in),
    .send(vif.send),
    .parity_en(vif.parity_en),
    .parity_odd(vif.parity_odd),
    .tx(vif.tx),
    .busy(vif.busy)
  );

  uart_rx u_rx (
    .clk(clk),
    .reset(vif.reset),
    .rx(vif.tx),
    .parity_en(vif.parity_en),
    .parity_odd(vif.parity_odd),
    .data_out(vif.data_out),
    .data_valid(vif.data_valid),
    .parity_error(vif.parity_error)
  );

  initial begin
    vif.reset = 1;
    #50 vif.reset = 0;
    run_test("uart_test");
  end

endmodule
