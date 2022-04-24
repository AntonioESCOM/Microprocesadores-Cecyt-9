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
tempo_2			equ			0x37;	//Registro en donde se almacena temporalmente el nibble alto del byte almacenado en la RAM
tempo_3			equ			0x38;	//Registro en donde se almacena temporalmente el nibble bajo del byte almacenado en la RAM
temporal		equ			0x39;	//Registro en donde se almacena la variable para la subrutina de conversión de hexadecimal a ASCII
Var_teclado 	equ			0x40;	//Guardar el codigo de la tecla activa sobre el puerto B.
Var_tecopri		equ			0x41;	//Regresar el codigo ASCII de la tecla oprimida.
Var_tecbin		equ 		0x42;	//Guarda el calor de la tecla oprimida en binario.
tempo_1			equ 		0x43;	//Registro en donde se almacena temporalmente el byte almacenado en la RAM
buffer0  		equ			0x44;	//Direccion de la memoria RAM para el buffer 0.
buffer1  		equ			0x45;	//Direccion de la memoria RAM para el buffer 1.
buffer2 		equ			0x46;	//Direccion de la memoria RAM para el buffer 2.
buffer3			equ			0x47;	//Direccion de la memoria RAM para el buffer 3.
buffer4 		equ			0x48;	//Direccion de la memoria RAM para el buffer 4.
buffer5x		equ			0x49;	//Direccion de la memoria RAM para el buffer 5.
buffer6x  		equ			0x75;	//Direccion de la memoria RAM para el buffer 6.
buffer7  		equ			0x50;	//Direccion de la memoria RAM para el buffer 7.
buffer8  		equ			0x51;	//Direccion de la memoria RAM para el buffer 8.
buffer9  		equ			0x52;	//Direccion de la memoria RAM para el buffer 9.
bufferA  		equ			0x53;	//Direccion de la memoria RAM para el buffer A.
bufferB  		equ			0x54;	//Direccion de la memoria RAM para el buffer B.
bufferC  		equ			0x55;	//Direccion de la memoria RAM para el buffer C.
bufferD  		equ			0x56;	//Direccion de la memoria RAM para el buffer D.
bufferE  		equ			0x57;	//Direccion de la memoria RAM para el buffer E.
bufferF			equ			0x58;	//Direccion de la memoria RAM para el buffer F.
buffer0DO  		equ			0x59;	//Direccion de la memoria RAM para el buffer 0.
buffer1DO  		equ			0x60;	//Direccion de la memoria RAM para el buffer 1.
buffer2DO 		equ			0x61;	//Direccion de la memoria RAM para el buffer 2.
buffer3DO		equ			0x62;	//Direccion de la memoria RAM para el buffer 3.
buffer4DO		equ			0x63;	//Direccion de la memoria RAM para el buffer 4.
buffer5DO		equ			0x64;	//Direccion de la memoria RAM para el buffer 5.
buffer6DO 		equ			0x65;	//Direccion de la memoria RAM para el buffer 6.
buffer7DO 		equ			0x66;	//Direccion de la memoria RAM para el buffer 7.
buffer8DO  		equ			0x67;	//Direccion de la memoria RAM para el buffer 8.
buffer9DO 		equ			0x68;	//Direccion de la memoria RAM para el buffer 9.
bufferADO 		equ			0x69;	//Direccion de la memoria RAM para el buffer A.
bufferBDO  		equ			0x70;	//Direccion de la memoria RAM para el buffer B.
bufferCDO 		equ			0x71;	//Direccion de la memoria RAM para el buffer C.
bufferDDO  		equ			0x72;	//Direccion de la memoria RAM para el buffer D.
bufferEDO 		equ			0x73;	//Direccion de la memoria RAM para el buffer E.
bufferFDO		equ			0x74;	//Direccion de la memoria RAM para el buffer F.
auxnibble_bajo 	equ			0x76;
auxnibble_alto 	equ			0x77;
auxporte		equ 		0x78;
reg5s			equ 		0x79;

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
Enable_LCD		equ			.0; // Señal de control de Comando o dato en la LCD
RS_LCD			equ			.1; // Señal de ingreso de información a la LCD
WE_RAM			equ			.2; // Señal de WR en la memoria RAM
RD_RAM			equ			.3; // Señal de RD en la memoria RAM
Led_rojo		equ			.4; // Monitor del sistema
CE_RAM			equ			.5; // Descativación/activación de la RAM.

proga			equ	b'000000'; // Programacion Inicial del Puerto A.

;Puerto B.
Act_Ren1		equ 		.0; // Pin de salida para activar el reglon de 1 del teclado.
Act_Ren2		equ 		.1; // Pin de salida para activar el reglon de 2 del teclado.
Act_Ren3		equ 		.2; // Pin de salida para activar el reglon de 3 del teclado.
Act_Ren4		equ 		.3; // Pin de salida para activar el reglon de 4 del teclado.
Col_1			equ 		.4; // Pin de entrada para leer el codigo de la tecla oprimida.
Col_2			equ 		.5; // Pin de entrada para leer el codigo de la tecla oprimida.
Col_3			equ 		.6; // Pin de entrada para leer el codigo de la tecla oprimida.
Col_4   		equ 		.7; // Pin de entrada para leer el codigo de la tecla oprimida.
		
progb			equ	b'11110000'; // Programacion Inicial del Puerto B.

