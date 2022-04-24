;INSTITUTO POLITECNICO NACIONAL
;CECYT 9 JUAN DE DIOS BATIZ
;
;PRACTICA 4 MULTIPLEXADO MODULO ANALÓGICO “DAC CONVERTIDOR DIGITAL ANALOGICO”.  
;(GENERADOR DE SEÑALES BASICAS).
;GRUPO:6IM2
;
;INTEGRANTE
;Morales Martínez José Antonio
;
;El programa ejecutara un generador de señales, con capacidad de mostrar
;una señal triangular, cuadrada, y senoidal cambiando entre ellas por medio de 
;un teclado matricial 4x4 y un LCD para vizualizar la señal que se esta mostrando
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

res_w		    equ 		0x29;	//Registro de resplado de la variable W en la subruitna de interrupción 
res_status		equ			0x30;	//Registro de resplado de la variable status en la subruitna de interrupción
res_pclath		equ			0x31;	//Registro de resplado de la variable pclath en la subruitna de interrupción
res_fsr			equ			0x32;	//Registro de resplado de la variable fsr en la subruitna de interrupción
presc_1			equ			0x33;	//T int= T interrupcion(0.001s)*presc_1 multiplica por un escalar al tiempo de interrupcion base
presc_2			equ			0x34;	//T int= T interrupcion(0.001s)*presc_1*presc_2 multiplica por un escalar al tiempo de interrupcion base 
banderas		equ			0x35;	//Registro en donde se definen bits banderas (bandera_c, bandera_D, bandera_clear)
cont_milis		equ			0x36;	//Registro que lleva la cuenta de las unidades de milisegundos (0-255)
buffer5		   	equ			0x39;	//DirecciÃ³n de la memoria RAM para el buffer 5.
buffer4 		equ			0x40;	//DirecciÃ³n de la memoria RAM para el buffer 4.
buffer3			equ			0x41;	//DirecciÃ³n de la memoria RAM para el buffer 3.
buffer2 		equ			0x42;	//DirecciÃ³n de la memoria RAM para el buffer 2.
buffer1  		equ			0x43;	//DirecciÃ³n de la memoria RAM para el buffer 1.
buffer0  		equ			0x44;	//DirecciÃ³n de la memoria RAM para el buffer 0.
Var_teclado 	equ			0x45;	//Guardar el codigo de la tecla activa sobre el puerto B.
Var_tecopri		equ			0x46;	//Regresar el codigo ASCII de la tecla oprimida.
Var_tecbin		equ 		0x47;	//Guarda el calor de la tecla oprimida en binario.
buffer6  		equ			0x48;	//DirecciÃ³n de la memoria RAM para el buffer 6.
buffer7  		equ			0x49;	//DirecciÃ³n de la memoria RAM para el buffer 7.
buffer8  		equ			0x50;	//DirecciÃ³n de la memoria RAM para el buffer 8.
buffer9  		equ			0x51;	//DirecciÃ³n de la memoria RAM para el buffer 9.
bufferA  		equ			0x52;	//DirecciÃ³n de la memoria RAM para el buffer A.
bufferB  		equ			0x53;	//DirecciÃ³n de la memoria RAM para el buffer B.
bufferC  		equ			0x54;	//DirecciÃ³n de la memoria RAM para el buffer C.
bufferD  		equ			0x55;	//DirecciÃ³n de la memoria RAM para el buffer D.
bufferE  		equ			0x56;	//DirecciÃ³n de la memoria RAM para el buffer E.
bufferF			equ			0x57;	//DirecciÃ³n de la memoria RAM para el buffer F.
cont_señal  	equ 		0x58;	//Direccion del registro que lleva la cuenta de la señal

;-----------------------------------------------------------------------------------------------------
;Constantes

No_haytecla		equ 		0xF0;	//Esta constante desctiva todos los reglones y no habrá tecla en la entrada
Tec_1			equ			0xE0;	//Esta costante representa a la tecla "1" 
Tec_2			equ			0xD0;	//Esta costante representa a la tecla "2"
Tec_3			equ			0XB0;	//Esta costante representa a la tecla "3"
Tec_A			equ			0x70;	//Esta costante representa a la tecla "A"
Tec_4			equ			0xE0;	//Esta costante representa a la tecla "4"
Tec_5			equ			0xD0;	//Esta costante representa a la tecla "5"
Tec_6			equ			0XB0;	//Esta costante representa a la tecla "6"
Tec_B			equ			0x70;	//Esta costante representa a la tecla "B"
Tec_7			equ			0xE0;	//Esta costante representa a la tecla "7"
Tec_8			equ			0xD0;	//Esta costante representa a la tecla "8"
Tec_9			equ			0XB0;	//Esta costante representa a la tecla "9"
Tec_C			equ			0x70;	//Esta costante representa a la tecla "C"
Tec_Clear		equ			0xE0;	//Esta costante representa a la tecla "*"
Tec_0			equ			0xD0;	//Esta costante representa a la tecla "0"
Tec_gato		equ			0XB0;	//Esta costante representa a la tecla "#"
Tec_D			equ			0x70;	//Esta costante representa a la tecla "D"

