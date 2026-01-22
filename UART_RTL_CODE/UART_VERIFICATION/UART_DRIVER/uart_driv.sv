class uart_driver extends uvm_driver #(uart_tx_item);

  `uvm_component_utils(uart_driver)
  virtual uart_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);

      vif.data_in   <= req.data;
      vif.parity_en <= req.parity_en;
      vif.parity_odd<= req.parity_odd;

      // Start transmission
      vif.send <= 1;
      @(posedge vif.clk);
      vif.send <= 0;

      // Wait till TX completes
      wait(vif.busy == 0);

      seq_item_port.item_done();
    end
  endtask

endclass
