;Programa desarrollado por Oscar Casarrubias Paredes

.model small
.stack
.data
	edText DB "--- VI   para   Windows   ---$"
	enterMs db "Presiona ENTER para SALIR$"
	oscar db "Oscar Casarrubias Paredes$"
	fernando db "Fernando Ruiz Ruiz$"
	ana db "Ana Rodriguez Armas$"
	victor db "Victor Emanuel Garcia$"
	color db 15 ; 0= NEGRO, 1=AZUL, 2=VERDE, 3=Verde-Azulado, 4=ROJO, 5=Violeta, 6=AMARILLO,
				; 7=BLANCO, 8=GRIS, 9=Azul Rey, 10=Verde Claro, 11=Azul Claro, 12=Rojo Claro,
				; 13=ROSA, 14=Amarillo Claro, 15=Blanco Claro, 16=De aqui en adelante cambia junto con el fondo
				
	edit db       "MODO DE EDICION. --> Presiona ESC para volver a menu de comandos          $"
	command db    "MODO LINEA DE COMANDOS. --> w=Guardar q=Salir e=Editar c=Color a=Abrir    $"
	menucolor db  "Colores n=Negro, a=Azul Marino, v=Verde, r=Rojo, m=Violeta, +=Mas colores $"
	menucolor2 db "a=Amarillo, b=Blanco, g=Gris, v=Verde Claro, r Rojo Claro,  +=Mas colores $"
	menucolor3 db "a=Azul Claro, b=Blanco Claro, k=Azul Rey, y=Amarillo Claro, r=Rosa        $"
	menusave   db "GUARDAR   n=En archivo nuevo, g=En el archivo actual$"
	newFileq    db "Ingresa el nombre del archivo en que se guardara la informacion           $"
	pageN db 0
	pages db 0 ; Para iteracion sobre las paginas al guardar y leer desde archivo
	openfile	db "¿Que archivo deseas abrir?                                                $"
	
	;;;Datos de archivo
	NOMARCH DB 'untitled.txt',0 ; El nombre por defecto será untitled.txt
	NEWFILE DB 'untitled.txt',0 ; El archivo a guardar por defecto sera untitled.txt
	HANDLE   DW ?
	HANDLE2   DW ?
	FBUFF	 DB ?        ;ARCHIVO DE DATOS DEL BUFFER
	OEMSG    DB 'No se puede abrir el archivo $'
	RFMSG    DB 'No se puede leer el archivo $'
	CFMSG    DB 'No se puede cerrar el archivo $'
	NESC	 DB 'NO se puede escribir en el archivo$'
	char	 DB ?
	
.code


;/*******************************MACROS*********************************/
	
	PAGEM MACRO a
		MOV AH,05H ;Petición de página activa
		MOV AL,a ; Número de página
		INT 10H 
	ENDM
	
;/********************** FIN MACROS    *********************************/

