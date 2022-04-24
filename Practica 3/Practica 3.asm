;INSTITUTO POLITECNICO NACIONAL
;CECYT 9 JUAN DE DIOS BATIZ
;
;Practica 3.
;MULTIPLEXADO “MANEJO DE DISPLAYS DE MATRIZ DE PUNTOS”.
;(ANIMACIÓN DE IMAGENES).
;
;GRUPO:6IM2
;
;INTEGRANTE
;Morales Martínez José Antonio
;
;El programa mostrara 5 caracteres alfanumericos y posteriormente mostrara
;Un par de imagenes con animacion haciendo uso de un display matricial de 5x7
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
banderas		equ			0x35;	//Registro en donde se definen la bandera de interupcion de 1s 
animacion		equ			0x38;	//Registro encargado del ciclo de la animación 
cont_seg		equ 		0x39;
;-----------------------------------------------------------------------------------------------------
;Constantes
;Codigo de los caracteres en el display
Act_col11				equ 	0x01;	//Activa la columna 1 y desactiva las demás 
Act_col12				equ 	0x02;	//Activa la columna 2 y desactiva las demás
Act_col13				equ 	0x04;	//Activa la columna 3 y desactiva las demás
Act_col14				equ 	0x08;	//Activa la columna 4 y desactiva las demás
Act_col15				equ 	0x10;	//Activa la columna 5 y desactiva las demás
des_columnas 			equ 	0x00; 	//Desactiva todas las columnas del display matricial
Act_col11ycol15			equ 	0x11;	//Activa la columna 1 y columna 5 desactiva las demás
Act_col12ycol3ycol14	equ		0x0E;	//Activa la columna 2,3 y 4, desactiva las demás
Act_col12ycol14			equ 	0x0A;	//Activa la columna 2 y 4, desactiva las demás
Act_col12col13col14ycol15	equ		0x1E;//Activa la columna 2,3,4 y 5 desactiva las demás



;Caracter M Mayuscula
CarM_col11				equ		0x00;	X       X
CarM_col12				equ		0xFD;	X X   X X	
CarM_col13				equ 	0xF3;	X	X   X
CarM_col14				equ		0xFD;	X	X	X
CarM_col15				equ		0x00;	X       X
									;	X		X
									;	X		X

;Caracter O Mayuscula
CarO_col11				equ		0xC1;	  X X X 
CarO_col12				equ		0xBE;	X   	X 
CarO_col13				equ 	0xBE;	X	    X
CarO_col14				equ		0xBE;	X		X
CarO_col15				equ		0xC1;	X       X
									;	X		X
									;	  X X X

;Caracter R Mayuscula
CarR_col11				equ		0x00;	X X X X
CarR_col12				equ		0xF6;	X       X 	
CarR_col13				equ 	0xE6;	X       X	    
CarR_col14				equ		0xD6;	X X X X		
CarR_col15				equ		0xB9;	X   X     
									;	X	  X	
									;	X       X
;Caracter A Mayuscula
CarA_col11				equ		0x03;	    X
CarA_col12				equ		0x6D;	  X   X  	
CarA_col13				equ 	0x6E;	X       X	    
CarA_col14				equ		0x6D;	X 	    X
CarA_col15				equ		0x03;	X X X X X  
									;	X	    X
									;	X       X 

;Caracter L Mayuscula
CarL_col11				equ		0x00;	X
CarL_col12				equ		0xBF;   X    	
CarL_col13				equ 	0xBF;	X       	    
CarL_col14				equ		0xBF;	X 	    
CarL_col15				equ		0xBF;	X  
									;	X	    
									;	X X X X X

;Caracter persona con brazos abajo Mayuscula
CarH1_col11				equ		0xEF;	    X
CarH1_col12				equ		0x95;     X   X  	
CarH1_col13				equ 	0xE2;	    X 	    
CarH1_col14				equ		0x95;	  X X X	    
CarH1_col15				equ		0xEF;  	 X  X  X
									;	  X	  X   
									;	  X   X

