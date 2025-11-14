         ORG   $800
         DSK   ../bin/PAC.BIN
         TYP   $06  ; /BIN file

         PUT  COMMON.S

*      START OF THE PAC ROUTINES
* NOTE THE VALUE AT $FFF DETERMINES THE PLACE
* FOR THE SHAPES TO COME FROM  $10 OR $A0
HIGHS    =     $E00   ; high order byte for HGR scanline
LOWS     =     $F00   ; low order byte for HGR scanline

RNDBUFF  =     $200   ; buffer of 256 random bytes

VERT     =     0
TEMP1    =     1
TEMP2    =     2
TEMP3    =     3
TEMP4    =     4
TEMP5    =     5
TEMP6    =     6
TEMP7    =     7
TEMP8    =     8
INDEX    =     $FE
START    =     $FF

HGRSRC_LO =     $E0
HGRSRC_HI =     $E1
HGRTGT_LO =     $26
HGRTGT_HI =     $27

MASKBYTE  =     $71
MASKON    =     $72

*       JUMPS TO START OF ROUTINES
         JMP   BIGSHAPE
         JMP   LOOKUP
         JMP   SET
         JMP   RNDMIZE
         JMP   RNDM
         JMP   TEXT
         JMP   TEXTSET
         JMP   DRAW
         JMP   HIGHLITE
         JMP   POCKETS
         JMP   CLEAR
         JMP   CLEAR2
         JMP   BOTTOMLINE
         JMP   SETMASK

         lst   off
CLEAR    LDX   #144
         JSR   CALC+1
         LDA   #0
         LDY   #14
CL1      STA   (HGRTGT_LO),Y
         DEY
         BNE   CL1
         INX
         CPX   #184
         BNE   CLEAR+2
         RTS

* initialize the random number system
RNDMIZE  LDY   #0
         STY   TEMP1
R1L      JSR   RND
         LDA   $9F
         LDY   TEMP1
         STA   RNDBUFF,Y
         INC   TEMP1
         BNE   R1L
         RTS

* return a random byte from the table
* if we run out of space, compute a new random index
* into the table.

RNDM     INC   INDEX
         LDY   INDEX
         CPY   START
         BNE   R2L
         JSR   RND
         LDY   $9F
         STY   START
         STY   INDEX
R2L      LDA   RNDBUFF,Y
         RTS

UNUSED = 0
         DO UNUSED

* Potential new random number generator
* Seed the random number generator with a reasonable initial value

RNDMIZE 
         LDA $4E          ; Seed the random number generator
         STA R1           ; based on delay between keypresses
         STA R3
         LDA $4F
         STA R2
         STA R4
         LDX #$20         ; Generate a few random numbers
INITLOOP JSR RNDM         ; to kick things off
         DEX
         BNE INITLOOP
         RTS

R1       DFB 0
R2       DFB 0
R3       DFB 0
R4       DFB 0

* return a random byte 

RNDM   
         ROR R4           ; Bit 25 to carry
         LDA R3           ; Shift left 8 bits
         STA R4
         LDA R2
         STA R3
         LDA R1
         STA R2
         LDA R4           ; Get original bits 17-24
         ROR              ; Now bits 18-25 in ACC
         ROL R1           ; R1 holds bits 1-7
         EOR R1           ; Seven bits at once
         ROR R4           ; Shift right by one bit
         ROR R3
         ROR R2
         ROR
         STA R1
         RTS

         FIN

* For a given scanline in A, set up HGRTGT_LO,HGRTGT_HI ($26,$27) to point at
* the scan line start (X and A are scrambled)
CALC     TAX
         LDA   LOWS,X
         STA   HGRTGT_LO
         LDA   HIGHS,X
         STA   HGRTGT_HI
         RTS

* Set scanline masking for blocks in the accumulator 0=none 1=even
SETMASK  CMP   #0
         BEQ   THEMASK
         LDA   #31
THEMASK  STA   MASKON
         RTS

BIGSHAPE PHA
         LDA   #0
         STA   HGRSRC_LO
         PLA
         LSR
         ROR   HGRSRC_LO
         LSR
         ROR   HGRSRC_LO
         LSR
         ROR   HGRSRC_LO
         ORA   PAC_WHICHTBL
         STA   HGRSRC_HI
         LDA   TBL,Y
         STA   VERT
         TXA
         ASL
         TAY
         INY   ; Move the blocks two columns to the right RJF
         INY
         STY   TEMP3
         LDA   #16    ; Blocks are 16 scanlines high
         STA   TEMP1

