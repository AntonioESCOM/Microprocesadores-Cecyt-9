;INSTITUTO POLITECNICO NACIONAL
;CECYT 9 JUAN DE DIOS BATIZ
;
;PRACTICA 2 MULTIPLEXADO “MANEJO DE UN TECLADO MATRICIAL DE 4X4”.
;(ACTUALIZACIÓN DEL TIEMPO).
;
;GRUPO:6IM2
;
;INTEGRANTE
;Morales Martínez José Antonio
;
;El programa ejecutara un reloj en tiempo real mediante interrupciones un reloj en tiempo real
;con posible actualizacion por medio de un teclado matricial haciendo uso de la tecla c para entrar 
;y D para salir
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


cta_uniseg		equ			0x23;	//Registro que se encarga de llevar la cuenta de las unidades de segundo dentro de la subrutina de muestra_tiempo
cta_decseg		equ			0x24;	//Registro que se encarga de llevar la cuenta de las decenas de segundo dentro de la subrutina de muestra_tiempo
cta_unimin		equ			0x25;	//Registro que se encarga de llevar la cuenta de las unidades de minuto dentro de la subrutina de muestra_tiempo
cta_decmin  	equ			0x26;	//Registro que se encarga de llevar la cuenta de las decenas de minuto dentro de la subrutina de muestra_tiempo
cta_unihor		equ			0x27;	//Registro que se encarga de llevar la cuenta de las unidades de hora dentro de la subrutina de muestra_tiempo
cta_dechor  	equ			0x28;	//Registro que se encarga de llevar la cuenta de las decenas de hora dentro de la subrutina de muestra_tiempo

res_w		    equ 		0x29;	//Registro de resplado de la variable W en la subruitna de interrupción 
res_status		equ			0x30;	//Registro de resplado de la variable status en la subruitna de interrupción
res_pclath		equ			0x31;	//Registro de resplado de la variable pclath en la subruitna de interrupción
res_fsr			equ			0x32;	//Registro de resplado de la variable fsr en la subruitna de interrupción
presc_1			equ			0x33;	//T int= T interrupcion(0.001s)*presc_1 multiplica por un escalar al tiempo de interrupcion base
presc_2			equ			0x34;	//T int= T interrupcion(0.001s)*presc_1*presc_2 multiplica por un escalar al tiempo de interrupcion base 
banderas		equ			0x35;	//Registro en donde se definen bits banderas (bandera_c, bandera_D, bandera_clear)
cont_milis		equ			0x36;	//Registro que lleva la cuenta de las unidades de milisegundos (0-255)
buffer5		   	equ			0x39;	//Dirección de la memoria RAM para el buffer 5.
buffer4 		equ			0x40;	//Dirección de la memoria RAM para el buffer 4.
buffer3			equ			0x41;	//Dirección de la memoria RAM para el buffer 3.
buffer2 		equ			0x42;	//Dirección de la memoria RAM para el buffer 2.
buffer1  		equ			0x43;	//Dirección de la memoria RAM para el buffer 1.
buffer0  		equ			0x44;	//Dirección de la memoria RAM para el buffer 0.
Var_teclado 	equ			0x45;	//Guardar el codigo de la tecla activa sobre el puerto B.
Var_tecopri		equ			0x46;	//Regresar el codigo ASCII de la tecla oprimida.
Var_tecbin		equ 		0x47;	//Guarda el calor de la tecla oprimida en binario.



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

sig_int    clrf presc_1;			//Limpia el registro presc 1
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
				clrf cta_uniseg;		// Inicializa la cuenta de unidades de segundo a 0 
				clrf cta_decseg;		// Inicializa la cuenta de decenas de segundo a 0 
				clrf cta_unimin;		// Inicializa la cuenta de unidades de minutos a 0 
				clrf cta_decmin;		// Inicializa la cuenta de decenas de minutos a 0 
				clrf cta_unihor;		// Inicializa la cuenta de unidades de hora a 0
				clrf cta_dechor;		// Inicializa la cuenta de decenas de hora a 0
				clrf Var_tecopri;		//Limpia el registro Var_tecopri
				clrf Var_tecbin;		//Limpia el registro Var_tecbin
				clrf Var_teclado;		//Limpia el registro Var_teclado

				movlw 0X0F;				//Inicializa el teclado como No hay tecla
				movwf portb;			// Mueve el contenido de W al puerto B
			  	return;					//Regresa de la subrutina de inicializacion
