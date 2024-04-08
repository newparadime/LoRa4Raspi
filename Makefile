LIBRARY_NAME=lora

PROJECT_ROOT:=$(shell pwd)

INTERFACE_DIR:=$(realpath interface)
OBJECT_DIR:=$(realpath obj)
SOURCE_DIR:=$(realpath src)
LIBRARY_DIR:=$(realpath lib)
EXAMPLE_DIR:=$(realpath examples)

SOURCE_FILES:=$(wildcard $(SOURCE_DIR)/*.cpp)
INTERFACE_FILES:=$(wildcard $(INTERFACE_DIR)/*.h*)
OBJECT_FILES=$(SOURCE_FILES:$(SOURCE_DIR)/%.cpp=$(OBJECT_DIR)/%.o)
EXAMPLES=$(wildcard $(EXAMPLE_DIR)/*/.)
CLEAN_EXAMPLES=$(EXAMPLES:%=%!clean)

TRIPLET?=arm-linux-gnueabihf
CXX:=$(TRIPLET)-$(CXX)
CC:=$(TRIPLET)-$(CC)
AR:=$(TRIPLET)-$(AR)
LD:=$(TRIPLET)-$(LD)
CXXFLAGS+=-I$(INTERFACE_DIR) -Wall -Werror -std=gnu++11 -O1 -fPIC
LDFLAGS+=-shared
LDLIBS=-lwiringPi

PREFIX?=/usr/local/$(TRIPLET)
DESTDIR?=
LIBRARY_INSTALL_DIR=$(DESTDIR)/$(PREFIX)/lib
INTERFACE_INSTALL_DIR=$(DESTDIR)/$(PREFIX)/include

.PHONY: default lib examples all clean $(EXAMPLES) $(CLEAN_EXAMPLES)

default: lib

all: lib examples

lib: $(LIBRARY_DIR)/lib$(LIBRARY_NAME).a $(LIBRARY_DIR)/lib$(LIBRARY_NAME).so

examples: $(EXAMPLES)

clean: $(CLEAN_EXAMPLES)
	$(RM) $(OBJECT_FILES) $(LIBRARY_DIR)/lib$(LIBRARY_NAME).a $(LIBRARY_DIR)/lib$(LIBRARY_NAME).so

install: install_libs install_headers

install_headers: $(INTERFACE_FILES)
	mkdir -p $(INTERFACE_INSTALL_DIR)
	cp $^ $(INTERFACE_INSTALL_DIR)

install_libs: $(LIBRARY_DIR)/lib$(LIBRARY_NAME).a $(LIBRARY_DIR)/lib$(LIBRARY_NAME).so
	mkdir -p $(LIBRARY_INSTALL_DIR)
	cp $^ $(LIBRARY_INSTALL_DIR)

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $^ -o $@

$(LIBRARY_DIR)/lib$(LIBRARY_NAME).a: $(OBJECT_FILES)
	mkdir -p $(@D)
	$(AR) r $@ $?

$(LIBRARY_DIR)/lib$(LIBRARY_NAME).so: $(OBJECT_FILES)
	mkdir -p $(@D)
	$(CXX) $(LDFLAGS) $^ -o $@

$(EXAMPLES): $(LIBRARY_DIR)/lib$(LIBRARY_NAME).so
	$(MAKE) -C $@ PROJECT_ROOT=$(PROJECT_ROOT)

$(CLEAN_EXAMPLES): 
	$(MAKE) -C $(@:%!clean=%) clean