BLK_LINE LDX   VERT   ; Set up scanline addr
         LDA   LOWS,X
         STA   HGRTGT_LO
         LDA   HIGHS,X
         STA   HGRTGT_HI

         LDA   MASKON   ; are we drawing this line?
         AND   TEMP1
         BEQ   DRAWLINE

         LDA   #0      ; Draw a blank line
         INC   HGRSRC_LO
         INC   HGRSRC_LO
         STA   (HGRTGT_LO),Y
         INY
         STA   (HGRTGT_LO),Y
         JMP   NEXT

DRAWLINE LDX   #0
         LDA   (HGRSRC_LO,X)
         INC   HGRSRC_LO
         STA   (HGRTGT_LO),Y
         INY
         LDA   (HGRSRC_LO,X)
         INC   HGRSRC_LO
         STA   (HGRTGT_LO),Y

NEXT     LDY   TEMP3
         INC   VERT
         DEC   TEMP1
         BNE   BLK_LINE
         RTS

TBL      DFB   8,24,40,56,72,88,104

LOOKUP   STX   TEMP1   ; lookup up what shape is located at X,Y
         STY   TEMP2
         ; Scan the enemy table
         LDX   #0
         LDY   #0
PL2      INY
         INY
         INY
         INY
         LDA   ENEMY_TABLE,Y
         CMP   TEMP1
         BNE   PL3
         INY
         LDA   ENEMY_TABLE,Y
         CMP   TEMP2
         BNE   PL3
         INY   ; The location is an enemy, return the proper block
         INY
         LDA   ENEMY_TABLE,Y
         SEC
         RTS
;       IF CARRY IS SET YOU FOUND AN ENEMY AND ITS # IS X
PL3      INX
         CPX   #32
         BEQ   PL4
         TXA
         ASL
         ASL
         ASL
         TAY
         JMP   PL2
PL4      LDA   TEMP2    ; Return the shape at the location
         LDX   #0
         STX   TEMP3
         LSR
         ROR   TEMP3
         LSR
         ROR   TEMP3
         ORA   #$60
         STA   TEMP4
         LDY   TEMP1
         LDA   (TEMP3),Y
         CLC            ; Carry is clear and A is the shape
         RTS

SET      STX   TEMP1
         PHA
         TYA
         LDY   #0
         STY   TEMP3
         LSR
         ROR   TEMP3
         LSR
         ROR   TEMP3
         ORA   #$60
         STA   TEMP4
         LDY   TEMP1
         PLA
         STA   (TEMP3),Y
         RTS
TEXTSET  STX   CURX
         STX   XSTART
         LDX   #0
         STX   CURCOUNT
         STY   CURY
         STA   COUNT
         RTS
XSTART   DFB   0
CURCOUNT DFB   0
CURX     DFB   0
CURY     DFB   0
COUNT    DFB   0
*  SET TAKES X & Y AND POINTS THE CURRENT TEXT TO THAT POINT
* IT ALSO RESETS THE COUNTER FOR LOOPING AT ACC CHARS
TEXT     CMP   #$FE
         BEQ   MOVEONLY
         PHA
*    PRINT CHARACTER IN ACC AT CURRENT X,Y AND UPDATE
         LDA   CURY
         STA   TEMP1
         LDY   CURX
         PLA
         AND   #$7F
         LDX   #%00010111  ; 0x17 Then two ROLs (high order char bits)
* Char table effectively starts at 5C00 -> %010111xx
         STX   MOD+2
         ASL
         ASL
         ROL   MOD+2
         ASL
         ROL   MOD+2
         STA   MOD+1
         LDX   #8
         STX   TEMP2
PL6      LDA   TEMP1
         JSR   CALC
MOD      LDA   $FFFF
         STA   (HGRTGT_LO),Y
         INC   MOD+1
         INC   TEMP1
         DEC   TEMP2
         BNE   PL6
MOVEONLY INC   CURX
         INC   CURCOUNT
         LDA   CURCOUNT
         CMP   COUNT
         BNE   PL7
         LDA   XSTART
         STA   CURX
BUMPLINE LDA   CURY
         CLC
         ADC   #8
         STA   CURY
         LDA   #0
         STA   CURCOUNT
