
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;   TITLE: SKYFALL CHARACTERS - 8086 ASSEMBLY ARCADE GAME
;   AUTHOR: Fidan Imamaliyeva
;   DEPARTMENT: Computer Engineering
;   DATE: April 2026
;
;   DESCRIPTION:
;   This project is a high-performance arcade game developed in Intel 8086 Assembly.
;   The game utilizes low-level hardware interactions to manage real-time character 
;   rendering, keyboard interrupts, and timing loops.
;
;   TECHNICAL FEATURES:
;   - Video Mode: 80x25 Text Mode (INT 10h, AH=00h, AL=03h).
;   - Speed Control: Implemented via a dynamic delay system with 3 difficulty 
;     levels (Easy, Medium, Hard), adjusting processor-level wait cycles.
;   - Memory Management: Uses 'row' and 'column' arrays for dynamic sprite tracking.
;   - Randomization: System clock ticks (INT 1ah) are used as a seed for the 
;     Linear Congruential Generator (LCG) to produce random characters.
;   - Optimization: Features an optimized "Print-and-Vanish" algorithm that prevents 
;     visual artifacts and vertical trailing by managing cursor positions.
;
;   CONTROLS:
;   - Navigation: Use '1', '2', '3' keys in menus.
;   - Gameplay: Type the corresponding character to 'catch' it before it hits the ground.
;   - Quit: Press 'ESC' during selection menus to return or exit.
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

.model  small
;.stack 100H
 
.data
    row db 80 DUP (1)            		; contains in which row the character is at of the index column
    column db 80 DUP (32)        		; contains the character which is at row = column[index], column = index position 
    generatedRandom dw ?
    temp    dw 0        
    scoreLSB  db 30h                	; LSB
    scoreMSB  db 30h                	; MSB
    lives   db 51                  	    ; Total lives
    temp2   db 0                    	; Char temp
    startPosition   dw 0            	; Start position temp
    keyInput    dw 0                	; Keyboard input temp
    delay   db 10
    tempTime   db 0
    mulTime db 0
	graRow db -1
	graCol db 0
	
	gameTitle db "SKYFALL CHARACTERS"
	difficulty db "CHOOSE DIFFICULTY:" 
    noob       db "1. EASY   "      
    regular    db "2. MEDIUM "      
    hardended  db "3. HARD   "           
	play db "PLAY"
	about db "ABOUT"
	help db "HELP"
	helpText db "Type to catch the letters"
	helpText1 db "before they touch the ground."
	about0 db "Developed by:"
    about1 db "Fidan Imamaliyeva" 
    about2 db "Computer Engineering" 
    about3 db "Year 2026"
    about4 db " " 
    about5 db " "
    about6 db " "

    
    ;Message
    showScore db "Score:"
    remainingLives db "lives: "
    gameOverShow db "GAMEOVER!!!"
    exitMessage db "....Press any key to continue"
    spa db "     "
 
.code   
    ;mov dx, offset msg					; print welcome message:
    ;mov ah, 9 
    ;int 21h
    ;mov ah, 00h						;wait for any key:
    ;int 16h  
main:
    mov ax, @data
    mov ds, ax
    CALL randomInitializer
    
    MOV AH, 00H 
    MOV AL, 03H         
    INT 10H             

                        
    mov ah, 1
    mov ch, 32
    int 10h
menu:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX          
    CALL screenClear    
    
    ;  START
    mov bp, offset gameTitle
    mov ah, 13h
    mov bh, 0h
    mov bl, 0Eh        
    mov al, 00h
    mov cx, 18         
    mov dl, 31         
    mov dh, 5         
    int 10h
    ;  PLAY
    mov bp, offset play
    mov ah, 13h
    mov bl, 0Dh       
    mov cx, 4          
    mov dl, 38         
    mov dh, 10         
    int 10h

    ;  ABOUT
    mov bp, offset about
    mov ah, 13h
    mov bl, 0Dh
    mov cx, 5          
    mov dl, 38         
    mov dh, 12        
    int 10h

    ;  HELP
    mov bp, offset help
    mov ah, 13h
    mov bl, 0Dh
    mov cx, 4          
    mov dl, 38        
    mov dh, 14         
    int 10h
    ; NOTE
    mov bp, offset exitMessage
    mov ah, 13h
    mov bl, 07h        
    mov cx, 29         
    mov dl, 25         
    mov dh, 22         
    int 10h
