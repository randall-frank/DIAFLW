         ORG   $9000
         DSK   bin/IO2.BIN
         TYP   $06  ; /BIN file

         PUT  COMMON.S

         JMP   OPEN
         JMP   CLOSE
         JMP   SCORE
         JMP   LOCAL_HIT
         JMP   GETPREFIX  ; RETURN NUMBER IN ACC AND LIST @6000
         JMP   LOCAL_HITINC
         JMP   LOCAL_HPOC
         JMP   LOCAL_GETWINFO
         JMP   LOCAL_PLAYSOUND
         JMP   LOCAL_GETWINFO_ACC
         JMP   LOCAL_MSGS

         LST   OFF
FILENAME HEX   08
         ASC   'SQUARE  '  ; was 08D3D1D5C1D2C50000
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

; Open/read the SQUAREXY file...
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
IN       JSR   PAC_CLEAR
         LDY   #144
         LDX   #1
         LDA   #14
         JSR   PAC_TEXTSET
         LDA   #0
         STA   8
T1       LDY   8
         LDA   MESS,Y
         CMP   #$FF
         BEQ   DONE
         JSR   PAC_TEXT
         INC   8
         JMP   T1
DONE     STA   $C010
         LDA   $C000
         BPL   DONE+3
         STA   $C010
         JSR   PAC_CLEAR
         JMP   OPEN
MESS     ASC   'PLACE SCENARIODISK SIDE A INA DRIVE.'
         DFB   255
OK       JSR   PAC_RNDIZE
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
NEXT     JSR   PAC_RND
         AND   #$3F
         STA   7
         JSR   PAC_RND
         AND   #$3F
         STA   8
         TAY
         LDA   7
         TAX
         JSR   PAC_LOOKUP
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
         JSR   PAC_RNDIZE
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
         JSR   PAC_TEXTSET
         LDA   #0
         STA   9
         LDY   9
SC2      LDA   $7308,Y
         ORA   #$B0
         JSR   PAC_TEXT
         INC   9
         LDY   9
         CPY   #4
         BNE   SC2
         RTS

LOCAL_HITINC   
         LDA   $730D
         CLC
         ADC   #1
         STA   $730D
         CMP   #10     ; if below 10, done...
         BNE   HOK
         LDA   #0
         STA   $730D
         LDA   $730C
         CLC
         ADC   #1
         STA   $730C
         CMP   #10     ; if below 10, done...
         BNE   HOK
         LDA   #9      ; set to 99
         STA   $730D
         STA   $730C
         JMP   HOK

LOCAL_HIT      
         LDA   $730D
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
HOK      JMP   LOCAL_DRAWHEALTH

; Scan the table of SQUAREXY files that have been touched
; and adjust the offset based on if the file had been loaded previously
TESTOLD  LDY   $8FFF
         BEQ   NEWREAD
TO1      LDA   $8EFE,Y
         CMP   $7305
         BNE   NOTIT
         LDA   $8EFF,Y
         CMP   $7306
         BNE   NOTIT

         ; File has been visited, read with $1100 offset
         LDA   #$11
         STA   DPOS+1
         LDA   #0
         STA   DPOS
         JSR   PFILE
         RTS

NOTIT    DEY
         DEY
         BNE   TO1

NEWREAD  LDA   #0 ; first time the SQUAREXY file is read, add it to the list
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
GPTOP    JSR   PAC_CLEAR2
         STA   $C052
         JSR   DRAW_TEXTBOX
         LDY   #8
         LDX   #1
         LDA   #38
         JSR   PAC_TEXTSET
         LDA   PREFIX
         BEQ   GP2
         LDA   #1
         STA   STOR1
GP1      LDY   STOR1
         LDA   PREFIX,Y
         JSR   PAC_TEXT
         INC   STOR1
         LDA   STOR1
         CMP   PREFIX
         BEQ   GP1
         BLT   GP1
GP2      LDA   #0
         STA   CUR_LINE
         LDA   #$FF
         STA   AUTO
         JSR   GETNAMES
         LDA   AUTO
         CMP   #$FF
         BEQ   GP12
         LDA   AUTO
         JMP   DOWNY
RDRAW    JSR   DRAWNAMES
GP12     STA   $C010
GP13     LDA   $C000
         BPL   GP13
         CMP   #$E0    ; Lowercase to uppercase conversion
         BLT   ITSOK
         EOR   #$20
ITSOK
         CMP   #$C4    ; "D)isk"
         BNE   GP14
         LDA   #0
         STA   PREFIX
         JSR   BACKUP
         JMP   GPTOP
GP14
         CMP   #138  ; Down arrow map to right arrow #$95
         BNE   GP41
         LDA   #$95
GP41
         CMP   #$8D    ; "return" map to "O"
         BNE   GP411
         LDA   #$CF
GP411
         CMP   #139  ; Up Arrow map to left arrow #$88
         BNE   GP33
         LDA   #$88
GP33
         CMP   #$D5    ; 'U)DirUp'  C=#$C3
         BNE   GP4
GP3      JSR   BACKUP
         JMP   GPTOP
