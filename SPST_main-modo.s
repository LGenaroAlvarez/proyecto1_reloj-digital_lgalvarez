    #include <xc.inc>

    GLOBAL INT_IOCRB    

    PSECT code
    ORG   04h
    //----------------------------INT SUBRUTINAS------------------------------------    
    INT_IOCRB:			; SUBRUTINA DE INTERRUPCIÓN EN PORTB
	BANKSEL PORTA		; SELECCIONAR BANCO 0
	BTFSS   PORTB, 0		; REVISAR SI EL BIT DEL PRIMER BOTON EN RB HA CAMBIADO A 0
	INCF    PORTE		; SI HA CAMBIADO A 0 (HA SIDO PRESIONADO) INCREMENTAR CUENTA EN PORTA
	BTFSS   PORTB, 1		; REVISAR SI EL BIT DEL SEGUNDO BOTON EN RB HA CAMBIADO A 0
	INCF    PORTA		; SI HA CAMBIADO A 0 (HA SIDO PRESIONADO) DISMINUIR LA CUENTA EN PORTA
	BTFSS   PORTB, 2
	DECF    PORTA
	BTFSS   PORTB, 3
	INCF    PORTD
	BCF	RBIF		; LIMPIAR LA BANDERA DE PORTB
	RETURN  
END

