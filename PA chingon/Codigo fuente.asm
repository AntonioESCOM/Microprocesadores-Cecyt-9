;INSTITUTO POLITECNICO NACIONAL
;CECYT 9 JUAN DE DIOS BATIZ
;
;PROYECTO AULA Sonnenblume 
;
;Hernández Oropeza Andrés 
;Jiménez Jaimes Karla Lilú 
;Morales Martínez José Antonio
;Ramírez Sologuren Samantha Montserrat
;Vertiz Romero Daniel Alejandro
;
;GRUPO:6IM2
;
;PROGRAMA QUE SE ENCARGA DE CONTROLAR UN MOTOR A PASOS MEDIANTES UN DISPOSITIVO BLUETOOTH 
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
presc_1			equ			0x33;	//T int= T interrupcion(0.001s)*presc_1 
presc_2			equ			0x34;	//T int= T interrupcion(0.001s)*presc_1*presc_2 
banderas		equ			0x35;	//Registro en donde se definen bits banderas 
cont_milis		equ			0x36;	//Registro que lleva la cuenta de las unidades de milisegundos 
buffer5		   	equ			0x39;	//Dirección de la memoria RAM para el buffer 5.
buffer4 		equ			0x40;	//Dirección de la memoria RAM para el buffer 4.
buffer3			equ			0x41;	//Dirección de la memoria RAM para el buffer 3.
buffer2 		equ			0x42;	//Dirección de la memoria RAM para el buffer 2.
buffer1  		equ			0x43;	//Dirección de la memoria RAM para el buffer 1.
buffer0  		equ			0x44;	//Direcció³n de la memoria RAM para el buffer 0.
Var_teclado 	equ			0x45;	//Guardar el codigo de la tecla activa sobre el puerto B.
Var_tecopri		equ			0x46;	//Regresar el codigo ASCII de la tecla oprimida.
Var_tecbin		equ 		0x47;	//Guarda el valor de la tecla oprimida en binario.
buffer6  		equ			0x48;	//Dirección de la memoria RAM para el buffer 6.
buffer7  		equ			0x49;	//Dirección de la memoria RAM para el buffer 7.
buffer8  		equ			0x50;	//Dirección de la memoria RAM para el buffer 8.
buffer9  		equ			0x51;	//Dirección de la memoria RAM para el buffer 9.
bufferA  		equ			0x52;	//Dirección de la memoria RAM para el buffer A.
bufferB  		equ			0x53;	//Dirección de la memoria RAM para el buffer B.
bufferC  		equ			0x54;	//Dirección de la memoria RAM para el buffer C.
bufferD  		equ			0x55;	//Dirección de la memoria RAM para el buffer D.
bufferE  		equ			0x56;	//Dirección de la memoria RAM para el buffer E.
bufferF			equ			0x57;	//Dirección de la memoria RAM para el buffer F.
cont_señal  	equ 		0x58;
auxiliar		equ			0x59;


;-----------------------------------------------------------------------------------------------------
;Constantes

No_haytecla		equ 		0x07;	//Esta constante desctiva todos los reglones y no habrá tecla en la entrada
No_haylluv		equ			0x0B

IZQUIERDA		equ			0x06;	//Esta costante representa a la tecla "1" 
STOP			equ			0x00;	//Esta costante representa a la tecla "2"
DERECHA			equ			0X03;	//Esta costante representa a la tecla "3"
auxiliar		equ			0x00;	//Esta costante representa a la tecla "A"
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

;Asigancion de los bits de los puertos de I/O.

; Puerto A.
RS_LCD		        	equ     .0;	//BIT RS DE LA LCD
Enable_LCD          	equ     .1;	//BIT ENABLE DE LA LCD
Sin_UsoRA2         		equ     .2; //Terminal A del motor a pasos
Sens_lluv 	         	equ     .3; //Terminal B del motor a pasos
Sin_UsoRA4             	equ     .4;	//Terminal C del motor a pasos
Sin_UsoRA5     	    	equ     .5; //Terminal D del motor a pasos

progA                   equ 	B'111100'	;Programacion inicial del puerto A.

;Puerto B.
D0_LCD		            equ     .0;	 	//Bit D0 de la LCD.
D1_LCD		            equ     .1; 	//Bit D1 de la LCD.
D2_LCD		            equ     .2; 	//Bit D2 de la LCD.
D3_LCD		            equ     .3; 	//Bit D3 de la LCD.
D4_LCD		            equ     .4; 	//Bit D4 de la LCD.
D5_LCD		            equ     .5; 	//Bit D5 de la LCD.
D6_LCD		            equ     .6; 	//Bit D6 de la LCD.
D7_LCD		            equ     .7; 	//Bit D7 de la LCD.

