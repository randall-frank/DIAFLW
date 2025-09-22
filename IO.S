         ORG   $9000
CLEAR    =     $81E
TEXT     =     $80F
TEXTSET  =     TEXT+3
RNDIZE   =     $809
RND      =     RNDIZE+3
LOOKUP   =     $803
CLEAR2   =     $F3E2
         JMP   OPEN
         JMP   CLOSE
         JMP   SCORE
         JMP   HIT
         JMP   GETPREFIX  ; RETURN NUMBER IN ACC AND LIST @6000
         LST   OFF
FILENAME HEX   08D3D1D5C1D2C50000  ; 'SQUAREXY'
OFILE    JSR   $BF00
         HEX   C8
         DA    OPDOS
         RTS
OPDOS    HEX   03
         DA    FILENAME
         DA    $B000
         HEX   01
RFILE    JSR   $BF00
         HEX   CA
         DA    RPDOS
         RTS
RPDOS    HEX   0401
DBUFF    DA    $0000
DLEN     DA    $0000
         HEX   0000
WFILE    JSR   $BF00
         HEX   CB
         DA    RPDOS
         RTS
PFILE    JSR   $BF00
         HEX   CE
         DA    PPDOS
         RTS
PPDOS    HEX   0201
DPOS     HEX   000000
CFILE    JSR   $BF00
         HEX   CC
         DA    CPDOS
         RTS
CPDOS    HEX   0101
OPEN     LDX   #1
         LDA   $7305
         ORA   #$B0
         CMP   #$BA
         BLT   JUJ1
         CLC
         ADC   #$07
JUJ1
         STA   FILENAME+7
         LDA   $7306
         ORA   #$B0
         CMP   #$BA
         BLT   JUJ2
         CLC
         ADC   #$07
JUJ2
         STA   FILENAME+8
         JSR   OFILE
         BCC   OK
         LDA   $7306
         CLC
         ADC   #$C1
         STA   MESS+24
IN       JSR   CLEAR
         LDY   #144
         LDX   #1
         LDA   #14
         JSR   TEXTSET
         LDA   #0
         STA   8
T1       LDY   8
         LDA   MESS,Y
         CMP   #$FF
         BEQ   DONE
         JSR   TEXT
         INC   8
         JMP   T1
DONE     STA   $C010
         LDA   $C000
         BPL   DONE+3
         STA   $C010
         JSR   CLEAR
         JMP   OPEN
MESS     ASC   'PLACE SCENARIODISK SIDE A INA DRIVE.'
         DFB   255
OK       JSR   RNDIZE
         JSR   TESTOLD
         LDA   #0
         STA   DLEN
         STA   DBUFF
         LDA   #$60
         STA   DBUFF+1
         LDA   #$11
         STA   DLEN+1
         JSR   RFILE
         LDX   #0
         STX   5
TOPPER   TXA
         ASL
         ASL
         ASL
         STA   6
         TAY
         LDA   $7000,Y
         CMP   #$FF
         BNE   TOP1
         LDA   #6
         STA   $7000,Y
NEXT     JSR   RND
         AND   #$3F
         STA   7
         JSR   RND
         AND   #$3F
         STA   8
         TAY
         LDA   7
         TAX
         JSR   LOOKUP
         BCS   NEXT
         CMP   #106
         BGE   YEA
         CMP   #4
         BEQ   YEA
         BNE   NEXT
YEA      LDY   6
         LDA   7
         STA   $7004,Y
         LDA   8
         STA   $7005,Y
TOP1     INC   5
         LDX   5
         CPX   #32
         BNE   TOPPER
         JSR   RNDIZE
         RTS
CLOSE    LDA   #$0
         STA   DPOS
         LDA   #$11
         STA   DPOS+1
         JSR   PFILE
         LDA   #0
         STA   DLEN
         STA   DBUFF
         LDA   #$11
         STA   DLEN+1
         LDA   #$60
         STA   DBUFF+1
         JSR   WFILE
         JSR   CFILE
         RTS
SCORE    LDA   $730B
         CLC
         ADC   #1
         STA   $730B
         LDY   #3
AGAIN    LDA   $7308,Y
         CMP   #$0A
         BNE   SCOK
         LDA   #0
         STA   $7308,Y
         DEY
         LDA   $7308,Y
         CLC
         ADC   #1
         STA   $7308,Y
         CPY   #0
         BNE   AGAIN
SCOK     LDX   #25
         LDY   #16
         LDA   #5
         JSR   TEXTSET
         LDA   #0
         STA   9
         LDY   9
SC2      LDA   $7308,Y
         ORA   #$B0
         JSR   TEXT
         INC   9
         LDY   9
         CPY   #4
         BNE   SC2
         RTS
