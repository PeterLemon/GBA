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
map '&',  $8195
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

// Opening
//TextStyle1($06B0A4, "In Champ Town.") 