;-----------------------------------------------------------------------------------------------------

; banderas del registro banderas.
ban_int                 equ     .0;	//Bit bandera de retardo 1s
bandera_d             	equ     .1; //Bit bandera de salida de la subrutina configtime
bandera_teclado        	equ     .2; //Bit bandera de combrobacion de la variable introducida mediante teclado
bandera_clear 		    equ     .3; //Bit bandera de * para borrar LCD
sin_bd4                 equ     .4; //Sin Uso bd4.
sin_bd5                 equ     .5;	//Sin Uso bd5. 
sin_bd6                 equ     .6; //Sin Uso bd6.
sin_bd7                 equ     .7; //Sin Uso bd7.
;-----------------------------------------------------------------------------------------------------
;Asignacion de los bits de los puertos de I/O.
;Puerto A.
RS_LCD			equ			.0; // Señal de control de Comando o dato en la LCD
Enable_LCD		equ			.1; // Señal de ingreso de información a la LCD
Sin_UsoRA2		equ			.2; // Sin Uso RA2.
Sin_UsoRA3		equ			.3; // Sin Uso RA3
Sin_UsoRA4		equ			.4; // Sin Uso RA4.
Sin_UsoRA5		equ			.5; // Sin Uso RA5.

proga			equ	b'111100'; // Programacion Inicial del Puerto A.

;Puerto B.
Act_Ren1		equ 		.0; // Pin de salida para activar el reglon de 1 del teclado.
Act_Ren2		equ 		.1; // Pin de salida para activar el reglon de 2 del teclado.
Act_Ren3		equ 		.2; // Pin de salida para activar el reglon de 3 del teclado.
Act_Ren4		equ 		.3; // Pin de salida para activar el reglon de 4 del teclado.
Col_1			equ 		.4; // Pin de entrada para leer el codigo de la tecla oprimida.
Col_2			equ 		.5; // Pin de entrada para leer el codigo de la tecla oprimida.
Col_3			equ 		.6; // Pin de entrada para leer el codigo de la tecla oprimida.
Col_4   			equ 		.7; // Pin de entrada para leer el codigo de la tecla oprimida.
		
progb			equ	b'11110000'; // Programacion Inicial del Puerto B.

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
BitD0_DAC		equ			.0; // Bit 0 de datos para el DAC
BitD1_DAC		equ			.1; // Bit 1 de datos para el DAC
BitD2_DAC		equ			.2; // Bit 2 de datos para el DAC
BitD3_DAC		equ			.3; // Bit 3 de datos para el DAC
BitD4_DAC		equ			.4; // Bit 4 de datos para el DAC
BitD5_DAC		equ			.5; // Bit 5 de datos para el DAC
BitD6_DAC		equ			.6; // Bit 6 de datos para el DAC
BitD7_DAC		equ			.7; // Bit 7 de datos para el DAC

progd			equ	b'00000000'; // Programacion Inicial del Puerto D como entradas.

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
                 org 0004h;  			//direccion de memoria donde se encuentra la subrtuina de servicio de interrupcion  
vec_int    		 movwf res_w;			//Respaldar el estado del registro w
                 movf status,w;			//Mover el contenido del registro status a el registro de trabajo
               	 movwf res_status;	 	//Respaldar las banderas de la alu
                 clrf status;			//Limpia el registro STATUS
                 movf pclath,w;			//Mover el contenido del registro res_pclath a el registro de trabajo
                 movwf res_pclath;		//Respaldar el estado del registro pclath		
                 clrf pclath;			//Limpia el registro pclath
                 movf fsr,w;			//Mover el contenido del registro res_fsr a el registro de trabajo
                 movwf res_fsr;			//Respaldar el estado del registro fsr	
                         
                 btfsc intcon,t0if;		//Si el bit t0if del registro intcon es igual a 0 salta
                 call rutina_int;		//LLamada a la subrutina de interrupciones
                        
