# galatea targets

ifneq ($(PLATFORM),galatea)
	$(error "Platform should be galatea when using this file!?")
endif

# Settings
DEFAULT_TARGET = base
TARGET ?= $(DEFAULT_TARGET)

# Image
image-flash-$(PLATFORM): image-flash-py
	@true

# Gateware
gateware-load-$(PLATFORM):
	@echo "Unsupported."
	@false

gateware-flash-$(PLATFORM): gateware-flash-py
	@true

# Firmware
firmware-load-$(PLATFORM):
	@echo "Unsupported."
	@false

firmware-flash-$(PLATFORM): firmwage-flash-py
	@true

firmware-connect-$(PLATFORM):
	flterm --port=$(COMM_PORT) --speed=$(BAUD)

firmware-clear-$(PLATFORM):
	@echo "FIXME: Unsupported?."
	@false

# Bios
bios-flash-$(PLATFORM):
	@echo "Unsupported."
	@false

# Extra commands
help-$(PLATFORM):
	@true

reset-$(PLATFORM):
	@echo "Unsupported."
	@false
