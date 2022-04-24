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
resp_w		    equ 		0x29;	
res_status		equ			0x30;
res_pclath		equ			0x31;
res_fsr			equ			0x32;
presc_1			equ			0x33;
presc_2			equ			0x34;
banderas		equ			0x35;	


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

;Asignacion de los bits del registro bandera
bin_int			equ			.0;
sin_bd1			equ			.1;
sin_bd2			equ			.2;
sin_bd3			equ			.3;
sin_bd4			equ			.4;
sin_bd5			equ			.5;
sin_bd6			equ			.6;
sin_bd7			equ			.7;

;-------------------------------------------------------------------------------------
;
;Asignacion de los bits de los puertos de I/O.
;Puerto A.
RS_LCD			equ			.0; // 
Enabl_LCD		equ			.1; // 
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
D0_LCD			equ			.0; // Bit D0 del LCD.
D1_LCD			equ			.1; // Bit D1 del LCD.
D2_LCD			equ			.2; // Bit D2 del LCD.
D3_LCD			equ			.3; // Bit D3 del LCD.
D4_LCD			equ			.4; // Bit D4 del LCD.
D5_LCD			equ			.5; // Bit D5 del LCD.
D6_LCD			equ			.6; // Bit D6 del LCD.
D7_LCD			equ			.7; // Bit D7 del LCD.

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
vec_int          movwf resp_w;resp. esl estado del reg. w. 
                 movf status,w;
               	 movwf resp_status;resp. banderas de la alu.
                 clrf status;
                 movf pclath,w;
                 movwf res_pclath;
                 clrf pclath;
                 movf fsr,w;
                 movwf res_fsr; 
                         
                 btfsc intcon,t0if;
                 call rutina_int;
                        
sal_int            movlw .131;
                   movwf tmr0;
                        movf res_fsr,w;
                        movwf fsr;
                        movf res_pclath,w;
                        movwf pclath;
                        movf resp_status,w;
                        movwf status;
                        movf resp_w,w;
                        
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

sig_int           	 clrf presc_1;
                        incf presc_2,f;
                        movlw .5;
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
prog_ini		bsf STATUS,RP0; 			//colocate en el bco. 1 de ram
				movlw 0x81;					// Mueve la constante 0X81 al registro w
				movwf OPTION_REG ^0x80;	// Mueve la constante 0X81 al registro OPTION_REG
				movlw proga;		// Mueve el contenido de w a el registro proga
				movwf TRISA ^0x80;		// Mueve la constante 0X80 al registro TRISA
				movlw progb;		// Mueve el contenido de w a el registro progb
				movwf TRISB ^0x80;		// Mueve la constante 0X80 al registro TRISB
				movlw progc;		// Mueve el contenido de w a el registro progc
				movwf TRISC ^0x80;		// Mueve la constante 0X80 al registro TRISC
				movlw progd;		// Mueve el contenido de w a el registro progd
				movwf TRISD ^0x80;		// Mueve la constante 0X80 al registro TRISD
				movlw proge;		// Mueve el contenido de w a el registro proge
				movwf TRISE ^0x80;		// Mueve la constante 0X80 al registro TRISE
				movlw 0x06;		// Mueve la constante 0X06 al registro w
				movwf ADCON1 ^0x80;	// Mueve la constante 0X80 al registro ADCON1
				bcf	STATUS,RP0;	//regresa al bco. 0 de ram

				clrf PORTB;		// Limpia el registro PORTB 
				movlw b'11111111';		// Mueve la constante 0xFF al registro W
				movwf PORTC;		// Mueve el contenido de W a PORTC
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

