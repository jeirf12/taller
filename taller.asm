; Directiva para indicar el tamanio del programa.
.model small

; Tamanio de pila
.stack 200h ; Si no se especifica el default es 1Kbyte

; Declaracion de Constantes.
.const
        VAL_LF      EQU 10  ; Constante para el Line Feed.
        VAL_RET     EQU 13  ; Constante para el Return.
        CHR_FIN     EQU '$' ; Indica fin de cadena.
                
; Declaracion de Variables
.data
        ;Login
        Login           DB "**********************BIENVENIDO**********************",VAL_LF,VAL_RET,CHR_FIN
        msgPassw        DB VAL_LF, VAL_RET,"Digite la contrasenia: ",CHR_FIN
        exitLogin       DB VAL_LF,VAL_RET,"Invalidado, ha ingresado todos sus intentos.",VAL_LF,VAL_RET
                        DB "Saliendo del programa...",CHR_FIN
        passw           DB 'pass1234'
        passwInput      DB 20 dup(?),CHR_FIN
        
        ;Menu Principal
        MenuPrincipal   DB "*************************MENU*************************",VAL_LF,VAL_RET
                        DB "1. Suma y resta de dos numeros (0 a 65535)",VAL_LF,VAL_RET
                        DB "2. Multiplicacion y division de dos numeros (0 a 255)",VAL_LF,VAL_RET
                        DB "3. AND, OR, XOR, NOT de dos hexadecimales a binario",VAL_LF,VAL_RET
                        DB "4. Serie fibonacci (15 primeros terminos)",VAL_LF,VAL_RET
                        DB "5. Salir",VAL_LF,VAL_RET
                        DB "******************************************************",VAL_LF,VAL_RET
                        DB "Ingrese una opcion: ",CHR_FIN;

        ;Variable readCadenaInput
        dateRead        DB  8 dup(?)        
        ;Variables suma y resta
        msgNum1         DB VAL_LF,VAL_RET,"Ingrese primer numero: ",CHR_FIN;
        msgNum2         DB VAL_LF,VAL_RET,"Ingrese segundo numero: ",CHR_FIN;
        num1            Dw ?
        num2            DW ?
        msgSuma         DB VAL_LF,VAL_RET,"El resultado de la suma es: ",CHR_FIN
        msgResta        DB VAL_LF,VAL_RET,"El resultado de la resta es: ",CHR_FIN
        
        ;Variables Multiplicacion y Division
        div1            DB ?
        div2            DB ?
        msgMult         DB VAL_LF,VAL_RET,"El resultado de la multiplicacion es: ",CHR_FIN
        msgDiv          DB VAL_LF,VAL_RET,"El resultado de la division es: ",CHR_FIN
        msgDivCero      DB VAL_LF,VAL_RET,"No se puede realizar division por 0:",CHR_FIN

        ;Variables Hexadecimal
        numHex1         DB ?
        numHex2         DB ?
        numHexr1        DB ?
        numHexr2        DB ?
        hexrnot         DB VAL_LF,VAL_RET,"El resultado de NOT es: ",VAL_RET,VAL_LF,CHR_FIN
        hexrand         DB VAL_LF,VAL_RET,"El resultado de AND es: ",VAL_RET,VAL_LF,CHR_FIN     
        hexror          DB VAL_LF,VAL_RET,"El resultado de OR  es: ",VAL_RET,VAL_LF,CHR_FIN     
        hexrxor         DB VAL_LF,VAL_RET,"El resultado de ORX es: ",VAL_RET,VAL_LF,CHR_FIN     
        enterHex        DB VAL_LF,VAL_RET,CHR_FIN

        ;Variable de ITOA
        strItoa         DB 6 dup(?),VAL_LF,VAL_RET,CHR_FIN

        ;Variable de HTOA
        strHtoa         DB 2 dup(?),' h',CHR_FIN

        ;Variable de HTOB
        strHtob         DB 8 dup(?),VAL_LF,VAL_RET,CHR_FIN

        ;Variable System
        pressKey        DB VAL_LF,VAL_RET,"Pulse cualquier tecla para continuar",CHR_FIN

        ;Variables de la serie
        msgFib          DB VAL_LF,VAL_RET,"La serie fibonacci es: ",CHR_FIN
        arreglo         DW 10h dup(0000h)
        arreglo2        DW 15h dup(0000h)

; Directiva para indicar codigo.
.code

;obtiene los datos guardados en .data
getData PROC
  mov ax, @data
  mov ds, ax
RET
ENDP