sal_int    		 movlw .131;			//Mover la constante 131 al registro de trabajo
                 movwf tmr0;			//Mover el contenido del registro de trabajo al registro tmr0
                 movf res_fsr,w;		//Mover el contenido del respaldo res_fsr a el registro de trabajo
                 movwf fsr;				//Mover el contenido del registro de trabajo al registro far
                 movf res_pclath,w;		//Mover el contenido del respaldo res_pclath a el registro de trabajo
                 movwf pclath;			//Mover el contenido del registro de trabajo al registro pclath
                 movf res_status,w;		//Mover el contenido del respaldo res_status a el registro de trabajo
               	 movwf status;			//Mover el contenido del registro de trabajo al registro status
                 movf res_w,w;			//Mover el contenido del respaldo res_w a el registro de trabajo
                        
                 retfie;				//Regresar al programa principal
;--------------------------------------------------------------------------------------------------


                        ;=============================
                        ;== Subrutina de Interrupciones  ==
                        ;=============================
rutina_int  	incf cont_milis,f;		//Incrementa la variable cont milis en una unidad y guarda en el mismo registro
                incf presc_1,f;			//Incrementa la variable presc 1 en una unidad y guarda en el mismo registro
                        
                movlw .100;				//Mover la constante 100 al registro de trabajo
                xorwf presc_1,w;		//XOR entre registro presc 1 y el registro de trabajo
               	btfsc status,z;			//Si el bit z del registro status es igual a 0 salta
                goto sig_int;			//Ve para la etiqueta sig_int
                goto sal_rutint;		//Ve para la etiqueta sal_rutint

sig_int    		clrf presc_1;			//Limpia el registro presc 1
                incf presc_2,f;			//Incrementa la variable presc 2 y guarda en el mismo registro
                movlw .10;				//Mover la constante 10 al registro de trabajo
               	xorwf presc_2,w;		//XOR entre registro presc 2 y el registro de trabajo
                btfss status,z;			//Si el bit z del registro status es igual a 1 salta
               	goto sal_rutint;		//Ve para la etiqueta sal_rutint
                clrf presc_1;			//Limpia el registro presc 1
                clrf presc_2;			//Limpia el registro presc 2
                        
sal_rutext      bsf banderas,ban_int;	//Pon a 1 el bit ban int del registro banderas(retardo 1s)
                                 
sal_rutint      bcf intcon,t0if;		//Pon a 0 el bit bandera t0if puesto a 1 por la interrupcion
                return;					//Regresar al programa principal
;---------------------------------------------------------------------------------------------------------	


				;=======================
				;==Subrutina de inicio==
				;=======================
prog_ini		bsf STATUS,RP0; 		//Coloca al programa  en el bco. 1 de ram
				movlw 0x02;				// Mueve la constante 0X02 al registro w
				movwf OPTION_REG ^0x80;	// Configura el preescalador y activa los pull-up
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
			
                movlw 0xa0;				// Habilita la interrupcion del TMR0, Las globales y borra las banderas de interrupción 
                movwf intcon;			//Mover el contenido del registro de trabajo al registro intcon
                movlw .131;				//Mover la constante 131 al registro de trabajo
                movwf tmr0;				//Carga a tmr0 la constante 131 desde donde iniciará la cuenta

				clrf portc;				//Limpia el registro portc
				movlw 0x03;				//Inicializa el pin Enable y RS a 1 logico
				movwf porta;			//Mover el contenido del registro de trabajo al registro porta
				
				clrf res_w;				//Limpia el registro res w
				clrf res_status;		//Limpia el registro res status
				clrf res_pclath;		//Limpia el registro res pclath
				clrf res_fsr; 			//Limpia el registro res fsr
				clrf presc_1;			//Limpia el registro presc 1
				clrf presc_2;			//Limpia el registro presc 2
                clrf banderas;			//Limpia el registro banderas
				clrf Var_tecopri;		//Limpia el registro Var_tecopri
				clrf Var_tecbin;		//Limpia el registro Var_tecbin
				clrf Var_teclado;		//Limpia el registro Var_teclado
				clrf portd;				//LImpia el registro del puerto D
				clrf buffer0;			//Limpia el buffer0 encargado del dígito 0 del LCD
				clrf buffer1;			//Limpia el buffer1 encargado del dígito 1 del LCD
				clrf buffer2;			//Limpia el buffer2 encargado del dígito 2 del LCD
				clrf buffer3;			//Limpia el buffer3 encargado del dígito 3 del LCD
				clrf buffer4;			//Limpia el buffer4 encargado del dígito 4 del LCD
				clrf buffer5;			//Limpia el buffer5 encargado del dígito 5 del LCD
				clrf buffer6;			//Limpia el buffer6 encargado del dígito 6 del LCD
				clrf buffer7;			//Limpia el buffer7 encargado del dígito 7 del LCD
				clrf buffer8;			//Limpia el buffer8 encargado del dígito 8 del LCD
				clrf buffer9;			//Limpia el buffer9 encargado del dígito 9 del LCD
				clrf bufferA;			//Limpia el bufferA encargado del dígito A del LCD
				clrf bufferB;			//Limpia el bufferB encargado del dígito B del LCD
				clrf bufferC;			//Limpia el bufferC encargado del dígito C del LCD
				clrf bufferD;			//Limpia el bufferD encargado del dígito D del LCD
				clrf bufferE;			//Limpia el bufferE encargado del dígito E del LCD
				movlw 0X0F;				//Inicializa el teclado como No hay tecla
				movwf portb;			// Mueve el contenido de W al puerto B

			  	return;					//Regresa de la subrutina de inicializacion
