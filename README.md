# SPI Controller with Register Map

VHDL SPI master supporting CPOL/CPHA modes 0-3, 8-32 bit words, a programmable divider, register interface and a self-checking loopback test for all mode/width combinations.

## Run

Requires GHDL. Run `make test`. Register addresses: 0 control, 1 status, 2 TX, 3 RX. Control: bit0 start, bit1 CPOL, bit2 CPHA, bits13:8 width, bits31:16 divider. Configuration writes are accepted only while idle.
