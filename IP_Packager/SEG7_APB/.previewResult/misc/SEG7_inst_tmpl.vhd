component SEG7_inst is
    port(
        PCLK: in std_logic;
        RST_N: in std_logic;
        PADDR: in std_logic_vector(3 downto 0);
        PSEL: in std_logic;
        PENABLE: in std_logic;
        PWRITE: in std_logic;
        PWDATA: in std_logic_vector(31 downto 0);
        PRDATA: out std_logic_vector(31 downto 0);
        PREADY: out std_logic;
        PSLVERR: out std_logic;
        SEG7_OUT: out std_logic_vector(7 downto 0)
    );
end component;

__: SEG7_inst port map(
    PCLK=>,
    RST_N=>,
    PADDR=>,
    PSEL=>,
    PENABLE=>,
    PWRITE=>,
    PWDATA=>,
    PRDATA=>,
    PREADY=>,
    PSLVERR=>,
    SEG7_OUT=>
);