;----------------------------------------------------------------------------------------------------------

				;======================
				;==Programa Principal==
				;======================
prog_prin		call prog_ini;			//Llamada a la subrutina de inicio 		
				call ini_lcd;			//Llama a la subrutina de inicializacion del LCD

loop_prin		clrf cont_señal; 		//Limpia el registro que lleva la cuenta del muestreo de la señal
				clrf portd;				//Limpia el puerto D
				movlw 0x00;				//Carga el caracter espacio en el registro W
				movwf buffer1;			//Carga el contenido de w en el buffer 1
				movwf bufferE;			//Carga el contenido de w en el buffer E
				movlw 'G';				//Mueve el caracter G en ASCII a el registro W
				movwf buffer2;			//Mueve el caracter G a el buffer2
				movlw 'E';				//Mueve el caracter E en ASCII a el registro W
				movwf buffer3;			//Mueve el caracter E a el buffer3.
				movlw 'N';				//Mueve el caracter N en ASCII a el registro W
				movwf buffer4;			//Mueve el caracter N a el buffer4
				movlw 'E';				//Mueve el caracter E en ASCII a el registro W
				movwf buffer5;			//Mueve el caracter E a el buffer5
				movlw 'R';				//Mueve el caracter R en ASCII a el registro W
				movwf buffer6;			//Mueve el caracter R a el buffer6
				movlw 'A';				//Mueve el caracter A en ASCII a el registro W
				movwf buffer7;			//Mueve el caracter A a el buffer7
				movlw 'D';				//Mueve el caracter D en ASCII a el registro W
				movwf buffer8;			//Mueve el caracter D a el buffer8
				movlw 'O';				//Mueve el caracter O en ASCII a el registro W
				movwf buffer9;			//Mueve el caracter O a el buffer9
				movlw 'R';				//Mueve el caracter R en ASCII a el registro W
				movwf bufferA;			//Mueve el caracter R a el buffer A
				movlw 'F';				//Mueve el caracter F en ASCII a el registro W
				movwf bufferC;			//Mueve el caracter F a el buffer C
				movlw 'B';				//Mueve el caracter B en ASCII a el registro W
				movwf bufferD;			//Mueve el caracter B a el buffer D
	 			call muestra_caracter;
	 		
renglon_3			
switch			bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
				nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
				bcf	portb,Act_Ren3;		//Activa reglon 3 del teclado matricial
				movf portb,w;			//Mueve el contenido del puerto B a el registro W
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw 0XF0;				//Enmascaramiento
				andwf Var_teclado,f; 	//Enmascaramiento
				movlw No_haytecla;		//mueve la variable no hay tecla a W
				subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto renglon_3;			//Ve a barrer el reglon 2
		
				movlw Tec_1; 			//Mueve la constante tecla 1 a W
				subwf Var_teclado,W;	//Resta la variable teclado - tecla 1, almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto Fue_Tec1;			//Ve aconvertir a ASCII la tecla 1
		
				movlw Tec_2; 			//Mueve la constante tecla 2 a W
				subwf Var_teclado,W;	//Resta la variable teclado - tecla 2, almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto Fue_Tec2;			//Ve aconvertir a ASCII la tecla 2

				movlw Tec_3; 			//Mueve la constante tecla 3 a W
				subwf Var_teclado,W;	//Resta la variable teclado - tecla 3, almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto Fue_Tec3;			//Ve aconvertir a ASCII la tecla 3

