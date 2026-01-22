class uart_tx_item extends uvm_sequence_item;

  rand bit [7:0] data;
  rand bit parity_en;
  rand bit parity_odd;

  `uvm_object_utils(uart_tx_item)

  function new(string name="uart_tx_item");
    super.new(name);
  endfunction

endclass