;/*************************  FUNCIONES ****************************/
	
	CLEANALL PROC
		pagem 4 
		call clrscr
		pagem 3
		call clrscr
		pagem 2
		call clrscr
		pagem 1
		call clrscr
		pagem 0
		call clrscr
		ret
	CLEANALL ENDP
	
	CLRSCR PROC ;;;;;;;;;;;;;Este procedimiento limpia la pantalla del sistema
		MOV Ah,06
		mov al,0
		MOV BH,07H
		MOV CX,0000
		MOV DX,184FH
		INT 10H   ;LIMPIA PANTALLA
	RET
	CLRSCR ENDP

	CURSOR PROC
		MOV AH,02H
		MOV BH,pagen
		INT 10H
		ret
	CURSOR ENDP
	
	PRINTPAGE PROC ;;Imprime el numero de pagian actual
		push cx
		mov dh,24
		mov dl,79
		call cursor
		MOV AH,09h
		mov al,pagen
		add al,31h
		mov bh,pageN
		mov bl,7
		mov cx,1
		int 10h
		pop cx
		ret
	printpage endp

	PRINTSTRING PROC ;;Imprime la cadena apuntada por dx
		mov ah,09h
		int 21h
	PRINTSTRING ENDP

	SALTO PROC
		CMP AL,13
		JE SALT
		RET
		SALT:
		MOV CL,79
		CALL COLUMNA
		mov al,00
		dec cl
		RET
	SALTO ENDP

	COLUMNA PROC
		CMP CL,79
		JE CDATO
		INC CL
		mov dl,cl
		RET
		CDATO:
		MOV CL,0
		mov dl,cl
		CALL FILA
		RET
	COLUMNA ENDP

	FILA PROC
		CMP CH,22
		JE DATO
		INC CH
		mov dh,ch
		RET
		DATO:
		cmp pageN,4
		je fila2
		inc pageN
		pageM pageN
		mov ch,0
		mov dh,ch
		fila2:
		RET
	FILA ENDP

	AUTORES PROC
		mov pagen,0
		MOV DH,6
		MOV DL,25
		call cursor
		MOV DX, OFFSET edText
		call printString
		
		MOV DH,10
		MOV DL,30
 		call cursor
		MOV DX, OFFSET ana
		call printString
	
		MOV DH,12
		MOV DL,27
		call cursor
		MOV DX, OFFSET oscar
		call PRINTSTRING
	
		MOV DH,14
		MOV DL,30
		CALL CURSOR
		MOV DX, OFFSET fernando
		call printString

		MOV DH,16
		MOV DL,29
		call cursor
		MOV DX, OFFSET victor
		call printstring
		
		MOV DH,24
		MOV DL,50
		call cursor
		MOV DX, OFFSET enterms
		call printString

		MOV AX,0000
		 MAIN:
		MOV AH,06H
		MOV DL,0FFH
		INT 21H
		CMP AL,13
		JNE MAIN
 	RET
	AUTORES ENDP   

	LEEARCH PROC
		push cx
		push dx
		call cleanall
		mov pagen,0
		
		iterpage2:
		mov dh,0
		iterrow2:
		mov dl,0
		itercol2:
		call cursor
		;;Leemos un caracter desde el archivo abierto
		push dx
		MOV AH,3FH
		MOV BX,HANDLE
		LEA DX,FBUFF
        MOV CX,1
        INT 21H
		JC ERRORLEE2
		CMP AX,0
		JZ EOFF2
        CMP al,1AH
		JZ EOFF2
		pop dx
		mov al,fbuff
		cmp al,13
		jne cont6
		mov dl,79
		mov al,0
		cont6:
		cmp al,10
		jne cont7
		mov al,0
		cont7:
		;Imprimimos el caracter leido del archivo en la pantalla
		push dx
		MOV AH,09h
		mov bh,pageN
		mov bl,color
		mov cx,1
		int 10h
		pop dx
		INC DL
		CMP DL,80 ; Fin de columna
		JNE ITERCOL2
		INC DH
		CMP DH,23 ;fin de pagina
		JNE ITERROW2
		
		inc pagen
		cmp pagen,5
		jne iterpage2 ; fin de documento
		pop dx
		pop cx
		mov pagen,0
		ret
		ERRORLEE2:
		LEA DX,RFMSG
		MOV AH,9
		INT 21H
		EOFF2:
		pop dx
		pop dx
		pop cx
		RET
	LEEARCH ENDP
	
	CREARCH PROC
		call printString
		mov di,0
		mov dh,23
		mov dl,0
		call cursor
		leec:
		MOV AH,01H
		MOV DL,0FFH
		INT 21H		;; Leemos un caracter
		cmp al,13
		je rett
		mov newfile[di],al ; Guardamos el caracter en la cadena
		inc di
		jmp leec
		rett:
		mov newfile[di],0
		
		;/** Ahora creamos el archivo **/
		mov dx, offset newfile
		mov cx,0
		mov ah,3ch
		int 21h ; Se crea el archivo
		mov handle2,ax
		call cierraarch
		ret		
	CREARCH ENDP
	
	ABREARCH PROC
	
		mov al,1
		mov ah,3dh
		int 21h
		jc errorab
		mov handle2,ax
		RET
		errorab:
		lea dx,oemsg
		call printstring
		ret
	ABREARCH ENDP
	
	ABREARCH2 PROC
		mov al,0
		mov ah,3dh
		int 21h
		jc errorab2
		mov handle,ax
		RET
		errorab2:
		lea dx,oemsg
		call printstring
		ret
	ABREARCH2 ENDP
	
	CIERRAaRCH PROC
		MOV AH,3EH
		MOV BX,HANDLE2
		INT 21H
		JC ERRORCIE
		RET
		ERRORCIE:LEA DX,CFMSG
		call printstring
		MOV AH,9
		INT 21H
	
		RET
	CIERRAaRCH ENDP
	CIERRAaRCH2 PROC
		MOV AH,3EH
		MOV BX,HANDLE
		INT 21H
		JC ERRORCIE2
		RET
		ERRORCIE2:LEA DX,CFMSG
		call printstring
		MOV AH,9
		INT 21H
	
		RET
	CIERRAaRCH2 ENDP
	
	leepant proc
		mov ah, 08
		mov bh,pagen
		int 10h
		cmp al,0
		jne cont
		mov al,32
		cont:
		mov char,al
		ret
	leepant endp
	
	ESCARCH PROC
		push cx
		push dx
		
		;/** Leemos del teclado hasta que sea un enter **/
		MOV PAGEN,0
		ITERPAGE: ;;;Iniciamos con el ciclo que itere sobre las paginas
		mov dh,0 ;; inicializamos la pantalla
		ITERROW: ;iTERANDO SOBRE LOS RENGLONES
		mov dl, 0
		ITERCOLUMN: ;iTERANDO SOBRE LAS COLUMNAS
		call cursor
		call leepant
		push dx
		mov ah,40h
		mov bx,handle2
		lea dx,char
		mov cx,1
		int 21h
		jc  ERRORESC
		pop dx
		INC DL
		CMP DL,80 ; Fin de columna
		JNE ITERCOLUMN
		push dx
		mov ah,40h
		mov bx,handle2
		mov char,13
		lea dx,char
		mov cx,1
		int 21h
		jc  ERRORESC
		pop dx
		INC DH
		CMP DH,23 ;fin de pagina
		JNE ITERROW
		inc pagen
		cmp pagen,5
		jne iterpage ; fin de documento
		pop dx
		pop cx
		mov pagen,0
		ret
		ERRORESC:
		mov ch,24
		mov cl,0
		LEA DX,NESC
		call printstring
		pop dx
		pop cx
		ret
	ESCARCH ENDP
	
	SAVEP PROC
		mov dh,24
		mov dl,00
		call cursor
		lea dx, newfileq
		call crearch
		lea dx, newfile
		mov cl,pagen
		push cx
		call abrearch
		call escarch
		call cierraarch
		pop cx
		mov pagen,cl
		ret
	SAVEP ENDP
	
	open proc
		mov dh,24
		mov dl,00
		call cursor		
		lea dx, openfile
		call printString
		mov di,0
		mov dh,23
		mov dl,0
		call cursor
		leec2:
		MOV AH,01H
		MOV DL,0FFH
		INT 21H		;; Leemos un caracter
		cmp al,13
		je rett2
		mov nomarch[di],al ; Guardamos el caracter en la cadena
		inc di
		jmp leec2
		rett2:
		mov nomarch[di],0
	
		lea dx, nomarch
		call abrearch2
		call leearch
		call cierraarch2
		ret
	open endp
		
