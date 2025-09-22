         ORG   $8000
         DSK   bin/OPENING2.BIN
         TYP   $06  ; /BIN file

         LST   Off
WHICHTBL =     $FFF
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
GETPREFIX =    $900C
SHOWSPLASH =   $4000
SHOWPLAY =     $4003   ; was $4F00

TEMP0    =     $19
TEMP1    =     $1A
TEMP2    =     $1B
TEMP3    =     $1C
TEMP4    =     $1D
TEMP5    =     $1E
TEMP6    =     $1F

         lda   #<BYEBYE
         sta   $3f2
         lda   #>BYEBYE
         sta   $3f3
         eor   #$A5
         sta   $3f4
         JMP   LETSGO
NSD      ASC   'Name:  Score: Damage:'
CLEAR2   LDA   #00
         STA   TEMP0
         LDA   #$20
         STA   TEMP1
CL1      LDY   #0
         TYA
CL2      STA   (TEMP0),Y
         INY
         BNE   CL2
         INC   TEMP1
         LDA   TEMP1
         CMP   #$40
         BNE   CL1
         RTS
FILEN    STA   TEMP1
         STY   TEMP0
         LDY   #16
O1       LDA   (TEMP0),Y
         STA   FILENAME,Y
         DEY
         BPL   O1
         RTS
FILENAME DS    18
OFILE    JSR   FILEN
         JSR   $BF00
         HEX   C8
         DA    OPEN
         RTS
OPEN     HEX   03
         DA    FILENAME
         DA    $B000
         HEX   01
RFILE    JSR   $BF00
         HEX   CA
         DA    READ
         RTS
READ     HEX   04
         HEX   01
DBUFF    HEX   0000
DLEN     HEX   0000
         HEX   0000
CFILE    JSR   $BF00
         HEX   CC
         DA    CLOSE
         RTS
CLOSE    HEX   0101
WFILE    JSR   $BF00
         HEX   CB
         DA    READ
         RTS
PFILE    JSR   $BF00
         HEX   CE
         DA    POSITION
         RTS
POSITION HEX   0201000000
BYEBYE   JSR   $BF00
         HEX   65
         DA    QUIT
         RTS
QUIT     HEX   04000000000000
DESTROY  JSR   FILEN
         JSR   $BF00
         HEX   C1
         DA    DELZZ
         RTS
DELZZ    HEX   01
         DA    FILENAME
CREATE   JSR   FILEN
         JSR   $BF00
         HEX   C0
         DA    CREZZ
         RTS
CREZZ    HEX   07
         DA    FILENAME
         HEX   C30600730100000000
BLOCKS   HEX   06
         ASC   'BLOCKS         '
STARTER  HEX   07
         ASC   'STARTER        '
SAVED    HEX   05
         ASC   'SAVED          '
DATA     HEX   04
         ASC   'DATA           '
WEAPONS  HEX   07
         ASC   'WEAPONS        '
BLOCKS2  HEX   07
         ASC   'BLOCKS2        '
PROMPT   PHA
         JSR   CLEAR2
         LDA   #40
         LDX   #0
         LDY   #96
         JSR   TEXTSET
         PLA
         STA   TT+25
         LDA   #0
         STA   TEMP0
P1       LDY   TEMP0
         LDA   TT,Y
         CMP   #$FF
         BEQ   P2
         JSR   TEXT
         INC   TEMP0
         JMP   P1
P2       STA   $C010
P3       LDA   $C000
         BPL   P3
         STA   $C010
         JSR   CLEAR2
         RTS
TT       ASC   'PLACE SCENARIO DISK SIDE A IN A DRIVE.'
         DFB   255
LETSGO   JSR   SHOWSPLASH  ; Set up graphics splash screen
         LDA   $C000
         CMP   #$82     ; '^B' bye, everything else selects play
         BNE   LETUSGO
         JMP   BYEBYE
LETUSGO  
         STA   $C010
         JSR   GETPREFIX
         LDA   #>BLOCKS
         LDY   #<BLOCKS
         JSR   OFILE
         BCS   LETSGO+3
         LDA   #$10
         STA   DBUFF+1
         STA   DLEN+1
         LDA   #$0
         STA   DBUFF
         STA   DLEN
         JSR   RFILE
         JSR   CFILE
         LDA   #>BLOCKS2
         LDY   #<BLOCKS2
         JSR   OFILE
         BCC   UIJ
         LDA   #0
         STA   0
         STA   2
         LDA   #$10
         STA   1
         LDA   #$A0
         STA   3
