// GBA "Guru Logic Champ" Japanese To English Translation by krom (Peter Lemon):

endian msb // Used To Encode SHIFT-JIS Words
output "Guru Logic Champ.gba", create
origin $000000; insert "Guru Logic Champ (J).gba" // Include Japanese Guru Logic Champ GBA ROM

macro TextStyle1(OFFSET, TEXT) {
  origin {OFFSET}
  dw {TEXT} // ASCII Text To Print
}

map '\n', $04FF // newline
map ' ',  $8140
map 'c',  $8143 // comma ','
map '.',  $8144
map ':',  $8146
map '?',  $8148
map '!',  $8149
map '-',  $815B
map '~',  $8160
map 'd',  $8163 // '...'
map '\s', $8166 // Single Quote "'"
map '\d', $8168 // Double Quote '"'
map '(',  $8169
map ')',  $816A
map '&',  $8195
map '*',  $819C // Heart
map 'm',  $81F4 // Music Note
map '0',  $824F, 10
map 'A',  $8260, 26

// Intro / Tutorial 1
TextStyle1($0002C4, "O.Kc IT\sS\n")
TextStyle1($0002D8, "LESSON\n")
TextStyle1($0002E6, "TIME!") ; dw $0FFF

TextStyle1($0002F6, "I TEACH\n")
TextStyle1($00030A, "THE GAME\n")
TextStyle1($00031C, "RULES") ; dw $0FFF

TextStyle1($00032C, "TRY\n")
TextStyle1($000334, "& KEEP\n")
TextStyle1($000342, "UP!") ; dw $0FFF

TextStyle1($000356, "NOW\n")
TextStyle1($00035E, "LEARN HOW\n")
TextStyle1($000372, "TO PLAY") ; dw $0FFF

TextStyle1($00038E, "MOVE LEFT\n")
TextStyle1($0003A2, "RIGHT ON\n")
TextStyle1($0003B4, "\dD-PAD\d") ; dw $0FFF

TextStyle1($0003D0, "TURN THE\n")
TextStyle1($0003E2, "AREA\n")
TextStyle1($0003EC, "\dL-R\d") ; dw $0FFF

TextStyle1($000404, "USE \dA\d\n")
TextStyle1($000414, "FIRES\n")
TextStyle1($000420, "BLOCK") ; dw $0FFF

TextStyle1($000438, "USE \dB\d\n")
TextStyle1($000448, "SUCKS\n")
TextStyle1($000454, "BLOCK!") ; dw $0FFF

TextStyle1($00046E, "CAN\sT HIT\n")
TextStyle1($000482, "EDGES\n")
TextStyle1($00048E, "OF AREA") ; dw $0FFF

TextStyle1($0004AA, "NUMBER OF\n")
TextStyle1($0004BE, "BLOCKS \n")
TextStyle1($0004CE, "IS FIXED") ; dw $0FFF

TextStyle1($0004EC, "IF ZERO\n")
TextStyle1($0004FC, "NO BLOCK\n")
TextStyle1($00050E, "TO FIRE") ; dw $0FFF

TextStyle1($00052A, "FILL GAPS\n")
TextStyle1($00053E, "USING\n")
TextStyle1($00054A, "BLOCKS") ; dw $0FFF

TextStyle1($000564, "USE SIDE\n")
TextStyle1($000576, "HIT TO\n")
TextStyle1($000584, "FILL IT") ; dw $0FFF

TextStyle1($0005A0, "ALSOd\n")
TextStyle1($0005AC, "MORE INFO") ; dw $0FFF

TextStyle1($0005C4, "FILL BLUE\n")
TextStyle1($0005D8, "BLOCK FOR\n")
TextStyle1($0005EC, "STAGES") ; dw $0FFF

TextStyle1($0005FE, "BECOMES A\n")
TextStyle1($000612, "RED BLOCK\n")
TextStyle1($000626, "IF BAD") ; dw $0FFF

TextStyle1($000638, "IT SHOWS\n")
TextStyle1($00064A, "CHANGE") ; dw $0FFF

TextStyle1($000664, "LEARN THE\n")
TextStyle1($000678, "RULES!") ; dw $0FFF

TextStyle1($000692, "THOSE\n")
TextStyle1($00069E, "WERE THE\n")
TextStyle1($0006B0, "RULES") ; dw $0FFF

TextStyle1($0006C0, "O.K\n")
TextStyle1($0006C8, "ENJOY\n")
TextStyle1($0006D4, "PLAYING") ; dw $0FFF

// Intro / Tutorial 2
TextStyle1($000736, "ABOUT\n")
TextStyle1($000742, "HOLEc\n")
TextStyle1($00074E, "RUBBERd") ; dw $0FFF

TextStyle1($000762, "I\sLL\n")
TextStyle1($00076C, "EXPLAINd") ; dw $0FFF

TextStyle1($000782, "PLEASE\n")
TextStyle1($000790, "WATCH") ; dw $0FFF

TextStyle1($0007A0, "SCREEN") ; dw $0FFF


TextStyle1($0007BA, "ABOUT\n")
TextStyle1($0007C6, "HOLEc\n")
TextStyle1($0007D2, "RUBBERd") ; dw $0FFF

TextStyle1($0007E6, "I\sLL\n")
TextStyle1($0007F0, "EXPLAINd") ; dw $0FFF

TextStyle1($000806, "PLEASE\n")
TextStyle1($000814, "WATCH") ; dw $0FFF

