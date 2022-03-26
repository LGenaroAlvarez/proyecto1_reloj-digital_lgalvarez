; Archivo: main_lab04.s
; Dispositivo: PIC16F887
; Autor: Luis Genaro Alvarez Sulecio
; Compilador: pic-as (v2.30), MPLABX V5.40
;
; Programa: CONFIGURACIONES PRINCIPALES
; Hardware: PIC 16F887 Y PUSHBUTTONS
;
; Creado: 17 mar, 2022
; Última modificación: 

; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

PROCESSOR 16F887  

//---------------------------CONFIGURACION WORD1--------------------------------
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

//---------------------------CONFIGURACION WORD2--------------------------------
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
  
//---------------------------------MACROS---------------------------------------
RESET_TMR0 MACRO TMR_VAR
    BANKSEL TMR0		; SELECCIONAR EL BANK 2 DEL TMR0
    MOVLW   TMR_VAR		; CARGAR EL VALOR RECIBIDO POR LA FUNCIÓN AL REGISTRO W
    MOVWF   TMR0		; CARGAR EL VALOR DEL REGISTRO W AL TMR0
    BCF	    T0IF		; LIMPIAR BANDERA DEL TIMER0
    ENDM
    
TMR1_RESET MACRO TMR1_H, TMR1_L	; MACRO PARA RESETEO DEL TMR1
    MOVLW   TMR1_H		; PREPARACION DEL VALRO A CARGAR EN TMR1H
    MOVWF   TMR1H		; GARGA DEL VALOR AL TMR1H
    MOVLW   TMR1_L		; PREPARACION DEL VALOR A CARGAR EN TMR1L
    MOVWF   TMR1L		; CARGA DEL VALOR AL TMR1L
    BCF	    TMR1IF		; LIMPIADO DE LA BANDERA DE INTERRUPCIONES PARA EL TMR1
    ENDM    
  
SET_DISPLAY MACRO DISP1, DISP2, DISP3, DISP4
    MOVF    DISP1, W		; MOVER VALOR DE CUENTA EN SEGUDOS AL REGISTRO W
    CALL    HEX_INDEX		; INICIAR SUBRUTINA DE TABLA HEXADECIMAL
    MOVWF   R_display		; CARGAR VALOR EN HEXADECIMAL A VARIABLE DE DISPLAY_0
    
    MOVF    DISP2, W		; MOVER VALOR DE CUENTA EN DECENAS DE SEGUNDOS AL REGISTRO W
    CALL    HEX_INDEX		; INICIAR SUBRUTINA DE TABLA HEXADECIMAL
    MOVWF   R_display+1		; CARGAR VALOR EN HEXADECIMAL A VARIABLE DE DISPLAY_1
    
    MOVF    DISP3, W
    CALL    HEX_INDEX
    MOVWF   L_display
    
    MOVF    DISP4, W
    CALL    HEX_INDEX
    MOVWF   L_display+1
    ENDM    
    
DEC_UF_TEST MACRO UF_VAL, TRUE_VAL, DEC_VAR_1, POS_B
    MOVF    DEC_VAR_1, W
    SUBLW   UF_VAL
    BTFSS   ZERO
    GOTO    POS_B
    MOVLW   TRUE_VAL
    MOVWF   DEC_VAR_1
    ENDM
    
INC_OF_TEST MACRO OF_VAL, INC_VAR_1, POS_A
    MOVF    INC_VAR_1, W
    SUBLW   OF_VAL
    BTFSS   ZERO
    GOTO    POS_A
    CLRF    INC_VAR_1
    ENDM
    
    
CONT_TEST   MACRO CONT1, CONT2, CONT3, CONT4, POS1, POS2
    MOVF    CONT1, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    POS1
    MOVF    CONT2, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    POS1
    MOVF    CONT3, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    POS1
    MOVF    CONT4, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    POS1
    GOTO    POS2
    ENDM
    
PSECT udata_bank0
    alarma:		DS 1	; BANDERA PARA ALARMA
    cont_alarma:	DS 1	; CUENTA PARA APAGADOAUTOMATICO DE LA ALARMA
    edicion:		DS 1	; BANDERA PARA EDICION DE ESTADOS
    estado:		DS 1	; BANDERA PARA IDENTIFICACION DE ESTADOS
    inc_flag:		DS 1	; BANDERA PARA INCREMENTOS
    Cont_Hora:		DS 1	; VARIABLE DE CONTEO PARA 1 SEGUNDO DE FUNCIÓN HORA
    cont_useg:		DS 1	; VARIABLE DE CUENTA DE UNIDADES DE SEGUNDOS PARA RELOJ
    cont_dseg:		DS 1	; VARIABLE DE CUENTA DE DECENAS DE SEGUNDOS PARA RELOJ
    cont_umin:		DS 1	; VARIABLE DE CUENTA DE UNIDADES DE MINUTOS PARA RELOJ
    cont_dmin:		DS 1	; VARIABLE DE CUENTA DE DECENAS DE MINUTOS PARA RELOJ
    cont_uhor:		DS 1	; VARIABLE DE CUENTA DE UNIDADES DE HORA PARA RELOJ
    cont_dhor:		DS 1	; VARIABLE DE CUENTA DE DECENAS DE HORA PARA RELOJ
    tmr_var:		DS 1	; BANDERA PARA DETERMINAR SI SE ESTA DECREMENTANDO LA CUENTA DEL TIMER
    tmr_cont:		DS 1	; VARIABLE DE CUENTA DEL TIMER PARA LLEGAR A 1 SEGUNDO
    tmr_useg:		DS 1	; VARIABLE DE CUENTA DE UNIDADES DE SEGUNDO PARA TIMER
    tmr_dseg:		DS 1	; VARIABLE DE CUENTA DE DECENAS DE SEGUNDO PARA TIMER
    tmr_umin:		DS 1	; VARIABLE DE CUENTA DE UNIDADES DE MINUTO PARA TIMER
    tmr_dmin:		DS 1	; VARIABLE DE CUENTA DE DECENAS DE MINUTO PARA TIMER
    Cont_T2:		DS 1	; VARIABLE DE CONTEO PARA TMR2
    bandera:		DS 1	; BANDERA PARA MULTIPLEXADO
    edit:		DS 1	; BANDERA DE SELECCION DE CUENTA A EDITAR (MINUTOS/HORAS O SEGUNDOS/MINUTOS)
    the_end:		DS 1	; 
    L_display:		DS 2	; 
    R_display:		DS 2	; 
  
