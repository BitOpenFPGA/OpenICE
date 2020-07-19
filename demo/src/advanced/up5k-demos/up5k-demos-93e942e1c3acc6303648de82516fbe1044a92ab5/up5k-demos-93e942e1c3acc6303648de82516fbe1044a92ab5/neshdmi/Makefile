PROJ = nes

TOP = NES_ice40
PIN_DEF = up5k.pcf
DEVICE = up5k
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