cuenta_time		call rectifica	//Llamada a la subrutina que rectifica que no sean las 24hras si lo son reinicia
			movf cta_uniseg,w;	//Mover el contenido del registro cta unidades de segundo a el registro de trabajo
			movwf temporal;	//Mover el contenido del registro de trabajo al registro temporal
			call convbin_7seg;	//Llamada a la subrutina de conversion de binario a 7 segmentos
			movf temporal,w;	//Mover el contenido del registro temporal a el registro de trabajo 
			movwf buffer0;	//Mover el contenido del registro de trabajo al buffer 0

			movf cta_decseg,w;	//Mover el contenido del registro cta decenas de segundo a el registro de trabajo
			movwf temporal;	//Mover el contenido del registro de trabajo al registro temporal	
			call convbin_7seg;	//Llamada a la subrutina de conversion de binario a 7 segmento
			movf temporal,w;	//Mover el contenido del registro temporal a el registro de trabajo 
			movwf buffer1;	//Mover el contenido del registro de trabajo al buffer 

			movf cta_unimin,w;	//Mover el contenido del registro cta unidades de minuto a el registro de trabajo
			movwf temporal;	//Mover el contenido del registro de trabajo al registro temporal
			call convbin_7seg;	//Llamada a la subrutina de conversion de binario a 7 segmento
			movf temporal,w;	//Mover el contenido del registro temporal a el registro de trabajo
			movwf buffer2;	//Mover el contenido del registro de trabajo al buffer 2

			movf cta_decmin,w;	//Mover el contenido del registro cta decenas de minuto a el registro de trabajo
			movwf temporal;	//Mover el contenido del registro de trabajo al registro temporal		
			call convbin_7seg;	//Llamada a la subrutina de conversion de binario a 7 segmentos
			movf temporal,w;	//Mover el contenido del registro temporal a el registro de trabajo
			movwf buffer3;	//Mover el contenido del registro de trabajo al buffer 3

			movf cta_unihor,w;	//Mover el contenido del registro cta unidades de hora a el registro de trabajo
			movwf temporal;	//Mover el contenido del registro de trabajo al registro temporal
			call convbin_7seg;	//Llamada a la subrutina de conversion de binario a 7 segmentos
			movf temporal,w;	//Mover el contenido del registro temporal a el registro de trabajo
			movwf buffer4;	//Mover el contenido del registro de trabajo al buffer 4

			movf cta_dechor,w;	//Mover el contenido del registro cta decenas de hora a el registro de trabaj
			movwf temporal;	//Mover el contenido del registro de trabajo al registro temporal
			call convbin_7seg;	//Llamada a la subrutina de conversion de binario a 7 segmentos
			movf temporal,w;	//Mover el contenido del registro temporal a el registro de trabajo
			movwf buffer5;	//Mover el contenido del registro de trabajo al buffer 5

			call muestra_time;	//Llamada a la subrutina de muestra mensaje 
;----------------------------------------------------------------------------------------------------------
			
			incf cta_uniseg,f;	//Incrementa la variable cta unidades de segundo y guarada en el mismo registro
			movlw .10;		//Mueve la contante 10 al registro de trabajo 
			subwf cta_uniseg,w;	//Resta la variable cta unidades de segundo menos el contenido del registro de trabajo guarada en w
			btfss status,Z;	//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion 
			goto cuenta_time;	//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;	//Reinicia el contenido de las unidades de segundo 

			incf cta_decseg,f;	//Incrementa la variable cta decenas de segundo y guarada en el mismo registro
			movlw .6;		//Mueve la contante 6 al registro de trabajo 
			subwf cta_decseg,w;	//Resta la variable cta decenas de segundo menos el contenido del registro de trabajo guarda en w	
			btfss status,Z;	//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion 
			goto cuenta_time;	//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;	//Reinicia el contenido de las unidades de segundo 
			clrf cta_decseg;	//Reinicia el contenido de las decenas de segundo 
				
			incf cta_unimin,f;	//Incrementa la variable cta unidades de min y guarada en el mismo registro
			movlw .10;		//Mueve la contante 10 al registro de trabajo 
			subwf cta_unimin,w;	//Resta la variable cta unidades de min menos el contenido del registro de trabajo guarda en w
			btfss status,Z;	//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion	
			goto cuenta_time;	//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;	//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;	//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;	//Reinicia el contenido de las unidades de minutos 

			incf cta_decmin,f;	//Incrementa la variable cta decenas de min y guarada en el mismo registro
			movlw .6;		//Mueve la contante 6 al registro de trabajo 
			subwf cta_decmin,w;	//Resta la variable cta decenas de minutos menos el contenido del registro de trabajo guarda en 
			btfss status,Z;	//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion
			goto cuenta_time;	//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;	//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;	//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;	//Reinicia el contenido de las unidades de minutos 
			clrf cta_decmin;	//Reinicia el contenido de las decenas de minutos 

			incf cta_unihor,f;	//Incrementa la variable cta unidades de hora y guarada en el mismo registro
			movlw .10;		//Mueve la contante 10 al registro de trabajo 
			subwf cta_unihor,w;	//Resta la variable cta unidades de hora menos el contenido del registro de trabajo guarda en w
			btfss status,Z;	/Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion
			goto cuenta_time;	//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;	//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;	//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;	//Reinicia el contenido de las unidades de minutos 
			clrf cta_decmin;	//Reinicia el contenido de las decenas de minutos 
			clrf cta_unihor;	//Reinicia el contenido de las unidades de hora 

			incf cta_dechor,f;	//Incrementa la variable cta decenas de hora y guarada en el mismo registro
			movlw .3;		//Mueve la contante 3 al registro de trabajo
			subwf cta_dechor,w;	//Resta la variable cta decenas de hora menos el contenido del registro de trabajo guarda en w
			btfss status,Z;	//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion
			goto cuenta_time;	//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;	//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;	//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;	//Reinicia el contenido de las unidades de minutos 
			clrf cta_decmin;	//Reinicia el contenido de las decenas de minutos
			clrf cta_unihor;	//Reinicia el contenido de las unidades de hora 
			clrf cta_dechor;	//Reinicia el contenido de las decenas de hora
			goto cuenta_time;	//Ve para la etiqueta cuenta_time