GP4         
         CMP   #$D1    ; 'Q)uit'
         BNE   GP44
         JMP   BYEBYE         
GP44
         LDX   NAMES
         CPX   #$FF
         BEQ   GP12
         CMP   #$95    ; Right/down arrow
         BNE   GP15
         INC   CUR_LINE
         LDA   CUR_LINE
         CMP   NAMES
         BLT   RDRAW
         LDA   NAMES
         STA   CUR_LINE
         JMP   RDRAW  
GP15     CMP   #$88    ; Left/up arrow
         BNE   GP16
         DEC   CUR_LINE
         LDA   CUR_LINE
         CMP   #$FF
         BNE   RDRAW
         LDA   #0
         STA   CUR_LINE
         JMP   RDRAW
GP16
         CMP   #$CF    ; 'O)pen' (also CR)
         BNE   GP12
         LDA   CUR_LINE
DOWNY
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
         CMP   #$0F
         BLT   DN1
         LDA   #$F
         STA   NAMES
DN1
         LDA   CUR_LINE
         SEC
         SBC   #$05
         STA   STOR1
         LDA   #$FF
         STA   AUTO
         LDA   #0
         STA   LINE_NUM
DNLOOP   LDA   LINE_NUM
         CLC
         ADC   #6
         ASL
         ASL
         ASL
         TAY
         LDX   #1
         LDA   #40
         JSR   PAC_TEXTSET
         LDA   #0
         STA   DIRFLG
         LDA   STOR1
         CMP   NAMES
         BEQ   GOON
         BLT   GOON
MYLOOPE  LDA   #16
         STA   PPP
MYLOOP   LDA   #$A0
         JSR   PAC_TEXT
         DEC   PPP
         BNE   MYLOOP
         JMP   DDN88
GOON     LDA   STOR1
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
         LDX   #$91
         LDA   $5FFF,Y
         CMP   #$2E
         BNE   DRICN
         LDA   $5FFE,Y
         CMP   #$2E
         BNE   DN16
         LDA   STOR1
         STA   AUTO
DN16
         INC   DIRFLG
         LDX   #$92
DRICN    TXA
         PHA
         LDA   #$A0
         LDX   CUR_LINE
         CPX   STOR1
         BNE   DRICN1
         LDA   #$8E
DRICN1
         JSR   PAC_TEXT
         PLA
         JSR   PAC_TEXT
DN6      LDY   PPPP
         LDA   $6000,Y
         LDY   DIRFLG
         BEQ   DDN7
         LDY   PPP
         CPY   #1
         BEQ   DDN8
DDN7
         ORA   #$80
         JSR   PAC_TEXT
         INC   PPPP
         DEC   PPP
         BNE   DN6
DDN8     LDA   #$A0
         JSR   PAC_TEXT
         INC   PPPP
         LDA   PPPP
         AND   #$0F
         BNE   DDN8
DDN88    INC   LINE_NUM
         INC   STOR1
         LDA   LINE_NUM
         CMP   #$0A
         BEQ   MYRTS
         JMP   DNLOOP
MYRTS    RTS
PPP      DFB   0
PPPP     DFB   0
COUNT    DFB   0
DIRFLG   DFB   0
AUTO     DFB   0
CUR_LINE DFB   0
LINE_NUM DFB   0
FIRST_TIME DFB 0
DRAW_TEXTBOX JSR PAC_BOTTOMLINE
         LDA   #1
         LDY   #6*8
         LDX   #0
         JSR   PAC_TEXTSET
         LDA   #10
         STA   PPP
BL1      LDA   #$19
         JSR   PAC_TEXT
         DEC   PPP
         BNE   BL1
         LDA   #1
         LDX   #25
         LDY   #6*8
         JSR   PAC_TEXTSET
         LDA   #10
         STA   PPP
BL2      LDA   #$19
         JSR   PAC_TEXT
         DEC   PPP
         BNE   BL2
         LDY   #5*8
         LDX   #0
         LDA   #26
         JSR   PAC_TEXTSET
         LDA   #$14
         JSR   PAC_TEXT
         LDA   #24
         STA   PPP
BL3      LDA   #$18
         JSR   PAC_TEXT
         DEC   PPP
         BNE   BL3
         LDA   #$15
         JSR   PAC_TEXT
         LDY   #16*8
         LDX   #0
         LDA   #26
         JSR   PAC_TEXTSET
         LDA   #$16
         JSR   PAC_TEXT
         LDA   #24
         STA   PPP
BL4      LDA   #$18
         JSR   PAC_TEXT
         DEC   PPP
         BNE   BL4
         LDA   #$17
         JSR   PAC_TEXT
BL5      RTS

; Shared with GAME1.S
TEMP0    =     0
TEMP1    =     1
TEMP2    =     2
TEMP3    =     3

* Set up TEMP0,TEMP1 for pocket,  TEMP2,TEMP3 for hand
LOCAL_HPOC
         LDA   #$73
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

* get the current hand weapon info: power, type, damage 
LOCAL_GETWINFO
         LDY   #0
         LDA   (TEMP2),Y
         JMP   LOCAL_GETWINFO_ACC

