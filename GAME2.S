         ORG   $7A00
         DSK   bin/GAME2.BIN
         TYP   $06  ; /BIN file

         PUT  COMMON.S

TEMP0    =     $19
TEMP1    =     $1A
TEMP2    =     $1B
TEMP3    =     $1C
TEMP4    =     $1D
TEMP5    =     $1E
TEMP6    =     $1F


* Main game step - 7A00

LOCAL_GAMESTEP
         LDA   #31
         STA   TEMP0   ; There are 32 enemy slots we walk them from 31->0.
TOP1     JSR   MOVE    ; First we attempt to move them all
         DEC   TEMP0
         BPL   TOP1
         LDA   $7307
         JSR   PAC_DRAW  ; Make sure the player is on top (could have been obscured)

         LDA   #31
         STA   TEMP0   ; Resolve all combat for the 32 enemy slots
TOP2     JSR   FIRE    ; Attempt to fire them all
         DEC   TEMP0
         BPL   TOP2
         RTS

* Attempt to move the enemy: TEMP0

MOVE     JSR   PAC_RND ; Attempt to move an enemy, but not all the time, say 70%
         CMP   #$B0
         BLT   M1
         RTS
M1       LDA   TEMP0
         ASL
         ASL
         ASL
         TAX         ; X is the first byte of the enemy definition
         STX   TEMP1
         LDA   $7000,X
         BEQ   M1-1  ; 0=Dead enemy
         CMP   #$80  ; All traps are from 128-131
         BGE   M1-1  
         ; Not sure what these are... might be legacy
         CMP   #1
         BEQ   M1-1
         CMP   #7
         BGE   M1-1
         STA   TEMP2 ; TEMP2 is the enemy type
         ; Grab the positions
         ; X
         LDA   $7004,X
         STA   XPOS
         SEC
         SBC   $7300
         STA   DELTAX
         BPL   M2
         EOR   #$FF
         CLC
         ADC   #1
         ORA   #$80
         STA   DELTAX
         ; Y
M2       LDA   $7005,X
         STA   YPOS
         SEC
         SBC   $7301
         STA   DELTAY
         BPL   M3
         EOR   #$FF
         CLC
         ADC   #1
         ORA   #$80
         STA   DELTAY
M3       LDA   XPOS  ; Should we try to move the enemy?  not if the are already on the player
         CMP   PLAYER_X 
         BNE   PICK
         LDA   YPOS
         CMP   PLAYER_Y
         BNE   PICK
         RTS
PICK     LDY   TEMP2 ; pick the enemy motion?
         DEY
         DEY
         BEQ   XIN   ; X finder (2)
         DEY
         BEQ   YIN   ; Y finder (3)
         DEY
         BEQ   BEST  ; XY-best (4)
         DEY
         BEQ   RAND  ; random (5)
         JSR   PAC_RND
         CMP   #$60
         BGE   BEST
RAND     JSR   PAC_RND
         AND   #3
         JMP   MOVIT
XIN      LDA   XPOS   ; X finder
         CMP   $7300
         BEQ   YIN
         LDX   #1
         LDA   DELTAX
         BMI   M4
         LDX   #3
M4       TXA
         JMP   MOVIT
YIN      LDA   YPOS   ; Y finder
         CMP   $7301
         BEQ   XIN
         LDX   #2
         LDA   DELTAY
         BMI   M5
         LDX   #0
M5       TXA
         JMP   MOVIT
BEST     LDA   DELTAX  ; XY best
         AND   #$7F
         STA   TEMP3
         LDA   DELTAY
         AND   #$7F
         CMP   TEMP3
         BLT   XIN
         JMP   YIN
MOVIT    ASL   ; Actually move the man
         TAX
         LDA   DX,X
         CLC
         ADC   XPOS
         CMP   #64
         BLT   M6
NOWAY    SEC
         RTS
M6       STA   XN
         LDA   DX+1,X
         CLC
         ADC   YPOS
         CMP   #64
         BGE   NOWAY
         STA   YN
         LDX   XN
         TAY
         JSR   PAC_LOOKUP
         BCS   NOWAY
         CMP   #4
         BEQ   M7
         CMP   #106
         BLT   NOWAY
M7       LDX   TEMP1
         LDA   XN
         CMP   $7300
         BNE   YESWAY
         LDA   YN
         CMP   $7301
         BNE   YESWAY
         SEC
         RTS
YESWAY   LDA   XN
         STA   $7004,X
         LDA   YN
         STA   $7005,X
         CLC
         RTS

DX       DFB   0,255,1,0,0,1,255,0
XPOS     DFB   0
YPOS     DFB   0
XN       DFB   0
YN       DFB   0
DELTAX   DFB   0
DELTAY   DFB   0

* Attempt to fire the enemy: TEMP0

FIRE     LDA   #$80
         STA   INNER       ; shoot probability
         LDA   #0
         STA   ONESHOT     ; if non-zero, this is a oneshot trap
F0       LDA   TEMP0
         ASL
         ASL
         ASL
         TAX
         STX   TEMP1       ; index into enemy table
         LDA   $7000,X
         BNE   LIVE_ENEMY  ; Non-dead enemy
FOUT     RTS

LIVE_ENEMY 
         PHA               ; Enemy type is in A
         JSR   DELT        ; Compute delta from enemy to player
         PLA
         JSR   CHECK_TRAPS ; can set ONESHOT if the enemy is to be removed on a shot
                           ; can also not return at all (return from FIRE) if not ON
         JSR   PAC_RND
         LDX   TEMP1
         CMP   INNER       ; Don't always shoot... (traps set INNER to 0)
         BGE   TRY_SHOT
         RTS

