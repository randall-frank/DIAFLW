         ORG   $7A00
         DSK   bin/GAME2.BIN
         TYP   $06  ; /BIN file

BIGSHAPE =     $800
LOOKUP   =     BIGSHAPE+3
SET      =     LOOKUP+3
RNDIZE   =     SET+3
RND      =     RNDIZE+3
TEXT     =     RND+3
TEXTSET  =     TEXT+3
DRAW     =     TEXTSET+3
HIGHLITE =     DRAW+3
POCKETS  =     HIGHLITE+3
CLEAR    =     POCKETS+3
HIT      =     $9009
SCORE    =     $9006
TEMP0    =     $19
TEMP1    =     $1A
TEMP2    =     $1B
TEMP3    =     $1C
TEMP4    =     $1D
TEMP5    =     $1E
TEMP6    =     $1F
SOUND    =     $8980

* Main game step - 7A00

LOCAL_GAMESTEP
         LDA   #31
         STA   TEMP0
TOP1     JSR   MOVE
         DEC   TEMP0
         BPL   TOP1
         LDA   $7307
         JSR   DRAW
         LDA   #31
         STA   TEMP0
TOP2     JSR   FIRE
         DEC   TEMP0
         BPL   TOP2
         RTS
MOVE     JSR   RND
         CMP   #$B0
         BLT   M1
         RTS
M1       LDA   TEMP0
         ASL
         ASL
         ASL
         TAX
         STX   TEMP1
         LDA   $7000,X
         BEQ   M1-1
         CMP   #$80
         BGE   M1-1
         CMP   #1
         BEQ   M1-1
         CMP   #7
         BGE   M1-1
         STA   TEMP2
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
M3       LDA   XPOS
         CMP   $7300
         BNE   PICK
         LDA   YPOS
         CMP   $7301
         BNE   PICK
         RTS
PICK     LDY   TEMP2
         DEY
         DEY
         BEQ   XIN
         DEY
         BEQ   YIN
         DEY
         BEQ   BEST
         DEY
         BEQ   RAND
         JSR   RND
         CMP   #$60
         BGE   BEST
RAND     JSR   RND
         AND   #3
         JMP   MOVIT
XIN      LDA   XPOS
         CMP   $7300
         BEQ   YIN
         LDX   #1
         LDA   DELTAX
         BMI   M4
         LDX   #3
M4       TXA
         JMP   MOVIT
YIN      LDA   YPOS
         CMP   $7301
         BEQ   XIN
         LDX   #2
         LDA   DELTAY
         BMI   M5
         LDX   #0
M5       TXA
         JMP   MOVIT
BEST     LDA   DELTAX
         AND   #$7F
         STA   TEMP3
         LDA   DELTAY
         AND   #$7F
         CMP   TEMP3
         BLT   XIN
         JMP   YIN
MOVIT    ASL
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
         JSR   LOOKUP
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
FIRE     LDA   #$80
         STA   INNER
F0       LDA   TEMP0
         ASL
         ASL
         ASL
         TAX
         STX   TEMP1
         LDA   $7000,X
         BNE   F1
FOUT     RTS
F1       PHA
         JSR   DELT
         PLA
         JSR   SPEC
         JSR   RND
         LDX   TEMP1
         CMP   INNER
         BGE   F1111
         RTS
F1111    LDA   $7004,X
         CMP   $7300
         BEQ   XYES
         LDA   $7005,X
         CMP   $7301
         BEQ   YYES
         RTS
XYES     LDA   DELTAY
         AND   #$7F
         CMP   #4
         BGE   XYES-1
         LDX   #2
         LDA   DELTAY
         BPL   F2
         LDX   #0
F2       TXA
         JMP   DFIRE
YYES     LDA   DELTAX
         AND   #$7F
         CMP   #4
         BGE   XYES-1
         LDX   #1
         LDA   DELTAX
         BPL   F3
         LDX   #3
F3       TXA
         JMP   DFIRE
DELT     LDA   $7005,X
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
DIRS     DFB   0,1,255,0,0,255,1,0
DIR      DFB   0
DFIRE    STA   DIR
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
         JSR   BIGSHAPE
         LDA   #4
         JSR   SOUND
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
         JSR   LOOKUP
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
         JSR   BIGSHAPE
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
ONTARGET JSR   RND
         AND   #3
         CLC
         ADC   #8
         LDX   #3
         LDY   #3
         JSR   BIGSHAPE
         LDA   #1
         JSR   SOUND
         JSR   RND
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
O1       JSR   HIT
         DEC   TEMP3
         BPL   O1
ONE1     LDY   #60
DELAY2   LDA   #200
         SEC
         SBC   #1
         BNE   DELAY2+2
         DEY
         BNE   DELAY2
         LDA   $7307
         LDX   #3
         LDY   #3
         JMP   BIGSHAPE
SPEC     PHA
         LDA   DELTAX
         BEQ   S2
         LDA   DELTAY
         BEQ   S2
         PLA
         RTS
S2       PLA
         CMP   #$80
         BLT   NOSPEC
         TAX
         AND   #1
         BNE   SPEC2
         LDA   DELTAX
         BNE   NO
         LDA   DELTAY
         BNE   NO
SPEC2    TXA
         AND   #2
         BNE   NSPEC
         LDX   TEMP1
         LDA   #$80
         STA   $7004,X
         STA   $7005,X
NSPEC    LDA   #0
         STA   INNER
NOSPEC   LDX   TEMP1
         RTS
NO       PLA
         PLA
         RTS
INNER    DFB   0