//--------------------------VARIABLES EN MEMORIA--------------------------------
PSECT udata_shr			; VARIABLES COMPARTIDAS
    W_TEMP:		DS 1	; VARIABLE TEMPORAL PARA REGISTRO W
    STATUS_TEMP:	DS 1	; VARIABLE REMPORAL PARA STATUS  
  
//-----------------------------Vector reset------------------------------------
 PSECT resVect, class = CODE, abs, delta = 2;
 ORG 00h			; Posición 0000h RESET
 resetVec:			; Etiqueta para el vector de reset
    PAGESEL main
    goto main
  
 PSECT intVect, class = CODE, abs, delta = 2, abs
 ORG 04h			; Posición de la interrupción
 
//--------------------------VECTOR INTERRUPCIONES------------------------------- 
PUSH:
    MOVWF   W_TEMP		; COLOCAR FALOR DEL REGISTRO W EN VARIABLE TEMPORAL
    SWAPF   STATUS, W		; INTERCAMBIAR STATUS CON REGISTRO W
    MOVWF   STATUS_TEMP		; CARGAR VALOR REGISTRO W A VARAIBLE TEMPORAL
    
ISR: 
    BTFSC   RBIF		; INT PORTB, SI=1 NO=0
    CALL    INT_IOCRB		; SI -> CORRER SUBRUTINA DE INTERRUPCIÓN
    
    BTFSC   T0IF		; INT TMR0, SI=1 NO=0
    CALL    TMR0_INT		; SI -> CORRER SUBRUTINA DE INTERRUPCIÓN
    
    BTFSC   edicion, 0
    GOTO    $+3
    BTFSC   TMR1IF		; REVISION DEL ESTADO DE LA BANDERA DE INTERRUPCION DEL TMR1
    CALL    TMR1_INT		; INICIAR INTERRUPCION DEL TMR1
    
    BTFSC   TMR2IF		; REVISION DEL ESTADO DE LA BANDERA DE INTERRUPCION DEL TMR2
    CALL    TMR2_INT		; INICIAR INTERRUPCION DEL TMR2
    
POP:
    SWAPF   STATUS_TEMP, W	; INTERCAMBIAR VALOR DE VARIABLE TEMPORAL DE ESTATUS CON W
    MOVWF   STATUS		; CARGAR REGISTRO W A STATUS
    SWAPF   W_TEMP, F		; INTERCAMBIAR VARIABLE TEMPORAL DE REGISTRO W CON REGISTRO F
    SWAPF   W_TEMP, W		; INTERCAMBIAR VARIABLE TEMPORAL DE REGISTRO W CON REGISTRO W
    RETFIE   
    
//----------------------------INT SUBRUTINAS------------------------------------    
INT_IOCRB:			; SUBRUTINA DE INTERRUPCIÓN EN PORTB
    BANKSEL PORTA		; SELECCIONAR BANCO 0
    BTFSS   PORTB, 0		; REVISAR SI EL BIT DEL PRIMER BOTON EN RB HA CAMBIADO A 0
    CALL    FMS_CONFIG		; SI HA CAMBIADO A 0 (HA SIDO PRESIONADO) INCREMENTAR CUENTA EN PORTA
    BTFSS   PORTB, 1		; REVISAR SI EL BIT DEL SEGUNDO BOTON EN RB HA CAMBIADO A 0
    CALL    INC_CONFIG		; SI HA CAMBIADO A 0 (HA SIDO PRESIONADO) DISMINUIR LA CUENTA EN PORTA
    BTFSS   PORTB, 2
    CALL    DEC_CONFIG
    BTFSS   PORTB, 3
    CALL    EDIT_CONFIG
    BCF	    RBIF		; LIMPIAR LA BANDERA DE PORTB
    RETURN     
    
TMR0_INT:
    RESET_TMR0 250		; REINICIAR TMR0 CADA 2mS
    CLRF    PORTD
    CALL    SHOW_DISPLAY	; LLAMAR SUBRUTINA PARA MOSTRAR EL DISPLAY
    RETURN

