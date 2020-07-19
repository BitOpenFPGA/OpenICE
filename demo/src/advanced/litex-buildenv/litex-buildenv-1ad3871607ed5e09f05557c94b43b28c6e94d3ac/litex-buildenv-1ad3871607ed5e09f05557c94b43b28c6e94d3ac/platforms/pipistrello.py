from litex.build.generic_platform import *
from litex.build.xilinx import XilinxPlatform
from litex.build.xilinx.programmer import XC3SProg
from litex.build.openocd import OpenOCD

_io = [
    ("user_led", 0, Pins("V16"), IOStandard("LVTTL"), Drive(8), Misc("SLEW=QUIETIO")),  # green at hdmi
    ("user_led", 1, Pins("U16"), IOStandard("LVTTL"), Drive(8), Misc("SLEW=QUIETIO")),  # red at hdmi
    ("user_led", 2, Pins("A16"), IOStandard("LVTTL"), Drive(8), Misc("SLEW=QUIETIO")),  # green at msd
    ("user_led", 3, Pins("A15"), IOStandard("LVTTL"), Drive(8), Misc("SLEW=QUIETIO")),  # red at msd
    ("user_led", 4, Pins("A12"), IOStandard("LVTTL"), Drive(8), Misc("SLEW=QUIETIO")),  # red at usb

    ("user_btn", 0, Pins("N14"), IOStandard("LVTTL"), Misc("PULLDOWN")),

    ("clk50", 0, Pins("H17"), IOStandard("LVTTL")),

    ("serial", 0,
        Subsignal("tx", Pins("A10")),
        Subsignal("rx", Pins("A11"), Misc("PULLUP")),
        Subsignal("cts", Pins("C10"), Misc("PULLUP")),
        Subsignal("rts", Pins("A9"), Misc("PULLUP")),
        IOStandard("LVTTL"),
    ),

    ("usb_fifo", 0,
        Subsignal("data", Pins("A11 A10 C10 A9 B9 A8 B8 A7")),
        Subsignal("rxf_n", Pins("C7")),
        Subsignal("txe_n", Pins("A6")),
        Subsignal("rd_n", Pins("B6")),
        Subsignal("wr_n", Pins("A5")),
        Subsignal("siwua", Pins("C5")),
        IOStandard("LVTTL"),
    ),

    ("hdmi", 0,
        Subsignal("clk_p", Pins("U5"), IOStandard("TMDS_33")),
        Subsignal("clk_n", Pins("V5"), IOStandard("TMDS_33")),
        Subsignal("data0_p", Pins("T6"), IOStandard("TMDS_33")),
        Subsignal("data0_n", Pins("V6"), IOStandard("TMDS_33")),
        Subsignal("data1_p", Pins("U7"), IOStandard("TMDS_33")),
        Subsignal("data1_n", Pins("V7"), IOStandard("TMDS_33")),
        Subsignal("data2_p", Pins("U8"), IOStandard("TMDS_33")),
        Subsignal("data2_n", Pins("V8"), IOStandard("TMDS_33")),
        Subsignal("scl", Pins("V9"), IOStandard("I2C")),
        Subsignal("sda", Pins("T9"), IOStandard("I2C")),
        Subsignal("hpd_notif", Pins("R8"), IOStandard("LVTTL")),
    ),

    ("spiflash", 0,
        Subsignal("cs_n", Pins("V3")),
        Subsignal("clk", Pins("R15")),
        Subsignal("mosi", Pins("T13")),
        Subsignal("miso", Pins("R13"), Misc("PULLUP")),
        Subsignal("wp", Pins("T14")),
        Subsignal("hold", Pins("V14")),
        IOStandard("LVTTL"), Misc("SLEW=FAST")
    ),

    ("spiflash2x", 0,
        Subsignal("cs_n", Pins("V3")),
        Subsignal("clk", Pins("R15")),
        Subsignal("dq", Pins("T13 R13"), Misc("PULLUP")),
        Subsignal("wp", Pins("T14")),
        Subsignal("hold", Pins("V14")),
        IOStandard("LVTTL"), Misc("SLEW=FAST")
    ),

    ("spiflash4x", 0,
        Subsignal("cs_n", Pins("V3")),
        Subsignal("clk", Pins("R15")),
        Subsignal("dq", Pins("T13 R13 T14 V14"), Misc("PULLUP")),
        IOStandard("LVTTL"), Misc("SLEW=FAST")
    ),

    ("mmc", 0,
        Subsignal("clk", Pins("A3")),
        Subsignal("cmd", Pins("B3"), Misc("PULLUP")),
        Subsignal("dat", Pins("B4 A4 B2 A2"), Misc("PULLUP")),
        IOStandard("SDIO")
    ),

    ("mmc_spi", 0,
        Subsignal("cs_n", Pins("A2"), Misc("PULLUP")),
        Subsignal("clk", Pins("A3")),
        Subsignal("mosi", Pins("B3")),
        Subsignal("miso", Pins("B4"), Misc("PULLUP")),
        IOStandard("SDIO")
    ),

    ("audio", 0,
        Subsignal("l", Pins("R7"), Misc("SLEW=SLOW")),
        Subsignal("r", Pins("T7"), Misc("SLEW=SLOW")),
        IOStandard("LVTTL"),
    ),

    ("pmod", 0,
        Subsignal("d", Pins("D9 C8 D6 C4 B11 C9 D8 C6")),
        IOStandard("LVTTL")
    ),

    ("ddram_clock", 0,
        Subsignal("p", Pins("G3")),
        Subsignal("n", Pins("G1")),
        IOStandard("MOBILE_DDR")
    ),

    ("ddram", 0,
        Subsignal("a", Pins("J7 J6 H5 L7 F3 H4 H3 H6 D2 D1 F4 D3 G6")),
        Subsignal("ba", Pins("F2 F1")),
        Subsignal("cke", Pins("H7")),
        Subsignal("ras_n", Pins("L5")),
        Subsignal("cas_n", Pins("K5")),
        Subsignal("we_n", Pins("E3")),
        Subsignal("dq", Pins("L2 L1 K2 K1 H2 H1 J3 J1 M3 M1 N2 N1 T2 T1 U2 U1")),
        Subsignal("dqs", Pins("L4 P2")),
        Subsignal("dm", Pins("K3 K4")),
        IOStandard("MOBILE_DDR")
    )
]

