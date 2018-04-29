baud=57600
src=src/main
build=build
asset=project
avrType=atmega328p
avrFreq=16000000 # 4MHz for accurate baudrate timing
programmerDev=/dev/ttyUSB0
programmerType=arduino

cflags=-std=c99 -g -DF_CPU=$(avrFreq) -Wall -Os -Werror -Wextra

memoryTypes=calibration eeprom efuse flash fuse hfuse lfuse lock signature application apptable boot prodsig usersig

.PHONY: backup clean disassemble dumpelf eeprom elf flash help hex makefile object program

help:
	@echo 'backup       Read all known memory types from controller and write it into a file. Available memory types: $(memoryTypes)'
	@echo 'clean        Delete automatically created files.'
	@echo 'disassemble  Compile source code, then disassemble object file to mnemonics.'
	@echo 'dumpelf      Dump the contents of the .elf file. Useful for information purposes only.'
	@echo 'eeprom       Extract EEPROM data from .elf file and program the device with it.'
	@echo 'elf          Create $(build)/$(asset).elf'
	@echo 'flash        Program $(build)/$(asset).hex to controller flash memory.'
	@echo 'help         Show this text.'
	@echo 'hex          Create all hex files for flash, eeprom.'
	@echo 'object       Create $(build)/$(asset).o'
	@echo 'program      Do all programming to controller.'

#all: object elf hex

clean:
	rm -f $(build)/$(asset).elf $(build)/$(asset).eeprom.hex $(build)/$(asset).flash.hex $(build)/$(asset).o $(build)/$(asset).lst
	rm -df $(build)
	@date

$(build):
	mkdir $(build)

object: $(build)
	avr-gcc $(cflags) -mmcu=$(avrType) -Wa,-ahlmns=$(build)/$(asset).lst -c -o $(build)/$(asset).o $(src).c

elf: object
	avr-gcc $(cflags) -mmcu=$(avrType) -o $(build)/$(asset).elf $(build)/$(asset).o
	chmod a-x $(build)/$(asset).elf 2>&1

hex: elf
	avr-objcopy -j .text -j .data -O ihex $(build)/$(asset).elf $(build)/$(asset).flash.hex
	avr-objcopy -j .eeprom --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 -O ihex $(build)/$(asset).elf $(build)/$(asset).eeprom.hex

disassemble: elf
	avr-objdump -s -j .fuse $(build)/$(asset).elf
	avr-objdump -C -d $(build)/$(asset).elf 2>&1

eeprom: hex
	#avrdude -p$(avrType) -c$(programmerType) -P$(programmerDev) -b$(baud) -v -U eeprom:w:$(build)/$(asset).eeprom.hex
	@date

dumpelf: elf
	avr-objdump -s -h $(build)/$(asset).elf

program: flash eeprom

flash: hex
	avrdude -p$(avrType) -c$(programmerType) -P$(programmerDev) -b$(baud) -v -U flash:w:$(build)/$(asset).flash.hex
	@date

backup:
	@for memory in $(memoryTypes); do \
		avrdude -p $(avrType) -c$(programmerType) -P$(programmerDev) -b$(baud) -v -U $$memory:r:./$(avrType).$$memory.hex:i; \
	done