TextStyle1($000824, "SCREEN") ; dw $0FFF

TextStyle1($00083E, "HERE\n")
TextStyle1($000848, "WE HAVE\n")
TextStyle1($000858, "HOLES") ; dw $0FFF

TextStyle1($000868, "YOU CAN\sT\n")
TextStyle1($00087C, "PLACE\n")
TextStyle1($000888, "A BLOCK") ; dw $0FFF

TextStyle1($0008A4, "ON \n")
TextStyle1($0008AC, "A HOLEd") ; dw $0FFF

TextStyle1($0008C0, "BLOCK\n")
TextStyle1($0008CC, "PASSES\n")
TextStyle1($0008DA, "A HOLE") ; dw $0FFF

TextStyle1($0008F4, "THE\n")
TextStyle1($0008FC, "WALLd") ; dw $0FFF

TextStyle1($000914, "IT IS\n")
TextStyle1($000920, "A RUBBERY\n")
TextStyle1($000934, "ONE") ; dw $0FFF

TextStyle1($000940, "THE BLOCK\n")
TextStyle1($000954, "DOES A\n")
TextStyle1($000962, "BOUNCE") ; dw $0FFF

TextStyle1($00097C, "DO YOU") ; dw $0FFF

TextStyle1($00098E, "GET IT? ") ; dw $0FFF

TextStyle1($0009A4, "TRY\n")
TextStyle1($0009AC, "IT HOW\n")
TextStyle1($0009BA, "I DO IT") ; dw $0FFF

TextStyle1($0009CE, "WELLc\n")
TextStyle1($0009DA, "SEE YA") ; dw $0FFF

// Intro / Tutorial 3
TextStyle1($000A86, "NOW ABOUT\n")
TextStyle1($000A9A, "\dPRESS\d\n")
TextStyle1($000AAA, "TYPE") ; dw $0FFF

TextStyle1($000AB8, "I WILL\n")
TextStyle1($000AC6, "EXPLAINd") ; dw $0FFF

TextStyle1($000ADC, "WATCH \n")
TextStyle1($000AEA, "THIS") ; dw $0FFF


TextStyle1($000B00, "NOW ABOUT\n")
TextStyle1($000B14, "\dPRESS\d\n")
TextStyle1($000B24, "TYPE") ; dw $0FFF

TextStyle1($000B32, "I WILL\n")
TextStyle1($000B40, "EXPLAINd") ; dw $0FFF

TextStyle1($000B56, "WATCH \n")
TextStyle1($000B64, "THIS") ; dw $0FFF

TextStyle1($000B7A, "YOU\n")
TextStyle1($000B82, "PRESS\n")
TextStyle1($000B8E, "BLOCK") ; dw $0FFF

TextStyle1($000B9E, "SHOOT\n")
TextStyle1($000BAA, "IT TO\n")
TextStyle1($000BB6, "PRESSd") ; dw $0FFF

TextStyle1($000BD0, "SEE IT\n")
TextStyle1($000BDE, "PRESS\n")
TextStyle1($000BEA, "BLOCK") ; dw $0FFF

TextStyle1($000BFA, "HIT A\n")
TextStyle1($000C06, "WALLd") ; dw $0FFF

TextStyle1($000C16, "CHANGES\n")
TextStyle1($000C26, "WHOLE OF\n")
TextStyle1($000C38, "A WALL") ; dw $0FFF

TextStyle1($000C52, "BESIDE\n")
TextStyle1($000C60, "A HARD\n")
TextStyle1($000C6E, "WALLd   ") ; dw $0FFF

TextStyle1($000C84, "BLOCK\n")
TextStyle1($000C90, "STRIKE") ; dw $0FFF

TextStyle1($000CA2, "WILL THEN\n")
TextStyle1($000CB6, "BOUNCE\n")
TextStyle1($000CC4, "BACKd") ; dw $0FFF

TextStyle1($000CDC, "SEE\n")
TextStyle1($000CE4, "BLOCK") ; dw $0FFF

TextStyle1($000CF4, "PUSHED\n")
TextStyle1($000D02, "IN \n")
TextStyle1($000D0A, "CORNERd") ; dw $0FFF

TextStyle1($000D26, "CAN\sT \n")
TextStyle1($000D34, "MOVE\n")
TextStyle1($000D3E, "ANYMORE") ; dw $0FFF

TextStyle1($000D52, "TAKE \n")
TextStyle1($000D5E, "NOTEd  ") ; dw $0FFF

TextStyle1($000D7A, "END  \n")
TextStyle1($000D86, "OF THE\n")
TextStyle1($000D94, "LESSONS") ; dw $0FFF

TextStyle1($000DA8, "SO I\n")
TextStyle1($000DB2, "WISH \n")
TextStyle1($000DBE, "YOU LUCK") ; dw $0FFF

// Stage Name: Misc
TextStyle1($0696F8, "   X    NEED ") ; dw $0000
TextStyle1($069714, "  UNKNOWN??  ") ; dw $0000