progb                   equ b'00000000'; // Programación inicial del puerto B.

;Puerto C.
Sin_UsoRC0		            equ     .0;	 	//Bit D0 de la LCD.
Sin_UsoRC1		            equ     .1; 	//Bit D1 de la LCD.
Sin_UsoRC2		            equ     .2; 	//Bit D2 de la LCD.
Sin_UsoRC3		            equ     .3; 	//Bit D3 de la LCD.
Sin_UsoRC4		            equ     .4; 	//Bit D4 de la LCD.
Sin_UsoRC5		            equ     .5; 	//Bit D5 de la LCD.
BIT_TOÑO		            equ     .6; 	//Bit D6 de la LCD.
BIT_TOÑO2		            equ     .7; 	//Bit D7 de la LCD.

progc                   equ b'11111111'; // Programación inicial del puerto C 
                                                                 
;Puerto D.
Term_A            		equ     .0;
Term_B           	 	equ     .1;
Term_C           	 	equ     .2;
Term_D           	 	equ     .3;
Sin_UsoRD4              equ     .4;
Sin_UsoRD5              equ     .5;
Sin_UsoRD6              equ     .6;
Sin_UsoRD7              equ     .7;

progD                   equ B'00000000'; // Programación inicial del puerto D

; Puerto E.
BOTON_IZQ              equ     .0;
BOTON_STOP	           equ     .1;
BOTON_DER              equ     .2;

progE                   equ B'111';  	// Programación inicial del puerto e
;-------------------------------------------------------------------------------------------------

						;================
						;==Vector Reset==
						;================
				org 0x0000;
vec_reset			
				clrf PCLATH;
				goto prog_prin;
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
				MOVLW	.25; BAUDIOS 9600
|				MOVWF	SPBRG;
				BCF	TXSTA,4; ASINCRONO
				BSF	TXSTA,2; LOW SPEED
				BCF	TXSTA,6; 8 BITS
				BSF	TXSTA,5; HABILITA TX
				BSF	PIE1,RCIE; HABILITA INT RX
				CLRF	TRISD; SALIDA
				BCF	STATUS,RP0;
				BSF	RCSTA,7; RX Y TX
				BSF	RCSTA,4; HABILITA RX
				BCF	RCSTA,6; 8 BITS
				BCF	PIR1,RCIF; LIMPIAMOS FLAG RX
			
                movlw 0xa0;				// Habilita la interrupcion del TMR0, Las globales y borra las banderas de interrupción 
                movwf intcon;			//Mover el contenido del registro de trabajo al registro intcon
                movlw .131;				//Mover la constante 131 al registro de trabajo
                movwf tmr0;				//Carga a tmr0 la constante 131 desde donde iniciará la cuenta

				clrf portb;				//Limpia el registro portc
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
				clrf portb;				//LImpia el registro del puerto D
				clrf portd;				//LImpia el registro del puerto D

			  	return;					//Regresa de la subrutina de inicializacion
;----------------------------------------------------------------------------------------------------------

                      					  ;===========================================
                    					  ;== Subrutina de inicializacion de la LCD ==
                     					  ;===========================================

ini_lcd					bcf porta,RS_LCD;		//Pone en modo comando a la LCD

						movlw 	0x38;			//
						movwf	portb;			//
						call	pulso_enable;	//Llama a la subrutina de pulso Enable
						movlw 	0x01;			//Borra el texto y dirige el cursor al primer digito
						movwf	portb;			//Cargar el puerto C con W
						call	pulso_enable;	//Llama a la subrutina de pulso Enable
						movlw 	0x06;			//
						movwf	portb;			//Cargar el puerto C con W
						call	pulso_enable;	//Llama a la subrutina de pulso Enable
						movlw	0x0c;
						movwf   portb;
						call 	pulso_enable;
						movlw 	0x80;			//Coloca el cursor en el primer digito
						movwf	portb;			//Cargar el puerto C con W
						call	pulso_enable;	//Llama a la subrutina de pulso Enable
						
						bsf		porta,RS_LCD;	//Pone en modo datos a la LCD
	
						return;					//Regresa de la subrutina

;-------------------------------------------------------------------------------------------------------------------------------
											;======================
											;==Programa Principal==
											;======================


