`ifndef TIMER
`define TIMER

`define TIMER_MTIMEL    2'b00
`define TIMER_MTIMEH    2'b01
`define TIMER_MTIMECMPL 2'b10
`define TIMER_MTIMECMPH 2'b11

module timer (
    input clk,
    input reset,

    /* cycle count (from the CPU core) */
    input [63:0] cycle_in,

    /* memory bus */
    input [31:0] address_in,
    input sel_in,
    input read_in,
    output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);
    logic [63:0] mtimecmp;

    assign ready_out = sel_in;

    always_comb begin
        if (sel_in) begin
            case (address_in[3:2])
                `TIMER_MTIMEL:    read_value_out = cycle_in[31:0];
                `TIMER_MTIMEH:    read_value_out = cycle_in[63:32];
                `TIMER_MTIMECMPL: read_value_out = mtimecmp[31:0];
                `TIMER_MTIMECMPH: read_value_out = mtimecmp[63:32];
            endcase
        end else begin
            read_value_out = 0;
        end
    end

    always_ff @(posedge clk) begin
        if (sel_in) begin
            case (address_in[3:2])
                `TIMER_MTIMECMPL: begin
                    if (write_mask_in[3])
                        mtimecmp[31:24] <= write_value_in[31:24];

                    if (write_mask_in[2])
                        mtimecmp[23:16] <= write_value_in[23:16];

                    if (write_mask_in[1])
                        mtimecmp[15:8] <= write_value_in[15:8];

                    if (write_mask_in[0])
                        mtimecmp[7:0] <= write_value_in[7:0];
                end
                `TIMER_MTIMECMPH: begin
                    if (write_mask_in[3])
                        mtimecmp[63:56] <= write_value_in[31:24];

                    if (write_mask_in[2])
                        mtimecmp[55:48] <= write_value_in[23:16];

                    if (write_mask_in[1])
                        mtimecmp[47:40] <= write_value_in[15:8];

                    if (write_mask_in[0])
                        mtimecmp[39:32] <= write_value_in[7:0];
                end
            endcase
        end

        if (reset) begin
            mtimecmp <= 0;
        end
    end
endmodule

`endif