;Caracter persona con brazos arriba Mayuscula
CarH2_col11				equ		0xBB;	    X
CarH2_col12				equ		0xD5;     X   X  	
CarH2_col13				equ 	0xE2;	 X 	X  X 
CarH2_col14				equ		0XD5;	  X X X	    
CarH2_col15				equ		0xBB;  	    X  
									;	  X	  X   
									;	 X      X




 ;---------------------------------------------------------------------------------------------------
 
;Asignacion de los bits de los puertos de I/O.
;Puerto A.
Sin_UsoRA0		equ			.0; // Sin Uso RA0.
Sin_UsoRA1		equ			.1; // Sin Uso RA1.
Sin_UsoRA2		equ			.2; // Sin Uso RA2.
Sin_UsoRA3		equ			.3; // Sin Uso RA3
Sin_UsoRA4		equ			.4; // Sin Uso RA4.
Sin_UsoRA5		equ			.5; // Sin Uso RA5.

proga			equ	b'111111'; // Programacion Inicial del Puerto A.

;Puerto B.
Col_1			equ 		.0; // Columna 1 del display matricial.
Col_2			equ 		.1; // Columna 2 del display matricial.
Col_3			equ 		.2; // Columna 3 del display matricial.
Col_4			equ 		.3; // Columna 4 del display matricial.
Col_5			equ 		.4; // Columna 5 del display matricial..
Sin_UsoRB5		equ 		.5; // Sin Uso RB5.
Sin_UsoRB6		equ 		.6; // Sin Uso RB6.
Sin_UsoRB7		equ 		.7; // Sin Uso RB7.
		
progb			equ	b'11100000'; // Programacion Inicial del Puerto B.

;Puerto C.
Ren_1			equ			.0; // Reglon 1 del display matricial
Ren_2			equ			.1; // Reglon 2 del display matricial
Ren_3			equ			.2; // Reglon 3 del display matricial
Ren_4			equ			.3; // Reglon 4 del display matricial
Ren_5			equ			.4; // Reglon 5 del display matricial
Ren_6			equ			.5; // Reglon 6 del display matricial
Ren_7			equ			.6; // Reglon 7 del display matricial
Sin_UsoRC7		equ 		.7; // Sin Uso RC7.

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

				incf cont_seg,f;		//Incrementa la variable cont_seg en una unidad y guarda en el mismo registro			          
sal_rutext      bsf banderas,ban_int;	//Pon a 1 el bit ban int del registro banderas(retardo 1s)
                                 
sal_rutint      bcf intcon,t0if;		//Pon a 0 el bit bandera t0if puesto a 1 por la interrupcion
                return;					//Regresar al programa principal
;---------------------------------------------------------------------------------------------------------	


				;=======================
				;==Subrutina de inicio==
				;=======================
prog_ini		bsf STATUS,RP0; 		//Coloca al programa  en el bco. 1 de ram
				movlw 0x82;				// Mueve la constante 0X82 al registro w
				movwf OPTION_REG ^0x80;	// Configura el preescalador y desactiva los pull-up
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
				clrf res_w;				//Limpia el registro res w
				clrf res_status;		//Limpia el registro res status
				clrf res_pclath;		//Limpia el registro res pclath
				clrf res_fsr; 			//Limpia el registro res fsr
				clrf presc_1;			//Limpia el registro presc 1
				clrf presc_2;			//Limpia el registro presc 2
             	clrf portb;				//Limpia el registro puerto B 
			  	return;					//Regresa de la subrutina de inicializacion
;----------------------------------------------------------------------------------------------------------

				;======================
				;==Programa Principal==
				;======================
prog_prin		call prog_ini;			//Llamada a la subrutina de inicio 

