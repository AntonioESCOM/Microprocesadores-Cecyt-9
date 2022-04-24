;INSTITUTO POLITECNICO NACIONAL
;CECYT 9 JUAN DE DIOS BATIZ
;
;PRACTICA 1 MANEJO DE UNA PANTALLA LCD (RELOJ DE TIEMPO REAL).
;
;GRUPO:6IM2
;
;INTEGRANTE
;Morales Martínez José Antonio
;
;El programa ejecutara un reloj en tiempo real mediante interrupciones y se vizualizara en un 
;LCD
;----------------------------------------------------------------------------------------------------

list p=16F877A; // Directiva utilizada para definir el microcontrolador a utilizar


#include "c:\program files (x86)\microchip\mpasm suite\p16f877a.inc"; 


;Bits de configuracion
__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _BODEN_OFF & _LVP_OFF & _CP_OFF; ALL

;------------------------------------------------------------------------------------------------------
;fosc = 4 Mhz.
;Ciclo de trabajo del PIC = (1/fosc)*4 = 1us.
;t int =(256-R)*(P)*((1/4000000)*4) = 1 ms ;// Tiempo de interrupción.
;R=131, p=8.
;frec int = 1/ t int = 1Khz.
;------------------------------------------------------------------------------------------------------
;
;Registros de proposito general Banco 0 de Memoria RAM.
;
;Registros propios de estructura del programa


cta_uniseg		equ			0x23;	//Dirección de la memoria RAM para el registro de las unidades de segundo
cta_decseg		equ			0x24;	//Dirección de la memoria RAM para el registro de las decenas de segundo
cta_unimin		equ			0x25;	//Dirección de la memoria RAM para el registro de las unidades de minuto
cta_decmin  	equ			0x26;	//Dirección de la memoria RAM para el registro de las decenas de minuto
cta_unihor		equ			0x27;	//Dirección de la memoria RAM para el registro de las unidades de minuto
cta_dechor  	equ			0x28;	//Dirección de la memoria RAM para el registro de las decenas de minuto
res_w		    equ 		0x29;	
res_status		equ			0x30;
res_pclath		equ			0x31;
res_fsr			equ			0x32;
presc_1			equ			0x33;
presc_2			equ			0x34;
banderas		equ			0x35;	
cont_milis		equ			0x36;