// Stage Name: Rescue 01
TextStyle1($386C04, " SPINNING TOP ") ; dw $0000 // Stage: 01
TextStyle1($386C22, "  RICE PLANT  ") ; dw $0000 // Stage: 02
TextStyle1($386C40, "  WINE GLASS  ") ; dw $0000 // Stage: 03
TextStyle1($386C5E, "   MANDARIN   ") ; dw $0000 // Stage: 04
TextStyle1($386C7C, "BASEBALL BALL ") ; dw $0000 // Stage: 05
TextStyle1($386C9A, " CATERPILLAR  ") ; dw $0000 // Stage: 06
TextStyle1($386CB8, "   PUDDING    ") ; dw $0000 // Stage: 07
TextStyle1($386CD6, "   SHURIKEN   ") ; dw $0000 // Stage: 08
TextStyle1($386CF4, "     CROW     ") ; dw $0000 // Stage: 09
TextStyle1($386D12, " WATER HANDLE ") ; dw $0000 // Stage: 10

// Stage Name: Rescue 02
TextStyle1($386D30, "KITCHEN KNIFE ") ; dw $0000 // Stage: 01
TextStyle1($386D4E, " WHITE FLOWER ") ; dw $0000 // Stage: 02
TextStyle1($386D6C, "      CD      ") ; dw $0000 // Stage: 03
TextStyle1($386D8A, " WORN GLASSES ") ; dw $0000 // Stage: 04
TextStyle1($386DA8, "    SNAIL     ") ; dw $0000 // Stage: 05
TextStyle1($386DC6, "  HOT SPRING  ") ; dw $0000 // Stage: 06
TextStyle1($386DE4, "  GOLF GREEN  ") ; dw $0000 // Stage: 07
TextStyle1($386E02, "  LUXURY BAG  ") ; dw $0000 // Stage: 08
TextStyle1($386E20, "  SNACK TIME  ") ; dw $0000 // Stage: 09
TextStyle1($386E3E, "  BUSY MAMA   ") ; dw $0000 // Stage: 10
TextStyle1($386E5C, "  CHEESECAKE  ") ; dw $0000 // Stage: 11
TextStyle1($386E7A, "   LAUGHTER   ") ; dw $0000 // Stage: 12
TextStyle1($386E98, "   PINWHEEL   ") ; dw $0000 // Stage: 13
TextStyle1($386EB6, "    CLOWN     ") ; dw $0000 // Stage: 14
TextStyle1($386ED4, "  TOILET KEY  ") ; dw $0000 // Stage: 15

//  Stage Name: Rescue 03
TextStyle1($386EF2, "     BONE     ") ; dw $0000 // Stage: 01
TextStyle1($386F10, " HOUSE MOUSE  ") ; dw $0000 // Stage: 02
TextStyle1($386F2E, " FRIESIAN COW ") ; dw $0000 // Stage: 03
TextStyle1($386F4C, "    TIGER     ") ; dw $0000 // Stage: 04
TextStyle1($386F6A, "    RABBIT    ") ; dw $0000 // Stage: 05
TextStyle1($386F88, "   SEAHORSE   ") ; dw $0000 // Stage: 06
TextStyle1($386FA6, "    SNAKE     ") ; dw $0000 // Stage: 07
TextStyle1($386FC4, "  RACE HORSE  ") ; dw $0000 // Stage: 08
TextStyle1($386FE2, "    SHEEP     ") ; dw $0000 // Stage: 09
TextStyle1($387000, "    MONKEY    ") ; dw $0000 // Stage: 10
TextStyle1($38701E, "   CHICKEN    ") ; dw $0000 // Stage: 11
TextStyle1($38703C, "FRISBEE CATCH!") ; dw $0000 // Stage: 12
TextStyle1($38705A, "  WILD BOAR   ") ; dw $0000 // Stage: 13
TextStyle1($387078, " OFFICE CHAIR ") ; dw $0000 // Stage: 14
TextStyle1($387096, "RED NOSE UNCLE") ; dw $0000 // Stage: 15
TextStyle1($3870B4, " ALARM CLOCK  ") ; dw $0000 // Stage: 16
TextStyle1($3870D2, "SPOT-BILL DUCK") ; dw $0000 // Stage: 17
TextStyle1($3870F0, " BAMBOO BOAT  ") ; dw $0000 // Stage: 18
TextStyle1($38710E, "  TABLE VASE  ") ; dw $0000 // Stage: 19
TextStyle1($38712C, "ELECTRIC PLUG ") ; dw $0000 // Stage: 20

//  Stage Name: Rescue 04
TextStyle1($38714A, "  BLOOD TEST  ") ; dw $0000 // Stage: 01
TextStyle1($387168, " LOVE LETTER  ") ; dw $0000 // Stage: 02
TextStyle1($387186, "  HEADLIGHT   ") ; dw $0000 // Stage: 03
TextStyle1($3871A4, " STREET LAMP  ") ; dw $0000 // Stage: 04
TextStyle1($3871C2, "  HOT-YOUCHA  ") ; dw $0000 // Stage: 05
TextStyle1($3871E0, "  TAKA HAWK   ") ; dw $0000 // Stage: 06
TextStyle1($3871FE, "  WILD WEST   ") ; dw $0000 // Stage: 07
TextStyle1($38721C, "  THUMB TACK  ") ; dw $0000 // Stage: 08
TextStyle1($38723A, " FLOPPY DISK  ") ; dw $0000 // Stage: 09
TextStyle1($387258, "CHECKERED FLAG") ; dw $0000 // Stage: 10
TextStyle1($387276, "  HANDCUFFS   ") ; dw $0000 // Stage: 11
TextStyle1($387294, "  HUGE POWER  ") ; dw $0000 // Stage: 12
TextStyle1($3872B2, " WARNING SIGN ") ; dw $0000 // Stage: 13
TextStyle1($3872D0, "  WALL CLOCK  ") ; dw $0000 // Stage: 14
TextStyle1($3872EE, "  DUMB-BELL   ") ; dw $0000 // Stage: 15