PL7      RTS
* DRAW ACC=DIR 1=R 2=D 3=L 0=U  X,Y= POSITION OF MAN
DRAW     PHA
         LDA   #0
         JSR   SETMASK
         LDX   $7300
         LDY   $7301
         TXA
         CLC
         ADC   #$FD       ;(-3)
         STA   TEMP5      ; X-3
         TYA
         CLC
         ADC   #$FD
         STA   TEMP6      ; Y-3
         PLA
         CMP   DIR
         BEQ   SAMEDIR
         BNE   SAMEDIR    ; RJF no need to erase on rotate as we are painting everything
* Erase the blocks of the previous direction         
         PHA
         LDA   DIR
         ASL
         ASL
         ASL
         ASL
         ASL
         ASL   ; RJF  dir*64 for TABX and TABY index
         STA   TEMP7      ; Index into the TABX,TABY arrays
ERAS     LDY   TEMP7
         LDA   TABX,Y
         TAX
         CPX   #$FF
         BEQ   SAMEDIR1
         LDA   TABY,Y
         TAY
         LDA   #4         ; BLANK SPACE
         JSR   BIGSHAPE   ; X=Relative to TEMP5, Y=Relative to TEMP6, A=shape
         INC   TEMP7
         JMP   ERAS
SAMEDIR1 PLA
SAMEDIR  STA   DIR
         ASL
         ASL
         ASL
         ASL
         ASL
         ASL   ; RJF  dir*64 for TABX and TABY index
         STA   TEMP7
DR       LDY   TEMP7
         LDA   TABX,Y
         CMP   #$FE
         BNE   CHECK_DONE
         LDA   #1     ; 254=switch to "hidden" mode
         JSR   SETMASK
         INC   TEMP7
         JMP   DR
CHECK_DONE
         CMP   #$FF
         BEQ   DROUT
         CLC
         ADC   TEMP5
         TAX
         LDA   TABY,Y
         CLC
         ADC   TEMP6
         TAY
         CPX   #64
         BGE   OUTSIDE
         CPY   #64
         BGE   OUTSIDE
         JSR   LOOKUP   ; if carry is set, then enemy.
         JMP   OK1
OUTSIDE  LDA   #4      ; Blank for outside of the grid
OK1      PHA
         LDY   TEMP7
         LDA   TABX,Y
         TAX
         LDA   TABY,Y
         TAY
         PLA
         JSR   BIGSHAPE  ; X=Relative to TEMP5, Y=Relative to TEMP6, A=shape
         INC   TEMP7
         JMP   DR
* Draw the player in the center (3,3)
DROUT    
         LDA   #0
         JSR   SETMASK
         LDX   #3
         LDY   #3
         LDA   DIR
         JMP   BIGSHAPE  ; Draw the character (DIR) in the center (3,3)
DIR      DFB   0
*   DRAWS HIGHLITES
*  $7303 =HAND   $7304=POCKET
HIGHLITE LDX   #18    ; RJF was 17
         LDY   #44
         LDA   #30
         JSR   TEXTSET
         LDA   #0
         STA   TEMP7
H1       LDY   TEMP7
         LDA   RL,Y
         CMP   #$FF
         BEQ   H2
         JSR   TEXT
         INC   TEMP7
         BNE   H1
H2       LDY   $7303
         LDA   XRL,Y
         STA   TEMP1
         LDA   #44
         STA   VERT
         JSR   HIGHL
         LDX   #18   ; RJF was 17
         LDY   #92
         LDA   #30
         JSR   TEXTSET
         LDA   #0
         STA   TEMP7
H3       LDY   TEMP7
         LDA   P12,Y
         CMP   #$FF
         BEQ   H4
         JSR   TEXT
         INC   TEMP7
         BNE   H3
H4       LDX   #18   ; RJF was 17
         LDY   #132
         LDA   #30
         JSR   TEXTSET
         LDA   #0
         STA   TEMP7
H5       LDY   TEMP7
         LDA   P34,Y
         CMP   #$FF
         BEQ   H6
         JSR   TEXT
         INC   TEMP7
         BNE   H5
H6       LDA   $7304
         ASL
         TAY
         LDA   OFFSETS,Y
         STA   TEMP1
         LDA   OFFSETS+1,Y
         STA   VERT
         JMP   HIGHL
XRL      DFB   18,29  ; RJF  was 17
OFFSETS  DFB   0,0,18,92,29,92,18,132,29,132  ; RJF
RL       ASC   'Right hand'
         DFB   254   ; RJF ,254 dropping out one char
         ASC   'Left hand '
         DFB   255