;----------------------------------------------------------------------------------------------------------

				;======================
				;==Programa Principal==
				;======================
prog_prin		call prog_ini;			//Llamada a la subrutina de inicio 
				call ini_lcd;			//Llama a la subrutina de inicializacion del LCD
			

loop_prin			call cuenta_time;		//Llama a la subrutina de cuenta time, (reloj en tiempo real)
				call config_time;		//Llama a la subrutina de actualizacion del tiempo
				goto loop_prin;			//Crea el loop principal
;---------------------------------------------------------------------------------------------------------------------------

			;================================================
			;==Subrutina de cuenta tiempo ==================
			;================================================

cuenta_time		
				bsf portb,Act_Ren4;	//Desactiva el reglon 4 del teclado.
				bcf portb,Act_Ren3;	//Activa el reglon 3 del teclado.
				bsf portb,Act_Ren2; //Desactiva el reglon 2 del teclado.
				bsf portb,Act_Ren1;	//Desactiva el reglon 1 del teclado.
				btfss portb,col_4;	//Realiza un chequeo de la tecla C.  
				goto sal_loco;		//Sale de la subrutina.

				call rectifica;		//Llamada a la subrutina que rectifica que no sean las 24hras si lo son reinicia

				movf cta_uniseg,w;	//Mover el contenido del registro cta unidades de segundo a el registro de trabajo 
				movwf buffer0;		//Mover el contenido del registro de trabajo al buffer 0

				movf cta_decseg,w;	//Mover el contenido del registro cta decenas de segundo a el registro de trabajo
				movwf buffer1;		//Mover el contenido del registro de trabajo al buffer 

				movf cta_unimin,w;	//Mover el contenido del registro cta unidades de minuto a el registro de trabajo
				movwf buffer2;		//Mover el contenido del registro de trabajo al buffer 2

				movf cta_decmin,w;	//Mover el contenido del registro cta decenas de minuto a el registro de trabajo
				movwf buffer3;		//Mover el contenido del registro de trabajo al buffer 3

				movf cta_unihor,w;	//Mover el contenido del registro cta unidades de hora a el registro de trabajo
				movwf buffer4;		//Mover el contenido del registro de trabajo al buffer 4

				movf cta_dechor,w;	//Mover el contenido del registro cta decenas de hora a el registro de trabaj
				movwf buffer5;		//Mover el contenido del registro de trabajo al buffer 5
				
				call muestra_time;	//Llamada a la subrutina de muestra mensaje 