;Imprime el login de inicio del programa
impLogin PROC
    mov dx, offset Login
    call impstr
    mov ch, 3h

    bucle:
      mov bx,15h
    cleanBuff:
      dec bx
      mov passwInput + bx, 0h
      cmp bx, 0h
      jne cleanBuff
    
      cmp ch, 0h
      jne printInput
      mov dx, offset exitLogin
      call impstr

      call killPro

    printInput:
      dec ch
      mov dx, offset msgPassw
      call impstr
      mov bx, offset passwInput

    readDate:
      mov ah, 7h
      int 21h
      cmp al, 0dh
      je dateEquals
      mov [bx], al
      mov ah, 2h
      mov dl, 2ah
      int 21h
      inc bx
      jmp readDate

    dateEquals:
      mov bx, offset passw
      mov si, offset passwInput
      mov cl, 8h
      
    equalsPassw:
      mov al, [bx]   ;mueve el la contrasenia ingresada al registro de bajo nivel al
      cmp al, [si]   ;Compara la contrasenia ingresada con la de memoria
      jne bucle
      inc bx
      inc si
      dec cl
      cmp cl, 0h
      jne equalsPassw
      mov al, [si]
      cmp al,0h
      jne bucle

RET
ENDP

;imprime y ejecuta el menu de operaciones
impMenu PROC
    bucleMenu:
        call clear
        call colorFondo
        mov dx, offset MenuPrincipal
        call impstr
        
        mov ah, 01
        int 21h
        
        cmp al, 31h
        je opt1
        cmp al, 32h
        je opt2
        cmp al, 33h
        je opt3
        cmp al, 34h
        je opt4
        cmp al, 35h
        je salir
        jmp bucleMenu
        
        opt1:
          call suma
          jmp press

        opt2:
          call multi
          jmp press

        opt3:
          call hexa
          jmp press
          
        opt4:
          call serieFibonacci
          jmp press

        salir:
          call killPro

        press:
          call msgKeyExit
          jmp impMenu
RET
ENDP

;Termina los procesos o hilos y termina la ejecucion de todo el programa
killPro PROC
  mov ah, 4ch
  int 21h
RET
ENDP

;imprime mensaje de presione una tecla para salir
msgKeyExit PROC
  mov dx, offset pressKey
  call impstr
  mov ah, 01
  int 21h
RET
ENDP

;imprime mensaje de presione una tecla para salir
suma PROC
  call getData
  
  mov dx, offset msgNum1
  call impMsgOperando
  mov num1,ax

  mov dx, offset msgNum2
  call impMsgOperando
  mov num2,ax
  
  ;Procedimiento Suma
  mov dx, offset msgSuma
  call impstr
  xor ax,ax
  mov ax, num1
  add ax, num2
  mov bx, ax
  LAHF                ;Se guarda en AH el estado de las banderas
  and ah,01h        

  positiveSum:             
    call itoa
    mov dx, offset strItoa
    call impstr

  ;Procedimiento Resta
  mov dx, offset msgResta
  call impstr
  xor ax,ax
  mov ax, num1
  cmp ax, num2
  jb positiveSub          ;Num1>Num2
  sub ax, num2
  mov bx, ax
  and ah,0h
  jmp printSub

  positiveSub:
    sub ax, num2
    mov bx, ax
    mov ah, 80h 

  printSub:
    call itoa
    mov dx, offset strItoa
    call impstr

RET
ENDP

;metodo que imprime y hace las multiplicaciones y divisiones
multi PROC
  call getData

  mov dx, offset msgNum1
  call impMsgOperandoEsp
  mov div1, al

  mov dx, offset msgNum2
  call impMsgOperandoEsp
  mov div2, al
  
  ;Procedimiento Multiplicacion
  mov dx, offset msgMult
  call impstr
  xor ax,ax
  mov al,div1 
  mul div2
  mov bx, ax
  mov ah,0h
  call itoa
  mov dx, offset strItoa
  call impstr

  ;Procedimiento Division
  cmp div2,0h
  jnz next 
  mov dx, offset msgDivCero
  call impstr
  jmp divisionEnd

  next:
    mov dx, offset msgDiv
    call impstr
    xor ax,ax
    mov al, div1
    div div2
    mov bl, al
    and bx,000ffh
    mov ah,0h
    call itoa
    mov dx, offset strItoa
    call impstr
  divisionEnd:
RET
ENDP

