library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
entity spi is port(clk,rst:in std_logic;addr:in unsigned(1 downto 0);wdata:in unsigned(31 downto 0);we:in std_logic;rdata:out unsigned(31 downto 0);sclk,mosi,cs_n:out std_logic;miso:in std_logic);end;
architecture rtl of spi is
 signal control,txdata,rxdata:unsigned(31 downto 0):=(others=>'0');signal busy,done,clock_:std_logic:='0';signal cpol,cpha:std_logic:='0';
 signal divider:natural range 1 to 65535:=2;signal counter:natural range 0 to 65535:=0;signal width:natural range 8 to 32:=8;signal edges:natural range 0 to 64:=0;signal sampled:natural range 0 to 32:=0;
 signal txreg,rxreg:unsigned(31 downto 0):=(others=>'0');signal output_:std_logic:='0';
begin
 sclk<=clock_;mosi<=output_;cs_n<=not busy;
 with to_integer(addr) select rdata<=control when 0,(31 downto 2=>'0')&done&busy when 1,txdata when 2,rxdata when others;
 process(clk) variable leading:boolean;variable sample_edge:boolean;variable next_rx:unsigned(31 downto 0);variable requested:natural;
 begin if rising_edge(clk) then
  if rst='1' then busy<='0';done<='0';clock_<='0';counter<=0;control<=(others=>'0');txdata<=(others=>'0');rxdata<=(others=>'0');
  else
   if we='1' then
    if addr=2 and busy='0' then txdata<=wdata;
    elsif addr=0 and busy='0' then
     control<=wdata;cpol<=wdata(1);cpha<=wdata(2);clock_<=wdata(1);done<='0';
     requested:=to_integer(wdata(13 downto 8));if requested<8 then requested:=8;elsif requested>32 then requested:=32;end if;width<=requested;
     if to_integer(wdata(31 downto 16))=0 then divider<=1;else divider<=to_integer(wdata(31 downto 16));end if;
     if wdata(0)='1' then busy<='1';txreg<=txdata;rxreg<=(others=>'0');edges<=0;sampled<=0;counter<=0;if wdata(2)='0' then output_<=txdata(requested-1);end if;end if;
    end if;
   end if;
   if busy='1' then
    if counter+1>=divider then
     counter<=0;clock_<=not clock_;leading:=(edges mod 2)=0;sample_edge:=(leading and cpha='0')or(not leading and cpha='1');
     if sample_edge then next_rx:=shift_left(rxreg,1);next_rx(0):=miso;rxreg<=next_rx;sampled<=sampled+1;
     elsif sampled<width then output_<=txreg(width-1-sampled);end if;
     if edges=width*2-1 then busy<='0';done<='1';clock_<=cpol;if sample_edge then rxdata<=next_rx;else rxdata<=rxreg;end if;else edges<=edges+1;end if;
    else counter<=counter+1;end if;
   end if;
  end if;
 end if;end process;
end;