//  Stage Name: Rescue 05
TextStyle1($38730C, "  ROAD SIGN   ") ; dw $0000 // Stage: 01
TextStyle1($38732A, " TISSUE PAPER ") ; dw $0000 // Stage: 02
TextStyle1($387348, "NORWEGIAN FLAG") ; dw $0000 // Stage: 03
TextStyle1($387366, "   DAIMONJI   ") ; dw $0000 // Stage: 04
TextStyle1($387384, " HERO\sS SWORD ") ; dw $0000 // Stage: 05
TextStyle1($3873A2, " RED LIPSTICK ") ; dw $0000 // Stage: 06
TextStyle1($3873C0, "FIRST SUNRISE ") ; dw $0000 // Stage: 07
TextStyle1($3873DE, "OLYMPIC RINGS ") ; dw $0000 // Stage: 08
TextStyle1($3873FC, "  HEADPHONES  ") ; dw $0000 // Stage: 09
TextStyle1($38741A, "BEGINNER MARK ") ; dw $0000 // Stage: 10
TextStyle1($387438, "  MAPLE MARK  ") ; dw $0000 // Stage: 11
TextStyle1($387456, "    KOREA     ") ; dw $0000 // Stage: 12
TextStyle1($387474, " BELT BUCKLE  ") ; dw $0000 // Stage: 13
TextStyle1($387492, " CACTUS PLANT ") ; dw $0000 // Stage: 14
TextStyle1($3874B0, " SILK TOP HAT ") ; dw $0000 // Stage: 15
TextStyle1($3874CE, "  PAPERCLIP   ") ; dw $0000 // Stage: 16
TextStyle1($3874EC, "    LEMON     ") ; dw $0000 // Stage: 17
TextStyle1($38750A, "    KETTLE    ") ; dw $0000 // Stage: 18
TextStyle1($387528, " PANDA EATING ") ; dw $0000 // Stage: 19
TextStyle1($387546, "  FILE TOOL   ") ; dw $0000 // Stage: 20

//  Stage Name: Rescue 06
TextStyle1($387564, "   DOUGHNUT   ") ; dw $0000 // Stage: 01
TextStyle1($387582, "     TANK     ") ; dw $0000 // Stage: 02
TextStyle1($3875A0, "  DRAGONFLY   ") ; dw $0000 // Stage: 03
TextStyle1($3875BE, " WIND CHIMES  ") ; dw $0000 // Stage: 04
TextStyle1($3875DC, "HANIWA FIGURE ") ; dw $0000 // Stage: 05
TextStyle1($3875FA, "AMANATSU FRUIT") ; dw $0000 // Stage: 06
TextStyle1($387618, "    SKULL     ") ; dw $0000 // Stage: 07
TextStyle1($387636, "    STRIKE!   ") ; dw $0000 // Stage: 08
TextStyle1($387654, "    KOALA     ") ; dw $0000 // Stage: 09
TextStyle1($387672, "  RICE SPOON  ") ; dw $0000 // Stage: 10
TextStyle1($387690, "*VALENTINE\sS* ") ; dw $0000 // Stage: 11
TextStyle1($3876AE, "   HOME BASE  ") ; dw $0000 // Stage: 12
TextStyle1($3876CC, "HOTAIR BALLOON") ; dw $0000 // Stage: 13
TextStyle1($3876EA, "   BIG TREE   ") ; dw $0000 // Stage: 14
TextStyle1($387708, "     WASP     ") ; dw $0000 // Stage: 15
TextStyle1($387726, "CLOTHES BUTTON") ; dw $0000 // Stage: 16
TextStyle1($387744, " WEATHER DOLL ") ; dw $0000 // Stage: 17
TextStyle1($387762, "    SHIRT     ") ; dw $0000 // Stage: 18
TextStyle1($387780, "   ELEPHANT   ") ; dw $0000 // Stage: 19
TextStyle1($38779E, " BOTTLE GOURD ") ; dw $0000 // Stage: 20
TextStyle1($3877BC, " KOKESHI DOLL ") ; dw $0000 // Stage: 21
TextStyle1($3877DA, "   POSTBOX    ") ; dw $0000 // Stage: 22
TextStyle1($3877F8, "ARABIAN CAMEL ") ; dw $0000 // Stage: 23
TextStyle1($387816, "  RED HAIRED  ") ; dw $0000 // Stage: 24
TextStyle1($387834, "  ICE CREAM   ") ; dw $0000 // Stage: 25
TextStyle1($387852, "   SCISSORS   ") ; dw $0000 // Stage: 26
TextStyle1($387870, "SHRIMP TEMPURA") ; dw $0000 // Stage: 27
TextStyle1($38788E, " STEEL FLASK  ") ; dw $0000 // Stage: 28
TextStyle1($3878AC, " BRANDY GLASS ") ; dw $0000 // Stage: 29
TextStyle1($3878CA, "   SPANNER    ") ; dw $0000 // Stage: 30

