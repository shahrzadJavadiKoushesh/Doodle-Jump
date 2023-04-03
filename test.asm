STACK SEGMENT PARA STACK 
   DB 64 DUP (' ')     ;FILL THE STACK WITH 64 EMPTY SPACES
STACK ENDS

DATA SEGMENT PARA 'DATA' 
    
    BALL_X DW 0Ah   ;X OF THE BALL
    BALL_Y DW 0Ah   ;Y OF THE BLL  
    BALL_SIZE DW 08h ;SIZE OF THE BALL
    
    
DATA ENDS


CODE SEGMENT PARA 'CODE'
    
    MAIN PROC FAR
    ASSUME CS:CODE, DS:DATA, SS:STACK  ;ASSUME AS CODE, DATA AND STACK SEGMENT
    PUSH DS                            ; PUSH DS SEGMENT TO THE STACK
    SUB AX, AX                         ;CLEAN THE AX REGISTER
    PUSH AX 
    MOV AX, DATA                       ;SAVE THE CONTENTS OF THE DATA SEGMENT TO AX
    MOV DS, AX                         ;SAVE THE CONTENTS OF AX TO DS
    POP AX                             ;RELEASE THE TOP ITEM OF THE STACK TO THE AX REGISTER
        
      MOV AH, 00h   ; SET VIDEO MODE
      MOV AL, 13h   ; CHOOSE THE VIDEO MODE
      INT 10h  
      
      MOV AH, 0BH   ; SET THE CONFIGURATION TO THE BACKGROUND COLOR
      MOV BH, 00H
      MOV BL, 00H   ;CHOOSE BLACK AS BACKGROUND COLOR
      INT 10H   
      
     
        
      CALL DRAW_BALL 
      
      RET
    
    MAIN ENDP 
    
    
    DRAW_BALL PROC NEAR 
       
      MOV CX, BALL_X   ; SET THE INITIAL COLUMN (X)
      MOV DX, BALL_Y   ; SET THE INITIAL ROW (Y) 
      
      DRAW_BALL_HORIZONTAL:
                            
        MOV AH, 0CH   ; SET THE CONFIGURATION TO WRITE A PIXEL
        MOV AL, 0FH   ; CHOOSE WHITE AS COLOR OF THE PIXEL
        MOV BH, 00H   ; SET THE PAGE NUMBER
        INT 10H 
        INC CX        ; CX++
        MOV AX, CX              ; CX - BALL_X > BALL_SIZE ( Y -> GO TO NEXT LINE, N -> GO TO NEXT COL
        SUB AX, BALL_X
        CMP AX, BALL_SIZE
        JNG DRAW_BALL_HORIZONTAL
        MOV CX, BALL_X ;CX GOES BACK TO INITIAL COL
        INC DX         ; ADVANCE ONE LINE 
        MOV AX, DX
        SUB AX, BALL_Y          ; same logic for y
        CMP AX, BALL_SIZE
        JNG DRAW_BALL_HORIZONTAL
       
        
      RET 
    DRAW_BALL ENDP
    
    
CODE ENDS
  
END  
  