UI1      LDY   #0
UI2      LDA   (0),Y
         STA   (2),Y
         DEY
         BNE   UI2
         INC   1
         INC   3
         LDA   1
         CMP   #$20
         BNE   UI1
         JMP   UI3
UIJ      LDA   #0
         STA   DBUFF
         STA   DLEN
         LDA   #$A0
         STA   DBUFF+1
         LDA   #$10
         STA   DLEN+1
         JSR   RFILE
         JSR   CFILE
UI3      LDA   #>WEAPONS
         LDY   #<WEAPONS
         JSR   OFILE
         LDA   #0
         STA   DLEN
         STA   DBUFF
         LDA   #1
         STA   DLEN+1
         LDA   #$72
         STA   DBUFF+1
         JSR   RFILE
         JSR   CFILE
         LDA   #>STARTER
         LDY   #<STARTER
         JSR   OFILE
         LDA   #0
         STA   DLEN
         STA   DBUFF
         LDA   #1
         STA   DLEN+1
         LDA   #$73
         STA   DBUFF+1
         JSR   RFILE
         JSR   CFILE
         LDA   #0
         STA   $8FFF
         LDA   #$10
         STA   WHICHTBL
         LDA   #>SAVED
         LDY   #<SAVED
         JSR   OFILE
         BCC   SKIP
         JMP   NEWCOMER
SKIP     LDA   #0
         STA   DLEN
         STA   DBUFF
         LDA   #1
         STA   DLEN+1
         LDA   #$73
         STA   DBUFF+1
         JSR   RFILE
         LDA   #$8F
         STA   DBUFF+1
         JSR   RFILE
         JSR   CFILE
         LDA   #>SAVED
         LDY   #<SAVED
         JSR   DESTROY
GAME     JSR   SHOWPLAY
         LDA   #7
         LDX   #19
         LDY   #8
         JSR   TEXTSET
         LDA   #0
         STA   TEMP1
G11      LDY   TEMP1
         LDA   NSD,Y
         JSR   TEXT
         INC   TEMP1
         LDY   TEMP1
         CPY   #21
         BNE   G11
         JSR   $9000
         JSR   HIGHLITE
         LDA   #0
         JSR   DRAW
         LDA   #1
         STA   TEMP1
G1       JSR   POCKETS
         INC   TEMP1
         LDA   TEMP1
         CMP   #7
         BNE   G1
         LDA   #0
         STA   TEMP1
         LDA   #30
         LDX   #24
         LDY   #8
         JSR   TEXTSET
         LDY   TEMP1
G2       LDA   $73A0,Y
         JSR   TEXT
         INC   TEMP1
         LDY   TEMP1
         CPY   #15
         BNE   G2
         LDA   #30
         LDX   #17
         LDY   #176
         JSR   TEXTSET
         LDA   #0
         STA   TEMP1
         TAY
G3       LDA   $7380,Y
         JSR   TEXT
         INC   TEMP1
         LDY   TEMP1
         CPY   #22
         BNE   G3
         LDA   #20
         LDX   #25
         LDY   #16
         JSR   TEXTSET
         LDA   $7308
         ORA   #$B0
         JSR   TEXT
         LDA   $7309
         ORA   #$B0
         JSR   TEXT
         LDA   $730A
         ORA   #$B0
         JSR   TEXT
         LDA   $730B
         ORA   #$B0
         JSR   TEXT
         LDA   #20
         LDX   #26
         LDY   #24
         JSR   TEXTSET
         LDA   $730C
         ORA   #$B0
         JSR   TEXT
         LDA   $730D
         ORA   #$B0
         JSR   TEXT
         LDA   #0
         STA   $7302
BIGLOOP  LDA   #$FF
         STA   T1
         LDA   #$20
         STA   T2
         LDA   #4
         STA   T3
LOOP1    LDA   $C000
         CMP   #$91
         BNE   HHGGRR
         LDA   #1
         STA   $7302
         LDA   $C000
HHGGRR   CMP   #$82
         BNE   HHGGRR2
         JMP   BYEBYE
HHGGRR2
         CMP   #$AF
         BEQ   HELP
         CMP   #$BF
         BNE   NOTHELP
