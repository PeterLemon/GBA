; LCD I/O Registers
DISPCNT       = $4000000 ; $4000000: LCD Control                          (R/W)(Bit 0-15)
MODE_0        =       $0 ; DISPCNT: BG Mode 0                                  (Bit 0-2)
MODE_1        =       $1 ; DISPCNT: BG Mode 1                                  (Bit 0-2)
MODE_2        =       $2 ; DISPCNT: BG Mode 2                                  (Bit 0-2)
MODE_3        =       $3 ; DISPCNT: BG Mode 3                                  (Bit 0-2)
MODE_4        =       $4 ; DISPCNT: BG Mode 4                                  (Bit 0-2)
MODE_5        =       $5 ; DISPCNT: BG Mode 5                                  (Bit 0-2)
MODE_CGB      =       $8 ; DISPCNT: Reserved / CGB Mode                        (Bit 3)
FRAME_SELECT  =      $10 ; DISPCNT: Display Frame Select                       (Bit 4)
OAM_HBLANK    =      $20 ; DISPCNT: H-Blank Interval Free                      (Bit 5)
OBJ_MAP_1D    =      $40 ; DISPCNT: OBJ Character VRAM Mapping One dimensional (Bit 6)
FORCE_BLANK   =      $80 ; DISPCNT: Forced Blank                               (Bit 7)
BG0_ENABLE    =     $100 ; DISPCNT: Screen Display BG0                         (Bit 8)
BG1_ENABLE    =     $200 ; DISPCNT: Screen Display BG1                         (Bit 9)
BG2_ENABLE    =     $400 ; DISPCNT: Screen Display BG2                         (Bit 10)
BG3_ENABLE    =     $800 ; DISPCNT: Screen Display BG3                         (Bit 11)
OBJ_ENABLE    =    $1000 ; DISPCNT: Screen Display OBJ                         (Bit 12)
WIN1_ENABLE   =    $2000 ; DISPCNT: Window 0 Display Flag                      (Bit 13)
WIN2_ENABLE   =    $4000 ; DISPCNT: Window 1 Display Flag                      (Bit 14)
WINOBJ_ENABLE =    $8000 ; DISPCNT: OBJ Window Display Flag                    (Bit 15)

GRN_SWAP = $2 ; $4000002: Undocumented - Green Swap     (R/W)(Bit 0-15)
DISPSTAT = $4 ; $4000004: General LCD Status (STAT,LYC) (R/W)(Bit 0-15)
VCOUNT   = $6 ; $4000006: Vertical Counter   (LY)       (R)  (Bit 0-15)
BG0CNT   = $8 ; $4000008: BG0 Control                   (R/W)(Bit 0-15)
BG1CNT   = $A ; $400000A: BG1 Control                   (R/W)(Bit 0-15)
BG2CNT   = $C ; $400000C: BG2 Control                   (R/W)(Bit 0-15)
BG3CNT   = $E ; $400000E: BG3 Control                   (R/W)(Bit 0-15)

BG0HOFS = $10 ; $4000010: BG0 X-Offset (W)(Bit 0-15)
BG0VOFS = $12 ; $4000012: BG0 Y-Offset (W)(Bit 0-15)
BG1HOFS = $14 ; $4000014: BG1 X-Offset (W)(Bit 0-15)
BG1VOFS = $16 ; $4000016: BG1 Y-Offset (W)(Bit 0-15)
BG2HOFS = $18 ; $4000018: BG2 X-Offset (W)(Bit 0-15)
BG2VOFS = $1A ; $400001A: BG2 Y-Offset (W)(Bit 0-15)
BG3HOFS = $1C ; $400001C: BG3 X-Offset (W)(Bit 0-15)
BG3VOFS = $1E ; $400001E: BG3 Y-Offset (W)(Bit 0-15)

