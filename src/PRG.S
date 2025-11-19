         ORG   $2000
         DSK   ../bin/PRG.BIN
         TYP   $06  ; /BIN file

         LDY   #0
FF       LDA   $2026,Y
         STA   $1400,Y
         LDA   $2126,Y
         STA   $1500,Y
         LDA   $2226,Y
         STA   $1600,Y
         LDA   $2326,Y
         STA   $1700,Y
         LDA   $2426,Y
         STA   $1800,Y
         INY
         BNE   FF
         JMP   $1400
         ORG   $1400
AD       =     $1800
         JSR   $BF00
         HEX   C8
         DA    OPEN
         JSR   $BF00
         HEX   CA
         DA    READ
         JSR   $BF00
         HEX   CC
         DA    CLOSE
         JMP   GOIN
BYEBYE   JSR   $BF00
         HEX   65
         DA    QUIT
         RTS
QUIT     HEX   04000000000000
OPEN     HEX   03
         DA    FILENAME
         DA    $800
         HEX   00
READ     HEX   0401
         DA    $2000-300
         DA    $9E00
         DA    0
CLOSE    HEX   0101
FILENAME HEX   06
         ASC   'DIAFLW'
GOIN     LDA   $BF98
         AND   #$22
         CMP   #$22
         BNE   BYEBYE
         LDA   #$A0
         JSR   $C300
         jsr   $FC58
         JSR   PAGE
         JSR   AD
         LDA   #1
         STA   6
TOP      JSR   DISPLAY
         STA   $C010
T2       LDA   $C000
         BPL   T2
         AND   #$7F
         CMP   #10
         BEQ   NEXT
         CMP   #21
         BEQ   NEXT
         CMP   #8
         BEQ   PREV
         CMP   #11
         BEQ   PREV
         CMP   #27
         BEQ   BYEBYE
         JMP   T2
NEXT     LDA   #1
         STA   6
         JMP   TOP
PREV     LDA   #0
         STA   6
         JMP   TOP
DISPLAY  LDA   #2
         STA   34
         LDA   #22
         STA   35
         JSR   AD+3
         LDA   #0
         STA   34
         LDA   #22
         STA   35
         RTS
PAGE     LDA   #0
         STA   0
P2       LDY   0
         LDA   TITLES,Y
         JSR   $FDED
         INC   0
         LDA   0
         CMP   #160  ; two lines 80+80
         BNE   P2
         LDA   #22
         sta   37
         JSR   $FC22
         LDA   #0
         STA   0
P3       LDY   0
         LDA   TITLES+160,Y
         JSR   $FDED
         INC   0
         LDA   0
         CMP   #80  ; one line
         BNE   P3
         RTS
TITLES   ASC   '                 Documentation for Death'
         ASC   ' is a Four Letter Word                  '
         asc   '----------------------------------------'
         asc   '----------------------------------------'
         ASC   '---------------- Arrow keys to page up/d'
         ASC   'own, escape key to exit ----------------'
