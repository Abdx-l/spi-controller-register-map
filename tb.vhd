library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;use std.env.all;
entity tb is end;architecture test of tb is
signal clk:std_logic:='0';signal rst:std_logic:='1';signal we:std_logic:='0';signal addr:unsigned(1 downto 0):=(others=>'0');signal wd,rd:unsigned(31 downto 0):=(others=>'0');signal sclk,mosi,cs:std_logic;
begin clk<=not clk after 5 ns;
dut:entity work.spi port map(clk,rst,addr,wd,we,rd,sclk,mosi,cs,mosi);
process
procedure write_register(a:natural;v:unsigned(31 downto 0))is begin wait until falling_edge(clk);addr<=to_unsigned(a,2);wd<=v;we<='1';wait until falling_edge(clk);we<='0';end;
variable control:unsigned(31 downto 0);
begin wait for 30 ns;rst<='0';
for mode in 0 to 3 loop
 for bits in 8 to 32 loop
  write_register(2,x"A5C33C5A");control:=to_unsigned(2*65536+bits*256+1,32);if mode>=2 then control(1):='1';end if;if mode mod 2=1 then control(2):='1';end if;
  write_register(0,control);wait until cs='1';wait until falling_edge(clk);addr<=to_unsigned(3,2);wait for 1 ns;
  assert rd=resize(resize(unsigned'(x"A5C33C5A"),bits),32) report "SPI loopback mismatch" severity failure;
 end loop;
end loop;report "PASS SPI modes and widths";stop;wait;end process;
process begin wait for 1 ms;assert false report "timeout" severity failure;end process;
end;