* get the weapon info (weapon index in A): power, type, damage 
LOCAL_GETWINFO_ACC
         ASL
         ASL
         ASL
         ASL
         ASL
         STA   TEMP2
         LDA   #$72
         STA   TEMP3
         LDY   #19
         LDA   (TEMP2),Y  ; Weapon power
         STA   POWER
         INY
         LDA   (TEMP2),Y  ; Weapon type
         STA   EXPLOST
         INY
         LDA   (TEMP2),Y  ; Weapon damage
         STA   DAMAGE
         RTS

LOCAL_DRAWHEALTH
         LDX   #26
         LDY   #24
         LDA   #3
         JSR   PAC_TEXTSET
         LDA   $730C
         ORA   #$B0
         JSR   PAC_TEXT
         LDA   $730D
         ORA   #$B0
         JMP   PAC_TEXT

LOCAL_PLAYSOUND    ; Core sound routine.  Sound number in A, scrambles all registers
         CMP   #SOUND_SHOT+1
         BGE   GENERATED_SOUND

         JMP   T1_SOUND_ROUT  ; sounds [0,4] are handled by the binary T1 sound routine

GENERATED_SOUND       ; sound [0,15] in X register
         SEC
         SBC   #SOUND_SHOT+1
         TAX
         ; Routine from Assembly Cookbook for the Apple II/IIe (Don Lancaster)
         ; Chapter 4: Obnoxious Sounds
         PHP 
         PHA 
         TYA 
         PHA 
         TXA 
         CMP FLNGTH4 
         BCC LOK4 
         LDA #$00 
LOK4
         ASL 
         TAX 
         LDA SEFO,X 
         STA TRPCNT4 
         INX 
         LDA SEFO,X 
         STA SWEEP4+1 
SWEEP4 
         LDY #$00 
NXTSWP4 
         TYA 
         TAX 
NXTCYC4
         TYA 
         JSR WAIT 
         BIT SPKR 
         CPX #$80 
         BEQ EXIT4 
         DEX 
         BNE NXTCYC4 
         DEY 
         BNE NXTSWP4 
         DEC TRPCNT4 
         BNE SWEEP4
EXIT4 
         PLA 
         TAY 
         PLA 
         PLP 
         RTS

TRPCNT4  DFB $01
FLNGTH4  DFB $10
         ; Table for sounds that start at '5'
SEFO     DFB $01,$08 ; Tick
SEF1     DFB $01,$18 ; Whopidoop
SEF2     DFB $ff,$01 ; Pip
SEF3     DFB $06,$10 ; Phasor
SEF4     DFB $01,$30 ; Music scale (long)
SEF5     DFB $20,$06 ; Short beep
SEF6     DFB $70,$06 ; Medium beep
SEF7     DFB $ff,$06 ; Long beep
SEF8     DFB $01,$a0 ; Geiger (longish)
SEF9     DFB $ff,$02 ; Gleep (quick)
SEF10    DFB $04,$1c ; Glissade (woop,woop,woop,woop)
SEFll    DFB $01,$10 ; Qwip
SEF12    DFB $30,$0b ; Oboe (warble?  laser)
SEF13    DFB $30,$07 ; French horn (fail buzzer?)
SEF14    DFB $01,$15 ; Pass beep
SEF15    DFB $01,$64 ; Time bomb

LOCAL_MSGS
         PHA
         LDA   #14
         LDY   #144
         LDX   #1
         JSR   PAC_TEXTSET
         PLA
         ASL
         TAY
         CPY   #0
         BNE   MSGS2
         JMP   PAC_CLEAR
MSGS2    LDA   PTRTBL,Y
         STA   KLKL+1
         LDA   PTRTBL+1,Y
         STA   KLKL+2
         LDA   #0
         STA   PTRTBL
         JSR   PAC_CLEAR
MSGS3    LDY   PTRTBL
KLKL     LDA   $FFFF,Y
         CMP   #255
         Beq   MSGS4
         AND   #$7F
         JSR   PAC_TEXT
         INC   PTRTBL
         JMP   MSGS3
MSGS4    RTS

PTRTBL   DFB   0,0
         DA    MSG1
         DA    MSG2
         DA    MSG3
         DA    MSG4
         DA    MSG5
         DA    MSG6
         DA    MSG7
         DA    MSG8

MSG1     ASC   'No ammo.'
         dfb   255
MSG2     ASC   'No weapon.'
         dfb   255
MSG3     ASC   'Improper ammo.'
         dfb   255
MSG4     ASC   'Hand must be  '
         ASC   'empty to      '
         asc   'search.'
         dfb   255
MSG5     ASC   'Game paused.  '
         ASC   'Press RETURN.'
         dfb   255
MSG6     ASC   'No room in    '
         ASC   'pocket.'
         dfb   255
MSG7     ASC   'Invalid key   '
         ASC   'target.'
         dfb   255
MSG8     ASC   'Unlocked.     '
         dfb   255


; Note: if this goes into $9800, loader.s must be adjusted