TMR1_INT:
    TMR1_RESET	0x0B, 0xDC	; REINICIO DEL TMR1
    INCF    Cont_Hora		; INCREMENTO EN CUENTA
    MOVF    Cont_Hora, W	; CARGA DE CUENTA A REGISTRO W
    SUBLW   2			; USO DE RESTA PARA DETERMINAR SI LA CUENTA HA LLEGADO A 2X500mS QUE SERIA 1S
    BTFSC   ZERO		; SI NO SE HA LLEGADO AL SEGUNDO SALIR DE LA INTERRUPCION
    GOTO    INC_USEG		; SI SE LLEGO AL SEGUNDO IR A SUBRUTINA DE INCREMENTO DE SEGUNDOS
    RETURN    
 
INC_USEG:			; INCREMENTO DE UNIDADES DE SEGUNDOS CON TMR1
    BTFSS   alarma, 0
    GOTO    NEXT
    CALL    DEC_ALARM
    NEXT:
    CLRF    Cont_Hora
    INCF    cont_useg
    MOVF    cont_useg, W
    SUBLW   10
    BTFSC   ZERO
    GOTO    INC_DSEG
    RETURN
 
INC_DSEG:			; INCREMENTO DE DECENAS DE SEGUNDOS CON TMR1
    CLRF    cont_useg
    INCF    cont_dseg
    MOVF    cont_dseg, W
    SUBLW   6
    BTFSC   ZERO
    GOTO    INC_UMIN
    RETURN
    
INC_UMIN:			; INCREMENTO DE UNIDADES DE MINUTOS CON TMR1
    CLRF    cont_dseg
    INCF    cont_umin
    MOVF    cont_umin, W
    SUBLW   10
    BTFSC   ZERO
    GOTO    INC_DMIN
    RETURN
    
INC_DMIN:			; INCREMENTO DE DECENAS DE MINUTOS CON TMR1
    CLRF    cont_umin
    INCF    cont_dmin
    MOVF    cont_dmin, W
    SUBLW   6
    BTFSS   ZERO
    GOTO    $+2
    GOTO    INC_UHOR
    BTFSC   the_end,0
    GOTO    DAY_END
    RETURN
    
INC_UHOR:			; INCREMENTO DE UNIDADES DE HORAS CON TMR1
    CLRF    cont_dmin
    INCF    cont_uhor
    MOVF    cont_uhor, W
    BTFSC   the_end, 0
    GOTO    DAY_END
    SUBLW   10
    BTFSC   ZERO
    GOTO    INC_DHOR
    RETURN
    
    DAY_END:
	MOVF	cont_uhor, W
	SUBLW	4
	BTFSS	ZERO
	GOTO	$+3
	BCF	the_end, 0
	CLRF    cont_uhor
	CLRF    cont_dhor
	GOTO	CONT_MC
    RETURN
    
INC_DHOR:			; INCREMENTO DE DECENAS DE HORAS CON TMR1
    CLRF    cont_uhor
    INCF    cont_dhor
    MOVF    cont_dhor, W
    SUBLW   2
    BTFSC   ZERO
    BSF	    the_end, 0
    RETURN
    
CONT_MC:
    CLRF    cont_useg
    CLRF    cont_dseg
    CLRF    cont_umin
    CLRF    cont_dmin
    CLRF    cont_uhor
    CLRF    cont_dhor
    RETURN 
    
DEC_ALARM:
    INCF    cont_alarma
    MOVF    cont_alarma, W
    SUBLW   60
    BTFSS   ZERO
    GOTO    EXIT_DEC_ALARMA
    BCF	    alarma, 0
    BCF	    PORTA, 5
    EXIT_DEC_ALARMA:
    RETURN
    
TMR2_INT:
    BCF	    TMR2IF		; LIMPIAR BANDERA DE INTERRUPCION DEL TMR2
    INCF    Cont_T2		; INCREMENTAR CUENTA DEL TMR2
    MOVF    Cont_T2, W		; CARGAR CUENTA DEL TMR2 AL REGISTRO W
    SUBLW   10			; USO DE RESTA PARA DETERMINAR SI LA CUENTA HA LLEGADO A 10X50mS QUE SERIA 500mS
    BTFSC   ZERO		; SI NO SE HA LLEGADO A LOS 500mS CONTINUAR
    GOTO    INC_LED		; SI SE LLEGO A LOS 500mS IR A SUBRUTINA DE ACTIVACION DEL LED
    RETURN       
    
INC_LED:
    CLRF    Cont_T2		; LIMPIAR CUENTA DEL TMR2
    BTFSS   PORTA, 0
    GOTO    $+3
    BCF	    PORTA, 0
    GOTO    $+2
    BSF	    PORTA, 0
    BTFSS   PORTA, 1
    GOTO    $+3
    BCF	    PORTA, 1
    GOTO    $+2
    BSF	    PORTA, 1
    BTFSS   estado, 2
    GOTO    CONTINUE
    BTFSC   edicion, 2
    GOTO    CONTINUE
    CONT_TEST tmr_useg, tmr_dseg, tmr_umin, tmr_dmin, T_START, CONTINUE
    T_START:
    INCF    tmr_cont
    MOVF    tmr_cont, W
    SUBLW   2
    BTFSS   ZERO
    GOTO    CONTINUE
    CALL    TMR_DEC
    CONTINUE:
    BTFSC   edicion, 0
    GOTO    LED_E0
    BTFSC   edicion, 1
    GOTO    LED_E1
    BTFSC   edicion, 2
    GOTO    LED_E2
    RETURN    
    
    LED_E0:
	BTFSS   PORTA, 2
	GOTO    $+3
	BCF	PORTA, 2
	GOTO    $+2
	BSF	PORTA, 2
    RETURN
    
    LED_E1:
	BTFSS   PORTA, 3
	GOTO    $+3
	BCF	PORTA, 3
	GOTO    $+2
	BSF	PORTA, 3
    RETURN
    
    LED_E2:
	BTFSS   PORTA, 4
	GOTO    $+3
	BCF	PORTA, 4
	GOTO    $+2
	BSF	PORTA, 4
    RETURN
    