;----------------------------------------------------------------------------------------------------------
			
			incf cta_uniseg,f;		//Incrementa la variable cta unidades de segundo y guarada en el mismo registro
			movlw .10;				//Mueve la constante 10 al registro de trabajo 
			subwf cta_uniseg,w;		//Resta la variable cta unidades de segundo menos el contenido del registro de trabajo guarada en w
			btfss status,Z;			//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion 
			goto cuenta_time;		//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo 
 
			incf cta_decseg,f;		//Incrementa la variable cta decenas de segundo y guarada en el mismo registro
			movlw .6;				//Mueve la constante 6 al registro de trabajo 
			subwf cta_decseg,w;		//Resta la variable cta decenas de segundo menos el contenido del registro de trabajo guarda en w	
			btfss status,Z;			//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion 
			goto cuenta_time;		//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo 
			clrf cta_decseg;		//Reinicia el contenido de las decenas de segundo 
				
			incf cta_unimin,f;		//Incrementa la variable cta unidades de min y guarada en el mismo registro
			movlw .10;				//Mueve la constante 10 al registro de trabajo 
			subwf cta_unimin,w;		//Resta la variable cta unidades de min menos el contenido del registro de trabajo guarda en w
			btfss status,Z;			//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion	
			goto cuenta_time;		//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;		//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;		//Reinicia el contenido de las unidades de minutos 

			incf cta_decmin,f;		//Incrementa la variable cta decenas de min y guarada en el mismo registro
			movlw .6;				//Mueve la constante 6 al registro de trabajo 
			subwf cta_decmin,w;		//Resta la variable cta decenas de minutos menos el contenido del registro de trabajo guarda en 
			btfss status,Z;			//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion
			goto cuenta_time;		//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;		//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;		//Reinicia el contenido de las unidades de minutos 
			clrf cta_decmin;		//Reinicia el contenido de las decenas de minutos 

			incf cta_unihor,f;		//Incrementa la variable cta unidades de hora y guarada en el mismo registro
			movlw .10;				//Mueve la constante 10 al registro de trabajo 
			subwf cta_unihor,w;		//Resta la variable cta unidades de hora menos el contenido del registro de trabajo guarda en w
			btfss status,Z;			//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion
			goto cuenta_time;		//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;		//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;		//Reinicia el contenido de las unidades de minutos 
			clrf cta_decmin;		//Reinicia el contenido de las decenas de minutos 
			clrf cta_unihor;		//Reinicia el contenido de las unidades de hora 

			incf cta_dechor,f;		//Incrementa la variable cta decenas de hora y guarada en el mismo registro
			movlw .3;				//Mueve la constante 3 al registro de trabajo
			subwf cta_dechor,w;		//Resta la variable cta decenas de hora menos el contenido del registro de trabajo guarda en w
			btfss status,Z;			//Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion
			goto cuenta_time;		//Ve para la etiqueta cuenta_time
			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;		//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;		//Reinicia el contenido de las unidades de minutos 
			clrf cta_decmin;		//Reinicia el contenido de las decenas de minutos
			clrf cta_unihor;		//Reinicia el contenido de las unidades de hora 
			clrf cta_dechor;		//Reinicia el contenido de las decenas de hora
			goto cuenta_time;		//Ve para la etiqueta cuenta_time	

sal_loco	return;					//Regresa de la subrutina de cuenta del tiempo 

;----------------------------------------------------------------------------------------------------------

			;====================================================
			;==Subrutina que rectifica =
			;====================================================

rectifica 	movlw .2;				//Cargar la constante 2 representa la cantidad de decenas de hora
			subwf cta_dechor,w;	 	//Resta entre el registro cta_dechor menos el registro de trabajo
			btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta,de lo contrario ejecuta normalmente
			goto sal_rectifica;		//ve para la salida de la subrutina rectifica

			movlw .4;				//Cargar la constante 4 representa la cantidad de decenas de hora
			subwf cta_unihor,w;  	//Resta entre el contenido del registro cta_unihor menos el registro de trabajo
			btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta,de lo contrario ejecuta normalmente
			goto sal_rectifica;		//ve para la salida de la subrutina rectifica 


			clrf cta_uniseg;		//Reinicia el contenido de las unidades de segundo
			clrf cta_decseg;		//Reinicia el contenido de las decenas de segundo
			clrf cta_unimin;		//Reinicia el contenido de las unidades de minuto
			clrf cta_decmin;		//Reinicia el contenido de las decenas de minutos
			clrf cta_unihor;		//Reinicia el contenido de las unidades de hora 
			clrf cta_dechor;		//Reinicia el contenido de las decenas de hora

sal_rectifica	
			return;		//sal de la subrutina rectifica		

;----------------------------------------------------------------------------------------------------------

			;================================================
			;==Subrutina de muestra mensajes en el display ==
			;================================================

