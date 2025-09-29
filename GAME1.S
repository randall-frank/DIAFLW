         ORG   $7400
         DSK   bin/GAME1.BIN
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
MSG      =     CLEAR+3
CLEAR2   =     MSGS+3
BOTTOMLINE =   CLEAR2+3
HIT      =     $9009
SCORE    =     $9006

TEMP0    =     0
TEMP1    =     1
TEMP2    =     2
TEMP3    =     3
TEMP4    =     4
TEMP5    =     5
TEMP6    =     6
TEMP7    =     7
TEMP8    =     8
SOUND    =     $8980

         LST   OFF
         LDA   $C000
         BMI   L1
         JMP   MOVE
L1       LDY   #0
         STY   MESSAGE
         CMP   #$E0
         BLT   ITSOK
         EOR   #$20

* Change selection
ITSOK
         CMP   #$B1  ; '1'
         BLT   L5TO8
         CMP   #$B5  ; '5'
         BGE   L5TO8
         AND   #$0F
         JSR   BUMP
         LDA   #$D2
         JMP   L7
L5TO8    CMP   #$B5  ; '5'
         BLT   L2
         CMP   #$B9  ; '9'
         BGE   L2
         SEC
         SBC   #$B4
         AND   #$0F
         JSR   BUMP
         LDA   #$CC
         JMP   L4
BUMP     CMP   #5
         BNE   BZZ
         LDA   #1
BZZ      CMP   #0
         BNE   BZZ1
         LDA   #4
BZZ1
         STA   $7304 ; Selected pocket
         JSR   HIGHLITE
         RTS
L2       CMP   #$8D  ; 'CR'
         BNE   LZZ4
         LDA   $7303
         EOR   #$01
         JMP   LZZ3
LZZ4     CMP   #$B9  ; '9'
         BNE   LZ3
         LDA   #0
         BEQ   LZZ3
LZ3      CMP   #$B0  ; '0'
         BNE   LZQ3
         LDA   #1
LZZ3
         STA   $7303 ; selected hand?
         JSR   HIGHLITE
         JMP   MOVE
LZQ3     CMP   #$88  ; 'TAB'
         BNE   LZQ4
         INC   $7304
         LDA   $7304
         JSR   BUMP
         JMP   MOVE
LZQ4     CMP   #$95  ;  '?'
         BNE   L3
         DEC   $7304
         LDA   $7304
         JSR   BUMP
         JMP   MOVE
L3       CMP   #$9B  ; '?'
         BNE   L4
         LDA   #5
         JSR   MSG
         STA   $C010
L31      LDA   $C000
         CMP   #$8D
         BNE   L31
         STA   $C010
         LDA   #0
         JSR   MSG
         JMP   MOVE
L4       CMP   #$CC  ; 'L'
         BNE   L5
         JSR   HPOC
         LDY   #1
         LDA   (TEMP2),Y
         CMP   #$FF
         BNE   L42
         LDY   #3
L41      LDA   (TEMP0),Y
         STA   (TEMP2),Y
         DEY
         CPY   #0
         BNE   L41
         LDA   #$FF
         LDY   #1
         STA   (TEMP0),Y
         JSR   APOC
L42      JMP   MOVE

* Set up TEMP0,TEMP1 for pocket,  TEMP2,TEMP3 for hand
HPOC     LDA   #$73
         STA   TEMP1
         STA   TEMP3
         LDY   $7304  ; Selected pocket
         DEY
         TYA
         ASL
         ASL
         CLC
         ADC   #$10
         STA   TEMP0
         LDA   $7303  ; Selected hand
         CLC
         ADC   #4
         ASL
         ASL
         CLC
         ADC   #$10
         STA   TEMP2
         RTS

* Pocket/hand exchange
L5       CMP   #$C1  ; 'A'
         BNE   L6
         JSR   HPOC
         LDY   #1
L52      LDA   (TEMP0),Y
         CMP   #$FF
         BNE   EMPTYPOCKET
         LDY   #1
L51      LDA   (TEMP2),Y
         STA   (TEMP0),Y
         LDA   #$FF
         STA   (TEMP2),Y
         INY
         CPY   #3
         BNE   L51
         JSR   APOC
L53      JMP   MOVE
L6       CMP   #$C4  ; 'D'
         BNE   L7
         JSR   HPOC
         LDA   #$FF
         LDY   #3
L61      STA   (TEMP2),Y
         DEY
         BPL   L61
         JSR   APOC
         JMP   MOVE