Fue_Tec1		
	
			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x01;				//Comando de apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable				
				
			movlw 0x00;				//Carga el caracter espacio en el registro W
			movwf buffer0;			//Carga el contenido de w en el buffer 0
			movwf buffer1;			//Carga el contenido de w en el buffer 1
			movwf buffer2;			//Carga el contenido de w en el buffer 2
			movwf buffer3;			//Carga el contenido de w en el buffer 3
			movwf bufferC;			//Carga el contenido de w en el buffer C	
			movwf bufferD;			//Carga el contenido de w en el buffer D
			movwf bufferE;			//Carga el contenido de w en el buffer E
			movlw 'S';				//Mueve el caracter S en ASCII a el registro W
			movwf buffer4;			//Mueve el caracter S a el buffer4
			movlw 'E';				//Mueve el caracter E en ASCII a el registro W
			movwf buffer5;			//Mueve el caracter E a el buffer5.
			movlw 'N';				//Mueve el caracter N en ASCII a el registro W
			movwf buffer6;			//Mueve el caracter N a el buffer6
			movlw 'O';				//Mueve el caracter O en ASCII a el registro W
			movwf buffer7;			//Mueve el caracter O a el buffer7
			movlw 'I';				//Mueve el caracter I en ASCII a el registro W
			movwf buffer8;			//Mueve el caracter I a el buffer8
			movlw 'D';				//Mueve el caracter D en ASCII a el registro W
			movwf buffer9;			//Mueve el caracter D a el buffer9
			movlw 'A';				//Mueve el caracter A en ASCII a el registro W
			movwf bufferA;			//Mueve el caracter A a el bufferA
			movlw 'L';				//Mueve el caracter L en ASCII a el registro W
			movwf bufferB;			//Mueve el caracter L a el bufferB
			call muestra_caracter;	//Llamada a la subrutina de muestrar caracteres en el LCD 
				
oscilasin		
			bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
			nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
			bcf	portb,Act_Ren3;		//Activa reglon 3 del teclado matricial
			movf portb,w;			//Mueve el contenido del puerto B a el registro W
			movwf Var_teclado; 		//Mueve el contenido a la variable teclado
			movlw 0XF0;				//Enmascaramiento
			andwf Var_teclado,f; 	//Enmascaramiento
			movlw No_haytecla;		//mueve la variable no hay tecla a W
			subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
			btfss status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto switch;			//Ve a barrer el reglon 2
				
			bsf portb,Act_Ren4;		//Desactiva el reglon 4 del teclado.
			bsf portb,Act_Ren3;		//Desactiva el reglon 3 del teclado.
			bcf portb,Act_Ren2; 	//Activa el reglon 2 del teclado.
			bsf portb,Act_Ren1;		//Desactiva el reglon 1 del teclado.
			btfss portb,col_1;		//Realiza un chequeo de la tecla C.  
			goto loop_prin;			//Sale de la subrutina.
				 		
			clrf cont_señal;		//Limpia el registro que lleva la cuenta del muestreo de la señal
gen_señalsinup		
			movf cont_señal,w;		//Mueve el contenido de registro contador de señal a w
			movwf portd;			//Mueve al puerto D el contenido de W
			call espera_2ms;		//Llamada a la subrutina de espera de 2 ms, tiempo entre las muestras
			movlw .13;				//Carga a W la constante decimal 13
			addwf cont_señal,f;		//Operacion lógica AND entre el contenido del registro contador de señal y el registro w
			movlw .247;				//Carga a W la constante decimal 247 
			xorwf cont_señal,w;		//Operación lógica XOR entre el contenido del registro contador de señal y el registro w
			btfss status,z;			//Prueba el bit z del registro status, si es 1 salta si no ejecuta la siguiente instrucción 
			goto gen_señalsinup;	//Ve para generar señal seno de subida
				
			movf cont_señal,w;		//Mueve el contenido de registro contador de señal a w
			movwf portd;			//Mueve al puerto D el contenido de W
			call espera_4ms;		//Llamada a la subrutina de espera de 4 ms (Achatamiento de la curva)

gen_señalsindown		
			movf cont_señal,w;		//Mueve el contenido de registro contador de señal a w
			movwf portd;			//Mueve al puerto D el contenido de W
			call espera_2ms;		//Llamada a la subrutina de espera de 2 ms, tiempo entre las muestras	
			movlw .13;				//Carga a W la constante decimal 13
			subwf cont_señal,f;		//Resta entre contenido del registro W y el registro contador de señal
			movlw .0;				//Carga a W la constante decimal 0
			xorwf cont_señal,w;		//Operación lógica XOR entre el contenido del registro contador de señal y el registro w
			btfss status,z;			//Prueba el bit z del registro status, si es 1 salta si no ejecuta la siguiente instrucción
			goto gen_señalsindown;	// Ve para generar señal seno de bajada

			movf cont_señal,w;		//Mueve el contenido de registro contador de señal a w
			movwf portd;			//Mueve al puerto D el contenido de W
			call espera_4ms;		//Llamada a la subrutina de espera de 4 ms (Achatamiento de la curva)
			goto oscilasin;				//Lazo de osilación del seno 
			

