PROJECT_NAME := gatool
BLUEZ_PATH = ../pkg/bluez-5.30
PRJ_PATH = .
OBJECT_DIRECTORY = _build
OUTPUT_BINARY_DIRECTORY = .
OUTPUT_FILENAME := $(PROJECT_NAME)

export OUTPUT_FILENAME
MAKEFILE_NAME := $(MAKEFILE_LIST)
MAKEFILE_DIR := $(dir $(MAKEFILE_NAME) )

#GNU_PREFIX := arm-none-eabi-

MK := mkdir
RM := rm -rf

#echo suspend
ifeq ("$(VERBOSE)","1")
NO_ECHO :=
else
NO_ECHO := @
endif

# Toolchain commands
CC       		:= "$(GNU_PREFIX)gcc"
AS       		:= "$(GNU_PREFIX)as"
AR       		:= "$(GNU_PREFIX)ar" -r
LD       		:= "$(GNU_PREFIX)ld"
NM       		:= "$(GNU_PREFIX)nm"
OBJDUMP  		:= "$(GNU_PREFIX)objdump"
OBJCOPY  		:= "$(GNU_PREFIX)objcopy"
SIZE    		:= "$(GNU_PREFIX)size"

#function for removing duplicates in a list
remduplicates = $(strip $(if $1,$(firstword $1) $(call remduplicates,$(filter-out $(firstword $1),$1))))

#sources project
C_SOURCE_FILES += $(PRJ_PATH)/gatttool.c
C_SOURCE_FILES += $(PRJ_PATH)/att.c
C_SOURCE_FILES += $(PRJ_PATH)/gatt.c
C_SOURCE_FILES += $(PRJ_PATH)/gattrib.c
C_SOURCE_FILES += $(PRJ_PATH)/interactive.c
C_SOURCE_FILES += $(PRJ_PATH)/utils.c

C_SOURCE_FILES += $(BLUEZ_PATH)/btio/btio.c
C_SOURCE_FILES += $(BLUEZ_PATH)/src/log.c
C_SOURCE_FILES += $(BLUEZ_PATH)/client/display.c

#assembly files common to all targets
#ASM_SOURCE_FILES  = $(SDK_PATH)/some.s

#includes common to all targets
INC_PATHS += -I$(BLUEZ_PATH)

#includes project
#INC_PATHS += -I$(PRJ_PATH)/config

LISTING_DIRECTORY = $(OBJECT_DIRECTORY)

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )

#flags common to all targets
#CFLAGS += -mcpu=cortex-m0
#CFLAGS += -mthumb -mabi=aapcs --std=gnu99
CFLAGS += -Wall
#CFLAGS += -Werror
#CFLAGS += -mfloat-abi=soft
# keep every function in separate section. This will allow linker to dump unused functions
#CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
#CFLAGS += -flto -fno-builtin
CFLAGS += -DVERSION="\"1.0\""
CFLAGS += `pkg-config --cflags glib-2.0`


# keep every function in separate section. This will allow linker to dump unused functions
#LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
#LDFLAGS += -mcpu=cortex-m0

# let linker to dump unused sections
#LDFLAGS += -Wl,--gc-sections

# use newlib in nano version
#LDFLAGS += --specs=nano.specs -lc -lnosys


# Assembler flags
#ASMFLAGS += -x assembler-with-cpp

#Link Library
LIBS += $(BLUEZ_PATH)/lib/.libs/libbluetooth-internal.a
LIBS += $(BLUEZ_PATH)/src/.libs/libshared-glib.a
LIBS += -lreadline
LIBS += `pkg-config --libs glib-2.0`


#default target - first one defined
default: release

#building all targets
all:
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e cleanobj
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e debug

#target for printing all targets
help:
	@echo following targets are available:
	@echo 	debug release


C_SOURCE_FILE_NAMES = $(notdir $(C_SOURCE_FILES))
C_PATHS = $(call remduplicates, $(dir $(C_SOURCE_FILES) ) )
C_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(C_SOURCE_FILE_NAMES:.c=.o) )

#ASM_SOURCE_FILE_NAMES = $(notdir $(ASM_SOURCE_FILES))
#ASM_PATHS = $(call remduplicates, $(dir $(ASM_SOURCE_FILES) ))
#ASM_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(ASM_SOURCE_FILE_NAMES:.s=.o) )

vpath %.c $(C_PATHS)
#vpath %.s $(ASM_PATHS)

OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

debug: CFLAGS += -DDEBUG
debug: CFLAGS += -ggdb3 -O0
debug: ASMFLAGS += -DDEBUG -ggdb3 -O0
debug: LDFLAGS += -ggdb3 -O0
debug: $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo [DEBUG]Linking target: $(OUTPUT_FILENAME)
	@echo [DEBUG]CFLAGS=$(CFLAGS)
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME)

release: CFLAGS += -DNDEBUG -O3
release: ASMFLAGS += -DNDEBUG -O3
release: LDFLAGS += -O3
release: $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo [RELEASE]Linking target: $(OUTPUT_FILENAME)
	$(ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME)

## Create build directories
$(BUILD_DIRECTORIES):
	$(MK) $@

# Create objects from C SRC files
$(OBJECT_DIRECTORY)/%.o: %.c
	@echo Compiling C file: $(notdir $<): $(CFLAGS)
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<


# Assemble files
#$(OBJECT_DIRECTORY)/%.o: %.s
#	@echo Compiling ASM file: $(notdir $<)
#	$(NO_ECHO)$(CC) $(ASMFLAGS) $(INC_PATHS) -c -o $@ $<


# Link
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME): $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: $(OUTPUT_FILENAME)
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME)

clean:
	$(RM) $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME)