BG2PA = $20 ; $4000020: BG2 Rotation/Scaling Parameter A (dx)  (W)(Bit 0-15)
BG2PB = $22 ; $4000022: BG2 Rotation/Scaling Parameter B (dmx) (W)(Bit 0-15)
BG2PC = $24 ; $4000024: BG2 Rotation/Scaling Parameter C (dy)  (W)(Bit 0-15)
BG2PD = $26 ; $4000026: BG2 Rotation/Scaling Parameter D (dmy) (W)(Bit 0-15)
BG2X  = $28 ; $4000028: BG2 Reference Point X-Coordinate       (W)(Bit 0-31)
BG2Y  = $2C ; $400002C: BG2 Reference Point Y-Coordinate       (W)(Bit 0-31)

BG3PA = $30 ; $4000030: BG3 Rotation/Scaling Parameter A (dx)  (W)(Bit 0-15)
BG3PB = $32 ; $4000032: BG3 Rotation/Scaling Parameter B (dmx) (W)(Bit 0-15)
BG3PC = $34 ; $4000034: BG3 Rotation/Scaling Parameter C (dy)  (W)(Bit 0-15)
BG3PD = $36 ; $4000036: BG3 Rotation/Scaling Parameter D (dmy) (W)(Bit 0-15)
BG3X  = $38 ; $4000038: BG3 Reference Point X-Coordinate       (W)(Bit 0-31)
BG3Y  = $3C ; $400003C: BG3 Reference Point Y-Coordinate       (W)(Bit 0-31)

WIN0H  = $40 ; $4000040: Window 0 Horizontal Dimensions              (W)(Bit 0-15)
WIN1H  = $42 ; $4000042: Window 1 Horizontal Dimensions              (W)(Bit 0-15)
WIN0V  = $44 ; $4000044: Window 0 Vertical Dimensions                (W)(Bit 0-15)
WIN1V  = $46 ; $4000046: Window 1 Vertical Dimensions                (W)(Bit 0-15)
WININ  = $48 ; $4000048: Inside of Window 0 and 1                  (R/W)(Bit 0-15)
WINOUT = $4A ; $400004A: Inside of OBJ Window & Outside of Windows (R/W)(Bit 0-15)

MOSAIC = $4C ; $400004C: Mosaic Size (W)(Bit 0-15)

BLDCNT     =   $50 ; $4000050: Color Special Effects Selection            (R/W)(Bit 0-15)
BG0TARG1ST =    $1 ; BLDCNT: BG0 1st Target Pixel (Background 0)               (Bit 0)
BG1TARG1ST =    $2 ; BLDCNT: BG1 1st Target Pixel (Background 1)               (Bit 1)
BG2TARG1ST =    $4 ; BLDCNT: BG2 1st Target Pixel (Background 2)               (Bit 2)
BG3TARG1ST =    $8 ; BLDCNT: BG3 1st Target Pixel (Background 3)               (Bit 3)
OBJTARG1ST =   $10 ; BLDCNT: OBJ 1st Target Pixel (Top-most OBJ pixel)         (Bit 4)
BDTARG1ST  =   $20 ; BLDCNT: BD  1st Target Pixel (Backdrop)                   (Bit 5)
ALPHA      =   $40 ; BLDCNT: Alpha Blending       (1st+2nd Target mixed)       (Bit 6-7)
BRINCWHITE =   $80 ; BLDCNT: Brightness Increase  (1st Target becomes whiter)  (Bit 6-7)
BRDECBLACK =   $C0 ; BLDCNT: Brightness Decrease  (1st Target becomes blacker) (Bit 6-7)
BG0TARG2ND =  $100 ; BLDCNT: BG0 2nd Target Pixel (Background 0)               (Bit 8)
BG1TARG2ND =  $200 ; BLDCNT: BG1 2nd Target Pixel (Background 1)               (Bit 9)
BG2TARG2ND =  $400 ; BLDCNT: BG2 2nd Target Pixel (Background 2)               (Bit 10)
BG3TARG2ND =  $400 ; BLDCNT: BG3 2nd Target Pixel (Background 3)               (Bit 11)
OBJTARG2ND = $1000 ; BLDCNT: OBJ 2nd Target Pixel (Top-most OBJ pixel)         (Bit 12)
BDTARG2ND  = $2000 ; BLDCNT: BD  2nd Target Pixel (Backdrop)                   (Bit 13)

