component LED_PWM8_inst is
    port(
        pclk: in std_logic;
        presetn: in std_logic;
        paddr: in std_logic_vector(31 downto 0);
        psel: in std_logic;
        penable: in std_logic;
        pwrite: in std_logic;
        pwdata: in std_logic_vector(31 downto 0);
        prdata: out std_logic_vector(31 downto 0);
        pready: out std_logic;
        pslverr: out std_logic;
        led_out: out std_logic_vector(7 downto 0)
    );
end component;

__: LED_PWM8_inst port map(
    pclk=>,
    presetn=>,
    paddr=>,
    psel=>,
    penable=>,
    pwrite=>,
    pwdata=>,
    prdata=>,
    pready=>,
    pslverr=>,
    led_out=>
);