_connectors = [
    ("A", "U18 T17 P17 P16 N16 N17 M16 L15 L17 K15 K17 J16 H15 H18 F18 D18"),
    ("B", "C18 E18 G18 H16 J18 K18 K16 L18 L16 M18 N18 N15 P15 P18 T18 U17"),
    ("C", "F17 F16 E16 G16 F15 G14 F14 H14 H13 J13 G13 H12 K14 K13 K12 L12"),
]


_hdmi_infos = {
    "HDMI_OUT0_MNEMONIC": "J4",
    "HDMI_OUT0_DESCRIPTION" : (
      "  Type A connector, marked as J4.\\r\\n"
    )
}


class Platform(XilinxPlatform):
    name = "pipistrello"
    identifier = 0x5049
    default_clk_name = "clk50"
    default_clk_period = 20
    hdmi_infos = _hdmi_infos

    # Micron N25Q128 (ID 0x0018ba20)
    # FIXME: Create a "spi flash module" object in the same way we have SDRAM
    # module objects.
    spiflash_model = "n25q128"
    spiflash_read_dummy_bits = 10
    spiflash_clock_div = 4
    spiflash_total_size = int((128/8)*1024*1024) # 128Mbit
    spiflash_page_size = 256
    spiflash_sector_size = 0x10000

    # The Pipistrello has a XC6SLX45 which bitstream takes up ~12Mbit (1484472 bytes)
    # 0x200000 offset (16Mbit) gives plenty of space
    gateware_size = 0x200000

    def __init__(self, programmer="openocd"):
        XilinxPlatform.__init__(self, "xc6slx45-csg324-3", _io, _connectors)
        self.toolchain.bitgen_opt += " -g Compress -g ConfigRate:6"
        self.programmer = programmer

    def create_programmer(self):
        proxy="bscan_spi_{}.bit".format(self.device.split('-')[0])
        if self.programmer == "openocd":
            return OpenOCD(config="board/pipistrello.cfg", flash_proxy_basename=proxy)
	# Alternative programmers - not regularly tested.
        elif self.programmer == "xc3sprog":
            return XC3SProg("papilio", "bscan_spi_lx45_csg324.bit")
        else:
            raise ValueError("{} programmer is not supported".format(self.programmer))