prog_prin		call prog_ini;			//Llamada a la subrutina de inicio 		
				call ini_lcd;			//Llama a la subrutina de inicializacion del LCD

		
				movlw 0x00;
				movwf buffer1;
				movwf buffer2;
				movwf bufferD;
				movwf bufferE;
				movlw 'B';				//Mueve el caracter G en ASCII a el registro W
				movwf buffer3;			//Mueve el caracter G a el buffer2
				movlw 'I';				//Mueve el caracter E en ASCII a el registro W
				movwf buffer4;			//Mueve el caracter E a el buffer3.
				movlw 'E';				//Mueve el caracter N en ASCII a el registro W
				movwf buffer5;			//Mueve el caracter N a el buffer4
				movlw 'N';				//Mueve el caracter E en ASCII a el registro W
				movwf buffer6;			//Mueve el caracter E a el buffer5
				movlw 'V';				//Mueve el caracter R en ASCII a el registro W
				movwf buffer7;			//Mueve el caracter R a el buffer6
				movlw 'E';				//Mueve el caracter A en ASCII a el registro W
				movwf buffer8;			//Mueve el caracter A a el buffer7
				movlw 'N';				//Mueve el caracter D en ASCII a el registro W
				movwf buffer9;			//Mueve el caracter D a el buffer8
				movlw 'I';				//Mueve el caracter O en ASCII a el registro W
				movwf bufferA;			//Mueve el caracter O a el buffer9
				movlw 'D';				//Mueve el caracter R en ASCII a el registro W
				movwf bufferB;			//Mueve el caracter R a el buffer A
				movlw 'O';				//Mueve el caracter F en ASCII a el registro W
				movwf bufferC;			//Mueve el caracter F a el buffer C
	 			call muestra_caracter;

loop_serial		btfss PIR1,RCIF;
				goto loop_serial;
				movf RCREG,W;	
				XORLW 'A';
				btfss status,z;
				goto loop_serial;
				bsf portd,Sin_UsoRD7;
				call retardo_motor;
				bcf PIR1,RCIF;			//Se limpia la bandera de la interrupción 
				bcf portd,Sin_UsoRD7;
				goto loop_serial;





loop_prin	
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw IZQUIERDA; 			//Mueve la constante tecla 1 a W
				xorwf Var_teclado,W;	//Resta la variable teclado - tecla 1, almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				call MUEVE_IZQ;			//Ve aconvertir a ASCII la tecla 1
		
				movlw STOP; 			//Mueve la constante tecla 2 a W
				xorwf Var_teclado,W;	//Resta la variable teclado - tecla 2, almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto ver_again;			//Ve aconvertir a ASCII la tecla 2

				movlw DERECHA; 			//Mueve la constante tecla 3 a W
				xorwf Var_teclado,W;	//Resta la variable teclado - tecla 3, almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				call MUEVE_DER;			//Ve aconvertir a ASCII la tecla 3

				
				
				
ver_again		call lluvia;
				goto loop_prin;


;----------------------------------------------------------------------------------------------------------

						;===================================================
						;   ==Subrutina que mueve el motor a la izquierda ==
						;===================================================

MUEVE_IZQ					
				bsf  portd,Term_A; 	//Desactiva el reglon 2 del teclado matricial 
				call retardo_motor;
loop_izquierda	bsf  portd,Term_B;
				call retardo_motor;

				bcf  portd,Term_A;
				call retardo_motor;
				bsf  portd,Term_C;
				call retardo_motor;

				bcf  portd,Term_B;
				call retardo_motor;				
				bsf  portd,Term_D;
				call retardo_motor;

				bcf  portd,Term_C;
				call retardo_motor;
				bsf  portd,Term_A; 	//Desactiva el reglon 2 del teclado matricial 
				call retardo_motor;

				bcf  portd,Term_D
				call retardo_motor;

				call lluvia
				movf porte,w;			//Mueve el contenido del puerto B a el registro W
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw No_haytecla;		//mueve la variable no hay tecla a W
				xorwf Var_teclado,w;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
				btfsc status,z;	
				
				goto loop_izquierda;
				movwf Var_teclado;
				return;

;----------------------------------------------------------------------------------------------------------

						;===================================================
						;   ==Subrutina que mueve el motor a la derecha ==
						;===================================================

MUEVE_DER					
				bsf  portd,Term_A; 	//Desactiva el reglon 2 del teclado matricial 
				call retardo_motor;
loop_derecha	bsf  portd,Term_D;
				call retardo_motor;

				bcf  portd,Term_A;
				call retardo_motor;
				bsf  portd,Term_C;
				call retardo_motor;

				bcf  portd,Term_D;
				call retardo_motor;				
				bsf  portd,Term_B;
				call retardo_motor;

				bcf  portd,Term_C;
				call retardo_motor;
				bsf  portd,Term_A; 	//Desactiva el reglon 2 del teclado matricial 
				call retardo_motor;

				bcf  portd,Term_B
				call retardo_motor;
				call lluvia;	
			
				movf porte,w;			//Mueve el contenido del puerto B a el registro W
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw No_haytecla;		//mueve la variable no hay tecla a W
				xorwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
				btfsc status,z;				

				goto loop_derecha;
				movwf Var_teclado;
				return;


