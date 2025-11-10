         ORG   $9700
         DSK   bin/PRE.BIN#069700
         TYP   $06  ; /BIN file

CLEAR2   =     $FC58  ; HOME
VTAB     =     $FC24  ; VTABZ - set line...
COUT     =     $FDED  ; COUT

         JMP   GETPREFIX  ; RETURN NUMBER IN ACC AND LIST @6000
RFILE    JSR   $BF00
         HEX   CA
         DA    RPDOS
         RTS
RPDOS    HEX   0401
DBUFF    DA    $0000
DLEN     DA    $0000
         HEX   0000
CFILE    JSR   $BF00
         HEX   CC
         DA    CPDOS
         RTS
CPDOS    HEX   0101
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
         LDA   #$6D
         STA   DBUFF+1
         JMP   RFILE
ONLINE   JSR   $BF00
         HEX   C5
         DA    ONPARA
         RTS
ONPARA   HEX   0200006C
OPENPRE  JSR   $BF00
         HEX   C8
         DA    OPPRE
         RTS
OPPRE    HEX   03
         DA    PREFIX
         DA    $6800
         HEX   01
GETPREFIX LDA  #0
         STA   PREFIX
GPTOP    JSR   CLEAR2
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
GP2      JSR   GETNAMES
         STA   $C010
GP3      LDA   $C000
         CMP   #$8D
         BNE   GP33
         LDY   PREFIX
         LDA   PREFIX,Y
         CMP   #$2E
         BNE   GP3
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
         LDA   $6C00,X
         STA   STOR1
         INX
         INY
GP6      LDA   $6C00,X
         STA   PREFIX,Y
         INX
         INY
         DEC   STOR1
         BNE   GP6
         DEY
         STY   PREFIX
         JMP   GPTOP

; STOR1    DFB   0
; NAMES    DFB   0
STOR1 =  0
NAMES =  1

GETNAMES
         LDA   PREFIX
         BNE   DOCATALOG
         LDA   #0
         STA   COUNT
         JSR   ONLINE
ONL1     LDY   COUNT
         LDA   $6C00,Y
         BEQ   ONL4
         AND   #$0F
         BNE   ONL2
ONL3     LDA   $6C10,Y
         STA   $6C00,Y
         INY
         BNE   ONL3
         BEQ   ONL1
ONL2     STA   $6C00,Y
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
         LDA   $6D00
         AND   #$F0
         CMP   #$D0
         BNE   DCNOT
         LDA   $6D00
         AND   #$0F
         STA   $6D00
         LDX   #0
         LDY   COUNT
DC3      LDA   $6D00,X
         STA   $6C00,Y
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
         LDA   $6C00,Y
         TAX
         INY
         STX   PPP
         STY   PPPP
DN6      LDY   PPPP
         LDA   $6C00,Y
         ORA   #$80
         JSR   TEXT
         INC   PPPP
         DEC   PPP
         BNE   DN6
         INC   STOR1
         LDA   STOR1
         CMP   NAMES
         BEQ   DNLOOP
         BLT   DNLOOP
         RTS
PPP      DFB   0
PPPP     DFB   0
COUNT    DFB   0
BOTTOMLINE LDY #152
         LDX   #0
         STX   STOR1
         LDA   #40
         JSR   TEXTSET
BL1      LDY   STOR1
         LDA   BLTEXT,Y
         BEQ   BL2
         JSR   TEXT
         INC   STOR1
         JMP   BL1
BL2      RTS
BLTEXT   ASC   '--Select pathname for scenario prefix-- '
         ASC   '# to go down. ESC to go up. RET to edit.'
         ASC   '^B to quit.'
         HEX   00
TEXTSET  TYA
         LSR
         LSR
         LSR
         STA   $25
         JSR   VTAB
         LDA   #0
         STA   $24
         RTS
TEXT     ORA   #$80
         JMP   COUT