//  Stage Name: Rescue 07
TextStyle1($3878E8, " ALUMINUM CAN ") ; dw $0000 // Stage: 01
TextStyle1($387906, " COLLAR BELL  ") ; dw $0000 // Stage: 02
TextStyle1($387924, "  LIGHTHOUSE  ") ; dw $0000 // Stage: 03
TextStyle1($387942, "    BRIDGE    ") ; dw $0000 // Stage: 04
TextStyle1($387960, "    SCREW     ") ; dw $0000 // Stage: 05
TextStyle1($38797E, " LOST & FOUND ") ; dw $0000 // Stage: 06
TextStyle1($38799C, " BIRD CHICKS  ") ; dw $0000 // Stage: 07
TextStyle1($3879BA, "  CROCODILE   ") ; dw $0000 // Stage: 08
TextStyle1($3879D8, "OFFICE WORKER ") ; dw $0000 // Stage: 09
TextStyle1($3879F6, "  HOSHIGAKI   ") ; dw $0000 // Stage: 10
TextStyle1($387A14, "    DIAPER    ") ; dw $0000 // Stage: 11
TextStyle1($387A32, "    PENCIL    ") ; dw $0000 // Stage: 12
TextStyle1($387A50, "   SURFING    ") ; dw $0000 // Stage: 13
TextStyle1($387A6E, "     COMB     ") ; dw $0000 // Stage: 14
TextStyle1($387A8C, "     BOMB     ") ; dw $0000 // Stage: 15

//  Stage Name: Rescue 08
TextStyle1($387AAA, "   PENGUIN    ") ; dw $0000 // Stage: 01
TextStyle1($387AC8, "  TOY HAMMER  ") ; dw $0000 // Stage: 02
TextStyle1($387AE6, " BOWLING PIN  ") ; dw $0000 // Stage: 03
TextStyle1($387B04, "    GRAPES    ") ; dw $0000 // Stage: 04
TextStyle1($387B22, "   POPSICLE   ") ; dw $0000 // Stage: 05
TextStyle1($387B40, "   DOLPHIN    ") ; dw $0000 // Stage: 06
TextStyle1($387B5E, " SLIDING DOOR ") ; dw $0000 // Stage: 07
TextStyle1($387B7C, " FIREFLY GLOW ") ; dw $0000 // Stage: 08
TextStyle1($387B9A, "1 ENDAMA COIN ") ; dw $0000 // Stage: 09
TextStyle1($387BB8, "   CHESTNUT   ") ; dw $0000 // Stage: 10
TextStyle1($387BD6, "  BLUE DRESS  ") ; dw $0000 // Stage: 11
TextStyle1($387BF4, "   POSTCARD   ") ; dw $0000 // Stage: 12
TextStyle1($387C12, "  FISH BONE   ") ; dw $0000 // Stage: 13
TextStyle1($387C30, " SOCCER BALL  ") ; dw $0000 // Stage: 14
TextStyle1($387C4E, "    DIVING    ") ; dw $0000 // Stage: 15
TextStyle1($387C6C, "  KAKI FRUIT  ") ; dw $0000 // Stage: 16
TextStyle1($387C8A, "  HOURGLASS   ") ; dw $0000 // Stage: 17
TextStyle1($387CA8, "WIDE-SCREEN TV") ; dw $0000 // Stage: 18
TextStyle1($387CC6, "    SATURN    ") ; dw $0000 // Stage: 19
TextStyle1($387CE4, "WOODEN DRAWERS") ; dw $0000 // Stage: 20
TextStyle1($387D02, "     DICE     ") ; dw $0000 // Stage: 21
TextStyle1($387D20, "  WATERMELON  ") ; dw $0000 // Stage: 22
TextStyle1($387D3E, "    MEMORY    ") ; dw $0000 // Stage: 23
TextStyle1($387D5C, "    GUITAR    ") ; dw $0000 // Stage: 24
TextStyle1($387D7A, "TABASCO SAUCE ") ; dw $0000 // Stage: 25

//  Stage Name: Rescue 09
TextStyle1($387D98, "     PIG      ") ; dw $0000 // Stage: 01
TextStyle1($387DB6, "   YIN-YANG   ") ; dw $0000 // Stage: 02
TextStyle1($387DD4, "TRAFFIC LIGHTS") ; dw $0000 // Stage: 03
TextStyle1($387DF2, "   LAPTOP PC  ") ; dw $0000 // Stage: 04
TextStyle1($387E10, "  SINGLE BED  ") ; dw $0000 // Stage: 05
TextStyle1($387E2E, " NIGIRI SUSHI ") ; dw $0000 // Stage: 06
TextStyle1($387E4C, "  BASKETBALL  ") ; dw $0000 // Stage: 07
TextStyle1($387E6A, " 100 YEN COIN ") ; dw $0000 // Stage: 08
TextStyle1($387E88, " PHONE STRAP  ") ; dw $0000 // Stage: 09
TextStyle1($387EA6, "  LOFA SOFA   ") ; dw $0000 // Stage: 10
TextStyle1($387EC4, "   SUNFISH    ") ; dw $0000 // Stage: 11
TextStyle1($387EE2, "    APPLE     ") ; dw $0000 // Stage: 12
TextStyle1($387F00, "  COFFEE CUP  ") ; dw $0000 // Stage: 13
TextStyle1($387F1E, "LEATHER SHOES ") ; dw $0000 // Stage: 14
TextStyle1($387F3C, "  RED FLOWER  ") ; dw $0000 // Stage: 15
TextStyle1($387F5A, "VACUUM CLEANER") ; dw $0000 // Stage: 16
TextStyle1($387F78, "  FRYING PAN  ") ; dw $0000 // Stage: 17
TextStyle1($387F96, " IRON CANNON  ") ; dw $0000 // Stage: 18
TextStyle1($387FB4, "   DUSTPAN    ") ; dw $0000 // Stage: 19
TextStyle1($387FD2, " ANSWERPHONE  ") ; dw $0000 // Stage: 20
TextStyle1($387FF0, "    STOVE     ") ; dw $0000 // Stage: 21
TextStyle1($38800E, "    CANOE     ") ; dw $0000 // Stage: 22
TextStyle1($38802C, " PLAYING SNES ") ; dw $0000 // Stage: 23
TextStyle1($38804A, "  TOOTHPASTE  ") ; dw $0000 // Stage: 24
TextStyle1($388068, "    TULIP     ") ; dw $0000 // Stage: 25
TextStyle1($388086, "   COMPILE    ") ; dw $0000 // Stage: 26
TextStyle1($3880A4, "  SKY DIVING  ") ; dw $0000 // Stage: 27
TextStyle1($3880C2, " SLOT MACHINE ") ; dw $0000 // Stage: 28
TextStyle1($3880E0, "   BAR HANG   ") ; dw $0000 // Stage: 29
TextStyle1($3880FE, "     SALT     ") ; dw $0000 // Stage: 30

