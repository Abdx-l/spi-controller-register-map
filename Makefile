test:
	ghdl -a --std=08 spi.vhd tb.vhd
	ghdl -e --std=08 tb
	ghdl -r --std=08 tb --assert-level=error