;----------------------------------------------------------------------------------------------------------

						;===========================
						;   ==Subrutina de lluvia ==
						;===========================

lluvia			movf porta,w;			//Mueve el contenido del puerto B a el registro W
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw No_haylluv;		//mueve la variable no hay tecla a W
				subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto adios;
				call corre;
				
trabate_loco	movf porta,w;			//Mueve el contenido del puerto B a el registro W
				movwf Var_teclado; 		//Mueve el contenido a la variable teclado
				movlw No_haylluv;		//mueve la variable no hay tecla a W
				subwf Var_teclado,W;	//Resta la variable teclado - Ni hay tecla(F0), almacena en W
				btfsc status,z; 		//Revisa el estado de la bandera Z si es 0 salta
				goto adios;
				goto trabate_loco;			//Ve a barrer el reglon 2

adios			return;

;----------------------------------------------------------------------------------------------------------

						;===================================================
						;   ==Subrutina que mueve corre ==
						;===================================================

corre			clrf auxiliar;		
				bsf  portd,Term_A; 	//Desactiva el reglon 2 del teclado matricial 
				call retardo_motorc;
repite			bsf  portd,Term_D;
				call retardo_motorc;
				bcf  portd,Term_A;
				call retardo_motorc;
				bsf  portd,Term_C;
				call retardo_motorc;
				bcf  portd,Term_D;
				call retardo_motorc;				
				bsf  portd,Term_B;
				call retardo_motorc;
				bcf  portd,Term_C;
				call retardo_motorc;
				bsf  portd,Term_A; 	//Desactiva el reglon 2 del teclado matricial 
				call retardo_motorc;
				bcf  portd,Term_B
				call retardo_motorc;
				
				incf auxiliar;			
				movlw .10;
				subwf auxiliar,w;
				btfss status,z;										ss-->  
				goto  repite;	
	

			
		
salint			return;

;----------------------------------------------------------------------------------------------------------

						;======================================================
						;   ==Subrutina que muestra los caracteres en la LCD ==
						;======================================================


muestra_caracter

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x80;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer0,w;				//Mover la constante del buffer 0 a W			
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x81;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer1,w;				//Mover la constante del buffer 1 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x82;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer2,w;				//Mover la constante del buffer 2 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x83;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer3,w;				//Mover la constante del buffer 3 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x84;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer4,w;				//Mover la constante del buffer 4 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x85;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer5,w;				//Mover la constante del buffer 5 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x86;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer6,w;				//Mover la constante del buffer 6 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x87;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer7,w;				//Mover la constante del buffer 7 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x88;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer8,w;				//Mover la constante del buffer 8 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x89;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf Buffer9,w;				//Mover la constante del buffer 9 a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8A;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferA,w;				//Mover la constante del buffer A a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8B;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferB,w;				//Mover la constante del buffer B a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8C;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferC,w;				//Mover la constante del buffer C a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8D;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferD,w;				//Mover la constante del buffer D a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable

				bcf porta,RS_LCD; 			//Pone en modo comando al LCD
				movlw 0x8E;					//Comando de apuntador en el display
				movwf portb;				//Mover el contenido del registro de trabajo al registro portc
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable
				bsf porta,RS_LCD; 			//Pone en modo datos al LCD
				movf BufferE,w;				//Mover la constante del buffer E a W
				movwf portb;				//Mover la constante al puerto C
				call pulso_enable;			//Llamada a la subrutina de Pulso Enable


				return;					//Regreso al programa principal



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
				;==Subrutina de retardo de 40ms=
				;==============================

retardo_40ms 	clrf cont_milis;		//Limpia el registro cont milis	
loop_40ms		movlw .40;				//Mueve la constante 40 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta
				goto loop_40ms;			//Ve para la etiqueta loop_40ms
			
				return;					//regresa de la subrutina

;----------------------------------------------------------------------------------------------------------

				;=================================
				;==Subrutina de retardo del motor=
				;=================================

retardo_motor	clrf cont_milis;		//Limpia el registro cont milis	
loop_50ms		movlw .50;				//Mueve la constante 40 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta
				goto loop_50ms;			//Ve para la etiqueta loop_40ms
			
				return;					//regresa de la subrutina

				;=================================
				;==Subrutina de retardo del motorc=
				;=================================

retardo_motorc	clrf cont_milis;		//Limpia el registro cont milis	
loop_30ms		movlw .30;				//Mueve la constante 40 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta
				goto loop_30ms;			//Ve para la etiqueta loop_40ms
			
				return;					//regresa de la subrutina



end