TMR_DEC:
    CLRF    tmr_cont
    BSF	    tmr_var, 0
    DECF    tmr_useg
    CONT_TEST tmr_useg, tmr_dseg, tmr_umin, tmr_dmin, END_TMR_DEC, ALARM_START
    GOTO    END_TMR_DEC
    
    ALARM_START:
    BCF	    tmr_var, 0
    BSF	    alarma, 0
    BSF	    PORTA, 5
    
    END_TMR_DEC:
    RETURN
    
//---------------------------INDICE DISPLAY 7SEG--------------------------------
PSECT HEX_INDEX, class = CODE, abs, delta = 2
ORG 200h			; posición 200h para el codigo
 
HEX_INDEX:
    CLRF PCLATH
    BSF PCLATH, 1		; PCLATH en 01
    ANDLW 0x0F
    ADDWF PCL			; PC = PCLATH + PCL | SUMAR W CON PCL PARA INDICAR POSICIÓN EN PC
    RETLW 00111111B		; 0
    RETLW 00000110B		; 1
    RETLW 01011011B		; 2
    RETLW 01001111B		; 3
    RETLW 01100110B		; 4
    RETLW 01101101B		; 5
    RETLW 01111101B		; 6
    RETLW 00000111B		; 7
    RETLW 01111111B		; 8 
    RETLW 01101111B		; 9
    RETLW 01110111B		; A
    RETLW 01111100B		; b
    RETLW 00111001B		; C
    RETLW 01011110B		; D
    RETLW 01111001B		; C
    RETLW 01110001B		; F   
    
//------------------------------MAIN CONFIG-------------------------------------
main:
    CALL    IO_CONFIG		; INICIAR CONFIGURACION DE PINES
    CALL    CLK_CONFIG		; INICIAR CONFIGURACIÓN DE RELOJ
    CALL    TMR0_CONFIG
    CALL    TMR1_CONFIG
    CALL    TMR2_CONFIG		; INICIAR CONFIGURACION DEL TMR2
    CALL    IOCRB_CONFIG	; INICIAR CONFIGURACION DE IOC EN PORTB
    CALL    INT_CONFIG		; INICIAR CONFIGURACION DE INTERRUPCIONES
    BANKSEL PORTA

LOOP:
    BTFSC   estado, 0
    GOTO    DISP_HORA 
    BTFSC   estado, 1
    GOTO    DISP_FECHA
    BTFSC   estado, 2
    GOTO    DISP_TIMER
    GOTO    LOOP
    
    DISP_HORA:
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    GOTO LOOP
    
    DISP_FECHA:
;    SET_DISPLAY 
    GOTO LOOP
    
    DISP_TIMER:
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    BTFSS   tmr_var, 0
    GOTO    EXIT_DISP_TIMER
    DEC_UF_TEST	0xFF, 9, tmr_useg, EXIT_DISP_TIMER
    DECF    tmr_dseg
    DEC_UF_TEST	0xFF, 5, tmr_useg, EXIT_DISP_TIMER
    DECF    tmr_umin
    DEC_UF_TEST	0xFF, 9, tmr_umin, EXIT_DISP_TIMER
    DECF    tmr_dmin
    DEC_UF_TEST	0xFF, 0, tmr_dmin, EXIT_DISP_TIMER
    
    EXIT_DISP_TIMER:
    GOTO LOOP
    
//---------------------------CONFIG SUBRUTINES----------------------------------
CLK_CONFIG:
    BANKSEL OSCCON		; SELECCIONAR CONFIGURADOR DEL OSCILADOR
    BSF	    SCS			; USAR OSCILADOR INTERNO PARA RELOJ DE SISTEMA
    BCF	    IRCF0		; BIT 4 DE OSCCON EN 0
    BSF	    IRCF1		; BIT 5 DE OSCCON EN 1
    BSF	    IRCF2		; BIT 6 DE OSCCON EN 1
    //OSCCON 110 -> 4MHz RELOJ INTERNO
    RETURN
    
IOCRB_CONFIG:
    BANKSEL IOCB		; SELECCIONAR BANCO DONDE SE ENCUENTRA IOCB
    BSF	    IOCB, 0		; ACTIVAR IOCB PARA PUSHBOTTON 1
    BSF	    IOCB, 1		; ACTIVAR IOCB PARA PUSHBOTTON 2
    BSF	    IOCB, 2		; ACTIVAR IOCB PARA PUSHBOTTON 3
    BSF	    IOCB, 3		; ACTIVAR IOCB PARA PUSHBOTTON 4
    
    BANKSEL PORTA		; SELECCIONAR EL BANCO 0
    MOVF    PORTB, W		; CARGAR EL VALOR DEL PORTB A W PARA CORREGIR MISMATCH
    BCF	    RBIF		; LIMPIAR BANDERA DE INTERRUPCIÓN EN PORTB
    RETURN    
    
