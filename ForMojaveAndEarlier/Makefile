# Makefile for KimoUserDataDumper (Pure Objective-C Version)
# Compatible with macOS Mojave and earlier systems

CC = clang
# Use manual memory management for better compatibility with older systems
CFLAGS = -Wall -Wextra -framework Foundation -framework AppKit
TARGET = KimoUserDataDumper
SOURCE = KimoUserDataDumper.m

# Check if we're on macOS
UNAME_S := $(shell uname -s)

# Default target
all: 
ifeq ($(UNAME_S), Darwin)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)
else
	@echo "Warning: This can only be built on macOS systems with Foundation and AppKit frameworks."
	@echo "Please build on a macOS system to create the executable."
	@echo "The source code is ready for compilation on macOS."
endif

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	cp $(TARGET) /usr/local/bin/

.PHONY: all clean install

# Usage instructions
help:
	@echo "KimoUserDataDumper Pure Objective-C Version"
	@echo ""
	@echo "Build commands:"
	@echo "  make           - Build the executable"
	@echo "  make clean     - Remove built files"  
	@echo "  make install   - Install to /usr/local/bin"
	@echo "  make help      - Show this help"
	@echo ""
	@echo "System Requirements:"
	@echo "  - macOS with Xcode Command Line Tools"
	@echo "  - Yahoo KeyKey IME installed and running"
	@echo ""
	@echo "Usage examples:"
	@echo "  ./KimoUserDataDumper"
	@echo "  ./KimoUserDataDumper -f json -o phrases.json"
	@echo "  ./KimoUserDataDumper --builtin-export -o data.txt"