;Puerto C.
Data_BusD0			equ			.0; // Bit de Entrada/Salida del bus de datos.
Data_BusD1			equ			.1; // Bit de Entrada/Salida del bus de datos.
Data_BusD2			equ			.2; // Bit de Entrada/Salida del bus de datos.
Data_BusD3			equ			.3; // Bit de Entrada/Salida del bus de datos.
Data_BusD4			equ			.4; // Bit de Entrada/Salida del bus de datos.
Data_BusD5			equ			.5; // Bit de Entrada/Salida del bus de datos.
Data_BusD6			equ			.6; // Bit de Entrada/Salida del bus de datos.
Data_BusD7			equ			.7; // Bit de Entrada/Salida del bus de datos.

progc_in			equ	b'11111111'; // Programacion Inicial del Puerto C como Entradas.
progc_out			equ	b'00000000'; // Programacion Inicial del Puerto C como Salidas.

;Puerto D.
Bus_DirA0		equ			.0; // Bit 0 de salida A0 de direcciones;
Bus_DirA1		equ			.1; // Bit 1 de salida A1 de direcciones;
Bus_DirA2		equ			.2; // Bit 2 de salida A2 de direcciones;
Bus_DirA3		equ			.3; // Bit 3 de salida A3 de direcciones;
Bus_DirA4		equ			.4; // Bit 4 de salida A4 de direcciones;
Bus_DirA5		equ			.5; // Bit 5 de salida A5 de direcciones;
Bus_DirA6		equ			.6; // Bit 6 de salida A6 de direcciones;
Bus_DirA7		equ			.7; // Bit 7 de salida A7 de direcciones;

progd			equ	b'00000000'; // Programacion Inicial del Puerto D como salidas.

;Puerto E.
Bus_DirA10		equ			.0; // Bit 10 de salida A10 de direcciones;
Bus_DirA9		equ			.1; // Bit 9 de salida A9 de direcciones;
Bus_DirA8		equ			.2; // Bit 8 de salida A8 de direcciones;

proge			equ	b'000'; // Programacion inicial del Puerto E como salidas.
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
				movlw progc_out;			// Mueve el contenido de w a el registro progc
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
				
				clrf portb;
				movlw 0x3f;
				movwf porta;
				clrf porte;
				clrf portd;

				clrf buffer0;			//Limpia el buffer0 encargado del dígito 0 del LCD
				clrf buffer1;			//Limpia el buffer1 encargado del dígito 1 del LCD
				clrf buffer2;			//Limpia el buffer2 encargado del dígito 2 del LCD
				clrf buffer3;			//Limpia el buffer3 encargado del dígito 3 del LCD
				clrf buffer4;			//Limpia el buffer4 encargado del dígito 4 del LCD
				clrf buffer5x;			//Limpia el buffer5 encargado del dígito 5 del LCD
				clrf buffer6x;			//Limpia el buffer6 encargado del dígito 6 del LCD
				clrf buffer7;			//Limpia el buffer7 encargado del dígito 7 del LCD
				clrf buffer8;			//Limpia el buffer8 encargado del dígito 8 del LCD
				clrf buffer9;			//Limpia el buffer9 encargado del dígito 9 del LCD
				clrf bufferA;			//Limpia el bufferA encargado del dígito A del LCD
				clrf bufferB;			//Limpia el bufferB encargado del dígito B del LCD
				clrf bufferC;			//Limpia el bufferC encargado del dígito C del LCD
				clrf bufferD;			//Limpia el bufferD encargado del dígito D del LCD
				clrf bufferE;			//Limpia el bufferE encargado del dígito E del LCD
				clrf buffer0DO;			//Limpia el buffer0 encargado del dígito 0 del LCD
				clrf buffer1DO;			//Limpia el buffer1 encargado del dígito 1 del LCD
				clrf buffer2DO;			//Limpia el buffer2 encargado del dígito 2 del LCD
				clrf buffer3DO;			//Limpia el buffer3 encargado del dígito 3 del LCD
				clrf buffer4DO;			//Limpia el buffer4 encargado del dígito 4 del LCD
				clrf buffer5DO;			//Limpia el buffer5 encargado del dígito 5 del LCD
				clrf buffer6DO;			//Limpia el buffer6 encargado del dígito 6 del LCD
				clrf buffer7DO;			//Limpia el buffer7 encargado del dígito 7 del LCD
				clrf buffer8DO;			//Limpia el buffer8 encargado del dígito 8 del LCD
				clrf buffer9DO;			//Limpia el buffer9 encargado del dígito 9 del LCD
				clrf bufferADO;			//Limpia el bufferA encargado del dígito A del LCD
				clrf bufferBDO;			//Limpia el bufferB encargado del dígito B del LCD
				clrf bufferCDO;			//Limpia el bufferC encargado del dígito C del LCD
				clrf bufferDDO;			//Limpia el bufferD encargado del dígito D del LCD
				clrf bufferEDO;			//Limpia el bufferE encargado del dígito E del LCD
				clrf bufferFDO;			//Limpia el bufferE encargado del dígito E del LCD
				clrf reg5s;


			  	return;					//Regresa de la subrutina de inicializacion
;----------------------------------------------------------------------------------------------------------------

				;======================
				;==Programa Principal==
				;======================
prog_prin	call prog_ini;			//Llamada a la subrutina de inicio 		
			call ini_lcd;			//Llama a la subrutina de inicializacion del LCD
	
