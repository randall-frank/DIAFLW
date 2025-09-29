
         dsk   bin/HELP.BIN
         typ   $06  ; /BIN file

         org   $7000
         asc   " Death is a Four Letter Word 1.1.4 Help "
         asc   "---Key---Action-------------------------"
         asc   "   ^B    Execute a ProDOS BYE           "
         asc   "   ^Q    Abort the current mission      "
         asc   "   1-4   Get a weapon from pocket 1-4   "
         asc   "   5-8   Get ammo from pocket 1-4       "
         asc   "   9,0   Select current hand left/right "
         asc   "  RETURN Toggle current hand left/right "
         asc   "    S    Search body into current hand  "
         asc   "    D    Drop contents of current hand  "
         asc   "   ^V    Sound toggle                   "
         asc   "   ^S    Save current mission to disk   "
         asc   "   ESC   Pause/unpause current game     "
         asc   "    F    Fire weapon in current hand    "
         asc   "    A    Move ammo in hand to pocket    "
         asc   "    W    Move weapon in hand to pocket  "
         asc   "    L    Load ammo in pocket to hand    "
         asc   "    R    Load weapon in pocket to hand  "
         asc   "   "
         hex   48ac55    ; mousetext <-,->
         asc   "   Cycle pocket selection         "
         asc   "   ?,/   Display this help screen       "
         asc   "    I    Move forward                   "
         asc   "   J,K   Turn left/right                "
         asc   "   ^J    Toggle joystick on/off         "
         asc   "        Press RETURN to Continue        "