muestra_time 
			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x84;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 		//Pone en modo datos al LCD
			movlw 0x30;				//Cargar constante 30h a W
			addwf buffer5,w;		//Sumar 30h al valor del buffer 5 para pasar el valor numerico a ASCII
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable

			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x85;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 		//Pone en modo datos al LCD
			movlw 0x30;				// Cargar constante 30h a w
			addwf buffer4,w;		//Sumar 30h al valor del buffer 4 para pasar el valor numerico a ASCII
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable


			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x86;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD;	 	//Pone en modo datos al LCD
			movlw 0x3A;				// Cargar constante 3Ah, dos puntos en ascii
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
				

			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x87;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 		//Pone en modo datos al LCD
			movlw 0x30;				// Cargar constante 30h
			addwf buffer3,w;		//Sumar 30h al valor del buffer 3 para pasar el valor numerico a ASCII
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable

			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x88;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD;	 	//Pone en modo datos al LCD
			movlw 0x30;				// Cargar constante 30h
			addwf buffer2,w;		//Sumar 30h al valor del buffer 2 para pasar el valor numerico a ASCII
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable

			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x89;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 		//Pone en modo datos al LCD
			movlw 0x3A;				// Cargar constante 3Ah, dos puntos en ascii
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable

			bcf porta,RS_LCD; 		// Pone en modo comando al LCD
			movlw 0x8A;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 		//Pone en modo datos al LCD
			movlw 0x30;				//Cargar constante 30h
			addwf buffer1,w;		//Sumar 30h al valor del buffer 1 para pasar el valor numerico a ASCII
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable

			bcf porta,RS_LCD; 		//Pone en modo comando al LCD
			movlw 0x8B;				//Comando de ubicacion del apuntador en el display
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 		//Pone en modo datos al LCD
			movlw 0x30;				//Cargar constante 30h
			addwf buffer0,w;		//Sumar 30h al valor del buffer 0 para pasar el valor numerico a ASCII
			movwf portc;			//Mover el contenido del registro de trabajo al registro del puerto c
			call pulso_enable;		//Llamada a la subrutina de Pulso Enable

esp_int		nop;					//No operacion 
			
 			btfss banderas,ban_int; //Si la bandera Z esta en 1 salta, si no ejecuta la siguiente instruccion 
			goto esp_int;			//Ve para la etiqueta esp_int
			bcf banderas,ban_int;	//Pon a 0 el bit ban_int del registro banderas
			return;					//regresa de la subrutina 

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

Fue_Tec0	movlw '0';				//Mueve la constante 0 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .0;				//Mueve la constante 0 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado; 	//Sal de la subrutina barre teclado
Fue_Tec1	movlw '1';				//Mueve la constante 1 en ASCII a w
			movwf Var_tecopri;		//Mueve el contenido de w a la variable Var_tecopri
			movlw .1;				//Mueve la constante 1 en Binario a w
			movwf Var_tecbin;		//Mueve elcontenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subrutina barre teclado
Fue_Tec2	movlw '2';				//Mueve la constante 2 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .2;				//Mueve la constante 2 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec3	movlw '3';				//Mueve la constante 3 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .3;				//Mueve la constante 3 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec4	movlw '4';				//Mueve la constante 4 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .4;				//Mueve la constante 4 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec5	movlw '5';				//Mueve la constante 5 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .5;				//Mueve la constante 5 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec6	movlw '6';				//Mueve la constante 6 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .6;				//Mueve la constante 6 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec7	movlw '7';				//Mueve la constante 7 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .7;				//Mueve la constante 7 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec8	movlw '8';				//Mueve la constante 8 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .8;				//Mueve la constante 8 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tec9	movlw '9';				//Mueve la constante 9 en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .9;				//Mueve la constante 9 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecA	movlw 'A';				//Mueve la constante A en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .10;				//Mueve la constante 10 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecB	movlw 'B';				//Mueve la constante B en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .11;				//Mueve la constante 11 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecC	movlw 'C';				//Mueve la constante C en ASCII a w	
			movlw .12;				//Mueve la constante 12 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_TecD	movlw 'D';				//Mueve la constante D en ASCII a w
			bsf banderas,bandera_D;	//Pon a 1 la bandera D 
			movlw .13;				//Mueve la constante 13 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tecgato	movlw '#';				//Mueve la constante # en ASCII a w
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
			movlw .14;				//Mueve la constante 14 en Binario a w
			movwf Var_tecbin;		//Mueve el contenido de w a la variable Var_tecbin
			goto sal_barreteclado;	//Sal de la subruitan barre teclado
Fue_Tecclear	
			bsf banderas,bandera_clear;//Pon a 1 la bandera clear
			movwf Var_tecopri;		//Mueve elcontenido de w a la variable Var_tecopri
		
sal_barreteclado return;			//Sal de la subrutina de barrido de teclado
;----------------------------------------------------------------------------------------------------------

	;================================================
	;   ==Subrutina de congiguración del tiempo==
	;================================================

config_time
			nop;						//No operación 
