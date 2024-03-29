;============
; GBA Keypad
;============
; Keypad Input
KEYINPUT   = $130 ; $4000130: KEYINPUT Key Status (R)(Bit 0..15)
KEY_A      =   $1 ; KEYINPUT: Button A               (Bit 0)
KEY_B      =   $2 ; KEYINPUT: Button B               (Bit 1)
KEY_SELECT =   $4 ; KEYINPUT: Button Select          (Bit 2)
KEY_START  =   $8 ; KEYINPUT: Button Start           (Bit 3)
KEY_RIGHT  =  $10 ; KEYINPUT: D-Pad Right            (Bit 4)
KEY_LEFT   =  $20 ; KEYINPUT: D-Pad Left             (Bit 5)
KEY_UP     =  $40 ; KEYINPUT: D-Pad Up               (Bit 6)
KEY_DOWN   =  $80 ; KEYINPUT: D-Pad Down             (Bit 7)
KEY_R      = $100 ; KEYINPUT: Button R               (Bit 8)
KEY_L      = $200 ; KEYINPUT: Button L               (Bit 9)

KEYCNT = $132 ; $4000132: KEYCNT Key Interrupt Control (R/W)(Bit 0..15)

macro IsKeyDown Key {
  mov r11,IO ; GBA I/O Base Offset
  ldr r12,[r11,KEYINPUT] ; KEYINPUT Key Status
  tst r12,Key ; Test Key Status
}