loop			clrf cont_seg;			//Limpia el registro contador de segundos
loop_M			movlw Act_col11ycol15;	//Carga a w la constante que activa la columna 1 y 5
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarM_col11;		//Carga a w la constante para representar M en la columna 1 y 5
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				clrf portb;				//Limpia el registro puerto B
			

				movlw Act_col12ycol14;	//Carga a w la constante que activa la columna 2 y 4
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarM_col12;		//Carga a w la constante para representar M en la columna 2 y 4 
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w
				call retardo;			//Llama a la subrutina de retardo

				movlw Act_col13;		//Carga a w la constante que activa la columna 3
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarM_col13;		//Carga a w la constante para representar M en la columna 3
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w
				call retardo;			//Llama a la subrutina de retardo

				movlw .5;				//Carga a w la constante 5 decimal que representa los 5s de espera entre cambio de caracter
				subwf cont_seg,w;		//Resta entre el contenido de cont_seg y 5
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_M;			//Loop del caracter M
;----------------------------------------------------------------------------------------------------------

				clrf cont_seg;			//Limpia el registro contador de segundos
loop_o		
				movlw Act_col11ycol15;	//Carga a w la constante que activa la columna 1 y 5
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarO_col11;		//Carga a w la constante para representar O en la columna 1 y 5
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				clrf portb;				//Limpia el registro puerto B
				

				movlw Act_col12ycol3ycol14;//Carga a w la constante que activa la columna 2,3 y 4
				movwf portb;			//Mueve al puerto B el contenido de w	
				movlw CarO_col12;		//Carga a w la constante para representar O en la columna 2,3 y 4
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w
		

				movlw .5;				//Carga a w la constante 5 decimal que representa los 5s de espera entre cambio de caracter
				subwf cont_seg,w;		//Resta entre el contenido de cont_seg y 5
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_o;			//Loop del caracter O
;----------------------------------------------------------------------------------------------------------
		
				clrf cont_seg;			//Limpia el registro contador de segundos		
loop_R			movlw Act_col11;		//Carga a w la constante que activa la columna 1 
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarR_col11;		//Carga a w la constante para representar R en la columna 1
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				clrf portb;				//Limpia el registro puerto B
				
				movlw Act_col12; 		//Carga a w la constante que activa la columna 2
				movwf portb;			//Mueve al puerto B el contenido de w	
				movlw CarR_col12;		//Carga a w la constante para representar O en la columna 2
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw Act_col13; 		//Carga a w la constante que activa la columna 3
				movwf portb;			//Mueve al puerto B el contenido de w	
				movlw CarR_col13;		//Carga a w la constante para representar O en la columna 3
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw Act_col14; 		//Carga a w la constante que activa la columna 4
				movwf portb;			//Mueve al puerto B el contenido de w	
				movlw CarR_col14;		//Carga a w la constante para representar O en la columna 4
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw Act_col15; 		//Carga a w la constante que activa la columna 5
				movwf portb;			//Mueve al puerto B el contenido de w	
				movlw CarR_col15;		//Carga a w la constante para representar O en la columna 5
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw .5;				//Carga a w la constante 5 decimal que representa los 5s de espera entre cambio de caracter
				subwf cont_seg,w;		//Resta entre el contenido de cont_seg y 5
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_R;			//Loop del caracter O
;----------------------------------------------------------------------------------------------------------		
			
				clrf cont_seg;			//Limpia el registro contador de segundos
loop_A			movlw Act_col11ycol15;	//Carga a w la constante que activa la columna 1 y 5
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarA_col11;		//Carga a w la constante para representar A en la columna 1 y 5
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				clrf portb;				//Limpia el registro puerto B

				movlw Act_col12ycol14;	//Carga a w la constante que activa la columna 2 y 4
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarA_col12;		//Carga a w la constante para representar A en la columna 2 y 4 
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw Act_col13;		//Carga a w la constante que activa la columna 3
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarA_col13;		//Carga a w la constante para representar A en la columna 3
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw .5;				//Carga a w la constante 5 decimal que representa los 5s de espera entre cambio de caracter
				subwf cont_seg,w;		//Resta entre el contenido de cont_seg y 5
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_A;			//Loop del caracter M
;----------------------------------------------------------------------------------------------------------

				clrf cont_seg;			//Limpia el registro contador de segundo