IO_CONFIG:
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH		; I/O digitales
    
    BANKSEL TRISC
    CLRF    TRISC		; PORTC como salida
    MOVLW   0xF0
    MOVWF   TRISD		; PORTD 4 PINES PARA MULTIPLEX
    MOVLW   0xFC
    MOVWF   TRISE		; PORTE 2 PINES PARA ESTADOS
    BSF	    TRISB, 0
    BSF	    TRISB, 1
    BSF	    TRISB, 2
    BSF	    TRISB, 3
    CLRF    TRISA
    
    BCF	    OPTION_REG, 7	; LIMPIAR RBPU PARA DESBLOQUEAR EL MODO PULL-UP EN PORTB
    BSF	    WPUB, 0		; SETEAR WPUB PARA ATVICAR EL PIN 0 DEL PORTB COMO WEAK PULL-UP
    BSF	    WPUB, 1		; SETEAR WPUB PARA ACTIVAR EL PIN 1 DEL PORTB COMO WEAK PULL-UP
    BSF	    WPUB, 2
    BSF	    WPUB, 3
    
    BANKSEL PORTC		; SELECCIONAR BANCO 0
    CLRF    PORTC		; LIMPIEZA DE PUERTOS 
    CLRF    PORTD		; 
    CLRF    PORTE
    CLRF    PORTA
    CLRF    bandera
    CLRF    L_display
    CLRF    R_display
    CLRF    alarma
    CLRF    cont_alarma
    CLRF    edicion
    CLRF    estado
    CLRF    inc_flag
    CLRF    cont_useg
    CLRF    cont_dseg
    CLRF    cont_umin
    CLRF    cont_dmin
    CLRF    cont_uhor
    CLRF    cont_dhor
    CLRF    tmr_var
    CLRF    tmr_cont
    CLRF    tmr_useg
    CLRF    tmr_dseg
    CLRF    tmr_umin
    CLRF    tmr_dmin
    CLRF    Cont_T2
    CLRF    Cont_Hora
    CLRF    edit
    CLRF    the_end
    RETURN    

TMR0_CONFIG:
    BANKSEL OPTION_REG		; SELECCIONAR BANCO 1 PARA TMR0 CONFIG
    BCF	    T0CS		; USO DE RELOJ INTERNO
    BCF	    PSA			; PRESCALER A TMR0
    BSF	    PS2			; PRESCALER EN 256
    BSF	    PS1
    BSF	    PS0
    
    BANKSEL TMR0		; SELECIONAR EL BANCO 
    MOVLW   250			; N=256-[(2mS*4MHz)/(4x256)]=248 redondeado es: 250
    MOVWF   TMR0		; CARGAR VALOR DE N AL TMR0 
    BCF	    T0IF		; LIMPIAR BANDERA DE INTERRUPCION DE TMR0
    RETURN
    
TMR1_CONFIG:
    BANKSEL T1CON		; SELECIONAR EL BANCO DEL T1CON
    BCF	    TMR1GE		; ACTIVAR CUENTA PERPETUA EN TMR1
    BSF	    T1CKPS1		; PRESCALER EN 1:8
    BSF	    T1CKPS0		; |	    |	|
    BCF	    T1OSCEN		; MODO DE BAJA POTENCIA ACTIVADO
    BCF	    TMR1CS		; USO DEL RELOJ INTERNO
    BSF	    TMR1ON		; ENCENDIDO DEL TMR1
    
    TMR1_RESET 0x0B, 0xDC	; REINICIO DEL TMR1 EN 500mS
    ; VALOR A CARGAR: 65536-(0.5)/[8(1/1x10^6)]=3036d=0x0BDC
    RETURN    
    
TMR2_CONFIG:
    BANKSEL PR2			; SELECCIONAR BANCO DEL PR2
    MOVLW   195			; CARGAR VALOR CALCULADO PARA INTERRUPCIONES DE 50mS EN EL TMR2 AL REGISTRO W
    MOVWF   PR2			; MOVER VALOR AL PR2
    
    BANKSEL T2CON		; SELECCIONAR EL BANCO DEL T2CON
    BSF	    T2CKPS1		; PRESCALER EN 1:16
    BSF	    T2CKPS0		
    
    BSF	    TOUTPS3		; POSTSCALER EN 1:16
    BSF	    TOUTPS2		
    BSF	    TOUTPS1
    BSF	    TOUTPS0
    BSF	    TMR2ON		; ENCENDIDO DEL TMR2
    RETURN    
    
