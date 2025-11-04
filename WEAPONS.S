         ORG   $7200
         DSK   bin/WEAPONS.BIN
         TYP   $06  ; /BIN file

; Each weapon is 10+9+1+1+1+10 = 32 bytes
         ASC   'UZI 9MM   '
         ASC   '9MM CLIP '
         DFB   128    ; Power (% chance to kill enemy)
         DFB   0      ; Type 0=shot,1=explosion,2=healing
         DFB   6      ; Damage (damage to player if hit by it)
         DS    10
         ASC   'H&K 12PSH '
         ASC   'H&K CLIP '
         DFB   100
         DFB   0
         DFB   7
         DS    10
         ASC   'MAC-10    '
         ASC   'MAC .45C '
         DFB   140
         DFB   0
         DFB   7
         DS    10
         ASC   'M-16 AUTO '
         ASC   '7.68 MM  '
         DFB   175
         DFB   0
         DFB   5
         DS    10
         ASC   '.45 AUTO  '
         ASC   '.45 CLIP '
         DFB   100
         DFB   0
         DFB   5
         DS    10
         ASC   '.38 SNUB  '
         ASC   '.38 DRUM '
         DFB   85
         DFB   0
         DFB   4
         DS    10
         ASC   'GREN LNCHR'
         ASC   'GERNADES '
         DFB   190
         DFB   1
         DFB   10
         DS    10
         ASC   'AUTOLOADER'
         ASC   '12G SHLS '
         DFB   110
         DFB   0
         DFB   7
         DS    10