;----------------------------------------------------------------------------------------------------------
Fue_Tec2
				bcf porta,RS_LCD; 		//Pone en modo comando al LCD
				movlw 0x01;				//Comando de apuntador en el display
				movwf portc;			//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;		//Llamada a la subrutina de Pulso Enable				

				movlw 0x00;				//Carga el caracter espacio en el registro W
				movwf buffer0;			//Carga el contenido de w en el buffer 0
				movwf buffer1;			//Carga el contenido de w en el buffer 1
				movwf buffer2;			//Carga el contenido de w en el buffer 2
				movwf bufferD;			//Carga el contenido de w en el buffer D
				movwf bufferE;			//Carga el contenido de w en el buffer E
				movlw 'T';				//Mueve el caracter T en ASCII a el registro W
				movwf buffer3;			//Mueve el caracter T a el buffer3
				movlw 'R';				//Mueve el caracter R en ASCII a el registro W
				movwf buffer4;			//Mueve el caracter R a el buffer4
				movlw 'I';				//Mueve el caracter I en ASCII a el registro W
				movwf buffer5;			//Mueve el caracter I a el buffer5.
				movlw 'A';				//Mueve el caracter A en ASCII a el registro W
				movwf buffer6;			//Mueve el caracter A a el buffer6
				movlw 'N';				//Mueve el caracter N en ASCII a el registro W
				movwf buffer7;			//Mueve el caracter N a el buffer7
				movlw 'G';				//Mueve el caracter G en ASCII a el registro W
				movwf buffer8;			//Mueve el caracter G a el buffer8
				movlw 'U';				//Mueve el caracter U en ASCII a el registro W
				movwf buffer9;			//Mueve el caracter U a el buffer9
				movlw 'L';				//Mueve el caracter L en ASCII a el registro W
				movwf bufferA;			//Mueve el caracter L a el bufferA
				movlw 'A';				//Mueve el caracter A en ASCII a el registro W
				movwf bufferB;			//Mueve el caracter A a el bufferB
				movlw 'R';				//Mueve el caracter R en ASCII a el registro W
				movwf bufferC;			//Mueve el caracter R a el bufferC
	 			call muestra_caracter;	//Llamada a la subrutina de muestrar caracteres en el LCD 
				
oscilatriangular			 
				bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
				nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
				bcf	portb,Act_Ren3;		//Activa reglon 3 del teclado matricial
				movf portb,w;			//Mueve el contenido del puerto B a el registro W
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw 0XF0;				//Enmascaramiento
				andwf Var_teclado,f; 	//Enmascaramiento
				movlw No_haytecla;		//mueve la variable no hay tecla a W
				subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
				btfss status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto switch;			//Ve a barrer el reglon 2

				bsf portb,Act_Ren4;		//Desactiva el reglon 4 del teclado.
				bsf portb,Act_Ren3;		//Desactiva el reglon 3 del teclado.
				bcf portb,Act_Ren2;		//Activa el reglon 2 del teclado.
				bsf portb,Act_Ren1;		//Desactiva el reglon 1 del teclado.
				btfss portb,col_1;		//Realiza un chequeo de la tecla C.  
				goto loop_prin;			//Sale de la subrutina.
					
				clrf cont_señal;		//Limpia el registro que lleva la cuenta del muestreo de la señal	
gen_señalr
				movf cont_señal,w;		//Mueve el contenido de registro contador de señal a w	
				movwf portd;			//Mueve al puerto D el contenido de W
				call espera_4ms;		//Llamada a la subrutina de espera de 4 ms, tiempo entre las muestras
				movlw .25;				//Carga a W la constante decimal 25
				addwf cont_señal,f;		//Operacion lógica AND entre el contenido del registro contador de señal y el registro w	
				movlw .250;				//Carga a W la constante decimal 250
				xorwf cont_señal,w;		//Operación lógica XOR entre el contenido del registro contador de señal y el registro w	
				btfss status,z;			//Prueba el bit z del registro status, si es 1 salta si no ejecuta la siguiente instrucción	
				goto gen_señalr;		// Ve para generar señal triangular de subida