Decenas_hora
			bcf banderas,bandera_teclado;// pone a 0 la bandera teclado
			call barre_teclado;			//Llamada a la subrutina de barre teclado que nos regresa un valor en ASCII y otro en binario
			btfsc banderas,bandera_d;	//Revisa el estado de la bandera D si es 1 sale de la subrutina de config_time
			goto sal_configtime;		//Salida de la subrutina configuracion del tiempo

			btfsc banderas,bandera_clear;//Revisa el estado de la bandera clear si es 1 va a borrar el LCD
			goto borra_lcd;				//Ve a borrar el contenidod de la LCD
 
			movf Var_tecbin,w;			//Mueve el contenido de Var_tecbin a w
			movwf cta_dechor;			//Mueve el contenido de w a cta_dechor
			call rectifica_tecla;		//Llamada a la subrutina que rectifica que la tecla oprimida sea correcta
			btfsc banderas,bandera_teclado;//Revisa el estado de la bandera teclado si es 1 regresa a escanear las decenas de hora
			goto Decenas_hora;			//Regresa a escanear de nuevo las decenas de hora
			
			bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			movlw 0x84;					//Comando de apuntador en el display
			movwf portc;				//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 			//Pone en modo datos al LCD
			movf Var_tecopri,w; 		//Mover la constante de tecla oprimida a W
			movwf portc;				//Mover la constante al puerto C
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			call retardo_250ms;			//llamada a la subrtuina de retardo de 250ms
				
Unidades_hora
			bcf banderas,bandera_teclado;// pone a 0 la bandera teclado
			call barre_teclado;			//Llamada a la subrutina de barre teclado que nos regresa un valor en ASCII y otro en binario
			btfsc banderas,bandera_d;	//Revisa el estado de la bandera D si es 1 sale de la subrutina de config_time
			goto sal_configtime;		//Salida de la subrutina configuracion del tiempo
 
			movf Var_tecbin,w;			//Mueve el contenido de Var_tecbin a w
			movwf cta_unihor;			//Mueve el contenido de w a cta_unihor
			call rectifica_tecla;		//Llamada a la subrutina que rectifica que la tecla oprimida sea correcta
			btfsc banderas,bandera_teclado;//Revisa el estado de la bandera teclado si es 1 regresa a escanear las unidades de hora
			goto Unidades_hora;			//Regresa a escanear de nuevo las unidades de hora
			
			bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			movlw 0x85;					//Comando de apuntador en el display
			movwf portc;				//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 			//Pone en modo datos al LCD
			movf Var_tecopri,w;			//Mover la constante de tecla oprimida a W
			movwf portc;				//Mover la constante al puerto C
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			call retardo_250ms;			//llamada a la subrtuina de retardo de 250ms

Decenas_min
			bcf banderas,bandera_teclado;// pone a 0 la bandera teclado
			call barre_teclado;			//Llamada a la subrutina de barre teclado que nos regresa un valor en ASCII y otro en binario
			btfsc banderas,bandera_d;	//Revisa el estado de la bandera D si es 1 sale de la subrutina de config_time
			goto sal_configtime;		//Salida de la subrutina configuracion del tiempo
 
			movf Var_tecbin,w;			//Mueve el contenido de Var_tecbin a w
			movwf cta_decmin;			//Mueve el contenido de w a cta_decmin
			call rectifica_tecla;		//Llamada a la subrutina que rectifica que la tecla oprimida sea correcta
			btfsc banderas,bandera_teclado;//Revisa el estado de la bandera teclado si es 1 regresa a escanear las decenas de minuto
			goto Decenas_min;			//Regresa a escanear de nuevo las decenas de minuto
			
			bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			movlw 0x87;					//Comando de apuntador en el display
			movwf portc;				//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 			//Pone en modo datos al LCD
			movf Var_tecopri,w; 		//Mover la constante de tecla oprimida a W
			movwf portc;				//Mover la constante al puerto C
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			call retardo_250ms;			//llamada a la subrtuina de retardo de 250ms		

