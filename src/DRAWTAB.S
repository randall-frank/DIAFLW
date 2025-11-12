         ORG   $4E00
         DSK   ../bin/DRAWTAB.BIN
         TYP   $06  ; /BIN file

* UP
TABX1    DFB   0,1,2,3,4,5,6
         DFB   0,1,2,3,4,5,6
         DFB   0,1,2,3,4,5,6
         DFB   0,1,2,  4,5,6
         DFB   0,1,      5,6
         DFB   0,          6
         DFB   254         
         DFB       2,3,4
         DFB     1,2,3,4,5
         DFB   0,1,2,3,4,5,6
         DFB   255
         DS    14
* RIGHT
TABX2    DFB     1,2,3,4,5,6
         DFB       2,3,4,5,6
         DFB         3,4,5,6
         DFB           4,5,6
         DFB         3,4,5,6
         DFB       2,3,4,5,6
         DFB     1,2,3,4,5,6
         DFB   254
         DFB   0
         DFB   0,1
         DFB   0,1,2
         DFB   0,1,2
         DFB   0,1,2
         DFB   0,1
         DFB   0         
         DFB   255
         DS    14
* DOWN
TABX3    
         DFB   0,          6
         DFB   0,1,      5,6
         DFB   0,1,2,  4,5,6
         DFB   0,1,2,3,4,5,6
         DFB   0,1,2,3,4,5,6
         DFB   0,1,2,3,4,5,6
         DFB   254
         DFB   0,1,2,3,4,5,6
         DFB     1,2,3,4,5
         DFB       2,3,4
         DFB   255
         DS    14
* LEFT
TABX4    DFB   0,1,2,3,4,5
         DFB   0,1,2,3,4
         DFB   0,1,2,3
         DFB   0,1,2,  
         DFB   0,1,2,3
         DFB   0,1,2,3,4
         DFB   0,1,2,3,4,5
         DFB   254
         DFB               6
         DFB             5,6
         DFB           4,5,6
         DFB           4,5,6
         DFB           4,5,6
         DFB             5,6
         DFB               6
         DFB   255
         DS    14


* UP
TABY1    DFB   0,0,0,0,0,0,0
         DFB   1,1,1,1,1,1,1
         DFB   2,2,2,2,2,2,2
         DFB   3,3,3,  3,3,3
         DFB   4,4,      4,4
         DFB   5,          5
         DFB   254
         DFB       4,4,4
         DFB     5,5,5,5,5
         DFB   6,6,6,6,6,6,6
         DFB   255
         DS    14
* RIGHT
TABY2    DFB     0,0,0,0,0,0
         DFB       1,1,1,1,1
         DFB         2,2,2,2
         DFB           3,3,3
         DFB         4,4,4,4
         DFB       5,5,5,5,5
         DFB     6,6,6,6,6,6
         DFB   254
         DFB   0
         DFB   1,1
         DFB   2,2,2
         DFB   3,3,3
         DFB   4,4,4
         DFB   5,5
         DFB   6
         DFB   255
         DS    14
* DOWN
TABY3    
         DFB   1,          1
         DFB   2,2,      2,2
         DFB   3,3,3,  3,3,3
         DFB   4,4,4,4,4,4,4
         DFB   5,5,5,5,5,5,5
         DFB   6,6,6,6,6,6,6
         DFB   254
         DFB   0,0,0,0,0,0,0
         DFB     1,1,1,1,1
         DFB       2,2,2,
         DFB   255
         DS    14
* LEFT
TABY4    DFB   0,0,0,0,0,0
         DFB   1,1,1,1,1
         DFB   2,2,2,2
         DFB   3,3,3,  
         DFB   4,4,4,4
         DFB   5,5,5,5,5
         DFB   6,6,6,6,6,6
         DFB   254
         DFB               0
         DFB             1,1
         DFB           2,2,2
         DFB           3,3,3
         DFB           4,4,4
         DFB             5,5
         DFB               6
         DFB   255
