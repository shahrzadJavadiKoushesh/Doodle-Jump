STACK SEGMENT PARA STACK 
   DB 64 DUP (' ')     ;FILL THE STACK WITH 64 EMPTY SPACES
STACK ENDS

DATA SEGMENT PARA 'DATA'
    
    WINDOW_WIDTH DW 140H  ;WIDTH OF THE WINDOW 
    WINDOW_HEIGHT DW 0C8H ;HEIGHT OF THE WINDOW
    WINDOW_BOUNCE DW 6
  
     
    TIME_AUX DB 0   ;VARIABLE USED WHEN CHECKING IF THE TIME HAS CHANGED
    BALL_X DW 0Ah   ;X OF THE BALL
    BALL_Y DW 0Ah   ;Y OF THE BLL  
    BALL_SIZE DW 08h ;SIZE OF THE BALL 
    BALL_V_X DW 02H  ;X VELOCITY OF THE BALL
    BALL_V_Y DW 02H  ;Y VELOCITY OF THE BALL 
    
    ;VARIAVLES FOR PADDLES
    PADDLE_LEFT_X DW 00AH
    PADDLE_LEFT_Y DW 0B4H
    
    PADDLE_RIGHT_X DW 110H
    PADDLE_RIGHT_Y DW 0B4H
    
    PADDLE_WIDTH DW 01FH
    PADDLE_HEIGHT DW 005H 
    
    
    
                            
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
        
      CALL CLEAR_SCREEN  
      
      CHECK_TIME:
         MOV AH, 2CH   ; GET THE SYSTEM TIME
         INT 21H       ;CH = HOUR CL = MINUTE DH = SECOND DL = 1/100 SECOND 
      
         CMP DL, TIME_AUX
         JE CHECK_TIME ; IF IT IS THE SAME, CHECK AGAIN
         MOV TIME_AUX, DL  ;UPDATE TIME
           
         
         CALL CLEAR_SCREEN
             
         CALL MOV_BALL 
        
         CALL DRAW_BALL
         
         CALL DRAW_PADDLES
                  
         JMP CHECK_TIME    ;CHECKS TIME AGAIN AFTER EVERYTHING  
      
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
    
    
    DRAW_PADDLES PROC NEAR 
        
        ;LEFT PADDLE
        
        MOV CX, PADDLE_LEFT_X
        MOV DX, PADDLE_LEFT_Y 
        
        DRAW_PADDLE_LEFT_HORIZONTAL:
            MOV AH, 0CH
            MOV AL, 0FH
            MOV BH, 00H
            INT 10H 
            
            INC CX        ; CX++
            MOV AX, CX              
            SUB AX, PADDLE_LEFT_X
            CMP AX, PADDLE_WIDTH
            JNG DRAW_PADDLE_LEFT_HORIZONTAL 
            
            MOV CX, PADDLE_LEFT_X ;CX GOES BACK TO INITIAL COL
            INC DX         ; ADVANCE ONE LINE 
            MOV AX, DX
            SUB AX, PADDLE_LEFT_Y          ; same logic for y
            CMP AX, PADDLE_HEIGHT
            JNG DRAW_PADDLE_LEFT_HORIZONTAL  
            
               
        ;RIGHT PADDLE  
        
        MOV CX, PADDLE_RIGHT_X
        MOV DX, PADDLE_RIGHT_Y 
           
        
        DRAW_PADDLE_RIGHT_HORIZONTAL:
            MOV AH, 0CH
            MOV AL, 0FH
            MOV BH, 00H
            INT 10H 
            
            INC CX        ; CX++
            MOV AX, CX              
            SUB AX, PADDLE_RIGHT_X
            CMP AX, PADDLE_WIDTH
            JNG DRAW_PADDLE_RIGHT_HORIZONTAL 
            
            MOV CX, PADDLE_RIGHT_X ;CX GOES BACK TO INITIAL COL
            INC DX         ; ADVANCE ONE LINE 
            MOV AX, DX
            SUB AX, PADDLE_RIGHT_Y          ; same logic for y
            CMP AX, PADDLE_HEIGHT
            JNG DRAW_PADDLE_RIGHT_HORIZONTAL
        
         RET
    DRAW_PADDLES ENDP
    
    
    CLEAR_SCREEN PROC NEAR
        
         MOV AH, 00h   ; SET VIDEO MODE
         MOV AL, 13h   ; CHOOSE THE VIDEO MODE
         INT 10h
         
         MOV AH, 0BH   ; SET THE CONFIGURATION TO THE BACKGROUND COLOR
         MOV BH, 00H
         MOV BL, 00H   ;CHOOSE BLACK AS BACKGROUND COLOR
         INT 10H 
         
         RET
        
    CLEAR_SCREEN ENDP  
    
    
    MOV_BALL PROC NEAR
         
      CHECK_KEY_STROKE:
       ;CHECK IF ANY KEY IS BEING PRESSED, IF NOT EXIT THE PROCEDURE
       MOV AH, 01H
       INT 16H
       
       ;CHECK WHICH KEY IS BEING PRESSED, AL = ASCII CAHR 
       JZ CHECK_INPUT
       MOV AH, 00H
       INT 16H
       JMP CHECK_KEY_STROKE
            
       CHECK_INPUT:
       ;IF 'J'OR 'j' MOVE LEFT
       CMP AL, 4AH ;J
       JE MOV_BALL_LEFT
       CMP AL, 6AH ;j
       JE MOV_BALL_LEFT
       
       ;IF 'K'OR 'k' MOVE RIGHT
       CMP AL,4BH ;K
       JE MOV_BALL_RIGHT
       CMP AL, 6BH;k
       JE MOV_BALL_RIGHT 
       
       
       ;COLLISON  
       MOV AX, WINDOW_BOUNCE
       CMP BALL_Y, AX  ;BALL_Y < 0 -> COLLIDED
       JL NEG_VELOCITY_Y 
       
       MOV AX, WINDOW_HEIGHT
       SUB AX, BALL_SIZE 
       SUB AX, WINDOW_BOUNCE
      
       CMP BALL_Y, AX
       JG NEG_VELOCITY_Y ;BALL_Y > WINDOS_HEIGHT - BALL_SIZE -> COLLIDED
       
       RET 
       
       NEG_VELOCITY_Y:
        NEG BALL_V_Y
        RET
        
      
    MOV_BALL ENDP 
    
    
    MOV_BALL_RIGHT PROC NEAR
        MOV AX, BALL_V_X 
        ADD BALL_X, AX
        
      RET
        
     MOV_BALL_RIGHT ENDP 
    
    
     MOV_BALL_LEFT PROC NEAR
        MOV AX, BALL_V_X 
        SUB BALL_X, AX
        
        RET
     MOV_BALL_LEFT ENDP 
    
    
CODE ENDS
  
END  
  