Fue_Tec3AUX	movlw 0x00;				//Deja en blanco el espacio para el
			movwf buffer0;			//digito 0
			movwf buffer7;			//digito 8
			movwf bufferA;			//digito 11
			movwf bufferE;			//digito 15
			movwf bufferF;			//digito 16	
			movwf buffer0DO;		//digito 1 2do reglón
			movwf buffer1DO;		//digito 2 2do reglón
			movwf buffer9DO;		//digito 10 2do reglón
			movwf bufferDDO;		//digito 14 2do reglón
			movwf bufferEDO;		//digito 15 2do reglón
			movwf bufferFDO;		//digito 16 2do reglón
			movlw 'M';				//Carga al buffer 1 con el caracter M
			movwf buffer1;			//en ASCII para ser mostrado en el LCD 
			movlw 'A';				//Carga al buffer 2 con el caracter A
			movwf buffer2;			//en ASCII para ser mostrado en el LCD 
			movlw 'N';				//Carga al buffer 3 con el caracter N
			movwf buffer3;			//en ASCII para ser mostrado en el LCD 
			movlw 'E';				//Carga al buffer 4 con el caracter E
			movwf buffer4;			//en ASCII para ser mostrado en el LCD 
			movlw 'J';				//Carga al buffer 4 con el caracter E
			movwf buffer5x;			//en ASCII para ser mostrado en el LCD 
			movlw 'O';				//Carga al buffer 6 con el caracter O
			movwf buffer6x;			//en ASCII para ser mostrado en el LCD 
			movlw 'D';				//Carga al buffer 8 con el caracter D
			movwf buffer8;			//en ASCII para ser mostrado en el LCD 
			movlw 'E';				//Carga al buffer 9 con el caracter E
			movwf buffer9;			//en ASCII para ser mostrado en el LCD 
			movlw 'U';				//Carga al buffer A con el caracter U
			movwf bufferB;			//en ASCII para ser mostrado en el LCD 
			movlw 'N';				//Carga al buffer C con el caracter N
			movwf bufferC;			//en ASCII para ser mostrado en el LCD 
			movlw 'A';				//Carga al buffer D con el caracter A
			movwf bufferD;			//en ASCII para ser mostrado en el LCD 
			movlw 'M';				//Carga al buffer 2 con el caracter M
			movwf buffer2DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'E';				//Carga al buffer 3 con el caracter E
			movwf buffer3DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'M';				//Carga al buffer 4 con el caracter M
			movwf buffer4DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'O' ;				//Carga al buffer 5 con el caracter O
			movwf buffer5DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'R' ;				//Carga al buffer 6 con el caracter R
			movwf buffer6DO;		//en ASCII para ser mostrado en el LCD
			movlw 'I' ;				//Carga al buffer 7 con el caracter I
			movwf buffer7DO;		//en ASCII para ser mostrado en el LCD  
			movlw 'A' ;				//Carga al buffer 8 con el caracter A
			movwf buffer8DO;		//en ASCII para ser mostrado en el LCD
			movlw 'R' ;				//Carga al buffer 1A con el caracter R
			movwf bufferADO;		//en ASCII para ser mostrado en el LCD 
			movlw 'A' ;				//Carga al buffer 1B con el caracter A
			movwf bufferBDO;		//en ASCII para ser mostrado en el LCD 
			movlw 'M' ;				//Carga al buffer 1C con el caracter M
			movwf bufferCDO;		//en ASCII para ser mostrado en el LCD 
	 		call muestra_caracter;

;----------------------------------------------------------------------------------------------------------------
renglon_3A			
			bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
			nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
			bcf	portb,Act_Ren3;		//Activa reglon 3 del teclado matricial
			movf portb,w;			//Mueve el contenido del puerto B a el registro W
			movwf Var_teclado; 		//Mueve el contenido a la variable teclado
			movlw 0XF0;				//Enmascaramiento
			andwf Var_teclado,f; 	//Enmascaramiento
			movlw No_haytecla;		//mueve la variable no hay tecla a W
			subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto renglon_3A;			//Ve a barrer el reglon 2
switch		
			movlw Tec_1; 			//Mueve la constante tecla 1 a W
			subwf Var_teclado,W;	//Resta la variable teclado - tecla 1, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec1AUX;			//Ve aconvertir a ASCII la tecla 1
		
			movlw Tec_2; 			//Mueve la constante tecla 2 a W
			subwf Var_teclado,W;	//Resta la variable teclado - tecla 2, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec2AUX;			//Ve aconvertir a ASCII la tecla 2

			movlw Tec_3; 			//Mueve la constante tecla 3 a W
			subwf Var_teclado,W;	//Resta la variable teclado - tecla 3, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec3AUX;			//Ve aconvertir a ASCII la tecla 3