APOC     LDA   $7304
         JSR   POCKETS
         LDA   $7303
         CLC
         ADC   #5
         JMP   POCKETS
L7       CMP   #$D2  ; 'R'
         BNE   L8
         JSR   HPOC
         LDY   #0
         LDA   (TEMP2),Y
         CMP   #$FF
         BNE   L73
         LDY   #0
L71      LDA   (TEMP0),Y
         STA   (TEMP2),Y
         LDA   #$FF
         STA   (TEMP0),Y
         JSR   APOC
L73      JMP   MOVE
EMPTYPOCKET LDA #6
         STA   MESSAGE
         JMP   MOVE
L8       CMP   #$D7  ; 'W'
         BNE   L9
         JSR   HPOC
         LDY   #0
         LDA   (TEMP0),Y
         CMP   #$FF
         BNE   EMPTYPOCKET
         LDA   (TEMP2),Y
         STA   (TEMP0),Y
         LDA   #$FF
         STA   (TEMP2),Y
         JSR   APOC
         JMP   MOVE

* Rotation
L9       CMP   #$CB  ; 'K'
         BNE   L10
         INC   $7307
         LDA   $7307
         AND   #3
         STA   $7307
         JSR   DRAW
         JMP   MOVE
L10      CMP   #$CA  ; 'J'
         BNE   L11
         DEC   $7307
         BPL   L101
         LDA   #3
         STA   $7307
L101     LDA   $7307
         JSR   DRAW
         JMP   MOVE

* Move forward
L11      CMP   #$C9  ; 'I'
         BEQ   L11L
         JMP   L12
L11L     DEC   MCOUNT  ; Move handler
         LDA   $7307
         ASL
         TAY
         LDA   DX,Y
         CLC
         ADC   $7300
         STA   TEMP71
         LDA   DX+1,Y
         CLC
         ADC   $7301
         STA   TEMP81
         CMP   #64
         BGE   NPLANE
         TAY
         LDX   TEMP71
         CPX   #64
         BGE   NPLANE
         JSR   LOOKUP
         BCS   L111
         CMP   #64
         BLT   L112
         CMP   #106
         BGE   L111
         BLT   NOGO
L112     CMP   #6
         BEQ   NOGO
         CMP   #14
         BEQ   UP
         CMP   #15
         BEQ   DOWN
         CMP   #5
         BNE   L111
         LDA   #2
         STA   $7302
L111     LDA   TEMP71
         STA   $7300
         LDA   TEMP81
         STA   $7301
         LDA   $7307
         JSR   DRAW
         LDA   #0
         JSR   SOUND
NOGO     JMP   MOVE
DX       DFB   0,255,1,0,0,1,255,0
NPLANE   LDA   $7305
         ASL
         ASL
         CLC
         ADC   $7307
         TAY
         LDA   NEXTBLOCK,Y
         CMP   #$FF
         BEQ   NOGO
         PHA
         JSR   $9003      ;WRITE & CLOSE OLD FILE
         PLA
         STA   $7305
         JSR   $9000      ;READ FILE
         LDA   TEMP71
         LDY   #63
         CMP   #$FF
         BEQ   NP1
         LDY   #0
         CMP   #64
         BEQ   NP1
         TAY
NP1      STY   $7300
         LDA   TEMP81
         LDY   #63
         CMP   #$FF
         BEQ   NP2
         LDY   #0
         CMP   #64
         BEQ   NP2
         TAY
NP2      STY   $7301
         LDA   $7307
         JSR   DRAW
         JMP   MOVE
UP       JSR   $9003
         INC   $7306
         JMP   DOWN1
DOWN     JSR   $9003
         DEC   $7306
DOWN1    LDA   TEMP71
         STA   $7300
         LDA   TEMP81
         STA   $7301
         JSR   $9000
         LDA   $7307
         JSR   DRAW
         LDA   #0
         JSR   SOUND
         JMP   MOVE
TEMP71   DFB   0
TEMP81   DFB   0
NEXTBLOCK HEX  FF0104FFFF020500
         HEX   FF030601FFFF0702
         HEX   000508FF01060904
         HEX   02070A0503FF0B06
         HEX   04090CFF050A0D08
         HEX   060B0E0907FF0F0A
         HEX   080DFFFF090EFF0C
         HEX   0A0FFF0D0BFFFF0E