buffer7	    	equ			0x37;	//Dirección de la memoria RAM para el buffer 7
buffer6 	    equ			0x38;	//Dirección de la memoria RAM para el buffer 6
buffer5		    equ			0x39;	//Dirección de la memoria RAM para el buffer 5
buffer4 		equ			0x40;	//Dirección de la memoria RAM para el buffer 4
buffer3			equ			0x41;	//Dirección de la memoria RAM para el buffer 3
buffer2 		equ			0x42;	//Dirección de la memoria RAM para el buffer 2
buffer1  		equ			0x43;	//Dirección de la memoria RAM para el buffer 1
buffer0  		equ			0x44;	//Dirección de la memoria RAM para el buffer 0
;-----------------------------------------------------------------------------------------------------
;
;Constantes
M				equ		   .0;
N				equ		   .3;
L				equ		   .220;
Barrido         equ        .31;
;Constantes de caracteres en siete segmentos.
Car_A			EQU b'01110111'; Caracter A en siete segmentos.
Car_b			EQU b'01111100'; Caracter b en siete segmentos.
Car_C			EQU b'00111001'; Caracter C en siete segmentos.
Car_cc			EQU b'01011000'; Caracter c en siete segmentos.
Car_d			EQU b'01011110'; Caracter D en siete segmentos.
Car_E			EQU b'01111001'; Caracter E en siete segmentos.
Car_F			EQU b'01110001'; Caracter F en siete segmentos.
Car_G			EQU b'00111101'; Caracter G en siete segmentos.
Car_gg			EQU b'01101111'; Caracter g en siete segmentos.
Car_H			EQU b'01110110'; Caracter H en siete segmentos.
Car_hh			EQU b'01110100'; Caracter h en siete segmentos.
Car_I			EQU b'00000110'; Caracter I en siete segmentos.
Car_ii			EQU b'00000100'; Caracter i en siete segmentos.
Car_L			EQU b'00111000'; Caracter L en siete segmentos.
Car_J			EQU b'00011111'; Caracter J en siete segmentos.
Car_N			EQU b'00110111'; Caracter N en siete segmentos.
Car_M			EQU b'00101011'; Caracter M en siete segmentos.
Car_O			EQU b'00111111'; Caracter O en siete segmentos.
Car_oo			EQU b'01011100'; Caracter o en siete segmentos.
Car_P			EQU b'01110011'; Caracter P en siete segmentos.
Car_q			EQU b'01100111'; Caracter q en siete segmentos.
Car_R			EQU b'01010000'; Caracter R en siete segmentos.
Car_S			EQU b'01101101'; Caracter S en siete segmentos.
Car_t			EQU b'01111000'; Caracter t en siete segmentos.
Car_U			EQU b'00111110'; Caracter U en siete segmentos.
Car_uu			EQU b'00000110'; Caracter u en siete segmentos.
Car_y			EQU b'01101110'; Caracter y en siete segmentos.
Car_Z			EQU b'01011011'; Caracter Z en siete segmentos.
Car_0			EQU b'00111111'; Caracter 0 en siete segmentos.
Car_1			EQU b'00000110'; Caracter 1 en siete segmentos.
Car_2			EQU b'01011011'; Caracter 2 en siete segmentos.
Car_3			EQU b'01001111'; Caracter 3 en siete segmentos.
Car_4			EQU b'01100110'; Caracter 4 en siete segmentos.
Car_5			EQU b'01101101'; Caracter 5 en siete segmentos.
Car_6			EQU b'01111101'; Caracter 6 en siete segmentos.
Car_7			EQU b'00000111'; Caracter 7 en siete segmentos.
Car_8			EQU b'01111111'; Caracter 8 en siete segmentos.
Car_9			EQU b'01100111'; Caracter 0 en siete segmentos.
Car_			EQU	b'00001000'; Caracter _ en siete segmentos.
Car_guion			EQU	b'01000000'; Caracter - en siete segmentos.
Car_null		EQU b'00000000'; Caracter nulo en siete segementos. 

; banderas del registro banderas.
ban_int                 equ     .0;
sin_bd1                 equ     .1; 
sin_bd2                 equ     .2; 
sin_bd3                 equ     .3; 
sin_bd4                 equ     .4; 
sin_bd5                 equ     .5; 
sin_bd6                 equ     .6; 
sin_bd7                 equ     .7; ;Asignacion de los bits del registro bandera

;-------------------------------------------------------------------------------------
;
;Asignacion de los bits de los puertos de I/O.
;Puerto A.
RS_LCD			equ			.0; // 
Enable_LCD		equ			.1; // 
Sin_UsoRA2		equ			.2; // Sin Uso RA2.
Sin_UsoRA3		equ			.3; // Sin Uso RA3.
Sin_UsoRA4		equ			.4; // Sin Uso RA4.
Sin_UsoRA5		equ			.5; // Sin Uso RA5.

proga			equ	b'111100'; // Programacion Inicial del Puerto A.

;Puerto B.
Sin_UsoRB0		equ 		.0; // Sin Uso RB0.
Sin_UsoRB1		equ 		.1; // Sin Uso RB1.
Sin_UsoRB2		equ 		.2; // Sin Uso RB2.
Sin_UsoRB3		equ 		.3; // Sin Uso RB3.
Sin_UsoRB4		equ 		.4; // Sin Uso RB4.
Sin_UsoRB5		equ 		.5; // Sin Uso RB5.
Sin_UsoRB6		equ 		.6; // Sin Uso RB6.
Sin_UsoRB7   	equ 		.7; // Sin Uso RB7.

progb			equ	b'11111111'; // Programacion Inicial del Puerto B.