;----------------------------------------------------------------------------------------------------------

	;====================================================
		;==Subrutina que rectifica =
	;====================================================
;---------------------------------------------------------------------------------------------------------
rectifica 			movlw .2;		//Cargar la constante 2 al registro de trabajo
			subwf cta_dechor,w;	 //Resta entre el registro cta_dechor menos el registro de trabajo
			btfss status,Z;	//Si el bit Z del registro STATUS es igual a 1 salta
			goto sal_rectifica;	//ve para sal_rectifica

			movlw .4;		//Cargar la constante 4 al registro de trabajo
			subwf cta_unihor,w;  	//Resta entre el contenido del registro cta_unihor menos el registro de trabajo
			btfss status,Z;	//Si el bit Z del registro STATUS es igual a 1 salta
			goto sal_rectifica;	//ve para la salida de la subrutina 

			movlw .0;		//Cargar la constante 0 al registro de trabajo
			subwf cta_decmin,w;  	//Resta entre el contenido del registro cta_decmin menos el registro de trabajo
			btfss status,Z;	//Si el bit Z del registro STATUS es igual a 1 salta
			goto sal_rectifica;	//ve para la salida de la subrutina

			movlw .0;		//Cargar la constante 0 al registro de trabajo
			subwf cta_unimin,w;  	//Resta entre el contenido del registro cta_unimin menos el registro de trabajo
			btfss status,Z;	//Si el bit Z del registro STATUS es igual a 1 salta
			goto sal_rectifica;	//ve para la salida de la subrutina

			movlw .0;		//Cargar la constante 0 al registro de trabajo
			subwf cta_decseg,w;  	//Resta entre el contenido del registro cta_decseg menos el registro de trabajo
			btfss status,Z;	//Si el bit Z del registro STATUS es igual a 1 salta
			goto sal_rectifica;	//ve para la salida de la subrutina

			movlw .0;		//Cargar la constante 0 al registro de trabajo
			subwf cta_uniseg,w;  	//Resta entre el contenido del registro cta_uniseg menos el registro de trabajo
			btfss status,Z;	//Si el bit Z del registro STATUS es igual a 1 salta
			goto sal_rectifica;	// ve para la salida de la subrutina 

			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;		//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;		//Reinicia el contenido de las unidades de minuto
			clrf cta_decmin;		//Reinicia el contenido de las decenas de minutos
			clrf cta_unihor;		//Reinicia el contenido de las unidades de hora 
			clrf cta_dechor;		//Reinicia el contenido de las decenas de hora

sal_rectifica 		return;		//sal de la subrutina			

;----------------------------------------------------------------------------------------------------------

	;================================================
		;==Subrutina de muestra mensajes en el display ==
;================================================

muestra_time		movlw Barrido;	// Mueve el contenido de Barrido a el registro W
			movwf Contador3;	// Mueve el contenido de al registro Contador 1

