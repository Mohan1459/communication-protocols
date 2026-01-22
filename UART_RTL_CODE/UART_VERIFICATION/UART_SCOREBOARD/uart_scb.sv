class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard)

  uvm_analysis_imp #(uart_tx_item, uart_scoreboard) imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  function void write(uart_tx_item item);
    `uvm_info("UART_SCB",
      $sformatf("RX Data = %0h", item.data),
      UVM_LOW)
  endfunction

endclass