@play1:
	MOV		AH,0						;get char to AL
	INT		16h	
	CMP 	AL,49						;check 3 for Hardended
	JNE 	@about1
	JMP 	diffMenu1

@about1:CMP 	AL,50					;check 3 for Veteran
	JNE 	@help1
	JMP 	diffMenu
	
@help1:CMP 	AL,51						;check 3 for Veteran
	JNE 	@escape1
	JMP 	diffMenu2
	
@escape1:CMP	AL,27					;check ESC
	JNE		@play1
	JMP 	haltProgram
	
menu1:
	jmp menu
	
diffMenu:
	call screenClear
    
    ; "Developed by:"
    mov     BP, offset about0
    MOV     AH, 13h
    MOV     BH, 0h
    MOV     BL, 0Fh          
    MOV     AL, 00h
    MOV     CX, 13           
    MOV     DL, 13           
    MOV     DH, 4           
    INT     10h
    
    ; "Fidan Imamaliyeva" 
    mov     BP, offset about1
    MOV     AH, 13h
    MOV     BL, 0Ah          
    MOV     CX, 17           
    MOV     DL, 13
    MOV     DH, 6            
    INT     10h
    
    ; "Computer Engineering" 
    mov     BP, offset about2
    MOV     AH, 13h
    MOV     BL, 0Fh          
    MOV     CX, 20           
    MOV     DL, 13
    MOV     DH, 8
    INT     10h
    
    ; "Year 2026" 
    mov     BP, offset about3
    MOV     AH, 13h
    MOV     CX, 9            
    MOV     DL, 13
    MOV     DH, 10
    INT     10h 
    
@escape2:MOV		AH,0				;get char to AL
	INT		16h	
	CMP 	AL,27						;check 3 for Hardended
	JNE 	@escape2
	JMP 	menu
diffMenu2:
	call screenClear
	mov		BP,offset helpText			;print string
	MOV 	AH,13h
	MOV		BH,0h
	MOV		BL,0Fh
	MOV		AL,00h						;Write mode
	MOV 	CX,25						;Number of char in Str.
	MOV 	DL,7						;Column
	MOV		DH,10						;Row
	INT		10h
	mov		BP,offset helpText1			;print string
	MOV 	AH,13h
	MOV		BH,0h
	MOV		BL,0Fh
	MOV		AL,00h						;Write mode
	MOV 	CX,29						;Number of char in Str.
	MOV 	DL,5						;Column
	MOV		DH,12						;Row
	INT		10h
@escape3:
	MOV		AH,0						;get char to AL
	INT		16h	
	CMP 	AL,27						;check 3 for Hardended
	JNE 	@escape3
	JMP 	menu
diffMenu1:
    call screenClear
    mov ax, @data
    mov es, ax

    ;  CHOOSE DIFFICULTY
    mov     bp, offset difficulty
    mov     ah, 13h
    mov     bh, 0h
    mov     bl, 0Fh          
    mov     al, 00h
    mov     cx, 18          
    mov     dl, 31           
    mov     dh, 6            
    int     10h

    ;  1. EASY 
    mov     bp, offset noob
    mov     ah, 13h
    mov     bl, 0Ah          
    mov     cx, 10          
    mov     dl, 35           
    mov     dh, 10          
    int     10h

    ;  2. MEDIUM 
    mov     bp, offset regular
    mov     ah, 13h
    mov     bl, 0Eh          
    mov     cx, 10          
    mov     dl, 35          
    mov     dh, 12          
    int     10h

    ;  3. HARD 
    mov     bp, offset hardended
    mov     ah, 13h
    mov     bl, 0Ch          
    mov     cx, 10          
    mov     dl, 35          
    mov     dh, 14           
    int     10h

   
    mov     bp, offset exitMessage
    mov     ah, 13h
    mov     bl, 08h       
    mov     cx, 34
    mov     dl, 23
    mov     dh, 20
    int     10h

