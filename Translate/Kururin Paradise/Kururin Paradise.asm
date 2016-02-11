// GBA "Kururin Paradise" Japanese To English Translation by krom (Peter Lemon):

endian msb // Used To Encode SHIFT-JIS Words
output "Kururin Paradise.gba", create
origin $000000; insert "Kururin Paradise (J).gba" // Include Japanese Kururin Paradise GBA ROM

macro TextStyle1(OFFSET, TEXT) {
  origin {OFFSET}
  db {TEXT} // ASCII Text To Print
}

macro TextStyle2(OFFSET, TEXT) {
  origin {OFFSET}
  dw {TEXT} // ASCII Text To Print
}

// Hi-Score
TextStyle1($024CE0, "Pokorin") ; db $00
TextStyle1($024CE8, "Pikarin") ; db $00
TextStyle1($024CF0, "Hoyorin") ; db $00
TextStyle1($024CF8, "Fuwarin") ; db $00
TextStyle1($024D00, "Gekirin") ; db $00
TextStyle1($024D08, "Chikuri") ; db $00
TextStyle1($024D10, "Raburin") ; db $00
TextStyle1($024D18, "Maririn") ; db $00
TextStyle1($024D20, "Kakurin") ; db $00
TextStyle1($024D28, "Hyokori") ; db $00

TextStyle1($024D7D, "Hare") ; db $00, $00
TextStyle1($03C269, ".T") ; db $00

TextStyle1($024D87, "Hare") ; db $00, $00
TextStyle1($03C26C, ".P") ; db $00

// Adventure
TextStyle1($024DAC, "Quit Level") ; db $00
TextStyle1($024DB8, "See Map") ; db $00
TextStyle1($024DC0, "Retry") ; db $00
TextStyle1($024DC8, "UnPause") ; db $00
TextStyle1($024DD0, "Give Up") ; db $00
TextStyle1($024DDC, "See Demo") ; db $00
TextStyle1($024DE8, "Quit Demo") ; db $00
TextStyle1($024DF4, "See Again") ; db $00
TextStyle1($024E00, "See More") ; db $00
TextStyle1($024E0C, "Quit Replay") ; db $00
TextStyle1($024E18, "Hoginsu") ; db $00

// Title Screen
TextStyle1($025044, "1 PLAYER ") ; db $00, $00
TextStyle1($025050, "1 CART BATTLE") ; db $00

// Font Swap
TextStyle1($0250CC, "@\+-*/<>  ") ; db $00
TextStyle1($0250D8, "!$%&'()~^=") ; db $00
TextStyle1($0250E4, "0123456789") ; db $00
TextStyle1($0250F0, "uvwxyz,.;:") ; db $00
TextStyle1($0250FC, "klmnopqrst") ; db $00
TextStyle1($025108, "abcdefghij") ; db $00
TextStyle1($025114, "#@\+-*/<>  ") ; db $00
TextStyle1($025120, "#!$%&'()~^=") ; db $00
TextStyle1($02512C, "#0123456789") ; db $00
TextStyle1($025138, "#UVWXYZ,.;:") ; db $00
TextStyle1($025144, "#KLMNOPQRST") ; db $00
TextStyle1($025150, "#ABCDEFGHIJ") ; db $00

// 1 Player
TextStyle1($02530C, "Start New") ; db $00, $00

TextStyle1($025318, "Easy") ; db $00, $00, $00, $00

TextStyle1($025320, "Normal") ; db $00, $00

TextStyle1($025328, "Delete") ; db $00, $00

TextStyle1($025340, "ABCD") ; db $00, $00
TextStyle1($025348, "abcd") ; db $00
//TextStyle1($025350, "HIR") ; db $00
//TextStyle1($025354, "KAT") ; db $00

TextStyle1($02535C, "End") ; db $00
TextStyle1($025364, "Delete") ; db $00

TextStyle1($02536C, "No Save Data") ; db $00
TextStyle1($02537C, "Delete Save Data?") ; db $00

TextStyle1($025398, "Do You Want To Delete?") ; db $00

TextStyle1($0253B0, "Yes") ; db $00
TextStyle1($0253B8, " No") ; db $00

// Practice
TextStyle1($0253C8, "Area1") ; db $00
TextStyle1($0253D0, "Area2") ; db $00
TextStyle1($0253D8, "Area3") ; db $00
TextStyle1($0253E0, "Area4") ; db $00

// Mini-Game
TextStyle1($025458, "Twin-Hopper") ; db $00
TextStyle1($025464, "Spin-Shot") ; db $00
TextStyle1($025470, "Pit-Pat Racer") ; db $00
TextStyle1($025480, "Magne-Magne") ; db $00
TextStyle1($02548C, "Alien-Down") ; db $00
TextStyle1($025498, "Love-Attack") ; db $00
TextStyle1($0254A4, "Quick-Flip") ; db $00
TextStyle1($0254B0, "In The Sky") ; db $00
TextStyle1($0254BC, "Slip And Drop") ; db $00
TextStyle1($0254CC, "Glass-Cut") ; db $00
TextStyle1($0254D8, "Go-Hair") ; db $00
TextStyle1($0254E0, "Smash-Force") ; db $00
TextStyle1($0254EC, "Super-Jumper") ; db $00
TextStyle1($0254FC, "Star-Light Love") ; db $00
TextStyle1($02550C, "Cross-Fire") ; db $00
TextStyle1($025518, "Tutu-Panic") ; db $00
TextStyle1($025524, "Random") ; db $00


// SHIFT-JIS
map ' ',  $8140
map '.',  $8144
map ':',  $8146
map '?',  $8148
map '!',  $8149
map '~',  $8160
map '-',  $817C
map '\s', $818C
map '&',  $8195
map '0',  $824F, 10
map 'A',  $8260, 26
map 'a',  $8281, 26

// 1 Player
TextStyle2($0251BC, "VS. Mode") ; db $00, $00
TextStyle2($0251A0, "GBA LinkCable") ; db $00, $00

TextStyle2($0251F0, "Challenge Mode") ; db $00, $00
TextStyle2($0251D0, "Test Your Skill") ; db $00, $00

TextStyle2($02522C, "Practice Mode") ; db $00, $00
TextStyle2($025210, "Try Out Level") ; db $00, $00

TextStyle2($025264, "Adventure") ; db $00, $00
TextStyle2($025248, "Explore World") ; db $00, $00

TextStyle2($025278, "Easy Short Size") ; db $00, $00
TextStyle2($0252A8, "Normal Size") ; db $00, $00
TextStyle2($025298, "& Begin") ; db $00, $00

TextStyle2($0252C0, "Mini-Games") ; db $00, $00
TextStyle2($0252EC, "Short Courses") ; db $00, $00
TextStyle2($0252D8, "Challenge") ; db $00, $00

// 1 Cart Battle
TextStyle2($025400, "Mini-Games") ; db $00, $00
TextStyle2($025428, "Short Courses") ; db $00, $00
TextStyle2($025418, "Battle") ; db $00, $00

// Intro
TextStyle2($0A7C08, "It's always quiet") ; db $00, $00
TextStyle2($0A7CEC, "Until..") ; db $00, $00
TextStyle2($0A8828, "Show at 6:00 PM") ; db $00, $00
TextStyle2($0A8B94, "Let's see!") ; db $00, $00, $00, $00
TextStyle2($0A9188, "I am late!") ; db $00, $00
TextStyle2($0A97F4, "...Eh?") ; db $00, $00
TextStyle2($0A9948, "Weird~") ; db $00, $00
TextStyle2($0A9AB0, "OK!") ; db $00, $00