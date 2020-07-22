PROJ = nes

TOP = NES_ice40
PIN_DEF = blackicemx.pcf
DEVICE = hx8k
PACKAGE = tq144:4k
ADD_SRC = $(wildcard *.v)
FREQ = 8
#USE_ARACHNEPNR = Y

include main.mk

GAMES = $(sort $(wildcard rom/game*.nes))
IMAGES = $(GAMES:.nes=.bin)

rom/games.bin: $(IMAGES)
	cat $^ > $@

up5kprog_game: rom/games.bin
	iceprog -o 1024k rom/games.bin