;Puerto C.
D0_LCD			equ			.0; // Bit D0 del bus de datos de la LCD.
D1_LCD			equ			.1; // Bit D1 del bus de datos de la LCD.
D2_LCD			equ			.2; // Bit D2 del bus de datos de la LCD.
D3_LCD			equ			.3; // Bit D3 del bus de datos de la LCD.
D4_LCD			equ			.4; // Bit D4 del bus de datos de la LCD.
D5_LCD			equ			.5; // Bit D5 del bus de datos de la LCD.
D6_LCD			equ			.6; // Bit D6 del bus de datos de la LCD.
D7_LCD			equ			.7; // Bit D7 del bus de datos de la LCD.

progc			equ	b'00000000'; // Programacion Inicial del Puerto C como Entrada.

;Puerto D.
Sin_UsoRD0		equ			.0; // Sin Uso RD0.
Sin_UsoRD1		equ			.1; // Sin Uso RD1.
Sin_UsoRD2		equ			.2; // Sin Uso RD2.
Sin_UsoRD3		equ			.3; // Sin Uso RD3.
Sin_UsoRD4		equ			.4; // Sin Uso RD4.
Sin_UsoRD5		equ			.5; // Sin Uso RD5.
Sin_UsoRD6		equ			.6; // Sin Uso RD6.
Sin_UsoRD7		equ			.7; // Sin Uso RD7.

progd			equ	b'11111111'; // Programacion Inicial del Puerto D como entradas.

;Puerto E.
Sin_UsoRE0		equ			.0; // Sin Uso RE0.
Sin_UsoRE1		equ			.1; // Sin Uso RE1.
Sin_UsoRE2		equ			.2; // Sin Uso RE2.

proge			equ	b'111'; // Programacion inicial del Puerto E.
;---------------------------------------------------------------------------------------------------------
				;================
				;==Vector Reset==
				;================
				org 0x0000;				// dirección de inicio de la memoria donde el IDE comenzara a ensamblar
vec_reset		clrf PCLATH;			// Limpia el registro PCLATH
				goto prog_prin;			// ve para la etiqueta prog_ini
;---------------------------------------------------------------------------------------------------------
                        ;=============================
                        ;== Subrutina de Interrupciones  ==
                        ;=============================
                 org 0004h;   
vec_int          movwf res_w;		//resp.esl estado del reg. w. 
                 movf status,w;
               	 movwf res_status;	 //resp. banderas de la alu.
                 clrf status;
                 movf pclath,w;
                 movwf res_pclath;
                 clrf pclath;
                 movf fsr,w;
                 movwf res_fsr; 
                         
                 btfsc intcon,t0if;
                 call rutina_int;
                        
sal_int          movlw .131;
                 movwf tmr0;
                 movf res_fsr,w;
                 movwf fsr;
                 movf res_pclath,w;
                 movwf pclath;
                 movf res_status,w;
               	 movwf status;
                 movf res_w,w;
                        
                 retfie;
;--------------------------------------------------------------------------------------------------


                        ;=============================
                        ;== Subrutina de Interrupciones  ==
                        ;=============================
rutina_int      incf cont_milis,f;
                incf presc_1,f;
                        
                movlw .100;
                xorwf presc_1,w;
               	btfsc status,z;
                goto sig_int;
                goto sal_rutint;

sig_int         clrf presc_1;
                incf presc_2,f;
                movlw .10;
               	xorwf presc_2,w;
                btfss status,z;
               	goto sal_rutint;
                clrf presc_1;
                clrf presc_2;
                        
sal_rutext      bsf banderas,ban_int;
                                 
sal_rutint      bcf intcon,t0if;
                return;
;---------------------------------------------------------------------------------------------------------	


				;=======================
				;==Subrutina de inicio==
				;=======================