//  Stage Name: Rescue 10
TextStyle1($38811C, " GREEN APPLE  ") ; dw $0000 // Stage: 01
TextStyle1($38813A, "MORNING GLORY ") ; dw $0000 // Stage: 02
TextStyle1($388158, "   SPARKLER   ") ; dw $0000 // Stage: 03
TextStyle1($388176, "    EARTH     ") ; dw $0000 // Stage: 04
TextStyle1($388194, "     KEY      ") ; dw $0000 // Stage: 05
TextStyle1($3881B2, " BLACK PHONE  ") ; dw $0000 // Stage: 06
TextStyle1($3881D0, "  CALCULATOR  ") ; dw $0000 // Stage: 07
TextStyle1($3881EE, " COMPANY HEAD ") ; dw $0000 // Stage: 08
TextStyle1($38820C, "    PIZZA     ") ; dw $0000 // Stage: 09
TextStyle1($38822A, "  HAIRDRYER   ") ; dw $0000 // Stage: 10
TextStyle1($388248, " BABY BOTTLE  ") ; dw $0000 // Stage: 11
TextStyle1($388266, "   FAMICOM    ") ; dw $0000 // Stage: 12
TextStyle1($388284, "    BEETLE    ") ; dw $0000 // Stage: 13
TextStyle1($3882A2, "PAPER AIRPLANE") ; dw $0000 // Stage: 14
TextStyle1($3882C0, "  DICTIONARY  ") ; dw $0000 // Stage: 15
TextStyle1($3882DE, "   BALL BOY   ") ; dw $0000 // Stage: 16
TextStyle1($3882FC, " POWER PLANT  ") ; dw $0000 // Stage: 17
TextStyle1($38831A, "CLOTHES HANGER") ; dw $0000 // Stage: 18
TextStyle1($388338, " CHILI PEPPER ") ; dw $0000 // Stage: 19
TextStyle1($388356, "SEWING MACHINE") ; dw $0000 // Stage: 20
TextStyle1($388374, "HORSESHOE CRAB") ; dw $0000 // Stage: 21
TextStyle1($388392, "     DUCK     ") ; dw $0000 // Stage: 22
TextStyle1($3883B0, "  SPARE KEY   ") ; dw $0000 // Stage: 23
TextStyle1($3883CE, "RAINY WEATHER ") ; dw $0000 // Stage: 24
TextStyle1($3883EC, "    DARTS     ") ; dw $0000 // Stage: 25
TextStyle1($38840A, " 2 OF HEARTS  ") ; dw $0000 // Stage: 26
TextStyle1($388428, "    TOAST     ") ; dw $0000 // Stage: 27
TextStyle1($388446, "   RED CAN    ") ; dw $0000 // Stage: 28
TextStyle1($388464, "     GIRL     ") ; dw $0000 // Stage: 29
TextStyle1($388482, " CUMULONIMBUS ") ; dw $0000 // Stage: 30
TextStyle1($3884A0, "  SOY SAUCE   ") ; dw $0000 // Stage: 31
TextStyle1($3884BE, "     MILK     ") ; dw $0000 // Stage: 32
TextStyle1($3884DC, "     BAG      ") ; dw $0000 // Stage: 33
TextStyle1($3884FA, "  BLACK PIG   ") ; dw $0000 // Stage: 34
TextStyle1($388518, "YOUNG BROTHER ") ; dw $0000 // Stage: 35
TextStyle1($388536, " TIC-TAC-TOE  ") ; dw $0000 // Stage: 36
TextStyle1($388554, "    CAMERA    ") ; dw $0000 // Stage: 37
TextStyle1($388572, " TENNIS BALL  ") ; dw $0000 // Stage: 38
TextStyle1($388590, "  STRAWBERRY  ") ; dw $0000 // Stage: 39
TextStyle1($3885AE, "    MATCH     ") ; dw $0000 // Stage: 40

