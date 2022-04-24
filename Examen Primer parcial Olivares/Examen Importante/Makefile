# MPLAB IDE generated this makefile for use with GNU make.
# Project: Examen primer parcial de micro.mcp
# Date: Wed Mar 24 11:39:17 2021

AS = MPASMWIN.exe
CC = mcc18.exe
LD = mplink.exe
AR = mplib.exe
RM = rm

Examen\ de\ micros\ primer\ parcial.cof : Examen\ de\ micros\ primer\ parcial.o
	$(LD) /p16F877A "Examen de micros primer parcial.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"Examen de micros primer parcial.cof" /M"Examen de micros primer parcial.map" /W /x

Examen\ de\ micros\ primer\ parcial.o : Examen\ de\ micros\ primer\ parcial.asm ../../../../../Program\ files\ (x86)/Microchip/Mpasm\ Suite/p16f877a.inc
	$(AS) /q /p16F877A "Examen de micros primer parcial.asm" /l"Examen de micros primer parcial.lst" /e"Examen de micros primer parcial.err" /d__DEBUG=1 /c-

clean : 
	$(RM) "Examen de micros primer parcial.o" "Examen de micros primer parcial.hex" "Examen de micros primer parcial.err" "Examen de micros primer parcial.lst" "Examen de micros primer parcial.cof"