prog_ini		bsf STATUS,RP0; 		//colocate en el bco. 1 de ram
				movlw 0x82;				// Mueve la constante 0X81 al registro w
				movwf OPTION_REG ^0x80;	// Mueve la constante 0X81 al registro OPTION_REG
				movlw proga;			// Mueve el contenido de w a el registro proga
				movwf TRISA ^0x80;		// Mueve la constante 0X80 al registro TRISA
				movlw progb;			// Mueve el contenido de w a el registro progb
				movwf TRISB ^0x80;		// Mueve la constante 0X80 al registro TRISB
				movlw progc;			// Mueve el contenido de w a el registro progc
				movwf TRISC ^0x80;		// Mueve la constante 0X80 al registro TRISC
				movlw progd;			// Mueve el contenido de w a el registro progd
				movwf TRISD ^0x80;		// Mueve la constante 0X80 al registro TRISD
				movlw proge;			// Mueve el contenido de w a el registro proge
				movwf TRISE ^0x80;		// Mueve la constante 0X80 al registro TRISE
				movlw 0x06;				// Mueve la constante 0X06 al registro w
				movwf ADCON1 ^0x80;		// Mueve la constante 0X80 al registro ADCON1
				bcf	STATUS,RP0;			//regresa al bco. 0 de ram

			
                movlw 0xa0;		// Habilita la iterrupcion del TMR0, Las globales y borra las banderas de interrupción 
                movwf intcon;
                movlw .131;
                movwf tmr0;

				clrf portc;
				movlw 0x03;			//Inicializa el pin Enable y RS a 1 logico
				movwf porta;
				
				clrf res_w;
				clrf res_status;
				clrf res_pclath;
				clrf res_fsr; 
				clrf presc_1;
				clrf presc_2;
                clrf banderas;
				clrf cta_uniseg;		// Inicializa la cuenta de unidades de segundo a 0 
				clrf cta_decseg;		// Inicializa la cuenta de decenas de segundo a 0 
				clrf cta_unimin;		// Inicializa la cuenta de unidades de minutos a 0 
				clrf cta_decmin;		// Inicializa la cuenta de decenas de minutos a 0 
				clrf cta_unihor;		// Inicializa la cuenta de unidades de hora a 0
				clrf cta_dechor;		// Inicializa la cuenta de decenas de hora a 0
			  	return;
;----------------------------------------------------------------------------------------------------------

				;======================
				;==Programa Principal==
				;======================
prog_prin		call prog_ini;		//Llamada a la subrutina de inicio 

				call ini_lcd;


			bcf porta,RS_LCD; 	//Pone en modo comando al LCD
			movlw 0x88;
			movwf portc;
			call pulso_enable;
			bsf porta,RS_LCD; 	//Pone en modo datos al LCD
			movlw 0x31;
			movwf portc;
			call pulso_enable;
			

trabate_lucas nop;			
			goto trabate_lucas;



;----------------------------------------------------------------------------------------------------------

	;================================================
	;   ==Subrutina de inicializacion en el LCD ==
	;================================================

ini_lcd 	bcf porta,RS_LCD; 	//Pone en modo comando al LCD
			
			movlw 0x38;
			movwf portc;
			call pulso_enable;
			movlw 0X0C; 
			movwf portc;
			call pulso_enable;
			movlw 0x01;
			movwf portc;
			call pulso_enable;
			movlw 0x0;
			movwf portc;
			call pulso_enable;
			movlw 0x80;
			movwf portc;
			call pulso_enable;
			
			bsf porta,RS_LCD; 	//Pone en modo datos al LCD
			return;

;----------------------------------------------------------------------------------------------------------

				;==============================
				;	==Subrutina Pulso Enable=
				;==============================

pulso_enable	bcf porta,Enable_LCD;
				call retardo_1ms;
				bsf porta,Enable_LCD;
				call retardo_40ms
;----------------------------------------------------------------------------------------------------------


				;==============================
				;==Subrutina de retardo de 1ms=
				;==============================

retardo_1ms 	clrf cont_milis;
loop_1ms		movlw .1;
				subwf cont_milis,w;
				btfss status,Z;
				goto loop_1ms;
			
				return;
;----------------------------------------------------------------------------------------------------------


				;==============================
				;==Subrutina de retardo de 40ms=
				;==============================

retardo_40ms 	clrf cont_milis;
loop_40ms		movlw .40;
				subwf cont_milis,w;
				btfss status,Z;
				goto loop_40ms;
			
				return;
;----------------------------------------------------------------------------------------------------------
 
End