gen_señalf		movf cont_señal,w;		//Mueve el contenido de registro contador de señal a w
				movwf portd;			//Mueve al puerto D el contenido de W
				call espera_4ms;		//Llamada a la subrutina de espera de 4 ms, tiempo entre las muestras		
				movlw .25;				//Carga a W la constante decimal 25	
				subwf cont_señal,f;		//Resta entre contenido del registro W y el registro contador de señal
				movlw .0;				//Carga a W la constante decimal 0
				xorwf cont_señal,w;		//Operación lógica XOR entre el contenido del registro contador de señal y el registro w
				btfss status,z;			//Prueba el bit z del registro status, si es 1 salta si no ejecuta la siguiente instrucción	
				goto gen_señalf;		//Ve para generar señal triangular de bajada
			
				goto oscilatriangular;			//Lazo de osilación de la señal triangular
;----------------------------------------------------------------------------------------------------------
Fue_Tec3	

				movlw 0x00;				//Carga el caracter espacio en el registro W
				movwf buffer0;			//Carga el contenido de w en el buffer 0
				movwf buffer1;			//Carga el contenido de w en el buffer 1
				movwf buffer2;			//Carga el contenido de w en el buffer 2
				movwf buffer3;			//Carga el contenido de w en el buffer 3
				movwf bufferA;			//Carga el contenido de w en el buffer A
				movwf bufferB;			//Carga el contenido de w en el buffer B
				movwf bufferC;			//Carga el contenido de w en el buffer C
				movwf bufferD;			//Carga el contenido de w en el buffer D	
				movwf bufferE;			//Carga el contenido de w en el buffer E
				movlw 'D';				//Mueve el caracter G en ASCII a el registro W
				movwf buffer4;			//Mueve el caracter G a el buffer2
				movlw 'I';				//Mueve el caracter E en ASCII a el registro W
				movwf buffer5;			//Mueve el caracter E a el buffer3.
				movlw 'G';				//Mueve el caracter N en ASCII a el registro W
				movwf buffer6;			//Mueve el caracter N a el buffer4
				movlw 'I';				//Mueve el caracter E en ASCII a el registro W
				movwf buffer7;			//Mueve el caracter E a el buffer5
				movlw 'T';				//Mueve el caracter R en ASCII a el registro W
				movwf buffer8;			//Mueve el caracter R a el buffer6
				movlw 'A';				//Mueve el caracter A en ASCII a el registro W
				movwf buffer9;			//Mueve el caracter A a el buffer7
				movlw 'L';				//Mueve el caracter D en ASCII a el registro W
				movwf bufferA;			//Mueve el caracter D a el buffer8
		
				call muestra_caracter;	//Llamada a la subrutina de muestrar caracteres en el LCD 
				
loop_digital
				bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
				nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
				bcf	portb,Act_Ren3;		//Activa reglon 3 del teclado matricial
				movf portb,w;			//Mueve el contenido del puerto B a el registro W
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw 0XF0;				//Enmascaramiento
				andwf Var_teclado,f; 	//Enmascaramiento
				movlw No_haytecla;		//mueve la variable no hay tecla a W
				subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
				btfss status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto switch;			//Ve a barrer el reglon 2
			
				bsf portb,Act_Ren4;		//Desactiva el reglon 4 del teclado.
				bsf portb,Act_Ren3;		//Desactiva el reglon 3 del teclado.
				bcf portb,Act_Ren2; 	//Activa el reglon 2 del teclado.
				bsf portb,Act_Ren1;		//Desactiva el reglon 1 del teclado.
				btfss portb,col_1;		//Realiza un chequeo de la tecla C.  
				goto loop_prin;			//Sale de la subrutina.
			
				movlw .255;				//Carga a W la constante decimal 255
				movwf portd;			//Mueve al puerto D el contenido de W		
				call espera_41ms;		//Llamada a la subrutina de espera de 41 ms, tiempo entre las muestras	
				movlw .0;				//Carga a W la constante decimal 0
				movwf portd;			//Mueve al puerto D el contenido de W
				call espera_41ms;		//Llamada a la subrutina de espera de 41 ms, tiempo entre las muestras	
				goto loop_digital;		//Lazo de osilación de la señal digital	

