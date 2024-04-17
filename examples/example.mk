BINARY_NAME=$(notdir $(shell pwd))

PROJECT_ROOT?=$(abspath ../..)
INCLUDE_DIRS=$(PROJECT_ROOT)/interface
OBJECT_DIR=$(abspath obj)
SOURCE_DIR=$(abspath .)
LIBRARY_DIR?=$(PROJECT_ROOT)/lib
BINARY_DIR?=$(PROJECT_ROOT)/bin

SOURCE_FILES=$(wildcard $(SOURCE_DIR)/*.cpp)
OBJECT_FILES=$(SOURCE_FILES:$(SOURCE_DIR)/%.cpp=$(OBJECT_DIR)/%.o)

TRIPLET?=arm-linux-gnueabihf
CXX:=$(TRIPLET)-$(CXX)
CC:=$(TRIPLET)-$(CC)
LD:=$(TRIPLET)-$(LD)
CXXFLAGS+=$(INCLUDE_DIRS:%=-I%) -Wall -Werror -std=gnu++11 -O1 -fPIC
LDFLAGS+=-L$(LIBRARY_DIR)
LDLIBS+=-llora -lwiringPi

.PHONY: default all clean

default: all

all: $(BINARY_DIR)/$(BINARY_NAME)

clean:
	$(RM) $(OBJECT_FILES) $(BINARY_DIR)/$(BINARY_NAME)

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $^ -o $@

$(BINARY_DIR)/$(BINARY_NAME): $(OBJECT_FILES)
	mkdir -p $(@D)
	$(CXX) $^ $(LDFLAGS) $(LDLIBS) -o $@