HIT      LDA   $730D
         SEC
         SBC   #1
         STA   $730D
         CMP   #$FF
         BNE   HOK
         LDA   #9
         STA   $730D
         LDA   $730C
         SEC
         SBC   #1
         STA   $730C
         CMP   #$FF
         BNE   HOK
         LDA   #0
         STA   $730C
         STA   $730D
         LDA   #1
         STA   $7302
HOK      LDX   #26
         LDY   #24
         LDA   #3
         JSR   TEXTSET
         LDA   $730C
         ORA   #$B0
         JSR   TEXT
         LDA   $730D
         ORA   #$B0
         JMP   TEXT
TESTOLD  LDY   $8FFF
         BEQ   NEWREAD
TO1      LDA   $8EFE,Y
         CMP   $7305
         BNE   NOTIT
         LDA   $8EFF,Y
         CMP   $7306
         BNE   NOTIT
         LDA   #$11
         STA   DPOS+1
         LDA   #0
         STA   DPOS
         JSR   PFILE
         RTS
NOTIT    DEY
         DEY
         BNE   TO1
NEWREAD  LDA   #0
         STA   DPOS
         STA   DPOS+1
         JSR   PFILE
         LDY   $8FFF
         LDA   $7305
         STA   $8F00,Y
         LDA   $7306
         STA   $8F01,Y
         INY
         INY
         STY   $8FFF
         RTS
SETPREFIX JSR  $BF00
         HEX   C6
         DA    PPARAMS
         RTS
PPARAMS  HEX   01
         DA    PREFIX
PREFIX   HEX   05
         ASC   '/RAM5'
         DS    60
BYEBYE   JSR   $BF00
         HEX   65
         DA    QUIT
         RTS
QUIT     HEX   04000000000000
READN    STA   DLEN
         LDA   #0
         STA   DLEN+1
         STA   DBUFF
         LDA   #$70
         STA   DBUFF+1
         JMP   RFILE
ONLINE   JSR   $BF00
         HEX   C5
         DA    ONPARA
         RTS
ONPARA   HEX   02000060
OPENPRE  JSR   $BF00
         HEX   C8
         DA    OPPRE
         RTS
OPPRE    HEX   03
         DA    PREFIX
         DA    $1000
         HEX   01
GETPREFIX JSR  $BF00
         DFB   $C7
         DA    PPARAMS
         JSR   BACKUP
         LDA   FIRST_TIME
         BNE   GPTOP1
         INC   FIRST_TIME
         JMP   GPTOP
GPTOP1   JSR   BACKUP
GPTOP    JSR   CLEAR2
         STA   $C052
         JSR   BOTTOMLINE
         LDY   #0
         LDX   #0
         LDA   #40
         JSR   TEXTSET
         LDA   PREFIX
         BEQ   GP2
         LDA   #1
         STA   STOR1
GP1      LDY   STOR1
         LDA   PREFIX,Y
         JSR   TEXT
         INC   STOR1
         LDA   STOR1
         CMP   PREFIX
         BEQ   GP1
         BLT   GP1
GP2      LDA   #$FF
         STA   AUTO
         JSR   GETNAMES
         LDA   AUTO
         CMP   #$FF
         BEQ   GP12
         ORA   #$B0
         JMP   GP33
GP12
         STA   $C010
GP3      LDA   $C000
         CMP   #$8D
         BNE   GP33
         STA   $C010
         JMP   SETPREFIX
GP33
         CMP   #$9B
         BNE   GP44
         JSR   BACKUP
         JMP   GPTOP
GP44
         CMP   #$82
         BNE   GP4
         JMP   BYEBYE
GP4      LDY   NAMES
         CPY   #$FF
         BEQ   GP3
         CMP   #$BA
         BGE   GP3
         CMP   #$B0
         BLT   GP3
         AND   #$0F
         CMP   NAMES
         BEQ   GP5
         BGE   GP3
GP5      ASL
         ASL
         ASL
         ASL
         TAX
         LDY   PREFIX
         INY
         LDA   #$2F
         STA   PREFIX,Y
         LDA   $6000,X
         STA   STOR1
         INX
         INY
GP6      LDA   $6000,X
         STA   PREFIX,Y
         INX
         INY
         DEC   STOR1
         BNE   GP6
         DEY
         STY   PREFIX
         LDA   PREFIX,Y
         CMP   #$2E
         BNE   GPTOPJMP
         JMP   SETPREFIX
GPTOPJMP JMP   GPTOP
STOR1    DFB   0
NAMES    DFB   0
GETNAMES
         LDA   PREFIX
         BNE   DOCATALOG
         LDA   #0
         STA   COUNT
         JSR   ONLINE