barre_imagentime
			movf buffer5,w;	// Mueve el contendo de buffer 5 al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D7;	// Poner a 0 el bit 7 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D7;	// Poner a 1 el bit 7 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
				
			movf buffer4,w;	// Mueve el contendo de buffer 4 al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D6;	// Poner a 0 el bit 6 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D6;	// Poner a 1 el bit 6 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo

			movlw car_guion;	// Mueve el caracter guion en binario al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D5;	// Poner a 0 el bit 5 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D5;	// Poner a 1 el bit 5 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
				
			movf buffer3,w;	// Mueve el contenido de buffer 3 al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D4;	// Poner a 0 el bit 4 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D4;	// Poner a 1 el bit 4 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo

			movf buffer2,w;	// Mueve el contendo de buffer 2 al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D3;	// Poner a 0 el bit 3 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D3;	// Poner a 1 el bit 3 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo

			movlw car_guion;	// Mueve el caracter guion en binario al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D2;	// Poner a 0 el bit 2 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D2;	// Poner a 1 el bit 2 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
				
           		    	movf buffer1,w;	// Mueve el contendo de buffer 1 al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D1;	// Poner a 0 el bit 1 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D1;	// Poner a 1 el bit 1 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo

			movf buffer0,w;	// Mueve el contendo de buffer 0 al registro w
			movwf portb;	// Mueve el contenido de w al puerto B
			bcf portc,Com_D0;	// Poner a 0 el bit 0 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo
			bsf portc,Com_D0;	// Poner a 1 el bit 0 del registro puerto C
			call retardo;	// Llamada a la subrutina retardo

			decfsz Contador3,f;	//decrementa la variable contador3 y guardalo en el mismo archivo salta si es cero  
			goto barre_imagentime;	//Ve para barre_imagentime
			return;		//regresa de la subrutina 

;----------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------

		;====================================================
			;==Subrutina de convertidor de binario a 7 segmentos=
		;====================================================
;---------------------------------------------------------------------------------------------------------
convbin_7seg		movlw .0;		//Cargar 0 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_cero;	// ve para fue_cero
				
			movlw .1;		//Cargar 1 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_uno;	// ve para fue_uno

			movlw .2;		//Cargar 2 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_dos;	// ve para fue_dos

			movlw .3;		//Cargar 3 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_tres;	// ve para fue_tres

			movlw .4;		//Cargar 4 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_cuatro;	// ve para fue_cuatro

			movlw .5;		//Cargar 5 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_cinco;	// ve para fue_cinco

			movlw .6;		//Cargar 6 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_seis;	// ve para fue_seis

			movlw .7;		//Cargar 6 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_siete;	// ve para fue_siete

			movlw .8;		//Cargar 7 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_ocho;	// ve para fue_siete

			movlw .9;			//Cargar 8 binario al registro w
			subwf temporal,w;	//Resta entre el registro temporal y w y guardalo en el registro w
			btfsc status,Z;	//Si el bit Z del registro STATUS es igual a 0 salta
			goto fue_nueve;	// ve para fue_ocho
			goto sal_subcov7seg;

	

fue_cero			movlw car_0;	//Mueve el caracter 0 al registro W
			movwf temporal;	//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina 
fue_uno			movlw car_1;	//Mueve el caracter 1 al registro W
			movwf temporal;	//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina 
fue_dos			movlw car_2;	//Mueve el caracter 2 al registro W
			movwf temporal;	//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina
fue_tres			movlw car_3;	//Mueve el caracter 3 al registro W
			movwf temporal;	//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina
fue_cuatro			movlw car_4;	//Mueve el caracter 4 al registro W
			movwf temporal;		//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina
fue_cinco			movlw car_5;		//Mueve el caracter 5 al registro W
			movwf temporal;		//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina
fue_seis			movlw car_6;		//Mueve el caracter 6 al registro W
			movwf temporal;		//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina
fue_siete			movlw car_7;		//Mueve el caracter 7 al registro W
			movwf temporal;		//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina
fue_ocho			movlw car_8;		//Mueve el caracter 8 al registro W
			movwf temporal;		//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina

fue_nueve			movlw car_9;		//Mueve el caracter 9 al registro W
			movwf temporal;		//Mueve el contenido del registro W al registro temporal
			goto sal_subcov7seg; // Ve a la salida de la subrutina


sal_subcov7seg 		 return;				//Retorno de la subrutina


;----------------------------------------------------------------------------------------------------------

				;==============================
				;==Subrutina de retador de 2ms=
				;==============================
retardo			movlw .N;				//Carga la literal N al registro de trabajo
			movwf Contador2;		//Mueve el contenido del registro de trabajo al registro Contador 2
Loop2			movlw .L;				//Carga la literal L al registro de trabajo
			movwf Contador1;		//Mueve el contenido del registro de trabajo al registro Contador 1
Loop1			decfsz Contador1,f;		//Decremanta en una unidad el contenido de contador 1 y almacenalo en este mismo registro salta si es cero 
			goto Loop1;				//Ve para la etiqueta Loop1 	
			decfsz Contador2,f;		//Decremanta en una unidad el contenido de contador 2 y almacenalo en este mismo registro salta si es cero
			goto Loop2;				//Ve para la etiqueta Loop2

			return;					/Retorno de la subrutina

;----------------------------------------------------------------------------------------------------------

End