;Procedimiento de los hexadecimales a binario
hexa PROC
  call colorFondo

  mov dx, offset msgNum1
  call impMsgOperandoEspHex
  mov numHex1, bl
  call htob
  mov dx, offset strHtob
  call impstr

  mov dx, offset msgNum2
  call impMsgOperandoEspHex
  mov numHex2, bl
  call htob
  mov dx, offset strHtob
  call impstr
  
  ;Operacion NOT
  mov al, numHex1
  not al
  mov numHexr1, al
  mov dx, offset hexrnot
  call impstr
  mov bl, numHexr1
  call htoa
  mov dx, offset strHtoa
  call impstr
  mov bl, numHexr1
  call htob
  mov dx, offset strHtob
  call impstr
  mov dx, offset enterHex
  call impstr
  
  mov al, numHex2
  not al
  mov numHexr2, al
  mov bl, numHexr2
  call htoa
  mov dx, offset strHtoa
  call impstr
  mov bl, numHexr2
  call htob
  mov dx, offset strHtob
  call impstr

  ;Operacion AND
  mov al, numHex1
  and al, numHex2
  mov numHexr1, al
  mov dx, offset hexrand
  call impstr
  mov bl, numHexr1
  call htoa
  mov dx, offset strHtoa
  call impstr
  mov bl, numHexr1
  call htob
  mov dx, offset strHtob
  call impstr

  ;Operacion OR
  mov al, numHex1
  or al, numHex2
  mov numHexr1, al
  mov dx, offset hexror
  call impstr
  mov bl, numHexr1
  call htoa
  mov dx, offset strHtoa
  call impstr
  mov bl, numHexr1
  call htob
  mov dx, offset strHtob
  call impstr

  ;Operacion XOR
  mov al, numHex1
  xor al, numHex2
  mov numHexr1, al
  mov dx, offset hexrxor
  call impstr
  mov bl, numHexr1
  call htoa
  mov dx, offset strHtoa
  call impstr
  mov bl, numHexr1
  call htob
  mov dx, offset strHtob
  call impstr

RET
ENDP

;Procedimiento de la serie fibonacci
serieFibonacci PROC
  mov dx, offset msgFib
  call impstr

  mov arreglo[0], 0001h
  mov arreglo[2], 0001h
  mov si, 0004h

  sucesion:
    mov ax, 0000h
    mov ax, arreglo[si-2]
    add ax, arreglo[si-4]
    mov arreglo[si], ax
    add si, 0002h
    cmp si, 001eh
    jnz sucesion

  mov si, 0000h

  bucleSerie0:
    mov ax, arreglo[si]
    mov di, 0000h

  bucleSerie1:
    mov dx, 0000h
    mov bx, 0ah
    div bx
    mov arreglo2[di], dx
    add di, 0002h
    cmp ax, 0000h
    jnz bucleSerie1

  bucleSerie2:
    sub di, 0002h
    mov bx, arreglo2[di]
    mov arreglo2[di], 0000h

    mov dl, bl
    and dl, 0fh
    or dl, 30h
    mov ah, 02h
    int 21h
    cmp di, 0000h
    jnz bucleSerie2

    add si, 0002h
    
    mov ah, 02h
    mov dl, 20h
    int 21h
    cmp si, 1eh
    jnz bucleSerie0
  
RET
ENDP

;imprime un mensaje de entrada y captura el valor del teclado
impMsgOperando PROC
  call impstr
  call readCadenaInput
  xor si, si
  mov si, offset dateRead
  call atoi
  mov ax, bx
RET
ENDP

;imprime un mensaje de entrada y captura el valor del teclado de multiplicacion y divisiones
impMsgOperandoEsp PROC
  call impstr
  call readCadenaInput
  xor si, si
  mov si, offset dateRead
  call atoi
  mov al,bl
RET
ENDP

;imprime un mensaje de entrada y captura el valor del teclado para los hexadecimales
impMsgOperandoEspHex PROC
  call impstr
  call readCadenaInput
  xor si, si
  mov si, offset dateRead
  call atoh
  ;mov dx, offset enterhex ;para EMU
  ;call impstr 
RET
ENDP

;lee cadenas ingresados por teclado
readCadenaInput PROC
    call getData

    mov dateRead,0h
    mov dateRead+1,0h
    mov dateRead+2,0h
    mov dateRead+3,0h
    mov dateRead+4,0h
    mov bx,offset dateRead

    bucleRead:
      mov ah, 01h
      int 21h
      cmp al,0dh ;0dh es el c?digo hexadecimal del Enter, compara si el la tecla presionada fue un Enter.
      je readEnd ;Si no fue Enter salta a la etiqueta readc
      mov [bx],al
      inc bx
      jmp bucleRead
    
    readEnd:
ret
RET
ENDP