;---------------------------------------------------------------------------------------------------------
muestra_caracter
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x80;					//Comando de apuntador en el LCD digito 1
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer0,w;				//Mover la constante del buffer 0 a W			
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x81;					//Comando de apuntador en el LCD digito 2
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer1,w;				//Mover la constante del buffer 1 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x82;					//Comando de apuntador en el LCD digito 3
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer2,w;				//Mover la constante del buffer 2 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x83;					//Comando de apuntador en el LCD digito 4
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer3,w;				//Mover la constante del buffer 3 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x84;					//Comando de apuntador en el LCD digito 5
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer4,w;				//Mover la constante del buffer 4 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x85;					//Comando de apuntador en el LCD digito 6
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer5,w;				//Mover la constante del buffer 5 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x86;					//Comando de apuntador en el LCD digito 7
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer6,w;				//Mover la constante del buffer 6 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x87;					//Comando de apuntador en el LCD digito 8
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer7,w;				//Mover la constante del buffer 7 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x88;					//Comando de apuntador en el LCD digito 9
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer8,w;				//Mover la constante del buffer 8 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x89;					//Comando de apuntador en el LCD digito 10
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer9,w;				//Mover la constante del buffer 9 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8A;					//Comando de apuntador en el LCD digito 11
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferA,w;				//Mover la constante del buffer A a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8B;					//Comando de apuntador en el LCD digito 12
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferB,w;				//Mover la constante del buffer B a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8C;					//Comando de apuntador en el LCD digito 13
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferC,w;				//Mover la constante del buffer C a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8D;					//Comando de apuntador en el LCD digito 14
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferD,w;				//Mover la constante del buffer D a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8E;					//Comando de apuntador en el LCD digito 15
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferE,w;				//Mover la constante del buffer E a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable


				return;						//Regreso al programa principal
;----------------------------------------------------------------------------------------------------------

	;================================================
	;   ==Subrutina de inicializacion en el LCD ==
	;================================================

ini_lcd 	bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			
			movlw 0x38;				//selecciona el modo de bus, formato de vizualizacion y lineas de vizualizacion
			movwf portc;			//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			movlw 0X0C; 			//activa el cursor y configura el parpadeo del cursor
			movwf portc;			//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			movlw 0x01;				//Borra el texto y dirige el cursor al primer dígito
			movwf portc;			//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			movlw 0x80;				//Coloca el cursor en el primer dígito
			movwf portc;			//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			
			bsf porta,RS_LCD; 		//Pone en modo datos al LCD
			return;					//regresa de la subrutina 

;----------------------------------------------------------------------------------------------------------
				;==============================
				;	==Subrutina Pulso Enable=
				;==============================

pulso_enable	bcf porta,Enable_LCD;	//Pon a 0 el bit Enable_LCD del registro porta
				call retardo_1ms;  		//Llamada a la subrutina de retardo de 1ms
				bsf porta,Enable_LCD;	//Pon a 1 el bit Enable_LCD del registro porta
				call retardo_40ms;  	//Llamada a la subrutina de retardo de 40ms
				return;
;----------------------------------------------------------------------------------------------------------


				;==============================
				;==Subrutina de retardo de 1ms=
				;==============================

retardo_1ms 	clrf cont_milis;		//Limpia el registro cont milis		
loop_1ms		movlw .1;				//Mueve la constante 1 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta
				goto loop_1ms;			//Ve para la etiqueta loop_1ms
			
				return;					//regresa de la subrutina
;----------------------------------------------------------------------------------------------------------

				;==============================
				;==Subrutina de retardo de 6ms=
				;==============================

retardo_40ms 	clrf cont_milis;		//Limpia el registro cont milis	
loop_40ms		movlw .40;				//Mueve la constante 40 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS si es igual a 1 salta de lo contrario ejecuta normalmente
				goto loop_40ms;			//Ve para la etiqueta loop_40ms
			
				return;					//regresa de la subrutina


;----------------------------------------------------------------------------------------------------------

				;==============================
				;==Subrutina de retardo de 2ms=
				;==============================

espera_2ms		clrf cont_milis;		//Limpia el registro cont milis	
loop_2m			movlw .2;				//Mueve la constante 2 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS si es igual a 1 salta de lo contrario ejecuta normalmente
				goto loop_2m;			//Ve para la etiqueta loop_2ms
			
				return;					//regresa de la subrutina

;----------------------------------------------------------------------------------------------------------

				;==============================
				;==Subrutina de retardo de 41ms=
				;==============================

espera_41ms	clrf cont_milis;			//Limpia el registro cont milis	
loop_41			movlw .41;				//Mueve la constante 41 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS si es igual a 1 salta de lo contrario ejecuta normalmente
				goto loop_41;			//Ve para la etiqueta loop_41ms
			
				return;					//regresa de la subrutina

;----------------------------------------------------------------------------------------------------------

				;==============================
				;==Subrutina de retardo de 4ms=
				;==============================

espera_4ms		clrf cont_milis;		//Limpia el registro cont milis	
loop_4			movlw .4;				//Mueve la constante 4 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS si es igual a 1 salta de lo contrario ejecuta normalmente
				goto loop_4;			//Ve para la etiqueta loop_4
			
				return;					//regresa de la subrutina

;----------------------------------------------------------------------------------------------------------

end										//Fin del programa









			