;----------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------
Fue_Tec1AUX

			movlw 0x00;				//Deja en blanco el espacio para el
			movwf buffer0;			//digito 1
			movwf buffer1;			//digito 2
			movwf buffer2;			//digito 3
			movwf buffer3;			//digito 4
			movwf bufferB;			//digito 12	
			movwf bufferC;			//digito 13
			movwf bufferD;			//digito 14
			movwf bufferE;			//digito 15
			movwf bufferF;			//digito 16
			movwf buffer0DO;		//digito 1 2do reglón
			movwf bufferBDO;		//digito 12 2do reglón
			movwf bufferCDO;		//digito 13 2do reglón
			movwf bufferDDO;		//digito 14 2do reglón
			movwf bufferEDO;		//digito 15 2do reglón
			movwf bufferFDO;		//digito 16 2do reglón
			movlw 'L';				//Carga al buffer 4 con el caracter L
			movwf buffer4;			//en ASCII para ser mostrado en el LCD 
			movlw 'E';				//Carga al buffer 5 con el caracter E
			movwf buffer5x;			//en ASCII para ser mostrado en el LCD 
			movlw 'C';				//Carga al buffer 6 con el caracter C
			movwf buffer6x;			//en ASCII para ser mostrado en el LCD 
			movlw 'T';				//Carga al buffer 7 con el caracter T
			movwf buffer7;			//en ASCII para ser mostrado en el LCD 
			movlw 'U';				//Carga al buffer 8 con el caracter U
			movwf buffer8;			//en ASCII para ser mostrado en el LCD 
			movlw 'R';				//Carga al buffer 9 con el caracter R
			movwf buffer9;			//en ASCII para ser mostrado en el LCD 
			movlw 'A';				//Carga al buffer A con el caracter A
			movwf bufferA;			//en ASCII para ser mostrado en el LCD 
			
			movlw 'D';				//Carga al buffer 1  con el caracter D
			movwf buffer1DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'I';				//Carga al buffer 2 con el caracter I
			movwf buffer2DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'R';				//Carga al buffer 3 con el caracter R
			movwf buffer3DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'E';				//Carga al buffer 4 con el caracter E
			movwf buffer4DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'C';				//Carga al buffer 4 con el caracter C
			movwf buffer5DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'C';				//Carga al buffer 6 con el caracter C
			movwf buffer6DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'I';				//Carga al buffer 7 con el caracter I
			movwf buffer7DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'O';				//Carga al buffer 8 con el caracter O
			movwf buffer8DO;		//en ASCII para ser mostrado en el LCD 
			movlw 'N';				//Carga al buffer 9 con el caracter N
			movwf buffer9DO;		//en ASCII para ser mostrado en el LCD 
			movlw ':';				//Carga al buffer A con el caracter :
			movwf bufferADO;		//en ASCII para ser mostrado en el LCD 
			call muestra_caracter
;----------------------------------------------------------------------------------------------------------------


			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xCC;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxporte;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;

			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xCD;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxnibble_alto;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;

			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xCE;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxnibble_bajo;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;


			bsf status,RP0; 		//Selecciona el banco 0 de memoria RAM
			movlw progc_in;			//Configura el puerto c
			movwf TRISC ^0x80;		//como entradas 	.
			bcf status,RP0; 		//Regresa al banco 0 para interactuar con los registro que hay ahí
			
			swapf auxnibble_alto,w;
			addwf auxnibble_bajo,w;
			movwf portd;
			movf auxporte,w;
			movwf porte;
;----------------------------------------------------------------------------------------------------------------
		
			bcf porta,CE_RAM; 		//Activa el bus de datos de la RAM
			nop;			 		//Desfasamiento 	
			nop;					// de la señal 
			nop;					//4 ms
			nop;
			bcf porta,RD_RAM; 		//Activa la escritura de la RAM
			call retardo_1ms;		//Retardo de 1ms para para el pulso de lectura
			movf portc,w;			//Respalda el dato a leer de la RAM		
			movwf tempo_1;			//a un registro auxiliar para poder trabajar con el en el PIC16F877A
			bsf porta,RD_RAM;		//Desactiva la escritura de la RAM
			nop;			 		//Desfasamiento 	
			nop;					//de la señal 
			nop;					//3 ms
			bsf porta,CE_RAM;		//Desactiva el bus de datos de la RAM

			bsf status,RP0; 		//Selecciona el banco 0 de memoria RAM
			movlw progc_out;		//Configura el puerto c
			movwf TRISC ^0x80;		//como salidas.
			bcf status,RP0; 		//Regresa al banco 0 para interactuar con los registro que hay ahí
	
			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0x01;				
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xC4;				
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			movf tempo_1,w;
			movwf tempo_2;
			movwf tempo_3;

			movlw 'D';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 'A';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;
		
			movlw 'T';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 'O';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw ':';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 0xF0;
			andwf tempo_2,f;
			swapf tempo_2,f;
			movf tempo_2,w;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 0x0F;
			andwf tempo_3,f;
			movf tempo_3,w;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 'H';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

loop_1era	bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
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
			goto loop_1era;

;----------------------------------------------------------------------------------------------------------------


Fue_Tec2AUX