Unidades_min
			bcf banderas,bandera_teclado;// pone a 0 la bandera teclado
			call barre_teclado;			//Llamada a la subrutina de barre teclado que nos regresa un valor en ASCII y otro en binario
			btfsc banderas,bandera_d;	//Revisa el estado de la bandera D si es 1 sale de la subrutina de config_time
			goto sal_configtime;		//Salida de la subrutina configuracion del tiempo
 
			movf Var_tecbin,w;			//Mueve el contenido de Var_tecbin a w
			movwf cta_unimin;			//Mueve el contenido de w a cta_unimin
			call rectifica_tecla;		//Llamada a la subrutina que rectifica que la tecla oprimida sea correcta
			btfsc banderas,bandera_teclado;//Revisa el estado de la bandera teclado si es 1 regresa a escanear las unidades de minuto
			goto Unidades_min;			//Regresa a escanear de nuevo las unidades de minuto
			
			bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			movlw 0x88;					//Comando de apuntador en el display
			movwf portc;				//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 			//Pone en modo datos al LCD
			movf Var_tecopri,w; 		//Mover la constante de tecla oprimida a W
			movwf portc;				//Mover la constante al puerto C
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			call retardo_250ms;			//llamada a la subrtuina de retardo de 250ms
Decenas_seg
			bcf banderas,bandera_teclado;// pone a 0 la bandera teclado
			call barre_teclado;			//Llamada a la subrutina de barre teclado que nos regresa un valor en ASCII y otro en binario
			btfsc banderas,bandera_d;	//Revisa el estado de la bandera D si es 1 sale de la subrutina de config_time
			goto sal_configtime;		//Salida de la subrutina configuracion del tiempo
 
			movf Var_tecbin,w;			//Mueve el contenido de Var_tecbin a w
			movwf cta_decseg;			//Mueve el contenido de w a cta_decseg
			call rectifica_tecla;		//Llamada a la subrutina que rectifica que la tecla oprimida sea correcta
			btfsc banderas,bandera_teclado;//Revisa el estado de la bandera teclado si es 1 regresa a escanear las decenas de segundo
			goto Decenas_seg;			//Regresa a escanear de nuevo las decenas de segundo
			
		
			bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			movlw 0x8A;					//Comando de apuntador en el display
			movwf portc;				//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 			//Pone en modo datos al LCD
			movf Var_tecopri,w;			 //Mover la constante de tecla oprimida a W
			movwf portc;				//Mover la constante al puerto C
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			call retardo_250ms;			//llamada a la subrtuina de retardo de 250ms

Unidades_seg
			bcf banderas,bandera_teclado;// pone a 0 la bandera teclado
			call barre_teclado;			//Llamada a la subrutina de barre teclado que nos regresa un valor en ASCII y otro en binario
			btfsc banderas,bandera_d;	//Revisa el estado de la bandera D si es 1 sale de la subrutina de config_time
			goto sal_configtime;		//Salida de la subrutina configuracion del tiempo

			movf Var_tecbin,w;			//Mueve el contenido de Var_tecbin a w
			movwf cta_uniseg;			//Mueve el contenido de w a cta_uniseg
			call rectifica_tecla;		//Llamada a la subrutina que rectifica que la tecla oprimida sea correcta
			btfsc banderas,bandera_teclado;//Revisa el estado de la bandera teclado si es 1 regresa a escanear las unidades de segundo
			goto Unidades_seg;			//Regresa a escanear de nuevo las unidades de segundo
		
			bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			movlw 0x8B;					//Comando de apuntador en el display
			movwf portc;				//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 			//Pone en modo datos al LCD
			movf Var_tecopri,w; 		//Mover la constante de tecla oprimida a W
			movwf portc;				//Mover la constante al puerto C
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			call retardo_250ms;			//llamada a la subrtuina de retardo de 250ms
			goto config_time;			//Regresa a escanear de nuevo la configuracion del tiempo 
			

borra_lcd

			bcf porta,RS_LCD; 			//Pone en modo comando al LCD
			movlw 0x01;					//Borra el texto y dirige el cursor al primer dígito
			movwf portc;				//Mover el contenido del registro de trabajo al registro portc
			call pulso_enable;			//Llamada a la subrutina de Pulso Enable
			bsf porta,RS_LCD; 			//Pone en modo comando al LCD
			bcf banderas, bandera_clear;//Pone a 0 la bandera clear
			goto config_time;			//Regresa a escanear de nuevo la configuracion del tiempo 


sal_configtime	bcf banderas, bandera_d;//Pone a 0 la bandera D
				return;					//Regreso de la subrutina de configuracion del tiempo


;----------------------------------------------------------------------------------------------------------
				;==============================
				;	==Subrutina Rectifica Tecla=
				;==============================

