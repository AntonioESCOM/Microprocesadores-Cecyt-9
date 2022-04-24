; INSTITUTO POLITECNICO NACIONAL.
; CECYT 9 JUAN DE DIOS BATIZ.
;
; PRACTICA 0'.   
; MANEJO DE UN LED OSCILANDO A 1 Hz.
;
; EQUIPO:        GRUPO: 6IMX.
;
; INTEGRANTES:
; 1.-RAMIREZ PACHECO.
; 2.-RAMIREZ ESTRADA.
; 3.-VEGA ALTAMIRANO.
; 4.-YASKAWA SANCHEZ.
;
; FECHA DE ENTREGA DEL REPORTE.
;
; ESTE PROGRAMA CONTROLA UN LED HACIENDOLO OSCILAR A UNA 
; FRECUENCIA DE UN SEGUNDO, UTILIZANDO 
; INTERRUPCIONES CON EL TMR0.
;
;--------------------------------------------------------------------------------------------------
  List    p=16f877A; 
  #include "c:\Program files (x86)\Microchip\Mpasm Suite\p16f877a.inc";
                                                         
 __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _XT_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF;
;--------------------------------------------------------------------------------------------------
;
; Fosc = 4 MHz.
; Ciclo de trabajo del PIC = (1/fosc)*4 = 1 µs.
; T int =(256-tmr0)*(P)*((1/4000000)*4) = 1 ms.    // Tiempo de interrupción.
; tmr0=131,  P=8.
; frec int = 1/ t int = 1 KHz.
;----------------------------------------------------------------------------------------------------
;
;Def. de variables del programa en RAM.
resp_w                    equ    0x20;	//variable para respaldar w
resp_status            equ    0x21; // variable para respaldar registro status
res_pclath              equ    0x22; //variable para respaldar pclath 
res_fsr                     equ    0x23;  // variables para respaldar fsr
presc_1                   equ    0x24;            .001   100         5 
presc_2                   equ    0x25; t int = t intb * presc_1 * presc_2
banderas                equ    0x26;  // registro utilizado para avisar a través de un byte que la interrupción de 500ms ya ocurrió 
cont_milis              equ    0x27;
;---------------------------------------------------------------------------------------------------
; Def. de constantes a utilizar.
; Cod. de caracteres alfanuméricos en 7 segmentos.
Car_A                   equ   b'01110111';
Car_b                   equ   0xc7;
Car_0                   equ   0x3f;
Car_1                   equ   0x06;
; banderas del registro banderas.
ban_int                 equ     .0;
sin_bd1                 equ     .1; 
sin_bd2                 equ     .2; 
sin_bd3                 equ     .3; 
sin_bd4                 equ     .4; 
sin_bd5                 equ     .5; 
sin_bd6                 equ     .6; 
sin_bd7                 equ     .7; 
;---------------------------------------------------------------------------------------------------







; Def. de Ptos. I/0.
; Puerto A.
Sin_UsoRA0          equ     .0;
Sin_UsoRA1          equ     .1;
Sin_UsoRA2          equ     .2;
Sin_UsoRA3          equ     .3;
Led_Rojo               equ     .4;
Sin_UsoRA5          equ     .5;

progA                     equ B'101111';Def. la config. de los bits del pto. a.

;Puerto B.
Sin_UsoRB0          equ     .0;
Sin_UsoRB1          equ     .1;
Sin_UsoRB2          equ     .2;
Sin_UsoRB3          equ     .3;
Sin_UsoRB4          equ     .4;
Sin_UsoRB5          equ     .5;
Sin_UsoRB6          equ     .6;
Sin_UsoRB7          equ     .7;

progb                     equ b'11111111'; // Programación inicial del puerto B.

;Puerto C.
Sin_UsoRC0              equ     .0;
Sin_UsoRC1              equ     .1;
Sin_UsoRC2              equ     .2;
Sin_UsoRC3              equ     .3;
Sin_UsoRC4              equ     .4;
Sin_UsoRC5              equ     .5;
Sin_UsoRC6              equ     .6;
Sin_UsoRC7              equ     .7;

progc                   equ b'11111111'; // Programación inicial del puerto C como 
                                                                  Entrada.
;Puerto D.
Sin_UsoRD0              equ     .0;
Sin_UsoRD1              equ     .1;
Sin_UsoRD2              equ     .2;
Sin_UsoRD3              equ     .3;
Sin_UsoRD4              equ     .4;
Sin_UsoRD5              equ     .5;
Sin_UsoRD6              equ     .6;
Sin_UsoRD7              equ     .7;

progD                   equ B'11111111';Def. 

; Puerto E.
Sin_UsoRE0              equ     .0;
Sin_UsoRE1              equ     .1;
Sin_UsoRE2              equ     .2;
progE                   equ B'111';Def. la encua.
;-------------------------------------------------------------------------------------------------
      
                        ;=================
                        ;==  Vector Reset   ==
                        ;=================
                        org 0000h;
vec_reset       clrf pclath;
                        goto prog_prin;
;-------------------------------------------------------------------------------------------------
                  
                        ;=============================
                        ;== Subrutina de Interrupciones  ==
                        ;=============================
                        org 0004h;   
vec_int           movwf resp_w;resp. esl estado del reg. w. 
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
;--------------------------------------------------------------------------------------------------



                        ;================================
                        ;== Subrutina de Ini. de Reg. del Pic   ==
                        ;================================
prog_ini         bsf status,RP0; Ponte en el banco 1 de ram.
                        movlw 0x82;		// Deshabilitada pull ups y habilitar un preescalador de 8 en el timer 0
                        movwf option_reg ^0x80; 
                        movlw progA;
                        movwf trisa ^0x80;
                        movlw progb;
                        movwf trisB ^0x80;
                        movlw progC;
                        movwf trisc ^0x80; 
                        movlw progD;
                        movwf trisd ^0x80;
                        movlw progE;
                        movwf trise ^0x80;
                        movlw 0x06;
                        movwf adcon1 ^0x80;
                        bcf status,RP0; Ponte en el banco 0 de ram.      
                           
                        movlw 0xa0;		// Habilita la iterrupcion del TMR0, Las globales y borra las banderas de interrupción 
                        movwf intcon;

                        movlw .131;
                        movwf tmr0;

                       clrf banderas; 
                       return;
;--------------------------------------------------------------------------------------------------


                        ;=====================
                        ;== Programa principal  ==
                        ;=====================
prog_prin      call prog_ini;
Loop_prin      call esp_int;

                        btfss porta,Led_Rojo;
                        goto sec_led;
                        bcf porta,Led_Rojo; Prende el led.
                        goto Loop_prin;
sec_led          bsf porta,Led_Rojo; Apaga el led.
                        goto Loop_prin;
;-------------------------------------------------------------------------------------------------- 

                        ;=========================================
                        ;== Subrutina de espera de int. de 0.5 segundo  ==
                        ;=========================================
esp_int           nop;
                        btfss banderas,ban_int; 
                        goto esp_int;
                        bcf banderas,ban_int;

                        return;
;-------------------------------------------------------------------------------------------------- 
                        end