;----------------------------------------------------------------------------------------------------------------

			movlw 0x00;				//Deja en blanco el espacio para el
			movwf buffer0;			//digito 1
			movwf buffer1;			//digito 2
			movwf buffer2;			//digito 3	
			movwf bufferC;			//digito 13
			movwf bufferD;			//digito 14
			movwf bufferE;			//digito 15
			movwf bufferF;			//digito 16
			movwf buffer0DO;		//digito 1 2do reglón
			movwf buffer5DO;		//digito 6 2do reglón
			movwf buffer6DO;		//digito 7 2do reglón
			movwf buffer7DO;		//digito 8 2do reglón
			movwf buffer8DO;		//digito 9 2do reglón
			movwf bufferBDO;		//digito 12 2do reglón
			movwf bufferCDO;		//digito 13 2do reglón
			movwf bufferDDO;		//digito 14 2do reglón
			movwf bufferEDO;		//digito 15 2do reglón
			movwf bufferFDO;		//digito 16 2do reglón
			
			movlw 'E';				//Envía el caracter E
			movwf buffer3;			//en ASCII para ser mostrado en el LCD 
			movlw 'S';				//Envía el caracter S
			movwf buffer4;			//en ASCII para ser mostrado en el LCD 
			movlw 'C';				//Envía el caracter C
			movwf buffer5X;			//en ASCII para ser mostrado en el LCD.
 			movlw 'R';				//Envía el caracter R
			movwf buffer6X;			//en ASCII para ser mostrado en el LCD.
			movlw 'I';				//Envía el caracter I
			movwf buffer7;			//en ASCII para ser mostrado en el LCD.
			movlw 'T';				//Envía el caracter T
			movwf buffer8;			//en ASCII para ser mostrado en el LCD.
			movlw 'U';				//Envía el caracter U
			movwf buffer9;			//en ASCII para ser mostrado en el LCD.
			movlw 'R';				//Envía el caracter R
			movwf bufferA;			//en ASCII para ser mostrado en el LCD.
			movlw 'A';				//Envía el caracter A
			movwf bufferB;			//en ASCII para ser mostrado en el LCD.
		
			movlw 'D';				//Envía el caracter D
			movwf buffer1DO;		//en ASCII para ser mostrado en el LCD.
			movlw 'I';				//Envía el caracter I
			movwf buffer2DO;		//en ASCII para ser mostrado en el LCD.
			movlw 'R';				//Envía el caracter R
			movwf buffer3DO;		//en ASCII para ser mostrado en el LCD.
			movlw ':';				//Envía el caracter :
			movwf buffer4DO;		//en ASCII para ser mostrado en el LCD.

			movlw 'D';				//Envía el caracter D
			movwf buffer9DO;		//en ASCII para ser mostrado en el LCD.
			movlw 'A';				//Envía el caracter A
			movwf bufferADO;		//en ASCII para ser mostrado en el LCD.
			movlw 'T';				//Envía el caracter T
			movwf bufferBDO;		//en ASCII para ser mostrado en el LCD.
			movlw 'O';				//Envía el caracter O
			movwf bufferCDO;		//en ASCII para ser mostrado en el LCD.	
			movlw ':';				//Envía el caracter :
			movwf bufferDDO;		//en ASCII para ser mostrado en el LCD.
			call muestra_caracter

;----------------------------------------------------------------------------------------------------------------


			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xC5;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxporte;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;

			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xC6;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxnibble_alto;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;

			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xC7;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxnibble_bajo;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;

			swapf auxnibble_alto,w;
			addwf auxnibble_bajo,w;
			movwf portd;
			movf auxporte,w;
			movwf porte;

			bsf status,RP0; 		//Selecciona el banco 0 de memoria RAM
			movlw progc_out;		//Configura el puerto c
			movwf TRISC ^0x80;		//como salidas 	.
			bcf status,RP0; 		//Regresa al banco 0 para interactuar con los registro que hay ahí
;----------------------------------------------------------------------------------------------------------------
			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xCE;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxnibble_alto;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;

			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xCF;			
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			call barre_teclado;
			movf Var_tecopri,w;
			movwf auxnibble_bajo;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_250ms;

			swapf auxnibble_alto,w;
			addwf auxnibble_bajo,w;
			movwf portc;

			bcf porta,CE_RAM; 		//Activa el bus de datos de la RAM llevando a baja impedancia
			nop;			 		//Desfasamiento 	
			nop;					//de la señal 
			nop;					//4 ms
			nop;
			bcf porta,WE_RAM; 		//Activa la escritura de la RAM
			call retardo_1ms;		//Retardo de 1ms para el pulso de escritura
			bsf porta,WE_RAM;		//Desactiva la escritura de la RAM
			nop;			 		//Desfasamiento 	
			nop;					//de la señal 
			nop;					//3 ms
			bsf porta, CE_RAM;		//Desactiva el bus de datos de la RAM 
			


loop_2da	bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
			nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
			bcf	portb,Act_Ren3;		//Activa reglon 3 del teclado matricial
			movf portb,w;			//Mueve el contenido del puerto B a el registro W
			movwf Var_teclado; 		//Mueve el contenido a la variable teclado
			movlw 0XF0;				//Enmascaramiento
			andwf Var_teclado,f; 	//Enmascaramiento
			movlw No_haytecla;		//mueve la variable no hay tecla a W
			subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
			btfss status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto switch;			//Ve a barrer el reglon 3 del teclado matricial
			goto loop_2da;
















;----------------------------------------------------------------------------------------------------------
			movlw 0x02;				//Coloca el byte alto en el bus de direcciones
			movwf porte;			//especificado como 2 
			movlw 0x35;				//Seleccciona
			movwf portd;			//la direccion 35 de memoria RAM

			bsf status,RP0; 		//Selecciona el banco 0 de memoria RAM
			movlw progc_out;		//Configura el puerto c
			movwf TRISC ^0xC0;		//como salidas.
			bcf status,RP0; 		//Regresa al banco 0 para interactuar con los registro que hay ahí

			movlw 0x4B ; 			//Coloca el cracter 4B en hexadecimal
			movwf portc;			//en el bus de datos de la RAM


			bcf porta,CE_RAM; 		//Activa el bus de datos de la RAM llevando a baja impedancia
			nop;			 		//Desfasamiento 	
			nop;					//de la señal 
			nop;					//4 ms
			nop;
			bcf porta,WE_RAM; 		//Activa la escritura de la RAM
			call retardo_1ms;		//Retardo de 1ms para el pulso de escritura
			bsf porta,WE_RAM;		//Desactiva la escritura de la RAM
			nop;			 		//Desfasamiento 	
			nop;					//de la señal 
			nop;					//3 ms
			bsf porta, CE_RAM;		//Desactiva el bus de datos de la RAM 
			
			bsf status,RP0; 		//Selecciona el banco 0 de memoria RAM
			movlw progc_in;			//Configura el puerto c
			movwf TRISC ^0x80;		//como entradas 	.
			bcf status,RP0; 		//Regresa al banco 0 para interactuar con los registro que hay ahí
