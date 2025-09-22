         ORG   $0C80
         DSK   bin/BOTTOMLINE.BIN
         TYP   $06  ; /BIN file

TEXT     =     $80F
TEXTSET  =     TEXT+3
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