HELP     STA   $C010
         STA   $C051
         STA   $C00F
HELP2    LDA   $C000
         CMP   #$8D
         BNE   HELP2
         STA   $C050
         STA   $C010
NOTHELP
         CMP   #$8A
         BNE   LOOP3
         LDA   JOYSTICK
         EOR   #1
         STA   JOYSTICK
         STA   $C010
         JMP   DOP3
LOOP3    LDA   $C000
         BMI   DO
         LDA   JOYSTICK
         BEQ   LOOP2
         LDA   #$2B
         JSR   $FCA8
         JSR   STICK
         LDA   $C061
         BPL   LOOP4
         LDA   #$C6
         JMP   DOIT2
LOOP4    LDX   #0
         LDA   KEEP0
         CMP   #30
         BGE   LOOP5
         LDX   #$CA
         JMP   LOOP6
LOOP5    CMP   #100
         BLT   LOOP6
         LDX   #$CB
LOOP6    LDA   KEEP1
         CMP   #30
         BGE   LOOP7
         LDX   #$C9
         JMP   LOOP8
LOOP7    CMP   #100
         BLT   LOOP8
         LDX   #$C8
LOOP8    TXA
         BEQ   JLOOP2
DOIT2    PHA
         LDA   WHICHTBL
         EOR   #$B0
         STA   WHICHTBL
         PLA
         JSR   $7408
         JMP   JOYIT
LOOP2    DEC   T1
         BEQ   JLOOP2
         JMP   LOOP1
JLOOP2   DEC   T2
         BEQ   UJU2
         JMP   LOOP1
UJU2     DEC   T3
         BEQ   DO
         LDA   WHICHTBL
         EOR   #$B0
         STA   WHICHTBL
         LDA   $7307
         JSR   DRAW
         LDA   #$20
         STA   T2
         JMP   LOOP1
DO       LDA   WHICHTBL
         EOR   #$B0
         STA   WHICHTBL
         JSR   $7400
DOP3     JSR   $7A00
         LDA   $7302
         BNE   BIG
         JMP   BIGLOOP
BIG      CMP   #1
         BEQ   DEAD
         CMP   #2
         BEQ   WIN
         JMP   SAVEGAME
WIN      JSR   CLEAR
         JSR   $9003
         LDA   #0
         STA   TEMP1
         LDA   #14
         LDX   #1
         LDY   #144
         JSR   TEXTSET
W2       LDY   TEMP1
         LDA   WNI,Y
         CMP   #$FF
         BEQ   W1
         JSR   TEXT
         INC   TEMP1
         JMP   W2
W1       JMP   QAGAIN
DEAD     JSR   CLEAR
         JSR   $9003
         LDA   #0
         STA   TEMP1
         LDA   #14
         LDX   #1
         LDY   #144
         JSR   TEXTSET
D2       LDY   TEMP1
         LDA   DED,Y
         CMP   #$FF
         BEQ   D1
         JSR   TEXT
         INC   TEMP1
         JMP   D2
D1       JMP   QAGAIN
WNI      ASC   'You have won. Just wait till'
         ASC   'the next time.'
         ASC   'Press RETURN.'
         DFB   255
DED      ASC   'I am sorry to inform you '
         ASC   'butyou are now   dead...       '
         ASC   'Press RETURN.'
         DFB   255
JOYIT    JSR   $7A00
         LDA   #$A8
         JSR   $FCA8
         JMP   DOP3+3
SAVEGAME JSR   $9003
         LDA   #'A'
         JSR   PROMPT
         LDA   #>BLOCKS
         LDY   #<BLOCKS
         JSR   OFILE
         BCS   SAVEGAME
         JSR   CFILE
         LDA   #>SAVED
         LDY   #<SAVED
         JSR   CREATE
         LDA   #>SAVED
         LDY   #<SAVED
         JSR   OFILE
         LDY   #0
JKJ      LDA   $7300,Y
         STA   $8E00,Y
         DEY
         BNE   JKJ
         LDA   #0
         STA   DLEN
         STA   DBUFF
         LDA   #2
         STA   DLEN+1
         LDA   #$8E
         STA   DBUFF+1
         JSR   WFILE
         JSR   CFILE
         JMP   LETSGO
