# Project Info
USER=warc
LIB=cores
CORE=fan_control
TARGET=ultra96_v1
FLAGS=linux

GIT_VER=$(shell git describe --tags --abbrev=0)

.PHONY: all build flash clean

all:
	fusesoc run --tool=vivado --target=$(TARGET) --flag=$(FLAGS) $(USER):$(LIB):$(CORE):$(GIT_VER) 

build:
	fusesoc run --build --tool=vivado --target=$(TARGET) --flag=$(FLAGS) $(USER):$(LIB):$(CORE):$(GIT_VER)

flash:
	fusesoc run --run --tool=vivado --target=$(TARGET) --flag=$(FLAGS) $(USER):$(LIB):$(CORE):$(GIT_VER)

clean:
	rm -rf build
	-rm -f *.jou *.log