loop_L			movlw Act_col11;		//Carga a w la constante que activa la columna 1 
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarL_col11;		//Carga a w la constante para representar L en la columna 1 
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				clrf portb;				//Limpia el registro puerto B

				movlw Act_col12col13col14ycol15;	//Carga a w la constante que activa la columna 2 y 4
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarL_col12;		//Carga a w la constante para representar L en la columna 2 y 4 
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw .5;				//Carga a w la constante 5 decimal que representa los 5s de espera entre cambio de caracter
				subwf cont_seg,w;		//Resta entre el contenido de cont_seg y 5
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_L;			//Loop del caracter M
				
;----------------------------------------------------------------------------------------------------------
			
			
loop_animacion
				clrf cont_seg;//Limpia el registro contador de segundos
loop_Mu1		movlw Act_col11ycol15;	//Carga a w la constante que activa la columna 1 y 5
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarH1_col11;		//Carga a w la constante para representar H1 en la columna 1 y 5
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				clrf portb;				//Limpia el registro puerto B

				movlw Act_col12ycol14;	//Carga a w la constante que activa la columna 2 y 4
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarH1_col12;		//Carga a w la constante para representar H1 en la columna 2 y 4 
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw Act_col13;		//Carga a w la constante que activa la columna 3
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarH1_col13;		//Carga a w la constante para representar A en la columna 3
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw .5;				//Carga a w la constante 5 decimal que representa los 5s de espera entre cambio de caracter
				subwf cont_seg,w;		//Resta entre el contenido de cont_seg y 5
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_Mu1;			//Loop del caracter M

;----------------------------------------------------------------------------------------------------------

				clrf cont_seg;			//Limpia el registro contador de segundos
loop_Mu2		movlw Act_col11ycol15;	//Carga a w la constante que activa la columna 1 y 5
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarH2_col11;		//Carga a w la constante para representar H1 en la columna 1 y 5
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				clrf portb;				//Limpia el registro puerto B

				movlw Act_col12ycol14;	//Carga a w la constante que activa la columna 2 y 4
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarH2_col12;		//Carga a w la constante para representar H1 en la columna 2 y 4 
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw Act_col13;		//Carga a w la constante que activa la columna 3
				movwf portb;			//Mueve al puerto B el contenido de w
				movlw CarH2_col13;		//Carga a w la constante para representar A en la columna 3
				movwf portc;			//Mueve al puerto C el contenido de w
				call retardo;			//Llama a la subrutina de retardo
				movlw des_columnas;		//Carga a w el codigo de desactivacion de columnas
				movwf portb;			//Mueve al puerto B el contenido de w

				movlw .5;				//Carga a w la constante 5 decimal que representa los 5s de espera entre cambio de caracter
				subwf cont_seg,w;		//Resta entre el contenido de cont_seg y 5
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_Mu2;			//Loop del caracter M

				incf animacion,f;		//Incrementa en una unidad el registro animacion, encargado del ciclo de la animacion
				movlw .5;
				subwf animacion,w;		//Resta entre el contenido de 5 y el registro animacion
				btfss status,Z;			//Si el bit z del registro status es igual a 1 salta
				goto loop_animacion;			//Loop del caracter M

			
				clrf animacion;
				goto loop;
;----------------------------------------------------------------------------------------------------------

				;==============================
				;==Subrutina de retardo de 2ms=
				;==============================

retardo			clrf cont_milis;		//Limpia el registro cont milis		
loop_2ms		movlw .3;				//Mueve la constante 1 al registro de trabajo 
				xorwf cont_milis,w;		//Resta entre el registro cont milis menos el registro de trabajo
				btfss status,Z;			//Si el bit Z del registro STATUS es igual a 1 salta
				goto loop_2ms;			//Ve para la etiqueta loop_1ms
			
				return;					//regresa de la subrutina
;----------------------------------------------------------------------------------------------------------

end										//Fin del programa









			