P12      ASC   'Pocket #1 '
         DFB   254  ; RJF ,254
         ASC   'Pocket #2 '
         DFB   255
P34      ASC   'Pocket #3 '
         DFB   254    ; RJF ,254
         ASC   'Pocket #4 '
         DFB   255
HIGHL    LDA   #8
         STA   TEMP2
H7       LDA   VERT
         JSR   CALC
         LDY   TEMP1
         LDX   #10
H8       LDA   (HGRTGT_LO),Y
         EOR   #$7F
         STA   (HGRTGT_LO),Y
         INY
         DEX
         BNE   H8
         INC   VERT
         DEC   TEMP2
         BNE   H7
         RTS
POCKETS  STA   TEMP6
         ASL
         TAY
         LDA   XYLOC-2,Y
         TAX
         LDA   XYLOC-1,Y
         TAY
         LDA   #10
         JSR   TEXTSET
         LDY   TEMP6
         DEY
         TYA
         ASL
         ASL
         TAY
         STY   TEMP6
         LDA   $7310,Y
         CMP   #$FF
         BNE   POC1
         JSR   BLANKS
         JMP   POC2
POC1     ASL
         ASL
         ASL
         ASL
         ASL
         STA   TEMP4
         LDA   #$72
         STA   TEMP5
         JSR   PLOT10
POC2     JSR   BUMPLINE
         LDY   TEMP6
         LDA   $7311,Y
         CMP   #$FF
         BNE   POC3
         JMP   BLANKS
POC3     ASL
         ASL
         ASL
         ASL
         ASL
         CLC
         ADC   #10
         STA   TEMP4
         LDA   #$72
         STA   TEMP5
         LDA   #9
         JSR   PLOTX
         LDY   TEMP6
         LDA   $7312,Y
         ORA   #$B0
         JMP   TEXT

* Output 10 'blank' characters
BLANKS   LDA   #10
         STA   TEMP7
POC4     LDA   #$20   ; 2D='-'  20=' '
         JSR   TEXT
         DEC   TEMP7
         BNE   POC4
         RTS
PLOT10   LDA   #10
PLOTX    STA   TEMP7
         LDY   #0
         STY   TEMP8
POC5     LDA   (TEMP4),Y
         JSR   TEXT
         INC   TEMP8
         LDY   TEMP8
         DEC   TEMP7
         BNE   POC5
         RTS
* RJF 18s were 17s
XYLOC    DFB   18,104,29,104,18,144,29,144,18,56,29,56

* clear the entire HGR screen to black
CLEAR2   LDA   #$20
         STA   CLMOD+2
         LDX   #$20
         LDA   #$0
CL21     LDY   #0
CLMOD    STA   $2000,Y
         DEY
         BNE   CLMOD
         INC   CLMOD+2
         DEX
         BNE   CL21
         RTS

* Bottomline - draw the UI for the scenario selection screen
BOTTOMLINE
         LDX   #30
         LDY   #6*8
         LDA   #9
         JSR   TEXTSET
         LDY   #0
         STY   CNT
LOOP     LDY   CNT
         LDA   LINES,Y
         BEQ   OUTLOOP
         JSR   TEXT
         INC   CNT
         JMP   LOOP
OUTLOOP
         LDA   #40
         LDY   #0
         LDX   #0
         JSR   TEXTSET
         ldy   #0
         sty   CNT
LOOP2    LDY   CNT
         LDA   LINES2,Y
         BEQ   OL1
         JSR   TEXT
         INC   CNT
         JMP   LOOP2
OL1      RTS
LINES    HEX   14181818181818181519
         ASC   'O:Open '
         hex   19161818181818181817
         hex   14181818181818181519
         ASC   'U:DirUp'
         hex   19161818181818181817
         HEX   14181818181818181519
MYLINE   ASC   'D:Disk '
         hex   19161818181818181817
         hex   14181818181818181519
         ASC   'Q:Quit '
         hex   19161818181818181817
         DFB   0
CNT      DFB   0
LINES2   HEX   1418
         ASC   'Select a scenario to play'
         hex   A0181818181818181818181815
         hex   19
         asc   '                                      '
         hex   1919
         asc   '                                      '
         hex   19
         hex   1618181818181818181818181818181818181818
         hex   1818181818181818181818181818181818181817
         dfb   0