;/********************** FIN FUNCIONES *********************************/


	INICIO:
		MOV AX,@DATA
		MOV DS,AX
		CALL CLRSCR
	jmp comandos
	
	;;;Modo de Edicion
	EDICION:
		MOV DH,24
		MOV DL,0
		call cursor
		MOV DX, OFFSET edit
		call printString
		jmp lee ;;;
	;;;Fin Edicion

	;;;Iniciamos la pantalla con el menu de  comandos
	COMANDOS:
		MOV DH,24
		MOV DL,0
		call cursor
		MOV DX, OFFSET command
		call printString			
		com:
		MOV DH,23
		MOV DL,0
		call cursor
		MOV AH,07H
		MOV DL,0FFH
		INT 21H
	
		CMP AL,101 ; e  Modo de edicion
			JE edicion
		CMP AL,119 ;w Guardar
			JE save
		CMP AL,113 ;q Salir
			JE fin
		CMP AL, 120 ; x  Guardar y salir
			JE save_end 
		cmp al, 99  ; c cambiar color
			je menuc1
		cmp al, 97 ; a abrir
			je abrir
		jmp com
		
 	;;;;;;;;;;;;;;;;;;Finaliza comando
 	abrir:
 	call open
 	jmp comandos
	save_end:
	save:
		call savep
		jmp comandos
		
		comandos2:
		jmp comandos
	
	;/*****FINALIZACION DEL PROGRAMA********/
	FIN:
		call cleanall
		;pagem 0
   		CALL AUTORES ;;; Los creditos no pueden faltar
   		call clrscr
   		mov dh,0
		mov dl,0
		call cursor
   		MOV AH,4CH ;; Le regresamos el control a ms-dos
   		INT 21H

		menuc1:
		jmp menuc

	;;;Lee desde el teclado y lo posiciona en pantalla
	LEE:
		;push cx
		;mov	ah,01		;Seleccionamos el tipo de cursor
		;mov	cl,15
		;mov	ch,3
		;int	10h
		;pop cx		

   		MOV AH,07H
   		;MOV DL,0FFH
		INT 21H		;; Leemos un caracter
 			;JE LEE
   		CALL SALTO
   		CMP AL,77	;;Flecha derecha presionada???
 			JE lee
   		CMP AL,75	;;Flecha izquierda presionada???
 			JE izquierda
   		CMP AL,72       ;;Flecha Superior presionada???
			JE arriba
		CMP AL,80	;;Flecha inferior presionada???
			JE abajo
		CMP AL,27	;;tecla ESC presionada???
			JE comandos2
   		CMP AL,08	;; <-- Presionada???
			je return
		cmp al,09   ;; TAB presionado???
			je tab
		MOV DH,CH
 		MOV DL,CL
		call columna
		call cursor
		
		; ##### AQUI SE MANDA A IMPRIMIR A PANTALLA EL CARACTER LEIDO####
		MOV AH,09h
		mov bh,pageN
		mov bl,color
		push cx
		mov cx,1
		int 10h
		pop cx
		jmp lee

		;menuc1:
		;jmp menuc
	
	
	ABAJO:
		CMP CH,22
		JE ABAJO2
		inc ch
		sub cl,1
		mov dh,ch
		mov dl,cl
		CALL CURSOR
		mov al,13
		jmp abajo3
		abajo2:
		cmp pageN,4
		je abajo3
		inc pageN
		pageM pageN
		mov ch,0
		call printpage
		call cursor
		abajo3:
		JMP LEE
		
	IZQUIERDA:
		cmp cl,0
		je noizq
		sub cl,2
		mov dl,cl
		mov al, 13
		caLL CURSOR
		noizq:
		dec cl
		mov dl,cl
		jmp lee
	
	tab:
		jmp tab2
	return:
		jmp return2
	ARRIBA:
		CMP CH,0
		JNE ARRIBA2
		cmp pagen,0
		je slt
		dec pagen
		
		pagem pageN
		call printpage
		mov ch,22
		slt:
		JMP LEE
		ARRIBA2:
		DEC CH
		dec cl
		mov dh,ch
		mov dl,cl
		CALL CURSOR
		JMP LEE

	RETURN2:
		cmp cl,0
		je noret
		dec cl
		caLL CURSOR
		MOV AL,00
		noret:
		JMP LEE
	
	TAB2:
		cmp cl,79
		je tabfin
		push cx
		mov ch,79
		sub ch,cl
		cmp ch,4
		jb sss ;;Salta si es menor que 4 
		je sss ;; Tambien salta si es igual
		mov ch,4
		sss:
		add cl,ch
		pop dx
		mov ch,dh
		tabfin:
		mov al, 00
		jmp lee

	MENUC:
		mov dh,24
		mov dl,0
		call cursor
		MOV DX, OFFSET menucolor
		call printstring
		col:
		MOV DH,23
		MOV DL,0
		call cursor
		
		MOV AH,01H
		MOV DL,0FFH
		INT 21H
		
		CMP AL,97 ; a  Color Azul Marino
		JE setNavyBlue
		CMP AL,110 ;n Color Negro
		JE setBlack
		CMP AL,114 ;r Color Rojo
		JE setRed
		CMP AL, 118 ; v Color Verde
		JE setGreen
		CMP AL, 109 ; m Color Violeta
		JE setPurple
		CMP AL, 43 ; + Caracter para ver mas menus de colores
		JE menuc2
		cmp al,27
		je com4
		jmp col
		setNavyBlue:
		 mov color,1h
		 JMP COMANDOS
		setRed:
		 mov color,4h
		 JMP COMANDOS
		setGreen:
		 mov color,2h
		 JMP COMANDOS
		setBlack:
		 mov color,0h
		JMP COMANDOS
		setPurple:
		 mov color,5h
		JMP  COMANDOS
		
		com4:
		jmp comandos
		
	MENUC2:
		mov dh,24
		mov dl,0
		call cursor
		MOV DX, OFFSET menucolor2
		call printstring
		col2:
		MOV DH,23
		MOV DL,0
		call cursor
		
		MOV AH,01H
		MOV DL,0FFH
		INT 21H
		
		CMP AL,97 ; a  Color Amarillo
		JE setYellow
		CMP AL,98 ;n Color Blanco
		JE setWhite
		CMP AL,114 ;r Color Rojo Claro
		JE setWRed
		CMP AL, 118 ; v Color Verde Claro
		JE setWGreen
		CMP AL, 103 ; m Color Gris
		JE setGray
		CMP AL, 43 ; + Caracter para ver mas menus de colores
		JE menuc3
		cmp al,27
		je com3
		jmp col2
		setYellow:
		 mov color,6h
		 JMP COMANDOS
		setWRed:
		 mov color,12
		 JMP COMANDOS
		setWGreen:
		 mov color,10
		 JMP COMANDOS
		setWhite:
		 mov color,7h
		JMP COMANDOS
		setGray:
		 mov color,8h
		JMP  COMANDOS
		
		com3:
		jmp comandos
		
	MENUC3:
		mov dh,24
		mov dl,0
		call cursor
		MOV DX, OFFSET menucolor3
		call printstring
		col3:
		MOV DH,23
		MOV DL,0
		call cursor
		
		MOV AH,01H
		MOV DL,0FFH
		INT 21H
		
		
		CMP AL,97 ; a  Azul Claro
		JE setWBlue
		CMP AL,98 ;n Color Blanco Claro
		JE setWWhite
		CMP AL,114 ;r Color Rosa
		JE setPink
		CMP AL, 107 ; k AZul Rey
		JE setKing
		CMP AL, 121 ; y Amarillo Claro
		JE setWYellow
		cmp al,27
		je com3
		jmp col3
		setWBlue:
		 mov color,11
		 JMP COMANDOS
		setPink:
		 mov color,13
		 JMP COMANDOS
		setKing:
		 mov color,9
		 JMP COMANDOS
		setWWhite:
		 mov color,15
		JMP COMANDOS
		setWYellow:
		 mov color,14
		JMP  COMANDOS

	END INICIO