;----------------------------------------------------------------------------------------------------------

			movlw 0x02;				//Coloca el byte alto en el bus de direcciones
			movwf porte;			//especificado como 2 
			movlw 0x35;				//Seleccciona
			movwf portd;			//la direccion 35 de memoria RAM

			bcf porta,CE_RAM; 		//Activa el bus de datos de la RAM
			nop;			 		//Desfasamiento 	
			nop;					// de la señal 
			nop;					//4 ms
			nop;
			bcf porta,RD_RAM; 		//Activa la escritura de la RAM
			call retardo_1ms;		//Retardo de 1ms para para el pulso de lectura
			movf portc,w;			//Respalda el dato a leer de la RAM		
			movwf tempo_1;			//a un registro auxiliar para poder trabajar con el en el PIC16F877A
			bsf porta,RD_RAM;		//Desactiva la escritura de la RAM
			nop;			 		//Desfasamiento 	
			nop;					//de la señal 
			nop;					//3 ms
			bsf porta,CE_RAM;		//Desactiva el bus de datos de la RAM

			bsf status,RP0; 		//Selecciona el banco 0 de memoria RAM
			movlw progc_out;		//Configura el puerto c
			movwf TRISC ^0x80;		//como salidas.
			bcf status,RP0; 		//Regresa al banco 0 para interactuar con los registro que hay ahí

			bcf porta, RS_LCD; 		//Coloca la LCD en formato comandos
			movlw 0xC5;				
			movwf portc;
			call pulso_enable;
			bsf porta, RS_LCD;		//Coloca la LCD en modo datos

			movf tempo_1,w;
			movwf tempo_2;
			movwf tempo_3;

			movlw 'D';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 'A';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;
		
			movlw 'T';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 'O';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw ':';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 0xF0;
			andwf tempo_2,f;
			swapf tempo_2,f;
			movf tempo_2,w;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 0x0F;
			andwf tempo_3,f;
			movf tempo_3,w;
			movwf temporal;
			call convhex_ascii;
			movf temporal,w;
			movwf portc;
			call pulso_enable;
			call retardo_40ms;

			movlw 'H';
			movwf portc;
			call pulso_enable;
			call retardo_40ms;











;----------------------------------------------------------------------------------------------------------

	;================================================
	;   ==Subrutina de Barrre teclado================
	;================================================

barre_teclado
			
			bsf portb,Act_Ren4; 	//Desactiva el reglon 4 del teclado matricial
			nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
			bcf	portb,Act_Ren1;		//Activa reglon 1 del teclado matricial
			movf portb,w;			//Mueve el contenido del puerto B a el registro W
			movwf Var_teclado; 		//Mueve el contenido a la variable teclado
			movlw 0XF0;				//Enmascaramiento
			andwf Var_teclado,f; 	//Enmascaramiento
			movlw No_haytecla;		//Mueve la variable no hay tecla a W
			subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto renglon_2;			//Ve a barrer el reglon 2
		
			movlw Tec_7; 			//Mueve la constante tecla 7 a W
			subwf Var_teclado,W;	//Resta la variable teclado - Tec_7, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec7;			//Ve aconvertir a ASCII la tecla 7
		
			movlw Tec_8; 			//Mueve la constante tecla 8 a W
			subwf Var_teclado,W;	//Resta la variable teclado - Tec_8 , almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec8;			//Ve aconvertir a ASCII la tecla 8

			movlw Tec_9; 			//Mueve la constante tecla 9 a W
			subwf Var_teclado,W;	//Resta la variable teclado - Tec_9, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec9;			//Ve aconvertir a ASCII la tecla 9

			movlw Tec_A; 			//Mueve la constante tecla A a W
			subwf Var_teclado,W;	//Resta la variable teclado - Tec_A, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_TecA;			//Ve aconvertir a ASCII la tecla 9
			

;----------------------------------------------------------------------------------------------------------
renglon_2		
			bsf portb,Act_Ren1; 	//Desactiva el reglon 1 del teclado matricial
			nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
			bcf	portb,Act_Ren2;		//Activa reglon 2 del teclado matricial
			movf portb,w;			//Mueve el contenido del puerto B a el registro W
			movwf Var_teclado; 		//Mueve el contenido a la variable teclado
			movlw 0XF0;				//Enmascaramiento
			andwf Var_teclado,f; 	//Enmascaramiento
			movlw No_haytecla;		//mueve la variable no hay tecla a W
			subwf Var_teclado,W;	//Resta la variable teclado - No hay tecla(F0), almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto renglon_3;			//Ve a barrer el reglon 3
		
			movlw Tec_4; 			//Mueve la constante tecla 4 a W
			subwf Var_teclado,W;	//Resta la variable teclado - Tec_4, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec4;			//Ve aconvertir a ASCII la tecla 4
		
			movlw Tec_5; 			//Mueve la constante tecla 5 a W
			subwf Var_teclado,W;	//Resta la variable teclado - tecla 5, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec5;			//Ve aconvertir a ASCII la tecla 5

			movlw Tec_6; 			//Mueve la constante tecla 6 a W
			subwf Var_teclado,W;	//Resta la variable teclado - tecla 6, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec6;			//Ve aconvertir a ASCII la tecla 6

			movlw Tec_B; 			//Mueve la constante tecla B a W
			subwf Var_teclado,W;	//Resta la variable teclado - tecla B, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_TecB;			//Ve aconvertir a ASCII la tecla B

			
