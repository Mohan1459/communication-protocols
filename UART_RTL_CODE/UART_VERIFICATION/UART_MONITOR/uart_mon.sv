class uart_monitor extends uvm_monitor;

  `uvm_component_utils(uart_monitor)
  virtual uart_if vif;

  uvm_analysis_port #(uart_tx_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    uart_tx_item item;

    forever begin
      @(posedge vif.data_valid);
      item = uart_tx_item::type_id::create("item");
      item.data = vif.data_out;
      ap.write(item);
    end
  endtask

endclass