rectifica_tecla	
				movlw .3;		    //Mueve la cosntante 3 al registro W
				subwf cta_dechor,w;	// Resta el contenido del registro decenas de hora- w, el reultado lo almacena en W
				btfss status,DC;	//Verifica si la operacion tiene acarreo, si es asi va a borrar el contenido de registro decenas de hora,
				goto dechor2;		//Ve a rectifica decenas de hora  2
				goto borra_dechor;	//Vea borrar el contenido de decenas de hora
			

dechor2			movlw .2;			//Mueve la cosntante 2 al registro W
				subwf cta_dechor,w; // Resta el contenido del registro decenas de hora- w, el reultado lo almacena en W
				btfss status,Z;		//Verifica si la operacion tiene como resultado 0, si es asi salta, de lo contrario va a decenas de minutos
				goto decmin;		//Ve a rectificar decenas de minutos
				goto unihor;		//Ve a verificar decenas de minutos

unihor				movlw .4;		//Mueve la cosntante 4 al registro W
				subwf cta_unihor,w; //Resta el contenido del registro unidades de hora- w, el reultado lo almacena en W
				btfss status,DC;	//Verifica si la operacion tiene acarreo, si es asi va a borrar el contenido de registro decenas de minuto,
				goto decmin;		//Ve a rectificar decenas de minutos
				goto borra_unihor;  //Va a borrar el contenido de unidades de hora

decmin
				movlw .6;			//Mueve la cosntante 6 al registro W
				subwf cta_decmin,w; // Resta el contenido del registro decenas de minuto- w, el reultado lo almacena en W
				btfss status,DC;	//Verifica si la operacion tiene acarreo, si es asi va a borrar el contenido de registro decenas de segundo,
				goto decseg;		//Ve a rectificar decenas de segundos;
				goto borra_decmin;  //Va a borrar el contenido de decenas de minuto



decseg			movlw .6;			//Mueve la cosntante 6 al registro W
				subwf cta_decseg,w; // Resta el contenido del registro decenas de segundo- w, el resultado lo almacena en W
				btfss status,DC;	//Verifica si la operacion tiene acarreo, si es asi va a borrar el contenido de registro decenas de segundo,
				goto correcta;		//Una vez que se concluyo se determino que es correcto el numero introducido
				goto borra_decseg;  //Va a borrar el contenido de decenas de hora			
						

borra_dechor
				clrf cta_dechor;	//Borra la cuenta de decenas de hora
				goto incorrecta;	//Una vez que se concluyo se determino que es incorrecto el numero introducido
borra_unihor
				clrf cta_unihor;	//Borra la cuenta de unidades de hora
				goto incorrecta;	//Una vez que se concluyo se determino que es incorrecto el numero introducido
borra_decmin
				clrf cta_decmin;	//Borra la cuenta de decenas de minutos
				goto incorrecta;	//Una vez que se concluyo se determino que es incorrecto el numero introducido
borra_decseg
				clrf cta_decseg;	//Borra la cuenta de decenas de segundos
				goto incorrecta;	//Una vez que se concluyo se determino que es incorrecto el numero introducido

incorrecta		bsf banderas,bandera_teclado;//Pone a 1 la bandera de teclado
				goto salrutina; 	//Ve para la salida de la subrutina rectifica tecla

correcta		bcf banderas,bandera_teclado;	//Pone a 0 la bandera de teclado
			

salrutina		return;				//Salida de la subrutina rectifica tecla
				 
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
				;==Subrutina de retardo de 40ms=
				;==============================

retardo_40ms 	clrf cont_milis;		//Limpia el registro cont milis	
loop_40ms		movlw .40;				//Mueve la constante 40 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta
				goto loop_40ms;			//Ve para la etiqueta loop_40ms
			
				return;					//regresa de la subrutina

;----------------------------------------------------------------------------------------------------------



				;==============================
				;==Subrutina de retardo de 250ms=
				;==============================

retardo_250ms 	clrf cont_milis;		//Limpia el registro cont milis	
loop_250ms		movlw .250;				//Mueve la constante 250 al registro de trabajo 
				subwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta
				goto loop_250ms;		//Ve para la etiqueta loop_250ms
			
				return;					//regresa de la subrutina

;----------------------------------------------------------------------------------------------------------
end										//Fin del programa









			