@diffiInputWait:
    MOV     AH, 00h
    INT     16h              

    CMP     AL, 49           
    JE      @setEasy
    CMP     AL, 50           
    JE      @setMedium
    CMP     AL, 51           
    JE      @setHard
    CMP     AL, 27           
    JE      menu            
    JMP     @diffiInputWait 

@setEasy:
    MOV      delay, 3       
    JMP      start
@setMedium:                                                               
    MOV      delay, 2          
    JMP      start
@setHard:
    MOV      delay, 1        
    JMP      start


start:             
    MOV AX, @DATA 						; important
    MOV ES, AX
    CALL 	screenClear
    MOV BP, OFFSET showScore 			; ES: BP POINTS TO THE TEXT
    MOV AH, 13H 						; WRITE THE STRING
    MOV AL, 01H							; ATTRIBUTE IN BL, MOVE CURSOR TO THAT POSITION
    XOR BH,BH 							; VIDEO PAGE = 0
    MOV BL, 2 							; GREEN
    MOV CX, 6 							; LENGTH OF THE STRING
    MOV DH, 0 							; ROW TO PLACE STRING
    MOV DL, 2 							; COLUMN TO PLACE STRING
    INT 10H
	
    MOV AX, @DATA 						; important
    MOV ES, AX
    MOV BP, OFFSET remainingLives 		; ES: BP POINTS TO THE TEXT
    MOV AH, 13H 						; WRITE THE STRING
    MOV AL, 01H							; ATTRIBUTE IN BL, MOVE CURSOR TO THAT POSITION
    XOR BH,BH 							; VIDEO PAGE = 0
    MOV BL, 0Ch 						; GREEN
    MOV CX, 7 							; LENGTH OF THE STRING
    MOV DH, 0 							; ROW TO PLACE STRING
    MOV DL, 28 							; COLUMN TO PLACE STRING
    INT 10H
	
    MOV AX, @DATA 						;important
	MOV DS, AX

gameStart:                     			;Loop the game
    CALL    getColumn
    mov     bx,0
    CALL    checkRowPrint
    Call    keyMatch
    CALL    setDelay        
    JMP     gameStart          			;looping ;;keeps the game running 


getColumn:                       
    CALL    randomColumn
    CMP     row[bx],1       			;row
    ;JNE     getColumn
    INC     row[bx]          			;just for safety as we decrease in setCursor
    mov     startPosition,bx
    CALL    randomType
    mov     bx,startPosition
    mov     column[bx],dl
	RET
incCol: INC bx
checkRowPrint:                  		;checking each line to move forward
    CMP     bx,40
    JE      returnCRP
    CMP     row[bx],1
    JE      incCol
    mov     temp,bx
    CALL    printAndVanish
    mov     bx,temp
    JMP     incCol
returnCRP: RET

menu3:
	jmp menu

randomInitializer:              		;change generatedRandom each each frame
    mov ah,0                    		;Get system delay      
    INT 1ah                     		;there are approximately 18.20648 clock ticks per second,and 1800B0h per 24 hours.      
    mov generatedRandom,DX
										;CX:DX now hold number of clock ticks since midnight
										;CH = hour. CL = minute. DH = second. DL = 1/100 seconds.
										;Move dx Register to generatedRandom
    RET 
randomColumn:                       	;random algorithm by using generatedRandom from RandomInitializer
    mov ax, generatedRandom
    ADD generatedRandom,23
    xor dx, dx
    mov cx, 40
    DIV cx                      		;dx contains the remainder of the division from 0 to 40
    mov BX,DX
    ;ADD BX, 15                  		;Shift Screen Position
    RET                         		;result random number at AL 
randomSelection:                      	;Random type to display
    mov     AX, generatedRandom         ;Determining randomly to select character, we mod by 3 here
    xor     DX, DX               		;0 = Number, 1 = Upper Case letter, 2 = Lower Case letter
    mov     CX, 3
    DIV     CX      
    RET         
randomType:                      		;Select type from randomSelection function
    CALL    randomSelection           
    CMP     DL,0
    JE      number
    CMP     DL,1
    JE      upperCase
    CMP     DL,2
    JE      lowerCase  