INT_CONFIG:
    BANKSEL PIE1		; SELECCIONAR BANCO DEL PIE1
    BSF	    TMR1IE		; HABILITAR INTERRUPCIONES EN TMR1
    BSF	    TMR2IE		; HABILITAR INTERRUPCIONES EN TMR2
    
    BANKSEL INTCON
    BSF	    PEIE		; HABILITAR INTERRUPCIONES EN PERIFERICOS
    BSF	    GIE			; ACTIVAR INTERRUPCIONES GLOBALES
    BSF	    RBIE		; ACTIVAR CAMBIO DE INTERRUPCIONES EN PORTB
    BCF	    RBIF		; LIMPIAR BANDERA DE CAMBIO EN PORTB POR SEGURIDAD
    BSF	    T0IE		; HABILITAR INTERRUPCIONES EN TMR0
    BCF	    T0IF		; LIMPIAR BANDERA DE INTERRUPCIONES EN TMR0
    BCF	    TMR1IF		; LIMPIAR BANDERA DE INTERRUPCIONES EN TMR1
    BCF	    TMR2IF		; LIMPIAR BANDERA DE INTERRUPCIONES EN TMR2
    RETURN
    
//-------------------------------SPST SUBRUTINES--------------------------------    
FMS_CONFIG:
    BTFSC   PORTB, 0
    GOTO    EXIT_FMS_CONFIG
    BTFSC   edicion, 3		; REVISAR SI SE ESTA EN MODO DE EDICION
    GOTO    EDITANDO		; SI SE ESTA EN DICHO MODO, ACCEDER SECCION PARA EDICION DE FUNCIONES
    BTFSC   alarma, 0		; REVISAR SI ESTA PRENDIDA LA ALARMA
    CALL    ALARM_OFF		; SI ESTA PRENDIDA, IR A SUBRUTINA DE APAGADO DE ALARMA
    INCF    PORTE		; INCREMENTAR PORTE PARA REGISTRO DE ESTADOS
    BTFSS   PORTE, 0		; REVISAR SI EL BIT0 DEL PORTE ESTA EN 0
    CALL    AJUSTE_ESTADO	; SI ESTA EN 0 IR A AJUSTE DE ESTADO PARA SALIR DEL ESTADO 00
    MOVF    PORTE, W		; SI NO ESTABA EN 0, REVISAR SI EL VALOR DE PORTE ES 1
    SUBLW   1			; USO DE RESTA PARA REVISAR SI VALOR DEL PORTE ES 1
    BTFSC   ZERO		; BANDERA DE ZERO PARA DETERMINAR EL ESTADO AL QUE SE DEBE ACCEDER
    CALL    MODO_HORA		; SI SE ESTABA EN 1 IR A MODO HORA (PRIMER ESTADO)
    MOVF    PORTE, W		; SI NO SE ESTABA EN 1 REVISAR EL VALOR DEL PUERTO NUEVAMENTE
    SUBLW   2			; USO DE RESTA PARA REVISAR SI EL VALOR DE PORTE ES 2
    BTFSC   ZERO		; BANDERA DE ZERO PARA DETERMINAR EL ESTADO AL QUE SE DEBE ACCEDER
    CALL    MODO_FECHA		; SI SE ESTABA EN 2 IR A MODO FECHA (SEGUNDO ESTADO)
    MOVF    PORTE, W		; SI NO SE ESTABA EN 2 REVISAR EL VALOR DEL PUERTO NUEVAMENTE
    SUBLW   3			; USO DE RESTA PARA REVISAR SI EL VALOR DE PORTE ES 3
    BTFSC   ZERO		; BANDERA DE ZERO PARA DETERMINAR EL ESTADO AL QUE SE DEBE ACCEDER
    CALL    MODO_TIMER		; SI SE ESTABA EN 3 IR A MODO TIMER (TERCER Y ULTIMO ESTADO)
    RETURN
    EDITANDO:			; SI SE ESTA EN MODO DE EDICION
    BTFSS   edit, 0		; BANDERA "edit" USADA PARA EDITAR HORAS/MINUTOS O MINUTOS/SEGUNDOS
    GOTO    $+3			
    BCF	    edit, 0		; SI LA BANDERA ESTA EN 0 EDITAR TIEMPO DE MENOR DENOMINACION
    GOTO    $+2
    BSF	    edit, 0		; SI LA BANDERA ESTA EN 1 EDITAR TIEMPO DE MAYOR DENOMINACION
    EXIT_FMS_CONFIG:
    RETURN
    
EDIT_CONFIG:
    BTFSC   estado, 0		; REVISAR LA BANDERA DE ESTADO PARA DETERMINAR EL ESTADO A MODIFICAR
    GOTO    ESTADO_0
    BTFSC   estado, 1
    GOTO    ESTADO_1
    BTFSC   estado, 2
    GOTO    ESTADO_2
    RETURN
    
    ESTADO_0:
	BTFSS   edicion, 0	; PRIMERO SE REVISA SI YA SE ESTABA EN MODO DE EDICION PARA ESTADO 0
	GOTO    $+5		; SI NO SE ESTABA EN MODO DE EDICION, SE ACTIVAN LAS BANDERAS NECESARIAS
	BCF	edicion, 0	; SI SE ESTABA EN EL MODO DE EDICION SE LIMPIAN LAS BANDERAS
	BCF	edicion, 3	; PARA SALIR DEL MODO DE EDICION
	BSF	PORTA, 2	; SE ENCIENDE EL LED PARA QUE ESTE QUEDE FIJO
	GOTO    $+3		; SE SALTAN LAS SIGUIENTES DOS INSTRUCCIONES PARA NO
	BSF	edicion, 0	; BANDERA QUE INDICA QUE SE ESTA EDITANDO ESTADO 0
	BSF	edicion, 3	; BANDERA QUE INDICA QUE SE ESTA EN MODO DE EDICION
    RETURN

    ESTADO_1:
	BTFSS   edicion, 1
	GOTO    $+5
	BCF	edicion, 1
	BCF	edicion, 3
	BSF	PORTA, 3
	GOTO    $+3
	BSF	edicion, 1
	BSF	edicion, 3
    RETURN

    ESTADO_2:
	BTFSS   edicion, 2
	GOTO    $+5
	BCF	edicion, 2
	BCF	edicion, 3
	BSF	PORTA, 4
	GOTO    $+3
	BSF	edicion, 2
	BSF	edicion, 3
    RETURN
    
