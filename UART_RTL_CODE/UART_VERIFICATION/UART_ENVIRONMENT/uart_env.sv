class uart_env extends uvm_env;

  `uvm_component_utils(uart_env)

  uart_driver     drv;
  uart_monitor    mon;
  uart_scoreboard scb;
  uvm_sequencer #(uart_tx_item) seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    drv  = uart_driver::type_id::create("drv", this);
    mon  = uart_monitor::type_id::create("mon", this);
    scb  = uart_scoreboard::type_id::create("scb", this);
    seqr = uvm_sequencer#(uart_tx_item)::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
    mon.ap.connect(scb.imp);
  endfunction

endclass