;----------------------------------------------------------------------------------------------------------
renglon_3			
			bsf portb,Act_Ren2; 	//Desactiva el reglon 2 del teclado matricial
			nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
			bcf	portb,Act_Ren3;		//Activa reglon 3 del teclado matricial
			movf portb,w;			//Mueve el contenido del puerto B a el registro W
			movwf Var_teclado; 		//Mueve el contenido a la variable teclado
			movlw 0XF0;				//Enmascaramiento
			andwf Var_teclado,f; 	//Enmascaramiento
			movlw No_haytecla;		//mueve la variable no hay tecla a W
			subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto renglon_4;			//Ve a barrer el reglon 2
		
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

			movlw Tec_C; 			//Mueve la constante tecla C a W
			subwf Var_teclado,W;	//Resta la variable teclado - tecla 3, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_TecC;			//Ve aconvertir a ASCII la tecla C


;----------------------------------------------------------------------------------------------------------
renglon_4	bsf portb,Act_Ren3; 	//Desactiva el reglon 3 del teclado matricial
			nop;					//No operacion,para activar/desactivar dos bits consecutivamnete se requiere un nop entre ellos
			bcf	portb,Act_Ren4;		//Activa reglon 4 del teclado matricial
			movf portb,w;			//Mueve el contenido del puerto B a el registro W
			movwf Var_teclado; 		//Mueve el contenido a la variable teclado
			movlw 0XF0;				//Enmascaramiento
			andwf Var_teclado,f; 	//Enmascaramiento
			movlw No_haytecla;		//mueve la variable no hay tecla a W
			subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto barre_teclado;		//Ve a barrer el reglon 1
		
			movlw Tec_clear; 		//Mueve la constante tecla asterisco a W
			xorwf Var_teclado,W;	//Resta la variable teclado - tecla asterisco, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tecclear;		//Ve aconvertir a ASCII la tecla asterisco
		
			movlw Tec_0; 			//Mueve la constante tecla 0 a W
			xorwf Var_teclado,W;	//Resta la variable teclado - tecla 0, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tec0;			//Ve aconvertir a ASCII la tecla 0

			movlw Tec_gato; 		//Mueve la constante tecla gato a W
			xorwf Var_teclado,W;	//Resta la variable teclado - tecla gato, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_Tecgato;		//Ve aconvertir a ASCII la tecla gato

			movlw Tec_D; 			//Mueve la constante tecla D a W
			xorwf Var_teclado,W;	//Resta la variable teclado -tecla D, almacena en W
			btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
			goto Fue_TecD;			//Ve aconvertir a ASCII la tecla D
			call retardo_40ms;
			goto barre_teclado;

Fue_Tec0	movlw 0x00;				//Mueve la constante 0 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado; 	//Sal de la subrutina barre teclado
Fue_Tec1	movlw 0x01;				//Mueve la constante 1 en ASCII a w
			movwf Var_tecopri;		//Mueve el contenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subrutina barre teclado
Fue_Tec2	movlw 0x02;				//Mueve la constante 2 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec3	movlw 0x03;				//Mueve la constante 3 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec4	movlw 0x04;				//Mueve la constante 4 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec5	movlw 0x05;				//Mueve la constante 5 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec6	movlw 0x06;				//Mueve la constante 6 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec7	movlw 0x07;				//Mueve la constante 7 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec8	movlw 0x08;				//Mueve la constante 8 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec9	movlw 0x09;				//Mueve la constante 9 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecA	movlw 0x0A;				//Mueve la constante A en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecB	movlw 0x0B;				//Mueve la constante B en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecC		movlw 0X0C;				//Mueve la constante C en ASCII a w	
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecD	movlw 0X0D;				//Mueve la constante D en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tecgato	movlw 0x0E;				//Mueve la constante # en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tecclear	
			movlw 0x0F;				//Mueve la constante # en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
		
sal_barreteclado return;			//Sal de la subrutina de barrido de teclado
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
convhex_ascii
		 	movlw .0;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 0 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_0;			//Cambia 0x00 a 0 en ASCII para mostrarlo en la LCD	
		 	movlw .1;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 1 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_1;			//Cambia 0x01 a 1 en ASCII para mostrarlo en la LCD	
		 	movlw .2;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 2 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_2;			//Cambia 0x02 a 2 en ASCII para mostrarlo en la LCD	
		 	movlw .3;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 3 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_3;			//Cambia 0x03 a 3 en ASCII para mostrarlo en la LCD	
		 	movlw .4;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 4 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_4;			//Cambia 0x04 a 4 en ASCII para mostrarlo en la LCD	
		 	movlw .5;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 5 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_5;			//Cambia 0x05 a 5 en ASCII para mostrarlo en la LCD	
		 	movlw .6;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 6 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_6;			//Cambia 0x06 a 6 en ASCII para mostrarlo en la LCD	
		 	movlw .7;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 7 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_7;			//Cambia 0x07 a 7 en ASCII para mostrarlo en la LCD	
		 	movlw .8;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 8 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_8;			//Cambia 0x08 a 8 en ASCII para mostrarlo en la LCD	
		 	movlw .9;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 9 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_9;			//Cambia 0x09 a 9 en ASCII para mostrarlo en la LCD	
		 	movlw .10;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 10 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_A;			//Cambia 0x0A a A en ASCII para mostrarlo en la LCD	
		 	movlw .11;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 11 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_B;			//Cambia 0x0B a B en ASCII para mostrarlo en la LCD	
		 	movlw .12;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 12 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_C;			//Cambia 0x0C a C en ASCII para mostrarlo en la LCD	
		 	movlw .13;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 13 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_D;			//Cambia 0x0D a D en ASCII para mostrarlo en la LCD	
		 	movlw .14;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 14 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_E;			//Cambia 0x0E a E en ASCII para mostrarlo en la LCD	
		 	movlw .15;			//Fija en w la constante a comparar con temporal
			subwf temporal,w;	//Compara la variable temporal con w mediante una resta
			btfsc status,z;		//Verifica que Z no sea 15 si lo es ve a convertir a ASCII de lo contrario revisa el siguiente valor
			goto fue_F;			//Cambia 0x0F a F en ASCII para mostrarlo en la LCD	
			goto sal_convhex_ascii;	//Sal de la subruitna de convertir hexadecimal a ASCII