;-------Convertir cadena a numero  ----------
atoi PROC
  xor bx, bx
  mov di, 1h
  atoiPrin:
    lodsb
    cmp al, '-'
    jne atoiSiguiente
    cmp di, 1h
    jne noascii
    mov di, 2h
    jmp atoiPrin

  atoiSiguiente:
    cmp al, '0'
    jb noascii
    cmp al, '9'
    ja noascii
    sub al, 30h
    cbw
    push ax
    mov ax, bx
    mov cx, 10
    mul cx
    mov bx, ax
    pop ax
    add bx, ax
    jmp atoiPrin

  noascii:
    cmp di, 2h
    jne noascii_fin
    xor ax, ax
    sub ax, bx
    mov bx, ax

  noascii_fin:                 
RET
ENDP

; ---------------- Convertir numero a cadena ----------------
itoa PROC    
  ;Aqui vamos a ver el estado de las banderas.
  mov dh, ah  ;Se usa si SF esta en 1(negativo)
  mov dl, ah  ;Se usa si desbordamiento
  mov ax, bx
  and dh, 01h
  cmp dh, 01h
  jnz noOverFlow
  mov ch, 01h    

  noOverFlow:
    and dl, 80h
    cmp dl, 80h
    jnz positive
    mov cl, 01h
    dec ax
    not ax
  
  positive:
    mov si, 0h
    mov bx, 0ah

  htod:
    xor dx,dx
    div bx
    cmp ch, 01h
    jnz entire
    mov ch, 0h
    add dl, 6h
    add ax, 1999h
    cmp dl, 0ah
    jb entire
    sub dl, 0ah
    inc ax

  entire:
    inc si ;contador de nueros subidos a cola
    add dl, 30h
    push dx
    mov dx, 0h    
    cmp ax, 0h
    jnz htod 

    ;metemos el valor en la cadena de salida
    ;limpiando bufer
    mov bx,06h

  clsBuffer:
    mov strItoa + bx, 0
    dec bx
    cmp bx, 0h
    ja  clsBuffer
    xor bx, bx
    ;Es un numero negativo?
    cmp cl,01h
    jnz chain
    mov strItoa + bx, 2dh
    inc bx
    mov cl,0h

  chain:
    pop dx
    mov strItoa + bx, dl
    inc bx
    dec si
    cmp si,0h
    jnz chain        

RET
ENDP

atoh PROC
  xor bx, bx
  atoa1:
    lodsb
    cmp al, '0'
    jb noHexadecimal
    cmp al, '9'
    ja esHexadecimal

    sub al, 30h
    cbw
    push ax
    mov ax, bx
    mov cx, 10h
    mul cx
    mov bx, ax
    pop ax
    add bx, ax
    jmp atoa1

    esHexadecimal:
      cmp al, 'A'
      jb noHexadecimal
      cmp al, 'F'
      ja noHexadecimalMin
      sub al, 37h

    hexadecimalMin:
      cbw
      push ax
      mov ax, bx
      mov cx, 10h
      mul cx
      mov bx, ax
      pop ax
      add bx, ax
      jmp atoa1
    
    noHexadecimalMin:
      cmp al, 'a'
      jb noHexadecimal
      cmp al, 'f'
      ja noHexadecimal
      sub al, 57h
      jmp hexadecimalMin

    noHexadecimal:

RET
ENDP

htoa PROC
  call getData

  xor ax, ax
  mov al, bl
  mov bx, 02h
  mov dl, 10h
  bucleHtoa:
    div dl
    cmp ah, 0ah
    jnb htoa2
    add ah, 30h
    jmp htoa3

  htoa2:
    add ah, 37h

  htoa3:
    mov strHtoa + bx, ah
    xor ah, ah
    dec bx
    cmp bx, 0h
    jnz bucleHtoa

RET
ENDP

htob PROC
  call getData

  xor ax, ax
  mov al, bl
  mov bx, 08h
  mov dl, 02h

  bucleHtob:
    div dl
    add ah, 30h
    mov strHtob + bx, ah
    xor ah, ah
    dec bx
    cmp bx, 0h
    jnz bucleHtob

RET
ENDP

;imprime cadenas
impstr PROC
    mov ah, 09h
    int 21h
RET
ENDP

;limpia la pantalla de consola
clear PROC
    mov ah,0    ;Servicio para limpiar pantalla7
    mov al,3h
    int 10h
RET
ENDP

;Cambia el color de la consola
colorFondo PROC
    mov  ah,06h
    mov  al,0
    mov  bh,00011111b   ;cambia el color con binario aqui
    mov  cx,0000h
    mov  dx,484fh
    int  10h
    mov  ah,02h
    mov  bh,00h
    mov  dx,0000h
    int  10h
RET
ENDP

;Es el main del programa o el que ejecuta todo
inicio PROC
    call getData
    call impLogin
    call impMenu
RET
ENDP

END inicio
