;============
; GBA Object
;============
; OBJ/Sprite
ROTATION_FLAG    =  $100 ; OAM OBJ Attribute 0 - OBJ Rotation/Scaling Flag (Bit 8)
SIZE_DOUBLE      =  $200 ; OAM OBJ Attribute 0 - OBJ Double-Size Flag      (Bit 9)
OBJ_DISABLE      =  $200 ; OAM OBJ Attribute 0 - OBJ Disable Flag          (Bit 9)
MODE_NORMAL      =    $0 ; OAM OBJ Attribute 0 - OBJ Mode Normal           (Bit 10..11)
MODE_TRANSPARENT =  $400 ; OAM OBJ Attribute 0 - OBJ Mode Semi-Transparent (Bit 10..11)
MODE_WINDOWED    =  $800 ; OAM OBJ Attribute 0 - OBJ Mode Windowed         (Bit 10..11)
OBJ_MOSAIC       = $1000 ; OAM OBJ Attribute 0 - OBJ Mosaic Enable Flag    (Bit 12)
COLOR_16         =    $0 ; OAM OBJ Attribute 0 -  16 Colors/16 Palettes    (Bit 13)
COLOR_256        = $2000 ; OAM OBJ Attribute 0 - 256 Colors/ 1 Palette     (Bit 13)
SQUARE           =    $0 ; OAM OBJ Attribute 0 - OBJ Shape Square          (Bit 14..15)
TALL             = $8000 ; OAM OBJ Attribute 0 - OBJ Shape Tall            (Bit 14..15)
WIDE             = $4000 ; OAM OBJ Attribute 0 - OBJ Shape Wide            (Bit 14..15)

ROTATION_0       =    $0 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  0 (Bit 9..13)
ROTATION_1       =  $200 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  1 (Bit 9..13)
ROTATION_2       =  $400 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  2 (Bit 9..13)
ROTATION_3       =  $600 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  3 (Bit 9..13)
ROTATION_4       =  $800 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  4 (Bit 9..13)
ROTATION_5       =  $A00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  5 (Bit 9..13)
ROTATION_6       =  $C00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  6 (Bit 9..13)
ROTATION_7       =  $E00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  7 (Bit 9..13)
ROTATION_8       = $1000 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  8 (Bit 9..13)
ROTATION_9       = $1200 ; OAM OBJ Attribute 1 - Rotation/Scaling Table  9 (Bit 9..13)
ROTATION_10      = $1400 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 10 (Bit 9..13)
ROTATION_11      = $1600 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 11 (Bit 9..13)
ROTATION_12      = $1800 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 12 (Bit 9..13)
ROTATION_13      = $1A00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 13 (Bit 9..13)
ROTATION_14      = $1C00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 14 (Bit 9..13)
ROTATION_15      = $1E00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 15 (Bit 9..13)
ROTATION_16      = $2000 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 16 (Bit 9..13)
ROTATION_17      = $2200 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 17 (Bit 9..13)
ROTATION_18      = $2400 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 18 (Bit 9..13)
ROTATION_19      = $2600 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 19 (Bit 9..13)
ROTATION_20      = $2800 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 20 (Bit 9..13)
ROTATION_21      = $2A00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 21 (Bit 9..13)
ROTATION_22      = $2C00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 22 (Bit 9..13)
ROTATION_23      = $2E00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 23 (Bit 9..13)
ROTATION_24      = $3000 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 24 (Bit 9..13)
ROTATION_25      = $3200 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 25 (Bit 9..13)
ROTATION_26      = $3400 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 26 (Bit 9..13)
ROTATION_27      = $3600 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 27 (Bit 9..13)
ROTATION_28      = $3800 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 28 (Bit 9..13)
ROTATION_29      = $3A00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 29 (Bit 9..13)
ROTATION_30      = $3C00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 30 (Bit 9..13)
ROTATION_31      = $3E00 ; OAM OBJ Attribute 1 - Rotation/Scaling Table 31 (Bit 9..13)
HORIZONTAL_FLIP  = $1000 ; OAM OBJ Attribute 1 - Horizontal Flip           (Bit 12)
VERTICAL_FLIP    = $2000 ; OAM OBJ Attribute 1 - Vertical Flip             (Bit 13)
SIZE_8           =    $0 ; OAM OBJ Attribute 1 - OBJ Size 8                (Bit 14..15)
SIZE_16          = $4000 ; OAM OBJ Attribute 1 - OBJ Size 16               (Bit 14..15)
SIZE_32          = $8000 ; OAM OBJ Attribute 1 - OBJ Size 32               (Bit 14..15)
SIZE_64          = $C000 ; OAM OBJ Attribute 1 - OBJ Size 64               (Bit 14..15)