ONL1     LDY   COUNT
         LDA   $6000,Y
         BEQ   ONL4
         AND   #$0F
         BNE   ONL2
ONL3     LDA   $6010,Y
         STA   $6000,Y
         INY
         BNE   ONL3
         BEQ   ONL1
ONL2     STA   $6000,Y
         LDA   COUNT
         CLC
         ADC   #$10
         STA   COUNT
         JMP   ONL1
ONL4     LDA   COUNT
         SEC
         SBC   #$10
         LSR
         LSR
         LSR
         LSR
         STA   NAMES
         JMP   DRAWNAMES
DOCATALOG JSR  OPENPRE
         LDA   #0
         STA   COUNT
         LDA   #4
         JSR   READN
DC1      LDA   #$D
         STA   STOR1
DC2      LDA   #$27
         JSR   READN
         BCS   DOCATOUT
         LDA   $7000
         AND   #$F0
         CMP   #$D0
         BNE   DCNOT
         LDA   $7000
         AND   #$0F
         STA   $7000
         LDX   #0
         LDY   COUNT
DC3      LDA   $7000,X
         STA   $6000,Y
         INY
         INX
         CPX   #$10
         BNE   DC3
         STY   COUNT
DCNOT    DEC   STOR1
         BNE   DC2
         LDA   #$5
         JSR   READN
         BCS   DOCATOUT
         JMP   DC1
DOCATOUT JSR   CFILE
         LDA   COUNT
         BEQ   NODIRS
         SEC
         SBC   #$10
         LSR
         LSR
         LSR
         LSR
         STA   NAMES
         JMP   DRAWNAMES
NODIRS   LDA   #$FF
         STA   NAMES
         RTS
BACKUP   LDY   PREFIX
         BNE   BUP1
         RTS
BUP1     LDA   PREFIX,Y
         CMP   #$2F
         BEQ   BUP2
         DEY
         BNE   BUP1
         STY   PREFIX
         RTS
BUP2     DEY
         STY   PREFIX
         RTS
DRAWNAMES LDA  NAMES
         CMP   #$0A
         BLT   DN1
         LDA   #$9
         STA   NAMES
DN1
         LDA   #0
         STA   STOR1
         LDA   #$FF
         STA   AUTO
DNLOOP   LDY   STOR1
         INY
         INY
         INY
         TYA
         ASL
         ASL
         ASL
         TAY
         LDX   #0
         LDA   #40
         JSR   TEXTSET
         LDA   #0
         STA   DIRFLG
         LDA   STOR1
         ORA   #$B0
         JSR   TEXT
         LDA   #$A9
         JSR   TEXT
         LDA   #$A0
         JSR   TEXT
         LDA   STOR1
         ASL
         ASL
         ASL
         ASL
         TAY
         LDA   $6000,Y
         TAX
         INY
         STX   PPP
         STY   PPPP
         LDA   PPP
         CLC
         ADC   PPPP
         TAY
         LDA   $5FFF,Y
         CMP   #$2E
         BNE   DN6
         LDA   $5FFE,Y
         CMP   #$2E
         BNE   DN16
         LDA   STOR1
         STA   AUTO
DN16
         INC   DIRFLG
         LDA   #$5B
         JSR   TEXT
DN6      LDY   PPPP
         LDA   $6000,Y
         LDY   DIRFLG
         BEQ   DDN7
         LDY   PPP
         CPY   #1
         BEQ   DDN9
DDN7
         ORA   #$80
         JSR   TEXT
         INC   PPPP
         DEC   PPP
         BNE   DN6
DDN9     INC   STOR1
         LDA   DIRFLG
         BEQ   DDN8
         LDA   #$5D
         JSR   TEXT
DDN8
         LDA   STOR1
         CMP   NAMES
         BEQ   BBN10
         BGE   PPP-1
BBN10    JMP   DNLOOP
         RTS
PPP      DFB   0
PPPP     DFB   0
COUNT    DFB   0
DIRFLG   DFB   0
AUTO     DFB   0
FIRST_TIME DFB 0
BOTTOMLINE LDY #152
         LDX   #0
         LDA   #40
         JSR   TEXTSET
         LDA   #0
         STA   STOR1
BL1      LDY   STOR1
         LDA   BLTEXT,Y
         BEQ   BL2
         ORA   #$80
         JSR   TEXT
         INC   STOR1
         JMP   BL1
BL2      RTS
BLTEXT   ASC   'Select pathname for scenario prefix     '
         ASC   '# to go down. ESC to go up. RET to play.'
         ASC   '^B to quit.'
         HEX   00
