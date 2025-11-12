         ORG   $2000
         DSK   ../SYSTEM/READ.DOCS#ff0000
         TYP   $FF  ; /SYS file

* Relocate ourselves to $1400 - $18FF
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

MLI      =   $BF00
MONITOR  =   $FF69
HOME     =   $FC58
COUT     =   $FDED
VTAB     =   $FC22
HTAB     =	 $24

BASE     =     $2000
LENGTH   =     $9E00
PAGESLO  =     $1900
PAGESHI  =     $1A00
CURPAGE  =     6
MAXPAGE  =     7

* Open the file DIAFLW.DOCS
         JSR   MLI
         HEX   C8
         DA    OPEN
         JSR   MLI
         HEX   CA
         DA    READ
         JSR   MLI
         HEX   CC
         DA    CLOSE
         ; Zero terminate the read data
         LDA   #<BASE
         CLC
         ADC   RD_LEN
         STA   $26
         LDA   #>BASE
         ADC   RD_LEN+1
         STA   $27
         LDY   #0
         LDA   #0
         STA   ($26),Y
         JMP   START

BYEBYE   
         JSR   MLI
         HEX   65
         DA    QUIT
         RTS

* MLI command tables
QUIT     HEX   04000000000000
OPEN     HEX   03
         DA    FILENAME
         DA    $800        ; I/O buffer @ $800
         HEX   00
READ     HEX   0401
         DA    BASE   
         DA    LENGTH      ; File is ~$9600 bytes long
RD_LEN   DA    0
CLOSE    HEX   0101
FILENAME HEX   0B
         ASC   'DIAFLW.DOCS'

START    LDA   $BF98
         AND   #$22
         CMP   #$22
         BNE   BYEBYE
         LDA   #$A0
         JSR   $C300
         JSR   CALCPAGES
         LDA   #0
         STA   CURPAGE
TOP      JSR   HOME
         JSR   DRAWTITLES
         JSR   DISPLAYPAGE
         STA   $C010
KEYCHECK LDA   $C000
         BPL   KEYCHECK
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
         JMP   KEYCHECK

NEXT     LDA   CURPAGE
         CMP   MAXPAGE
         BEQ   SKIPNEXT
         INC   CURPAGE
SKIPNEXT JMP   TOP

PREV     LDA   CURPAGE
         BEQ   SKIPPREV
         DEC   CURPAGE
SKIPPREV JMP   TOP

DISPLAYPAGE
         LDY   CURPAGE
         LDA   PAGESLO,Y
         STA   $26
         LDA   PAGESHI,Y
         STA   $27
         LDA   #0
         STA   HTAB
         LDA   #2
         STA   37
         JSR   VTAB
         LDY   #0
         LDX   #0
PAGELOOP LDA   ($26,X)
         INC   $26
         BNE   CHECK
         INC   $27
CHECK    CMP   #0
         BEQ   PAGEDONE
         CMP   #10 ; '/n'  
         BEQ   PAGELOOP
         CMP   #13 ; '/r'
         BEQ   NEWLINE
         ORA   #$80
         JSR   COUT
         JMP   PAGELOOP
NEWLINE  LDA   #$8D
         JSR   COUT
         INY
         CPY   #20
         BNE   PAGELOOP         
PAGEDONE RTS
         
CALCPAGES
         LDY   #0
         STY   MAXPAGE
         LDA   #<BASE
         STA   $26
         STA   PAGESLO,Y
         LDA   #>BASE
         STA   $27
         STA   PAGESHI,Y
         LDY   #0
         LDX   #0
CALCLOOP LDA   ($26,X)
         INC   $26
         BNE   CHARCOMP
         INC   $27
CHARCOMP CMP   #0    ; EOF
         BEQ   CALCDONE
         CMP   #13   ; '/r'
         BEQ   NEXTLINE
         JMP   CALCLOOP
NEXTLINE INY
         CPY   #20
         BNE   CALCLOOP
         INC   MAXPAGE
         LDY   MAXPAGE
         LDA   $26
         STA   PAGESLO,Y
         LDA   $27
         STA   PAGESHI,Y
         LDY   #0
         JMP   CALCLOOP        
CALCDONE RTS

DRAWTITLES
         LDA   #0
         STA   0
P2       LDY   0
         LDA   TITLES,Y
         JSR   COUT
         INC   0
         LDA   0
         CMP   #160  ; two lines 80+80
         BNE   P2
         LDA   #22
         STA   37
         JSR   VTAB
         LDA   #0
         STA   0
P3       LDY   0
         LDA   TITLES+160,Y
         JSR   COUT
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