OBJ_PRIORITY_0   =    $0 ; OAM OBJ Attribute 2 - Priority Relative To BG 0 (Bit 10..11)
OBJ_PRIORITY_1   =  $400 ; OAM OBJ Attribute 2 - Priority Relative To BG 1 (Bit 10..11)
OBJ_PRIORITY_2   =  $800 ; OAM OBJ Attribute 2 - Priority Relative To BG 2 (Bit 10..11)
PALETTE_0        =    $0 ; OAM OBJ Attribute 2 - Palette Number 0          (Bit 12..15)
PALETTE_1        = $1000 ; OAM OBJ Attribute 2 - Palette Number 1          (Bit 12..15)
PALETTE_2        = $2000 ; OAM OBJ Attribute 2 - Palette Number 2          (Bit 12..15)
PALETTE_3        = $3000 ; OAM OBJ Attribute 2 - Palette Number 3          (Bit 12..15)
PALETTE_4        = $4000 ; OAM OBJ Attribute 2 - Palette Number 4          (Bit 12..15)
PALETTE_5        = $5000 ; OAM OBJ Attribute 2 - Palette Number 5          (Bit 12..15)
PALETTE_6        = $6000 ; OAM OBJ Attribute 2 - Palette Number 6          (Bit 12..15)
PALETTE_7        = $7000 ; OAM OBJ Attribute 2 - Palette Number 7          (Bit 12..15)
PALETTE_8        = $8000 ; OAM OBJ Attribute 2 - Palette Number 8          (Bit 12..15)
PALETTE_9        = $9000 ; OAM OBJ Attribute 2 - Palette Number 9          (Bit 12..15)
PALETTE_10       = $A000 ; OAM OBJ Attribute 2 - Palette Number 10         (Bit 12..15)
PALETTE_11       = $B000 ; OAM OBJ Attribute 2 - Palette Number 11         (Bit 12..15)
PALETTE_12       = $C000 ; OAM OBJ Attribute 2 - Palette Number 12         (Bit 12..15)
PALETTE_13       = $D000 ; OAM OBJ Attribute 2 - Palette Number 13         (Bit 12..15)
PALETTE_14       = $E000 ; OAM OBJ Attribute 2 - Palette Number 14         (Bit 12..15)
PALETTE_15       = $F000 ; OAM OBJ Attribute 2 - Palette Number 15         (Bit 12..15)

macro InitOBJ {
  mov r10,OAM
  mov r11,128
  mov r12,300 * 65536
  .Loop:
    str r12,[r10],8
    subs r11,1
    bne .Loop
}

macro MoveOBJ OBJ, X, Y {
  imm32 r12,OAM + (OBJ * 8) ; Load Sprite OAM Attribute Offset
  ldrh r11,[r12,2] ; Load Attribute 0
  ldrh r10,[r12]   ; Load Attributes 0&1
  and r11,$FF00 ; Clear X
  and r10,$FF00 ; Clear Y
  orr r11,X	; Set X
  orr r10,Y	; Set Y
  orr r10,r11,lsl 16 ; Add Together
  str r10,[r12] ; Store OAM
}

PA_0 = $7000006 ; Defines For Rotation Data
PB_0 = $700000E
PC_0 = $7000015
PD_0 = $700001C

PA_1 = $7000026
PB_1 = $700002E
PC_1 = $7000036
PD_1 = $700003E

PA_2 = $7000046
PB_2 = $700004E
PC_2 = $7000055
PD_2 = $700005C

PA_3 = $7000066
PB_3 = $700006E
PC_3 = $7000076
PD_3 = $700007E

PA_4 = $7000086
PB_4 = $700008E
PC_4 = $7000095
PD_4 = $700009C

PA_5 = $70000A6
PB_5 = $70000AE
PC_5 = $70000B6
PD_5 = $70000BE

PA_6 = $70000C6
PB_6 = $70000CE
PC_6 = $70000D5
PD_6 = $70000DC

PA_7 = $70000E6
PB_7 = $70000EE
PC_7 = $70000F6
PD_7 = $70000FE

PA_8 = $7000106
PB_8 = $700010E
PC_8 = $7000115
PD_8 = $700011C

PA_9 = $7000126
PB_9 = $700012E
PC_9 = $7000136
PD_9 = $700013E

PA_10 = $7000146
PB_10 = $700014E
PC_10 = $7000155
PD_10 = $700015C

PA_11 = $7000166
PB_11 = $700016E
PC_11 = $7000176
PD_11 = $700017E

PA_12 = $7000186
PB_12 = $700018E
PC_12 = $7000195
PD_12 = $700019C

PA_13 = $70001A6
PB_13 = $70001AE
PC_13 = $70001B6
PD_13 = $70001BE

PA_14 = $70001C6
PB_14 = $70001CE
PC_14 = $70001D5
PD_14 = $70001DC

PA_15 = $70001E6
PB_15 = $70001EE
PC_15 = $70001F6
PD_15 = $70001FE

PA_16 = $7000206
PB_16 = $700020E
PC_16 = $7000215
PD_16 = $700021C

PA_17 = $7000226
PB_17 = $700022E
PC_17 = $7000236
PD_17 = $700023E

PA_18 = $7000246
PB_18 = $700024E
PC_18 = $7000255
PD_18 = $700025C

PA_19 = $7000266
PB_19 = $700026E
PC_19 = $7000266
PD_19 = $700026E