L12      CMP   #$D3  ;  'S'  
         BNE   L13
         LDX   $7300
         LDY   $7301
         JSR   LOOKUP
         BCC   L121
         TXA
         ASL
         ASL
         ASL
         STA   TEMP7
         LDA   #$70
         STA   TEMP8
         JSR   HPOC
         LDY   #0
         LDA   (TEMP7),Y
         BNE   L121
         INC   TEMP7
L122     LDA   (TEMP2),Y
         CMP   #$FF
         BNE   EMPTYHAND
         INY
         CPY   #2
         BNE   L122
         LDY   #0
L123     LDA   (TEMP7),Y
         STA   (TEMP2),Y
         LDA   #$FF
         STA   (TEMP7),Y
         INY
         CPY   #3
         BNE   L123
         JSR   APOC
L121     JMP   MOVE
EMPTYHAND LDA  #4
         STA   MESSAGE
         JMP   MOVE
L13      CMP   #$C8 ; 'H'
         BNE   L14
         JMP   MOVE
L139     LDA   #1
         CLC
         ADC   $730D
         STA   $730D
         CMP   #$0A
         BLT   L131
         SEC
         SBC   #$0A
         STA   $730D
         INC   $730C
         LDA   $730C
         CMP   #$0A
         BLT   L131
         LDA   #9
         STA   $730D
         STA   $730C
L131     LDX   #26
         LDY   #24
         LDA   #5
         JSR   TEXTSET
         LDA   $730C
         ORA   #$B0
         JSR   TEXT
         LDA   $730D
         ORA   #$B0
         JMP   TEXT
L14      CMP   #$C6  ;  'F'
         BEQ   L141
         JMP   L15

* Fire weapon
L141     DEC   MCOUNT
         JSR   HPOC
         LDY   #0
         LDA   (TEMP2),Y
         STA   COUNT
         CMP   #$FF
         BNE   L142
         LDA   #2         ;NOWEAPON
GOODBYE  STA   MESSAGE
         JMP   MOVE
NOAMMO   LDA   #1
         BNE   GOODBYE
BADAMMO  LDA   #3
         BNE   GOODBYE
L142     INY
         LDA   (TEMP2),Y
         CMP   #$FF
         BEQ   NOAMMO
         CMP   COUNT
         BNE   BADAMMO
         INY
         LDA   (TEMP2),Y
         TAX
         DEX
         BNE   L143
         LDX   #$FF
         DEY
L143     TXA
         STA   (TEMP2),Y
         JSR   APOC
         LDA   #3
         STA   X1POS
         STA   Y1POS
         STA   COUNT
         LDA   $7300
         STA   XPOS
         LDA   $7301
         STA   YPOS
         LDA   $7307
         ASL
         TAY
         LDA   DX,Y
         STA   DELTAX
         LDA   DX+1,Y
         STA   DELTAY
         JMP   START
L144     LDX   X1POS
         LDY   Y1POS
         LDA   #7
         JSR   BIGSHAPE
         LDA   #4
         JSR   SOUND
         LDY   #40
LDELAY   LDA   #200
         SEC
         SBC   #1
         BNE   LDELAY+2
         DEY
         BNE   LDELAY
         LDX   XPOS
         LDY   YPOS
         JSR   LOOKUP
         BCC   L145
         JMP   COLLIDE
L145     CMP   #64
         BLT   L146
         CMP   #106
         BGE   L146
         JMP   COLLIDE
L146     CMP   #6
         BEQ   L146-3
         LDX   X1POS
         LDY   Y1POS
         JSR   BIGSHAPE
START    LDA   XPOS
         CLC
         ADC   DELTAX
         CMP   #64
         BGE   FDONE
         STA   XPOS
         LDA   YPOS
         CLC
         ADC   DELTAY
         CMP   #64
         BGE   FDONE
         STA   YPOS
         LDA   X1POS
         CLC
         ADC   DELTAX
         STA   X1POS
         LDA   Y1POS
         CLC
         ADC   DELTAY
         STA   Y1POS
         DEC   COUNT
         BPL   L144
FDONE    JMP   MOVE
DELTAX   DFB   0
DELTAY   DFB   0
COUNT    DFB   0
XPOS     DFB   0
YPOS     DFB   0
X1POS    DFB   0
Y1POS    DFB   0
POWER    DFB   0
EXPLOST  DFB   0

* keypress handling continued...
L15      CMP   #$93  ; '^S'
         BNE   L16
         LDA   #3
         STA   $7302
         JMP   MOVE