fue_0		movlw '0';			//Coloca el valor ASCII 0
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_1		movlw '1';			//Coloca el valor ASCII 1
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_2		movlw '2';			//Coloca el valor ASCII 2
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_3		movlw '3';			//Coloca el valor ASCII 3
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII	
fue_4		movlw '4';			//Coloca el valor ASCII 4
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_5		movlw '5';			//Coloca el valor ASCII 5
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_6		movlw '6';			//Coloca el valor ASCII 6
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_7		movlw '7';			//Coloca el valor ASCII 7
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_8		movlw '8';			//Coloca el valor ASCII 8
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_9		movlw '9';			//Coloca el valor ASCII 9
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_A		movlw 'A';			//Coloca el valor ASCII A
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_B		movlw 'B';			//Coloca el valor ASCII B
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_C		movlw 'C';			//Coloca el valor ASCII C
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCII
fue_D		movlw 'D';			//Coloca el valor ASCII D
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCI
fue_E		movlw 'E';			//Coloca el valor ASCII E
			movwf temporal;		//en el registro temporal que se mostrara en el LCD
			goto sal_convhex_ascii;//Sal de la subruitna de convertir hexadecimal a ASCI
fue_F		movlw 'F';			//Coloca el valor ASCII F
			movwf temporal;		//en el registro temporal que se mostrara en el LCD

sal_convhex_ascii
			return;


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
				movf Buffer5x,w;			//Mover la constante del buffer 5 a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x86;					//Comando de apuntador en el LCD digito 7
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer6x,w;				//Mover la constante del buffer 6 a W
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
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			
				movlw 0x8F;					//Comando de apuntador en el LCD digito 16
				movwf portc;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferF,w;				//Mover la constante del buffer E a W
				movwf portc;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD


			
				movlw 0xC0;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 1 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer0DO,w;			//Enviar el contenido de buffer 11			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xC1;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 2 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer1DO,w;			//Enviar el contenido de buffer 12			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xC2;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 3 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer2DO,w;			//Enviar el contenido de buffer 13		
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0xC3;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 4 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer3DO,w;			//Enviar el contenido de buffer 14			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0xC4;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 5 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer4DO,w;			//Enviar el contenido de buffer 15			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0xC5;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 6 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf buffer5DO,w;			//Enviar el contenido de buffer 5DO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xC6;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 7 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf buffer6DO,w;			//Enviar el contenido de buffer6DO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xC7;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 8 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf buffer7DO,w;			//Enviar el contenido de buffer7DO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xC8;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 9 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf buffer8DO,w;			//Enviar el contenido de buffer8DO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xC9;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 10 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf buffer9DO,w;			//Enviar el contenido de buffer9DO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xCA;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 11 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf bufferADO,w;			//Enviar el contenido de buffer9DO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD3

				movlw 0xCB;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 12 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf bufferBDO,w;			//Enviar el contenido de bufferBDO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xCC;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 13 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf bufferCDO,w;			//Enviar el contenido de bufferCDO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xCD;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 14 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf bufferDDO,w;			//Enviar el contenido de bufferDDO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xCE;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 15 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf bufferEDO,w;			//Enviar el contenido de bufferEDO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

				movlw 0xCF;					//Comando de apuntador en el 
				movwf portc;				//en el LCD digito 16 2do reglón
				call pulso_enable;			//Subrutina de pulso que permite el ingreso de  datos al LCD
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf bufferFDO,w;			//Enviar el contenido de bufferFDO			
				movwf portc;				//al bus de datos/comandos con la LCD
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bcf porta,RS_LCD; 			//Pone en modo comando al LCD

		

				return;						//Regreso al programa principal
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

retardo_250ms	clrf cont_milis;			//Limpia el registro cont milis	
loop_250		movlw .250;				//Mueve la constante 41 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS si es igual a 1 salta de lo contrario ejecuta normalmente
				goto loop_250;			//Ve para la etiqueta loop_41ms
			
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
				;==============================
				;==Subrutina de retardo de 5s=
				;==============================

espera_5s



loopseg			clrf cont_milis;		//Limpia el registro cont milis
				incf reg5s;	
loop_int			movlw .250;				//Mueve la constante 250 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS si es igual a 1 salta de lo contrario ejecuta normalmente
				goto loop_int;			//Ve para la etiqueta loop250
				
				movlw .9;				//Mueve la constante 250 al registro de trabajo
				subwf ,w;				//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS si es igual a 1 salta de lo contrario ejecuta normalmente
				goto loopseg;			//Ve para la etiqueta loop250

				return;					//regresa de la subrutina

;----------------------------------------------------------------------------------------------------------







end										//Fin del programa









			