//  Stage Name: Rescue 11
TextStyle1($3885CC, "BOTTLE OPENER ") ; dw $0000 // Stage: 01
TextStyle1($3885EA, " PLEASE HELP! ") ; dw $0000 // Stage: 02
TextStyle1($388608, "  BILLIARDS   ") ; dw $0000 // Stage: 03
TextStyle1($388626, "  CHOPSTICKS  ") ; dw $0000 // Stage: 04
TextStyle1($388644, "     ODEN     ") ; dw $0000 // Stage: 05
TextStyle1($388662, "DOMESTIC DUCK ") ; dw $0000 // Stage: 06
TextStyle1($388680, "*WIFE\sS LUNCH*") ; dw $0000 // Stage: 07
TextStyle1($38869E, "     FORK     ") ; dw $0000 // Stage: 08
TextStyle1($3886BC, "   GOLDFISH   ") ; dw $0000 // Stage: 09
TextStyle1($3886DA, "    STOAT     ") ; dw $0000 // Stage: 10
TextStyle1($3886F8, "     BEAN     ") ; dw $0000 // Stage: 11
TextStyle1($388716, "   MUSHROOM   ") ; dw $0000 // Stage: 12
TextStyle1($388734, "RED DRAGONFLY ") ; dw $0000 // Stage: 13
TextStyle1($388752, " I\sM HUNGRY~  ") ; dw $0000 // Stage: 14
TextStyle1($388770, "  TELESCOPE   ") ; dw $0000 // Stage: 15
TextStyle1($38878E, "FRESHWATER EEL") ; dw $0000 // Stage: 16
TextStyle1($3887AC, " DARUMA DOLL  ") ; dw $0000 // Stage: 17
TextStyle1($3887CA, "    BANANA    ") ; dw $0000 // Stage: 18
TextStyle1($3887E8, "   THE MOON   ") ; dw $0000 // Stage: 19
TextStyle1($388806, "  GYOZA DISH  ") ; dw $0000 // Stage: 20
TextStyle1($388824, "TIN CAN PHONE ") ; dw $0000 // Stage: 21
TextStyle1($388842, "STEALTH PLANE ") ; dw $0000 // Stage: 22
TextStyle1($388860, "   EAR PICK   ") ; dw $0000 // Stage: 23
TextStyle1($38887E, " NEW FAMICOM  ") ; dw $0000 // Stage: 24
TextStyle1($38889C, "  SHORTCAKE   ") ; dw $0000 // Stage: 25
TextStyle1($3888BA, "   MACKEREL   ") ; dw $0000 // Stage: 26
TextStyle1($3888D8, " BULLET TRAIN ") ; dw $0000 // Stage: 27
TextStyle1($3888F6, "CAPTURED ALIEN") ; dw $0000 // Stage: 28
TextStyle1($388914, "   GATEBALL   ") ; dw $0000 // Stage: 29
TextStyle1($388932, "     DO m     ") ; dw $0000 // Stage: 30
TextStyle1($388950, "  INK BOTTLE  ") ; dw $0000 // Stage: 31
TextStyle1($38896E, "  BUTTERFLY   ") ; dw $0000 // Stage: 32
TextStyle1($38898C, "     JUDO     ") ; dw $0000 // Stage: 33
TextStyle1($3889AA, " TOWER OF SUN ") ; dw $0000 // Stage: 34
TextStyle1($3889C8, " ELECTRIC FAN ") ; dw $0000 // Stage: 35
TextStyle1($3889E6, "   BICYCLE    ") ; dw $0000 // Stage: 36
TextStyle1($388A04, "ARTIST PALETTE") ; dw $0000 // Stage: 37
TextStyle1($388A22, "  TREE FROG   ") ; dw $0000 // Stage: 38
TextStyle1($388A40, "  HELICOPTER  ") ; dw $0000 // Stage: 39
TextStyle1($388A5E, " MILK CARTON  ") ; dw $0000 // Stage: 40
TextStyle1($388A7C, "    JAPAN     ") ; dw $0000 // Stage: 41
TextStyle1($388A9A, "  LONG NOSE   ") ; dw $0000 // Stage: 42
TextStyle1($388AB8, "  VIDEO TAPE  ") ; dw $0000 // Stage: 43
TextStyle1($388AD6, "COMPUTER MOUSE") ; dw $0000 // Stage: 44
TextStyle1($388AF4, "   BATTERY    ") ; dw $0000 // Stage: 45