BLDALPHA = $52 ; $4000052: Alpha Blending Coefficients          (W)(Bit 0-15)
BLDY     = $54 ; $4000054: Brightness (Fade-In/Out) Coefficient (W)(Bit 0-15)

macro VBlank {
  local .VB, .VBL
  mov r11,IO ; GBA I/O Base Offset
  .VB:
    ldrh r12,[r11,VCOUNT] ; Current LCD Scanline Position
    cmp r12,0 ; Compare Scanline 0
    bne .VB
    .VBL:
      ldrh r12,[r11,VCOUNT] ; Current LCD Scanline Position
      cmp r12,160 ; Compare Scanline 160
      bne .VBL
}

macro CLEARVPAL {
  mov r0,$4 ; Stores Reset Flag into r0
  swi $10000 ; Bios: Clear VPAL
}

macro CLEARVRAM {
  mov r0,$8 ; Stores Reset Flag into r0
  swi $10000 ; Bios: Clear VRAM
}

macro CLEAROAM {
  mov r0,$10 ; Stores Reset Flag into r0
  swi $10000 ; Bios: Clear OAM
}

macro DrawMode4Pic Picture, Destination, Palette {
  mov r0,Picture ; LZ77 Compressed Mode 4 Picture
  mov r1,Destination ; Uncompressed Picture Destination
  swi $120000 ; Bios: LZ77 Uncompress Data 16bit
  DMA32 Palette, VPAL, 128 ; DMA Copy BG Palette
}

macro BGOAMBlackFade {
  mov r11,IO ; GBA I/O Base Offset
  mov r12,BRDECBLACK ; Brightness Decrease To Black
  orr r12,OBJTARG1ST ; OBJ 1st Target Pixel
  orr r12,BG2TARG1ST ; BG2 1st Target Pixel
  strh r12,[r11,BLDCNT] ; Set Blending Control
}

macro BGOAMWhiteFade {
  mov r11,IO ; GBA I/O Base Offset
  mov r12,BRINCWHITE ; Brightness Increase To White
  orr r12,OBJTARG1ST ; OBJ 1st Target Pixel
  orr r12,BG2TARG1ST ; BG2 1st Target Pixel
  strh r12,[r11,BLDCNT] ; Set Blending Control
}

macro OAMAlpha {
  mov r11,IO ; GBA I/O Base Offset
  adr r12,OBJTARG1ST or BG2TARG2ND ; Load r12 with values BG2 1st Target Pixel (2) and Alpah Blending (6-7)
  strh r12,[r11,BLDCNT] ; Set Blending Control
}

macro FadeIn Time {
  local .Loop
  mov r9,IO ; GBA I/O Base Offset
  mov r10,16 ; Blend 16/16 Black
  .Loop:
    TimerWait TM1CNT, Time
    subs r10,1 ; Blend Black Decreased
    strb r10,[r9,BLDY] ; Set Brightness Control
    bne .Loop
}

macro FadeOut Time {
  local .Loop
  mov r9,IO ; GBA I/O Base Offset
  mov r10,0 ; Blend 0/16 Black
  .Loop:
    TimerWait TM1CNT, Time
    add r10,1 ; Blend Black Increased
    strb r10,[r9,BLDY] ; Set Brightness Control
    cmp r10,16 ; Compare Blend Full Black
    bne .Loop
}

macro TextDecompress Text {
  mov r0,Text ; LZ77 Compressed Text
  mov r1,OAM  ; Uncompressed Text Destination
  swi $120000 ; Bios: LZ77 Uncompress Data 16bit
}