T1       DFB   0
T2       DFB   0
T3       DFB   0
NEWCOMER JSR   CLEAR2
         LDA   #>DATA
         LDY   #<DATA
         JSR   OFILE
         LDA   #$10
         STA   DLEN+1
         LDA   #$00
         STA   DBUFF
         LDA   #$00
         STA   DLEN
         LDA   #$60
         STA   DBUFF+1
         JSR   RFILE
         JSR   CFILE
         LDA   #$60
         STA   FPTR+2
         STA   $7001
         LDA   #$00
         STA   FPTR+1
         STA   $7000
         LDX   #0         ;PAGES....
NEWPAGE  LDA   #0
         STA   NUM_LINES
NEWLINE  LDY   #0
NEWCHAR  INC   FPTR+1
         BNE   FPTR
         INC   FPTR+2
         LDA   FPTR+2
         CMP   #$70
         BEQ   QUITPAGES
FPTR     LDA   $FFFF
         AND   #$7F
         CMP   #$7E
         BEQ   QUITPAGES
         CMP   #$0D
         BNE   NEXT_CHAR
         LDY   #0
         LDA   #1
         STA   INCMOD+1
NEXTLINE INC   NUM_LINES
         LDA   NUM_LINES
         CMP   #20
         BNE   NEWCHAR
         CLC
         LDA   FPTR+1
INCMOD   ADC   #1
         STA   $7002,X
         LDA   FPTR+2
         ADC   #0
         STA   $7003,X
         INX
         INX
         JMP   NEWPAGE
NEXT_CHAR INY
         CPY   #40
         BNE   NEWCHAR
         LDY   #0
         LDA   #0
         STA   INCMOD+1
         JMP   NEXTLINE
NUM_LINES DFB  0
THISPAGE DFB   0
QUITPAGES STX  NUM_LINES
         LDA   #0
         STA   THISPAGE
NTOP     LDA   #0
         STA   TEMP5
         LDA   #40
         LDX   #0
         LDY   #0
         JSR   TEXTSET
         JSR   CLEAR2
         LDX   THISPAGE
         LDA   $7000,X
         STA   F2+1
         LDA   $7001,X
         STA   F2+2
N0       LDA   #0
         STA   TEMP6
N1       LDY   TEMP6
F2       LDA   $FFFF
         PHA
         INC   F2+1
         BNE   F3
         INC   F2+2
         LDA   F2+2
         CMP   #$70
         BEQ   APAGE
F3       PLA
         ORA   #$80
         CMP   #$FE
         BEQ   APAGE
         CMP   #$8D
         BNE   NOTRET
F4       LDA   #$A0
         JSR   TEXT
         INC   TEMP6
         LDA   TEMP6
         CMP   #39
         BNE   F4
         LDA   #$A0
NOTRET   JSR   TEXT
         INC   TEMP6
         LDA   TEMP6
         CMP   #40
         BNE   N1
         INC   TEMP5
         LDA   TEMP5
         CMP   #20
         BNE   N0
APAGE    JSR   DRAWBL
         STA   $C010
N2       LDA   $C000
         BPL   N2
         STA   $C010
         CMP   #$8D
         BEQ   OUT
         LDX   THISPAGE
         CPX   #0
         BEQ   NOBACK
         CMP   #$88
         BEQ   NB1
         CMP   #139
         BNE   NOBACK
NB1      DEC   THISPAGE
         DEC   THISPAGE
         JMP   NTOP
NOBACK   LDX   THISPAGE
         CPX   NUM_LINES
         BEQ   N2
         CMP   #$95
         BEQ   NB2
         CMP   #138
         BNE   N2
NB2      INC   THISPAGE
         INC   THISPAGE
         JMP   NTOP
OUT      STA   $C010
INPUT    JSR   CLEAR2
         LDA   #40
         LDY   #44
         LDX   #0
         JSR   TEXTSET
         LDA   #0
         STA   TEMP1
JJK      LDY   TEMP1
         LDA   LINEE,Y
         CMP   #$FF
         BEQ   JJKK
         JSR   TEXT
         INC   TEMP1
         JMP   JJK
LINEE    ASC   'Your objective square is:'
         HEX   FF
JJKK     LDA   #5
         LDY   #2
         LDX   #13
         JSR   $800
         LDA   #40
         LDY   #100
         LDX   #0
         JSR   TEXTSET
         LDA   #0
         STA   TEMP1
