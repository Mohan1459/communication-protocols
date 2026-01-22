class uart_sequence extends uvm_sequence #(uart_tx_item);

  `uvm_object_utils(uart_sequence)

  function new(string name="uart_sequence");
    super.new(name);
  endfunction

  task body();
    uart_tx_item req;

    repeat (10) begin
      req = uart_tx_item::type_id::create("req");
      assert(req.randomize());
      start_item(req);
      finish_item(req);
    end
  endtask

endclass