AJUSTE_ESTADO:
    BTFSS   PORTE, 1		; REVISAR SI EL SEGUNDO BIT DE PORTE ES 0 TAMBIEN
    BSF	    PORTE, 0		; SI LO ES, SETEARLO A 1 DE MANERA QUE NO SE PUEDA
    RETURN			; ACCEDER EL ESTADO 00 MAS QUE AL INICIO
    
INC_CONFIG:
    INC_MIN0:
    BTFSC   edit, 0
    GOTO    INC_HORA0
    BTFSS   edicion, 0
    GOTO    INC_SEG2
    INCF    cont_umin
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    INC_OF_TEST 10, cont_umin, END_INC
    INCF    cont_dmin
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    INC_OF_TEST 6, cont_dmin, END_INC
    CLRF    cont_umin
    CLRF    cont_dmin
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    INC_HORA0:
    BTFSS   edit, 0
    GOTO    INC_MIN0
    BTFSS   edicion, 0
    GOTO    INC_MIN2
    INCF    cont_uhor
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    BTFSC   the_end, 0
    GOTO    HORA_END
    INC_OF_TEST 10, cont_uhor, END_INC
    INCF    cont_dhor
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    MOVF    cont_dhor, W
    SUBLW   2
    BTFSC   ZERO
    BSF	    the_end, 0
    GOTO    END_INC
    HORA_END:
    MOVF    cont_uhor, W
    SUBLW   4
    BTFSS   ZERO
    GOTO    END_INC
    BCF	    the_end, 0
    CLRF    cont_dhor
    CLRF    cont_uhor
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    GOTO END_INC
    
    INC_SEG2:
    BTFSC   edit, 0
    GOTO    INC_MIN2
    BTFSS   edicion, 2
    GOTO    END_INC
    INCF    tmr_useg
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    INC_OF_TEST 10, tmr_useg, END_INC
    INCF    tmr_dseg
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    INC_OF_TEST 6, tmr_dseg, END_INC
    CLRF    tmr_useg
    CLRF    tmr_dseg
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    INC_MIN2:
    BTFSS   edit, 0
    GOTO    INC_SEG2
    INCF    tmr_umin
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    INC_OF_TEST 10, tmr_umin, END_INC
    INCF    tmr_dmin
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    INC_OF_TEST 10, tmr_dmin, END_INC
    CLRF    tmr_umin
    CLRF    tmr_dmin
    
    END_INC:
    RETURN
    
DEC_CONFIG:
    DEC_MIN0:
    BTFSC   edit, 0
    GOTO    DEC_HORA0
    BTFSS   edicion, 0
    GOTO    DEC_SEG2
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    MOVF    cont_dmin, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    TAG1
    MOVF    cont_umin, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    TAG1
    DECF    cont_umin
    MOVF    cont_umin, W
    SUBLW   0xFF
    BTFSS   ZERO
    GOTO    TAG1
    MOVLW   9
    MOVWF   cont_umin
    MOVLW   5
    MOVWF   cont_dmin
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    RETURN
    TAG1:
    DECF    cont_umin
    MOVF    cont_umin, W
    SUBLW   0xFF
    BTFSC   ZERO
    GOTO    RESET1
    GOTO    END_DEC
    RESET1:
    MOVLW   9
    MOVWF   cont_umin
    DECF    cont_dmin
    MOVF    cont_dmin, W
    SUBLW   0xFF
    BTFSC   ZERO
    GOTO    TAG2
    GOTO    END_DEC
    TAG2:
    MOVLW   5
    MOVWF   cont_dmin
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    GOTO    DEC_MIN0
    DEC_HORA0:
    BTFSS   edit, 0
    GOTO    DEC_MIN0
    BTFSS   edicion, 0
    GOTO    DEC_SEG2
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    MOVF    cont_dhor, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    TAG3
    MOVF    cont_uhor, W
    SUBLW   0
    BTFSS   ZERO
    GOTO    TAG3
    DECF    cont_uhor
    MOVF    cont_uhor, W
    SUBLW   0xFF
    BTFSS   ZERO
    GOTO    TAG3
    MOVLW   3
    MOVWF   cont_uhor
    MOVLW   2
    MOVWF   cont_dhor
    BSF	    the_end, 0
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    RETURN
    TAG3:
    BCF	    the_end, 0
    DECF    cont_uhor
    MOVF    cont_uhor, W
    SUBLW   0xFF
    BTFSC   ZERO
    GOTO    RESET2
    GOTO    END_DEC
    RESET2:
    MOVLW   9
    MOVWF   cont_uhor
    DECF    cont_dhor
    MOVF    cont_dhor, W
    SUBLW   0xFF
    BTFSC   ZERO
    GOTO    TAG4
    GOTO    END_DEC
    TAG4:
    BCF	    the_end, 0
    MOVLW   2
    MOVWF   cont_dhor
    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    GOTO    DEC_MIN0
    
    
    DEC_SEG2:
    BTFSC   edit, 0
    GOTO    DEC_MIN2
    BTFSS   edicion, 2
    GOTO    END_DEC
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    DECF    tmr_useg
    DEC_UF_TEST 0xFF, 10, tmr_useg, END_DEC
    DECF    tmr_dseg
    DEC_UF_TEST 0xFF, 5, tmr_dseg, END_DEC
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin    
    DEC_MIN2:
    BTFSS   edit, 0
    GOTO    DEC_SEG2
    BTFSS   edicion, 2
    GOTO    END_DEC
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin
    DECF    tmr_umin
    DEC_UF_TEST 0xFF, 9, tmr_umin, END_DEC
    DECF    tmr_dmin
    DEC_UF_TEST 0xFF, 9, tmr_dmin, END_DEC
    SET_DISPLAY tmr_useg, tmr_dseg, tmr_umin, tmr_dmin 
    END_DEC:
;    SET_DISPLAY cont_umin, cont_dmin, cont_uhor, cont_dhor
    RETURN
    
ALARM_OFF:
    BCF	    alarma, 0
    BCF	    PORTA, 5
    RETURN
    
MODO_HORA:
    BTFSC   estado, 2
    BCF	    estado, 2
    BSF	    estado, 0
    BTFSC   PORTA, 4
    BCF	    PORTA, 4
    BSF	    PORTA, 2
    RETURN
    
MODO_FECHA:
    BTFSC   estado, 0
    BCF	    estado, 0
    BSF	    estado, 1
    BTFSC   PORTA, 2
    BCF	    PORTA, 2
    BSF	    PORTA, 3
    RETURN
    
MODO_TIMER:
    BTFSC   estado, 1
    BCF	    estado, 1
    BSF	    estado, 2
    BTFSC   PORTA, 3
    BCF	    PORTA, 3
    BSF	    PORTA, 4
    CLRF    PORTE
    RETURN
    
//------------------------------MULTIPLEXADO------------------------------------   
SHOW_DISPLAY:
    BCF	    PORTD, 0		; LIMPIAR PIN0 DE PORTD
    BCF	    PORTD, 1		; LIMPIAR PIN1 DE PORTD
    BCF	    PORTD, 2		; LIMPIAR PIN1 DE PORTD
    BCF	    PORTD, 3		; LIMPIAR PIN1 DE PORTD
    MOVF    bandera, W
    SUBLW   1
    BTFSC   ZERO
    GOTO    DISPLAY_1		; SI LA BANDERA ESTA EN 1 INICIAR RDISPLAY_1
    MOVF    bandera, W
    SUBLW   2
    BTFSC   ZERO
    GOTO    DISPLAY_2		; SI LA BANDERA ESTA EN 1 INICIAR LDISPLAY_2
    MOVF    bandera, W
    SUBLW   3
    BTFSC   ZERO
    GOTO    DISPLAY_3		; SI LA BANDERA ESTA EN 1 INICIAR LDISPLAY_3
    
    DISPLAY_0:			; SI LA BANDERA ESTABA EN 0 INICIAR DISPLAY_0
	MOVF    R_display, W	; MOVER VALOR DE DISPLAY_0 A REGISTRO W
	MOVWF   PORTC		; CARGAR VALOR AL PORTC PARA MOSTRAR EN DISPLAY
	BSF	PORTD, 0	; ACTIVAR PIN1 DE PORTD PARA ACTIVAR DISPLAY_0
	MOVLW	0x01
	MOVWF	bandera		;
    RETURN
	
    DISPLAY_1:
	MOVF    R_display+1, W	; MOVER VALOR DE DISPLAY_1 A REGISTRO W
	MOVWF   PORTC		; CARGAR VALOR AL PORTC PARA MOSTRAR EN DISPLAY
	BSF	PORTD, 1	; ACTIVAR PIN0 DE PORTD PARA ACTIVAR DISPLAY_1
	MOVLW	0x02
	MOVWF	bandera		; SETEAR BANDERA A 0 PARA REINICIAR
    RETURN
	
    DISPLAY_2:
	MOVF    L_display, W	; MOVER VALOR DE DISPLAY_1 A REGISTRO W
	MOVWF   PORTC		; CARGAR VALOR AL PORTC PARA MOSTRAR EN DISPLAY
	BSF	PORTD, 2	; ACTIVAR PIN0 DE PORTD PARA ACTIVAR DISPLAY_1
	MOVLW	0x03
	MOVWF	bandera		; SETEAR BANDERA A 0 PARA REINICIAR
    RETURN
	
    DISPLAY_3:
	MOVF    L_display+1, W	; MOVER VALOR DE DISPLAY_1 A REGISTRO W
	MOVWF   PORTC		; CARGAR VALOR AL PORTC PARA MOSTRAR EN DISPLAY
	BSF	PORTD, 3	; ACTIVAR PIN0 DE PORTD PARA ACTIVAR DISPLAY_1
	MOVLW	0x0
	MOVWF	bandera		; SETEAR BANDERA A 0 PARA REINICIAR
    RETURN
END    