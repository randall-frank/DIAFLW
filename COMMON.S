* Collection of common addresses/etc

* From PAC.S
PAC_BIGSHAPE    = $0800
PAC_LOOKUP      = $0803
PAC_SET         = $0806
PAC_RNDIZE      = $0809
PAC_RND         = $080C
PAC_TEXT        = $080F
PAC_TEXTSET     = $0812
PAC_DRAW        = $0815
PAC_HIGHLITE    = $0818
PAC_POCKETS     = $081B
PAC_CLEAR       = $081E
PAC_MSG         = $0821
PAC_CLEAR2      = $0824
PAC_BOTTOMLINE  = $0827
PAC_SETMASK     = $082A
PAC_WHICHTBL    = $0FFF

* GAME1.S2
USERSTEP        = $7400
* Return values from various functions
POWER           = $7403
EXPLOST         = $7404
DAMAGE          = $7405

* GAME2.S2
GAMESTEP        = $7A00

* IO2.S
IO_OPEN         = $9000
IO_CLOSE        = $9003
IO_SCORE        = $9006
IO_HIT          = $9009
IO_GETPREFIX    = $900C
IO_HITINC       = $900F
IO_HPOC         = $9012
IO_GETWINFO     = $9015
PLAYSOUND       = $9018

* DRAWTAB.S
TABX            = $4E00
TABY            = $4F00

* Player state
PLAYER_X        = $7300
PLAYER_Y        = $7301
PLAYER_Z        = $7302
CUR_HAND        = $7303
CUR_POCK        = $7304
SQUARE_X        = $7305
SQUARE_Y        = $7306
PLAYER_DIR      = $7307
PLAYER_SCORE_LO = $7308  ; X000,0X00,00X0,000X
PLAYER_HIT_LO   = $730C  ; X0,0X
STEPS_TO_HEAL   = $730E  ; FF=table
HEAL_SIZE       = $730F  ; default=1

* Scenario state (IO2.S)
VISITED_TABLE   = $8F00  ; X,Y X,Y X,Y
VISITED_LENGTH  = $8FFF  ; number used bytes in VISITED_TABLE (2*# of x,y entries)

* Sound
T1_SOUND_ROUT   = $8980
SOUND_TICK      = 0
SOUND_FIRE      = 1
SOUND_LONGFIRE  = 2
SOUND_CHIRP     = 3
SOUND_SHOT      = 4
SOUND_Drip      = 5
SOUND_Whoop     = 6
SOUND_Pip       = 7
SOUND_Phasor    = 8
SOUND_Scale     = 9
SOUND_S_beep    = 10
SOUND_M_beep    = 11
SOUND_L_beep    = 12
SOUND_Geiger    = 13
SOUND_Gleep     = 14
SOUND_Whooping  = 15
SOUND_Qwip      = 16
SOUND_Laser     = 17
SOUND_Fail      = 18
SOUND_Pass      = 19
SOUND_Timebomb  = 20

* DECOMP_IMG.S
SHOWSPLASH      = $4000
SHOWPLAY        = $4003

* Aople II constants
SPKR            = $C030 
WAIT            = $FCA8