TRY_SHOT LDA   $7004,X
         CMP   PLAYER_X
         BEQ   XYES
         LDA   $7005,X
         CMP   PLAYER_Y
         BEQ   YYES
         RTS           ; Note: local RTS target for branches, must be before XYES

XYES     LDA   DELTAY  ; Lined up in X
         AND   #$7F
         CMP   #4
         BGE   XYES-1  ; too far away
         LDX   #2
         LDA   DELTAY
         BPL   F2
         LDX   #0
F2       TXA
         JMP   DFIRE

YYES     LDA   DELTAX  ; Lined up in Y
         AND   #$7F
         CMP   #4
         BGE   XYES-1  ; too far away
         LDX   #1
         LDA   DELTAX
         BPL   F3
         LDX   #3
F3       TXA
         JMP   DFIRE

DELT     LDA   $7005,X   ; Compute position delta from the player
         SEC
         SBC   $7301
         BEQ   F4
         BPL   F4
         EOR   #$FF
         CLC
         ADC   #1
         ORA   #$80
F4       STA   DELTAY
         LDA   $7004,X
         SEC
         SBC   $7300
         BEQ   F5
         BPL   F5
         EOR   #$FF
         CLC
         ADC   #1
         ORA   #$80
F5       STA   DELTAX
         RTS

; deltas for X and Y for directions
DIRS     DFB   0,1, 255,0, 0,255, 1,0
DIR      DFB   0  ; direction of shot (from enemy/player deltas)

DFIRE    STA   DIR       ; Actually fire from an enemy to the player
         LDX   TEMP1
         LDA   $7004,X
         STA   XPOS
         SEC
         SBC   $7300
         CLC
         ADC   #3
         STA   TEMP3
         LDA   $7005,X
         STA   YPOS
         SEC
         SBC   $7301
         CLC
         ADC   #3
         STA   TEMP4
LOOP     LDA   #7
         LDX   TEMP3
         LDY   TEMP4
         JSR   PAC_BIGSHAPE
         LDA   #4
         JSR   PLAYSOUND
         LDY   #50
DELAY    LDA   #200
         SEC
         SBC   #1
         BNE   DELAY+2
         DEY
         BNE   DELAY
         LDA   XPOS
         CMP   $7300
         BNE   F9
         LDA   YPOS
         CMP   $7301
         BNE   F9
         JMP   ONTARGET
F9       LDX   XPOS
         LDY   YPOS
         JSR   PAC_LOOKUP
         PHP
         PHA
         PHA
         LDX   DIR
         LDA   INVTAB,X
         TAX
         PLA
         CPX   $7307
         BNE   F11
         LDA   #4
F11      LDX   TEMP3
         LDY   TEMP4
         JSR   PAC_BIGSHAPE
         PLA
         PLP
         BCC   F99
         BCS   F97
F98      RTS
INVTAB   DFB   2,3,0,1
F99      CMP   #106
         BGE   F97
         CMP   #4
         BNE   F98
F97      LDA   DIR
         ASL
         TAX
         LDA   XPOS
         CLC
         ADC   DIRS,X
         STA   XPOS
         LDA   YPOS
         CLC
         ADC   DIRS+1,X
         STA   YPOS
         LDA   TEMP3
         CLC
         ADC   DIRS,X
         STA   TEMP3
         LDA   TEMP4
         CLC
         ADC   DIRS+1,X
         STA   TEMP4
         JMP   LOOP
ONTARGET JSR   PAC_RND
         AND   #3
         CLC
         ADC   #8
         LDX   #3
         LDY   #3
         JSR   PAC_BIGSHAPE
         LDA   #1
         JSR   PLAYSOUND
         JSR   PAC_RND
         CMP   #$B0
         BGE   ONE1
         LDX   TEMP1
         LDA   $7001,X
         ASL
         ASL
         ASL
         ASL
         ASL
         STA   TEMP5
         LDA   #$72
         STA   TEMP6
         LDY   #21
         LDA   (TEMP5),Y
         STA   TEMP3
O1       JSR   IO_HIT
         DEC   TEMP3
         BPL   O1
ONE1     LDY   #60
DELAY2   LDA   #200
DELAY3   SEC
         SBC   #1
         BNE   DELAY3
         DEY
         BNE   DELAY2
         LDA   ONESHOT    ; Handle oneshot trap flag
         BEQ   NOTONCE

         LDX   TEMP1      ; Disable the "once" trap by moving it off the map
         LDA   #$80
         STA   $7004,X
         STA   $7005,X

NOTONCE  LDA   $7307
         LDX   #3
         LDY   #3
         JMP   PAC_BIGSHAPE


* Check/handle traps - handle "ONCE" and reset probability to 100%
* The enemy type is in A

CHECK_TRAPS   ; Note: TRY_SHOT does the DX/DY check
         CMP   #$80
         BLT   NOSPEC  ; regular enemy
         ; Trap case, check for NEAR or ON low order bit 0 (1)
         TAX
         AND   #1
         BNE   CHECK_ONCE

         ; Trap "ON" cases?  if either is non-zero, we cannot be ON
         LDA   DELTAX
         BNE   SKIP_ON
         LDA   DELTAY
         BNE   SKIP_ON

         ; Trap check for ONCE or MULTIPLE bit 1 (2)
CHECK_ONCE
         TXA
         AND   #2
         BNE   RESET_PROB

         ; This is the ONCE case and we move the trap off the map
         LDX   TEMP1
         LDA   #1
         STA   ONESHOT

RESET_PROB    
         LDA   #0     ; reset the probability to 100% for traps
         STA   INNER
NOSPEC   LDX   TEMP1
         RTS

SKIP_ON  PLA   ; pop the RTS from the JSR FIRE
         PLA   ; thus, this results in a return from the FIRE function
         RTS

INNER    DFB   0
ONESHOT  DFB   0