number:                       			;Random number
    mov     AX, generatedRandom 
    ;ADD     generatedRandom,1
    xor     DX, DX      
    mov     CX, 10
    DIV     CX 
    ADD     DL, 48              		;DL contains random number 0 - 9
    ;mov     AL,DL
    RET 
upperCase:                     			;Random Capital Characters
    mov     AX, generatedRandom 
    ;ADD     generatedRandom,1
    mov     DX, 0       
    mov     CX, 26
    DIV     CX                  		; DX contains the remainder of the division from 0 to 93
    ADD     DL, 65              		; DL contain rand char A - Z
    ;mov     AL,DL
    RET 
lowerCase:                     			;Random Lower Characters
    mov     AX, generatedRandom 
    ;ADD     generatedRandom,1
    xor     DX, DX       
    mov     CX, 26 
    DIV     CX                  		; DX contains the remainder of the division from 0 to 93
    ADD     DL, 97              		; DL contain rand char a - z
    ;mov     AL,DL   
    RET

setDelay:                              
	mov    ah, 2ch                 		; Get delay from system
	INT        21h                                 
	mov        tempTime,DL              ; CH = hour. CL = minute. DH = second. DL = 1/100 seconds.
	mov        AH,delay
	mov    mulTime,ah            		; delay a delay estimate 5* delay milli second
	CALL    printScore
	CALL    printLives


delay2:                             	; Modified delay speed for level
	CALL    keyMatch
	mov    AH,2Ch
	INT        21h
	CMP        DL,tempTime
	JE     delay2
	DEC        mulTime
	mov        tempTime,DL
	CMP        mulTime,0
	JNE        delay2
	RET


printChar:                           	; Print Characters one by one
	mov     ah, 9h                  	; write character from AL at cursor position.
	mov     bh, 0h                  	; Page no = 0
	mov     cx, 1                   	;no. of times to write character
	INT     10h
	RET
	
printAndVanish:
	mov     bx, temp            ; get current column index
    mov     dl, bl             ; column position
    mov     dh, row[bx]        ; current row of character
    dec     dh                 ; move cursor one row up (erase old char)
    mov     ah, 02h
    mov     bh, 00h
    int     10h                ; set cursor position
    
    mov     al, ' '            ; print space to clear old character
    mov     ah, 09h
    mov     cx, 1
    mov     bl, 00h            ; color (black)
    int     10h                

    CALL    setCursor          ; set cursor to new position
    mov     bx, temp
    mov     al, column[bx]     ; get character to print
    mov     bl, 0Eh            ; color (yellow)
    mov     ah, 09h
    mov     cx, 1
    int     10h                ; print character

    mov     bx, temp
    INC     row[bx]            ; move character one row down
    
    CMP     row[bx], 25        ; check if reached bottom of screen
    JNE     returnPAV
    CALL    decLives           ; decrease life if missed
    mov     row[bx], 1         ; reset position to top
    
returnPAV:
    RET

setCursor:                         		;Set Cursor Position
    mov     bx, temp
    mov     dl, bl              ; Sütun (Column) - BX'ten aliyoruz
    mov     dh, row[bx]         ; Satir (Row)
    mov     ah, 02h
    mov     bh, 00h
    int     10h
    RET

menu4:
	jmp menu3

printScore:
    mov     BH,00       				; page no.
    mov     AH, 2       				; set cursor position
    mov     DL,11       				; column
    mov     DH,0       					; row
    INT     10h
    mov     AH, 9       				; write character
    mov     BL, 02h     				; color
    mov     BH, 00      				; page no. 0
    mov     CX, 1       				; Number of times to write character
    mov     AL, scoreLSB  				; character to write
    INT     10h
    mov     BH,00
    mov     AH, 2
    mov     DL,10       				; column
    mov     DH,0       					; row
    INT     10h
    mov     AH, 9
    mov     BL, 02h
    mov     BH, 00
    mov     CX, 1       				; Number of times to write character
    mov     AL, scoreMSB
    INT     10h
    ;Check digit
    CMP     scoreLSB, 39h
    JNE     returnPS
    je      incMSB     					; increasing the 2nd digit after 9
returnPS:
    RET     
