# MPLAB IDE generated this makefile for use with GNU make.
# Project: Machote.mcp
# Date: Wed Mar 10 23:29:47 2021

AS = MPASMWIN.exe
CC = mcc18.exe
LD = mplink.exe
AR = mplib.exe
RM = rm

Machote.cof : Machote.o
	$(LD) /p16F877A "Machote.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"Machote.cof" /M"Machote.map" /W /x

Machote.o : Machote.asm ../../../../../../Program\ files\ (x86)/Microchip/Mpasm\ Suite/p16f877a.inc
	$(AS) /q /p16F877A "Machote.asm" /l"Machote.lst" /e"Machote.err" /d__DEBUG=1 /c-

clean : 
	$(RM) "Machote.o" "Machote.hex" "Machote.err" "Machote.lst" "Machote.cof"

