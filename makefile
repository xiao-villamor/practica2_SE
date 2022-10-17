PREFIX=arm-none-eabi-

ARCHFLAGS=-mthumb -mcpu=cortex-m0plus 
COMMONFLAGS=-g3 -Og -Wall -Werror $(ARCHFLAGS)


CFLAGS=-I./includes/ -I./pin_mux_b -DCPU_MKL46Z256VLH4 $(COMMONFLAGS) 

CFLAGSXX=-I./includes/ -I./pin_mux_h -DCPU_MKL46Z256VLH4 $(COMMONFLAGS) 

LDFLAGS=$(COMMONFLAGS) -T link.ld  --specs=nano.specs  -Wl,--gc-sections,-Map,$(TARGET).map
LDLIBS= 

CC=$(PREFIX)gcc
CCXX=$(PREFIX)gcc
LD=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
SIZE=$(PREFIX)size
RM=rm -f

TARGET=led_blink

TARGET2=hello_world


SRC=$(wildcard led_blinky.c startup.c pin_mux_b.c drivers/*.c)

SRC2=$(wildcard hello_world.c startup.c pin_mux_h.c drivers/*.c)

OBJ=$(patsubst %.c, %.o, $(SRC))

OBJ2=$(patsubst %.c, %.o, $(SRC2))

all2 : hello build_h size_h
build_h : elf_h srec_h bin_h

elf_h: $(TARGET2).elf
srec_h: $(TARGET2).srec
bin_h: $(TARGET2).bin


all: led build size
build: elf srec bin

elf: $(TARGET).elf
srec: $(TARGET).srec
bin: $(TARGET).bin

led : $(OBJ)
	$(CC)  $(CFLAGS) -c $<

hello : $(OBJ2)
	$(CC)  $(CFLAGSXX) -c $<

clean_led:
	$(RM) $(TARGET).srec $(TARGET).elf $(TARGET).bin $(TARGET).map $(OBJ)

clean_hello:
	$(RM) $(TARGET2).srec $(TARGET2).elf $(TARGET2).bin $(TARGET2).map $(OBJ2)


$(TARGET).elf: $(OBJ) 
	$(LD) $(LDFLAGS)  $(OBJ) $(LDLIBS) -o $@

$(TARGET2).elf: $(OBJ2) 
	$(LD) $(LDFLAGS)  $(OBJ2) $(LDLIBS) -o $@

%.srec: %.elf
	$(OBJCOPY) -O srec $< $@

%.bin: %.elf
	    $(OBJCOPY) -O binary $< $@

size:
	$(SIZE) $(TARGET).elf

size_h:
	$(SIZE) $(TARGET2).elf

flash_hello : all2
	openocd -f openocd.cfg -c "program $(TARGET2).elf verify reset exit"

flash_led : all
	openocd -f openocd.cfg -c "program $(TARGET).elf verify reset exit"