incMSB:
    mov     scoreLSB, 30h
    ADD     scoreMSB, 1
    RET 
printLives:
    mov     BH,00
    mov     AH,2
    mov     DL,36
    mov     DH,0
    INT     10h
    mov     AH, 9
    mov     BL, 0Ch
    mov     BH, 00
    mov     CX, 1
    mov     AL, lives
    INT     10h
    RET
 
screenClear:							; Clear Screen

    MOV AH, 06h         
    MOV AL, 0           
    MOV BH, 07h         
    MOV CH, 0           
    MOV CL, 0           
    MOV DH, 24          
    MOV DL, 79          
    INT 10h            
    RET
decLives:
    DEC     lives
    CMP     lives,48            		; 48 is 0 ASCII code
    JE      endGame
    RET



endGame:
    call screenClear                    ;Clear Screen
	MOV AH, 00H 						;Set video mode
    MOV AL, 13H 						;Mode 13h
    INT 10H
	MOV 	ch, 32       				;hide cursor
	MOV		ah, 1       
	INT 	10h 
    LEA     BP,gameOverShow         	;GAMEOVER!!        
    mov     AH,13h
    mov     BH,0h
    mov     BL,04h
    mov     AL,00h              		;Write mode
    mov     CX,10               		;Number of char in Str.
    mov     DL,15               		;Column
    mov     DH,6                		;Row
    INT     10h
    LEA     BP,showScore            	;Your Score
    mov     AH,13h
    mov     BH,0h
    mov     BL,0Ah
    mov     AL,00h
    mov     CX,6
    mov     DL,15
    mov     DH,9        
    INT     10h
endPrintScore:
    mov     BH,00           			; page no = 0
    mov     AH, 2           			; set cursor position
    mov     DL, 22          			; Column
    mov     DH, 9           			; Row
    INT     10h
    mov     AH, 9           			; print character
    mov     BL, 0Ah         			; color
    mov     BH, 00          			; page no.
    mov     CX, 1           			; Number of times to write character
    mov     AL, scoreMSB      			; character
    INT     10h
    mov     BH,00
    mov     AH, 2           			; set cursor positon
    mov     DL, 23          			; Column
    mov     DH, 9           			; Row
    INT     10h
    mov     AH, 9
    mov     BL, 0Ah
    mov     BH, 00
    mov     CX, 1
    mov     AL, scoreLSB
    INT     10h
    LEA     BP,exitMessage          
    mov     AH,13h
	mov     BH,0h
    mov     BL,0Fh
    mov     AL,0
    mov     CX,34
    mov     DL,6
    mov     DH,12
    INT     10h
    mov     ah, 00h            			; wait for a key
    int     16h
    jmp     menu4

keyMatch:                       
    mov     AH,1                
    INT     16h                 		; Using Intrrupt 16h to get input from keyboard
    JNZ     keyStroke
    RET
keyStroke:                    			; Check when have key input
    mov     AH,0
    INT     16h
    CMP     AL,27               
    JNE     setColumnHigh
    JMP     haltProgram
setColumnHigh:
    mov keyInput, 40           ; start checking from last column index

checkSCH:
    DEC     keyInput           ; move to previous column
    CMP     keyInput, -1       ; if all columns checked
    JE      goa                ; exit if not found
    
    mov     bx, keyInput
    CMP     column[bx], AL     ; compare pressed key with falling char
    JNE     checkSCH           ; if not match, continue searching
    
    DEC     row[bx]            ; move cursor one row up (to erase char)
    mov     ah, 02h            
    mov     dh, row[bx]        
    mov     dl, bl             
    mov     bh, 00h
    int     10h                ; set cursor position
    
    mov     al, " "            ; replace with space (erase character)
    mov     ah, 09h
    mov     cx, 1
    mov     bl, 00h            
    int     10h                
    
    mov     bx, keyInput
    mov     row[bx], 1         ; reset row to top
    mov     column[bx], 32     ; clear stored character
    INC     scoreLSB           ; increase score
    
goa: 
    RET                        ; return to caller

haltProgram:
    mov ah, 4Ch
    mov al, 00
    INT 21h                    ; terminate program
    RET

END     main