L16      CMP   #$96  ; '^V'
         BNE   L17
         LDA   #$FF  ; Audio toggle
         BNE   DOSND
L17      CMP   #$8A  ; '^J'
         BEQ   L171
         CMP   #$AF  ; '/'
         BEQ   L171
         CMP   #$BF  ; '?'
         BEQ   L171
         CMP   #$82  ; '^B'
         BEQ   L171
         CMP   #$91  ; '^Q'
         BEQ   L171

* unknown keypress
         LDA   #3
DOSND    JSR   SOUND
         STA   $C010

* More keypress handling...
L171     JMP   MOVE+3

COLLIDE  JSR   HPOC
         LDY   #0
         LDA   (TEMP2),Y
         ASL
         ASL
         ASL
         ASL
         ASL
         STA   TEMP2
         LDA   #$72
         STA   TEMP3
         LDY   #19
         LDA   (TEMP2),Y
         STA   POWER
         INY
         LDA   (TEMP2),Y
         STA   EXPLOST
         JSR   DOIT
         LDA   EXPLOST
         BEQ   DONEE
         INC   XPOS
         INC   X1POS
         LDA   XPOS
         CMP   #64
         BGE   COL1
         LDA   X1POS
         CMP   #7
         BGE   COL1
         JSR   DOIT
COL1     DEC   XPOS
         DEC   XPOS
         DEC   X1POS
         DEC   X1POS
         LDA   XPOS
         CMP   #64
         BGE   COL2
         LDA   X1POS
         CMP   #7
         BGE   COL2
         JSR   DOIT
COL2     INC   XPOS
         INC   X1POS
         INC   YPOS
         INC   Y1POS
         LDA   YPOS
         CMP   #64
         BGE   COL3
         LDA   Y1POS
         CMP   #7
         BGE   COL3
         JSR   DOIT
COL3     DEC   YPOS
         DEC   YPOS
         DEC   Y1POS
         DEC   Y1POS
         LDA   YPOS
         CMP   #64
         LDA   Y1POS
         CMP   #7
         BGE   DONEF
         BGE   DONEF
         JSR   DOIT
DONEF    LDA   #2
         JSR   SOUND
         JMP   DDD1
DONEE    LDA   #1
         JSR   SOUND
DDD1     LDY   #40
DD1      LDA   #200
         SEC
         SBC   #1
         BNE   DD1+2
         DEY
         BNE   DD1
         LDA   $7307
         JSR   DRAW
         JMP   MOVE
EXPTBL   DFB   8,9,10,11,12,13,8,11
DOIT     JSR   RND
         AND   #$7
         TAY
         LDA   EXPTBL,Y
         LDX   X1POS
         LDY   Y1POS
         JSR   BIGSHAPE
         JSR   RND
         CMP   POWER
         BGE   NODAM
         LDX   XPOS
         LDY   YPOS
         JSR   LOOKUP
         BCC   GROUND
         TXA
         ASL
         ASL
         ASL
         STA   $26
         LDA   #$70
         STA   $27
         LDY   #0
         LDA   ($26),Y
         BNE   MAN1
         LDA   #$80
         LDY   #4
         STA   ($26),Y
         INY
         STA   ($26),Y
         JSR   SCORE
         JSR   SCORE
         JMP   NODAM
MAN1     CMP   #$80
         BLT   MAN2
         RTS
MAN2     LDA   #0
         TAY
         STA   ($26),Y
         LDY   #6
         LDA   ($26),Y
         STA   COUNT
         INY
         LDA   #16
         STA   ($26),Y
MAN3     JSR   SCORE
         DEC   COUNT
         BNE   MAN3
NODAM    RTS
GROUND   CMP   #64
         BLT   NODAM
         CMP   #106
         BGE   NODAM
         JSR   RND
         AND   #3
         CLC
         ADC   #106
         LDX   XPOS
         LDY   YPOS
         JSR   SET
         RTS
MOVE     STA   $C010
         LDA   MCOUNT
         BPL   V1
         JSR   L139
         LDA   $730C
         LSR
         TAY
         LDA   CCCC,Y
         STA   MCOUNT
V1       LDA   MESSAGE
         CMP   OLDMSG
         BNE   VV2
         RTS
VV2      STA   OLDMSG
         JMP   MSG
MCOUNT   DFB   255
MLEFT    DFB   0
CCCC     DFB   4,7,9,12,15
MESSAGE  DFB   0
OLDMSG   DFB   0