//  Stage Name: Rescue 12
TextStyle1($388B12, "  FRIED EGG   ") ; dw $0000 // Stage: 01
TextStyle1($388B30, "  GOLD RING   ") ; dw $0000 // Stage: 02
TextStyle1($388B4E, "     BUS      ") ; dw $0000 // Stage: 03
TextStyle1($388B6C, "HORSETAIL FERN") ; dw $0000 // Stage: 04
TextStyle1($388B8A, "  UNDERWEAR   ") ; dw $0000 // Stage: 05
TextStyle1($388BA8, " CRESTED IBIS ") ; dw $0000 // Stage: 06
TextStyle1($388BC6, "     GBA      ") ; dw $0000 // Stage: 07
TextStyle1($388BE4, "    GOLFER    ") ; dw $0000 // Stage: 08
TextStyle1($388C02, "     AXE      ") ; dw $0000 // Stage: 09
TextStyle1($388C20, "    WALRUS    ") ; dw $0000 // Stage: 10
TextStyle1($388C3E, "  SKI JUMPER  ") ; dw $0000 // Stage: 11
TextStyle1($388C5C, "    AFRICA    ") ; dw $0000 // Stage: 12
TextStyle1($388C7A, "CARP STREAMER ") ; dw $0000 // Stage: 13
TextStyle1($388C98, "ACE OF SPADES ") ; dw $0000 // Stage: 14
TextStyle1($388CB6, " SNOW MONKEY  ") ; dw $0000 // Stage: 15
TextStyle1($388CD4, "    SHIELD    ") ; dw $0000 // Stage: 16
TextStyle1($388CF2, "   TADPOLE    ") ; dw $0000 // Stage: 17
TextStyle1($388D10, " MOAI STATUE  ") ; dw $0000 // Stage: 18
TextStyle1($388D2E, " *LOVE LOVE*  ") ; dw $0000 // Stage: 19
TextStyle1($388D4C, "   GAMECUBE   ") ; dw $0000 // Stage: 20
TextStyle1($388D6A, "   MERMAID    ") ; dw $0000 // Stage: 21
TextStyle1($388D88, "MONKEY BANANA ") ; dw $0000 // Stage: 22
TextStyle1($388DA6, "SUMO WRESTLER ") ; dw $0000 // Stage: 23
TextStyle1($388DC4, "  GENTLEMAN   ") ; dw $0000 // Stage: 24
TextStyle1($388DE2, " PRETTY WOMAN ") ; dw $0000 // Stage: 25
TextStyle1($388E00, " SWALLOWTAIL  ") ; dw $0000 // Stage: 26
TextStyle1($388E1E, "  LIGHT BULB  ") ; dw $0000 // Stage: 27
TextStyle1($388E3C, "  STEEL DRUM  ") ; dw $0000 // Stage: 28
TextStyle1($388E5A, "   PYRAMID    ") ; dw $0000 // Stage: 29
TextStyle1($388E78, "    SHOOT!    ") ; dw $0000 // Stage: 30
TextStyle1($388E96, " KYOTO TEMPLE ") ; dw $0000 // Stage: 31
TextStyle1($388EB4, " TABLE TENNIS ") ; dw $0000 // Stage: 32
TextStyle1($388ED2, "LAUGHING WOMAN") ; dw $0000 // Stage: 33
TextStyle1($388EF0, "     TREE     ") ; dw $0000 // Stage: 34
TextStyle1($388F0E, "    KETTLE    ") ; dw $0000 // Stage: 35
TextStyle1($388F2C, "    PEACE     ") ; dw $0000 // Stage: 36
TextStyle1($388F4A, "DIGITAL CAMERA") ; dw $0000 // Stage: 37
TextStyle1($388F68, "   GAME BOY   ") ; dw $0000 // Stage: 38
TextStyle1($388F86, " JAPANESE FAN ") ; dw $0000 // Stage: 39
TextStyle1($388FA4, "CLENCHED FIST ") ; dw $0000 // Stage: 40
TextStyle1($388FC2, "    BRIEFS    ") ; dw $0000 // Stage: 41
TextStyle1($388FE0, "   BIG BRO    ") ; dw $0000 // Stage: 42
TextStyle1($388FFE, "  KIND UNCLE  ") ; dw $0000 // Stage: 43
TextStyle1($38901C, " PLUG SOCKET  ") ; dw $0000 // Stage: 44
TextStyle1($38903A, "  OPEN PALM   ") ; dw $0000 // Stage: 45
TextStyle1($389058, " AKI MIYAJIMA ") ; dw $0000 // Stage: 46
TextStyle1($389076, "  HAMBURGER   ") ; dw $0000 // Stage: 47
TextStyle1($389094, "    BOXING    ") ; dw $0000 // Stage: 48
TextStyle1($3890B2, "  CELL PHONE  ") ; dw $0000 // Stage: 49
TextStyle1($3890D0, " NAIL PULLER  ") ; dw $0000 // Stage: 50

//  Stage Name: Rescue EX
TextStyle1($3890EE, " CHAMP (DAD)  ") ; dw $0000 // Stage: 01
TextStyle1($38910C, "   BLUE POT   ") ; dw $0000 // Stage: 02
TextStyle1($38912A, "CHAMP(BIG BRO)") ; dw $0000 // Stage: 03
TextStyle1($389148, " JOGGING MAN  ") ; dw $0000 // Stage: 04
TextStyle1($389166, "   POMUKUN    ") ; dw $0000 // Stage: 05
TextStyle1($389184, "    HELEN     ") ; dw $0000 // Stage: 06
TextStyle1($3891A2, "   POOR MAN   ") ; dw $0000 // Stage: 07
TextStyle1($3891C0, "RUST MAN (OLD)") ; dw $0000 // Stage: 08
TextStyle1($3891DE, "RUST MAN (NEW)") ; dw $0000 // Stage: 09
TextStyle1($3891FC, " HAMSTER MAN  ") ; dw $0000 // Stage: 10
TextStyle1($38921A, "  CHUBBY MAN  ") ; dw $0000 // Stage: 11
TextStyle1($389238, "   DUMB MAN   ") ; dw $0000 // Stage: 12
TextStyle1($389256, "  SPACE SLUG  ") ; dw $0000 // Stage: 13
TextStyle1($389274, "  KOKKO MAN   ") ; dw $0000 // Stage: 14
TextStyle1($389292, "ROBOT DENTIST ") ; dw $0000 // Stage: 15
TextStyle1($3892B0, " TOP BREEDER  ") ; dw $0000 // Stage: 16
TextStyle1($3892CE, "BATTLEMAN(RED)") ; dw $0000 // Stage: 17
TextStyle1($3892EC, "  UNDERLING   ") ; dw $0000 // Stage: 18
TextStyle1($38930A, "     BOSS     ") ; dw $0000 // Stage: 19
TextStyle1($389328, "    HAKASE    ") ; dw $0000 // Stage: 20