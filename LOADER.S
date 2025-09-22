         ORG   $2000
         DSK   bin/LOADER.BIN
         TYP   $06  ; /BIN file

SRCLO    =     0
SRCHI    =     1
TGTLO    =     2
TGTHI    =     3

* Restore help page
         JSR   TEXTPAGE

* Low order addresses
         LDA   #$00
         STA   SRCLO
         STA   TGTLO

* Read from 2100-2800 and store to 9000-9700         
         LDA   #$21
         STA   SRCHI
         LDA   #$90
         STA   TGTHI
         LDX   #$07
         JSR   MOVEMEM

* Read from 2800-3000  and store to 0800-1000         
         LDA   #$28
         STA   SRCHI
         LDA   #$08
         STA   TGTHI
         LDX   #$08
         JSR   MOVEMEM

* Read from 3000-4000 and store to 8000-9000         
         LDA   #$30
         STA   SRCHI
         LDA   #$80
         STA   TGTHI
         LDX   #$10
         JSR   MOVEMEM

* Read from 6000-7000 and store to 7000-8000        
         LDA   #$60
         STA   SRCHI
         LDA   #$70
         STA   TGTHI
         LDX   #$10
         JSR   MOVEMEM

* Start the game                           
         JMP   $8000

MOVEMEM  LDY   #$00
MOVELOOP LDA   (SRCLO),Y
         STA   (TGTLO),Y
         DEY
         BNE   MOVELOOP
         INC   TGTHI
         INC   SRCHI
         DEX
         BNE   MOVEMEM
         RTS
* Paint the help screen to the text page $400-$800
* The page source (HELP.S) is available at $7000 before it is overwritten by the loader
TEXTPAGE LDX   #$00
         LDA   #$00
         STA   SCAN+1
         LDA   #$70
         STA   SCAN+2
TEXTLOOP 
         LDA   TEXTADDRS,X
         STA   TGTLO
         INX
         LDA   TEXTADDRS,X
         STA   TGTHI
         INX
         LDY   #$00
SCAN     LDA   $FFFF
         CPX   #$06        ; lines 0,1 and 23 are inverse text
         BCC   INVERSE
         CPX   #48
         BCS   INVERSE
         JMP   NORMAL
INVERSE  AND   #$7F      ; clear high order bit
         CMP   #$40
         BLT   NORMAL
         CMP   #$60
         BGE   NORMAL
         AND   #$BF
NORMAL   STA   (TGTLO),Y
         INC   SCAN+1
         BNE   SKIPHI
         INC   SCAN+2
SKIPHI   INY
         CPY   #40
         BNE   SCAN
         CPX   #48
         BNE   TEXTLOOP
         RTS
TEXTADDRS
         DA    $0400
         DA    $0480
         DA    $0500
         DA    $0580
         DA    $0600
         DA    $0680
         DA    $0700
         DA    $0780
         DA    $0428
         DA    $04A8
         DA    $0528
         DA    $05A8
         DA    $0628
         DA    $06A8
         DA    $0728
         DA    $07A8
         DA    $0450
         DA    $04D0
         DA    $0550
         DA    $05D0
         DA    $0650
         DA    $06D0
         DA    $0750
         DA    $07D0
                   