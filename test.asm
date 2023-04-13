.MODEL MEDIUM

STACK SEGMENT PARA STACK 
   DB 64 DUP (' ')     ;FILL THE STACK WITH 64 EMPTY SPACES
STACK ENDS
DATA SEGMENT PARA 'DATA'
    
    WINDOW_WIDTH DW 140H  ;WIDTH OF THE WINDOW 
    WINDOW_HEIGHT DW 0C8H ;HEIGHT OF THE WINDOW
    WINDOW_BOUNCE DW 6
    
    TEXT_PLAYER_POINTS DB '0','$'   ;TEXT WITH PLATER'S POINTS
    TEXT_GAME_OVER DB 'GAME OVER', '$' ;GAME OVER TITLE
  
    TIME_AUX DB 0   ;VARIABLE USED WHEN CHECKING IF THE TIME HAS CHANGED
    GAME_ACTIVE DB 1;CHECK IF THE GAME IS ACTIVE. 1 -> YES, 0 -> NO 
    
    BALL_X DW 0Ah   ;X OF THE BALL
    BALL_Y DW 0Ah   ;Y OF THE BLL  
    BALL_SIZE DW 08H ;SIZE OF THE BALL 
    BALL_V_X DW 05H  ;X VELOCITY OF THE BALL
    BALL_V_Y DW 05H  ;Y VELOCITY OF THE BALL 
    
    ;VARIABLES FOR PADDLES
    ;PADDLE_LEFT_X DW 00AH
    ;PADDLE_LEFT_Y DW 0B4H
    PADDLE_LEFT_POINT DW 0     
    
    PADDLE_RIGHT_X DW 110H
    PADDLE_RIGHT_Y DW 0B4H
    PADDLE_RIGHT_POINT DW 0
    
    PADDLE_WIDTH DW 01FH
    PADDLE_HEIGHT DW 005H  
    
    BAR_X DW 8DH
    BAR_Y DW 5DH
    BAR_SIZE DW 08H   
                       
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
      

      CHECK_TIME:      ;TIME CHECKING LOOP
      
         CMP GAME_ACTIVE, 00H
         JE  SHOW_GAME_OVER
         
         
         MOV AH, 2CH   ; GET THE SYSTEM TIME
         INT 21H       ;CH = HOUR CL = MINUTE DH = SECOND DL = 1/100 SECOND 
      
         CMP DL, TIME_AUX
         JE CHECK_TIME ; IF IT IS THE SAME, CHECK AGAIN
         MOV TIME_AUX, DL  ;UPDATE TIME                                         
         CALL CLEAR_SCREEN
             
         CALL MOV_BALL 
        
         CALL DRAW_BALL
         
         CALL DRAW_BAR
         
         CALL DRAW_PADDLES
         
         CALL DRAW_UI      ;DRAW USER'S POINT
                  
         JMP CHECK_TIME    ;CHECKS TIME AGAIN AFTER EVERYTHING
         
         SHOW_GAME_OVER:
            CALL DRAW_GAME_OVER 
            JMP CHECK_TIME 
      
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
    
    DRAW_BAR PROC NEAR 
        MOV CX, BAR_X
        MOV DX, BAR_Y
        DRAW_BAR_HORIZONTAL:
                            
        MOV AH, 0CH   ; SET THE CONFIGURATION TO WRITE A PIXEL
        MOV AL, 4   ; CHOOSE RED AS COLOR OF THE PIXEL
        MOV BH, 00H   ; SET THE PAGE NUMBER
        INT 10H 
        INC CX        ; CX++
        MOV AX, CX              ; CX - BALL_X > BALL_SIZE ( Y -> GO TO NEXT LINE, N -> GO TO NEXT COL
        SUB AX, BAR_X
        CMP AX, BAR_SIZE
        JNG DRAW_BAR_HORIZONTAL
        MOV CX, BAR_X ;CX GOES BACK TO INITIAL COL
        INC DX         ; ADVANCE ONE LINE 
        MOV AX, DX
        SUB AX, BAR_Y          ; same logic for y
        CMP AX, BAR_SIZE
        JNG DRAW_BAR_HORIZONTAL
        
        RET
        
    DRAW_BAR ENDP
        
    
    
    DRAW_PADDLES PROC NEAR 
            
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
    
    DRAW_NEW_PADDLE PROC NEAR 
        CALL GENERATE_RANDOM_X
        MOV PADDLE_RIGHT_X, AX
        CALL GENERATE_RANDOM_Y 
        MOV PADDLE_RIGHT_Y, AX
      
        MOV CX, PADDLE_RIGHT_X
        MOV DX, PADDLE_RIGHT_Y 
        
        DRAW_NEW_PADDLE_RIGHT_HORIZONTAL:
            MOV AH, 0CH
            MOV AL, 0FH
            MOV BH, 00H
            INT 10H 
            
            INC CX        ; CX++
            MOV AX, CX              
            SUB AX, PADDLE_RIGHT_X
            CMP AX, PADDLE_WIDTH
            JNG DRAW_NEW_PADDLE_RIGHT_HORIZONTAL 
            
            MOV CX, PADDLE_RIGHT_X ;CX GOES BACK TO INITIAL COL
            INC DX         ; ADVANCE ONE LINE 
            MOV AX, DX
            SUB AX, PADDLE_RIGHT_Y          ; same logic for y
            CMP AX, PADDLE_HEIGHT
            JNG DRAW_NEW_PADDLE_RIGHT_HORIZONTAL
        
        RET
    DRAW_NEW_PADDLE ENDP
    
    ;DISPLAY TEXT (PLAYER'S POINT)
    DRAW_UI PROC NEAR
        
        MOV AH, 02H   ;SET THE CURSOR'S POSITION
        MOV BH, 00H   ;SET PAGE NUMBER
        MOV DH, 002H   ;SET ROW
        MOV DL, 0C5H   ;SET COLUMN 
        INT 10H
        
        MOV AH, 09H   ;WRITE STRING TO OUTPUT
        LEA DX, TEXT_PLAYER_POINTS 
        INT 21H
        
        RET
    DRAW_UI ENDP
    
    
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
        
       MOV AX, BALL_V_Y
       ADD BALL_Y, AX   ;MOVE THE BALL VERTICALLY
       CMP BALL_Y, 00H
       JL COLL_UP
       
       ;MOV AX, BALL_V_X
       ;ADD BALL_X, AX   ;MOV THE BALL HORIZONTALLY 
       
       ;COLLISON WITH THE BOTTOM OF THE SCREEN
       
       ;MOV AX, WINDOW_BOUNCE 
       ;CMP BALL_Y, AX  ;BALL_Y < 0 -> COLLIDED
       ;JL NEG_VELOCITY_Y  
       
       MOV AX, WINDOW_HEIGHT
       SUB AX, BALL_SIZE 
       SUB AX, WINDOW_BOUNCE
      
       CMP BALL_Y, AX
       JG NEG_VELOCITY_Y ;BALL_Y > WINDOS_HEIGHT - BALL_SIZE -> COLLIDED
        
       
       ;COLLISION WITH RIGHT PADDLE
       
       ;CHECK COLLISON JUST IF VELOCITY IS GREATER THAN 0
       CMP BALL_V_Y, 00H
       JG COLL_RIGHT
       RET
        
       COLL_RIGHT:
        MOV AX, PADDLE_RIGHT_X
        ADD AX, PADDLE_WIDTH ;MAXX1
        CMP AX, BALL_X       ;MINX2
        JNG COLL_LEFT   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE
       
        MOV AX, BALL_X
        ADD AX, BALL_SIZE      ;MAXX2
        CMP PADDLE_RIGHT_X, AX ;MINX1
        JNL COLL_LEFT   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE 
       
        MOV AX, BALL_Y
        ADD AX, BALL_SIZE             ;MAXY1
        CMP AX, PADDLE_RIGHT_Y        ;MINY2
        JNG COLL_LEFT   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE
       
        MOV AX, BALL_X
        ADD AX, BALL_SIZE      ;MAXY2
        CMP PADDLE_RIGHT_Y, AX ;MINY1
        JNL COLL_LEFT   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE
       
       
       ;IF IT REACHES HERE, THERE'S A COLLISION WITH THE RIGHT PADDLE
       NEG BALL_V_Y           ;REVERSE VERTICAL VELOCITY OF THE BALL 
       CALL DRAW_NEW_PADDLE
       INC PADDLE_RIGHT_POINT
       CALL UPDATE_POINTS 
       RET                    ;EXIT THIS PROC
        
       NEG_VELOCITY_Y:
        NEG BALL_V_Y 
        JMP GAME_OVER
        RET
        
    MOV_BALL ENDP
    
    MOV_BALL_LEFT PROC NEAR
     MOV AX, BALL_V_X 
     SUB BALL_X, AX
     RET
    MOV_BALL_LEFT ENDP
                  
                  
     MOV_BALL_RIGHT PROC NEAR
      MOV AX, BALL_V_X 
      ADD BALL_X, AX
      RET 
     MOV_BALL_RIGHT ENDP  
     
     COLL_UP PROC NEAR
       MOV AX, WINDOW_BOUNCE
       SUB AX, BALL_SIZE 
       ;CMP BALL_V_Y, 00H
       CMP BALL_Y, AX
       JG  PURE_NEG_V
       
       PURE_NEG_V:
        NEG BALL_V_Y
        RET
       
       RET
     COLL_UP ENDP 
     
   
     COLL_LEFT PROC NEAR  
       
      RET
     COLL_LEFT ENDP 
     
     COLL_BAR PROC NEAR
        MOV AX, BAR_X
        ADD AX, BAR_SIZE ;MAXX1
        CMP AX, BALL_X       ;MINX2
        RET   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE
       
        MOV AX, BALL_X
        ADD AX, BALL_SIZE      ;MAXX2
        CMP BAR_X, AX ;MINX1
        RET   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE 
       
        MOV AX, BALL_Y
        ADD AX, BALL_SIZE             ;MAXY1
        CMP AX, BAR_Y        ;MINY2
        RET   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE
       
        MOV AX, BALL_X
        ADD AX, BALL_SIZE      ;MAXY2
        CMP BAR_Y, AX ;MINY1
        RET   ;IF THERE'S NO COLLISION, CHECK FOR THE OTHER PADDLE
       
       
       ;IF IT REACHES HERE, THERE'S A COLLISION WITH THE RIGHT PADDLE
       NEG BALL_V_Y           ;REVERSE VERTICAL VELOCITY OF THE BALL 
       ;CALL DRAW_NEW_PADDLE
       ;INC PADDLE_RIGHT_POINT
       ;CALL UPDATE_POINTS 
       CALL GAME_OVER
       RET 
    COLL_BAR ENDP
     
     
     UPDATE_POINTS PROC NEAR
        
       ; MOV  AX, 00H                ;CLEAR AX
        MOV AX, PADDLE_LEFT_POINT ;PADDLE LEFT POINTS      
        MOV DI, PADDLE_RIGHT_POINT
        ADD AX, DI
        
        ;NOW BEFORE PRINTING TO THE SCREEN WE NEED RO CONVERT DECIMAL VAL TO THE ASCII CODE CHAR
        ;WE DO THIS BU ADDING 30H AND BY SUBTRACTING 30H WE CONVERT ASCII TO NUMBER
        ADD AL, 30H
        MOV [TEXT_PLAYER_POINTS], AL            
                       
       RET                
     UPDATE_POINTS ENDP
     
     GAME_OVER PROC NEAR
        MOV GAME_ACTIVE, 00H       ; STOPS THE GAME
        
        RET
     GAME_OVER ENDP
     
     DRAW_GAME_OVER PROC NEAR 
        CALL CLEAR_SCREEN
        
        ;SHOW MENU 
        
        MOV AH, 02H   ;SET THE CURSOR'S POSITION
        MOV BH, 00H   ;SET PAGE NUMBER
        MOV DH, 002H   ;SET ROW
        MOV DL, 0B0H   ;SET COLUMN 
        INT 10H
        
        MOV AH, 09H   ;WRITE STRING TO OUTPU
        LEA DX, TEXT_GAME_OVER 
        INT 21H 
        
        ;WAIT FOR A KEY PRESS 
        MOV AH, 00H
        INT 16H                    
                             
        RET
     DRAW_GAME_OVER ENDP
     
     
     CLEAR_SCREEN PROC NEAR
         
        ;CLEAR SCREEN BY SETTING VIDEO MODE
        
         MOV AH, 00h   ;SET VIDEO MODE
         MOV AL, 13h   ;CHOOSE THE VIDEO MODE
         INT 10h
         
         MOV AH, 0BH   ;SET THE CONFIGURATION TO THE BACKGROUND COLOR
         MOV BH, 00H
         MOV BL, 00H   ;CHOOSE BLACK AS BACKGROUND COLOR
         INT 10H 
         
         RET
        
    CLEAR_SCREEN ENDP 
     
    GENERATE_RANDOM_X PROC NEAR   
        MOV AH, 00H             ;GET SYSTEM TIME
        INT 1AH                 ;CX:DX now hold number of clock ticks since midnight
        MOV AX, DX
        MOV DX, 0H
        MOV BX, 010D
        DIV BX
        MOV AL, DL
        MOV AH, 0
        MOV BX, 05D             ;MUL THE RANDOM NUMBER
        MUL BX
        ADD AX, 150D
        MOV DX, 0
        RET  
    GENERATE_RANDOM_X ENDP
    
    GENERATE_RANDOM_Y PROC NEAR 
        MOV AH, 00H
        INT 1AH
        MOV AX, DX
        MOV DX, 00H
        MOV BX, 010D
        DIV BX ; range the number between 0 to 9 dividing by 10
        MOV AL, DL
        MOV AH, 0
        MOV BX, 3D ; multiply the random number to screen X
        MUL BX 
        ADD AX, 100D
        MOV DX, 0
        RET
    GENERATE_RANDOM_Y ENDP
        
    
    
CODE ENDS
  
END  