N5       LDY   TEMP1
         LDA   LINE,Y
         CMP   #$FF
         BEQ   N6
         JSR   TEXT
         INC   TEMP1
         JMP   N5
LINE     ASC   'Enter your name:_______________'
         DFB   255
N6       LDA   #16
         LDX   #16
         LDY   #100
         JSR   TEXTSET
         LDA   #0
         STA   TEMP1
         STA   $C010
N7       LDA   $C000
         BPL   N7
         STA   $C010
         CMP   #$88
         BEQ   BKSPACE
         CMP   #$FF
         BEQ   BKSPACE
         CMP   #$9B
         BNE   LJK
         JMP   INPUT
LJK      CMP   #$8D
         BEQ   N9
         CMP   #$A0
         BLT   N7
         LDY   TEMP1
         CPY   #15
         BEQ   N7
         STA   $73A0,Y
         JSR   TEXT
         INC   TEMP1
         JMP   N7
BKSPACE  LDA   TEMP1
         CMP   #1
         BLT   N7
         LDA   TEMP1
         CLC
         ADC   #15
         LDY   #100
         TAX
         LDA   #16
         JSR   TEXTSET
         LDA   #$DF
         JSR   TEXT
         LDA   TEMP1
         CLC
         ADC   #15
         TAX
         LDY   #100
         LDA   #16
         JSR   TEXTSET
         DEC   TEMP1
         JMP   N7
N9       LDA   #$A0
         LDY   TEMP1
         CPY   #15
         BEQ   N99
N8       STA   $73A0,Y
         INY
         CPY   #15
         BNE   N8
N99      JMP   GAME
STICK    LDX   #0
         STX   KEEP0
         STX   KEEP1
         LDA   $C070
STK1     LDA   $C064
         BPL   WAIT0
         STX   KEEP0
PDL1     LDA   $C065
         BPL   WAIT1
         STX   KEEP1
CYCLE    INX
         BNE   STK1
         RTS
WAIT0    BPL   PDL1
WAIT1    BPL   CYCLE
KEEP0    DFB   0
KEEP1    DFB   0
JOYSTICK DFB   0
DRAWBL   LDA   #40
         LDX   #0
         LDY   #22*8
         JSR   TEXTSET
         LDA   #0
         STA   TEMP6
DBL1     LDY   TEMP6
         LDA   DBLTEXT,Y
         CMP   #$FF
         BEQ   DBL2
         JSR   TEXT
         INC   TEMP6
         JMP   DBL1
DBL2     RTS
DBLTEXT  ASC   'Use ARROWS to scroll or RETURN to play'
         DFB   255
QAGAIN   STA   $C010
W3       LDA   $C000
         CMP   #$8D
         BNE   W3
         STA   $C010
         LDA   #0
         STA   TEMP1
WW1      JSR   CLEAR
         LDA   #14
         LDX   #1
         LDY   #144
         JSR   TEXTSET
         LDA   TEMP1
         STA   TEMP2
WW2      LDY   TEMP2
         LDA   AGAINYN,Y
         CMP   #$FF
         BEQ   WW3
         JSR   TEXT
         INC   TEMP2
         JMP   WW2
WW3      STA   $C010
WW4      LDA   $C000
         BPL   WW4
         STA   $C010
         CMP   #$8D
         BEQ   SELECTYN
         CMP   #$88
         BEQ   TOGGLEYN
         CMP   #$95
         BEQ   TOGGLEYN
         CMP   #$A0
         BEQ   TOGGLEYN
         CMP   #$F9
         BEQ   DOYES
         CMP   #$D9
         BNE   WW5
DOYES    LDA   #0
         STA   TEMP1
         JMP   SELECTYN
WW5      CMP   #$EE
         BEQ   DONO
         CMP   #$CE
         BNE   WW3
DONO     LDA   #29
         STA   TEMP1
SELECTYN LDA   TEMP1
         BEQ   PLAYAGAIN
         JMP   LETSGO
PLAYAGAIN JMP  LETUSGO+3
TOGGLEYN LDA   TEMP1
         BEQ   TYN2
         LDA   #0
         STA   TEMP1
         JMP   WW1
TYN2     LDA   #29
         STA   TEMP1
         JMP   WW1
AGAINYN  ASC   'Replay same   '
         ASC   'scenario ? YES'
         DFB   255
         ASC   'Replay same   '
         ASC   'scenario ? NO '
         DFB   255
