; Game Boy Advance 'Bare Metal' Cylinder Mapping Demo by krom (Peter Lemon):
format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

copycode:
  adr r1,startcode
  mov r2,IWRAM
  imm32 r3,endcopy
  clp:
    ldr r0,[r1],4
    str r0,[r2],4
    cmp r2,r3
    bmi clp
  imm32 r2,start
  bx r2
startcode:
  org IWRAM

WIDTH  = 240 ; Pixel  Width For Screen & Texture
HEIGHT = 160 ; Pixel Height For Screen & Texture

start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

  imm32 r0,CylinderMap ; R0 = Cylinder Map
  mov r1,0 ; R1 = X Offset

Loop:
  imm32 r2,BG ; R2 = BG
  mov r3,VRAM ; R3 = VRAM

  mov r5,0 ; R5 = Y
  CylinderY:
    mov r4,0 ; R4 = X
    CylinderX:
      ldrb r6,[r0,r4] ; R6 = Cylinder Map X

      add r7,r6,r1 ; R7 = Cylinder Map X + X Offset
      cmp r7,WIDTH ; IF (R7 >= WIDTH)
      subge r7,WIDTH ; R7 -= WIDTH
      lsl r7,1 ; R7 *= BPP
      ldrh r8,[r2,r7] ; R8 = Scanline Cyclinder Map Pixel
      strh r8,[r3],2  ; Store Pixel To VRAM

      add r4,1 ; Increment X
      cmp r4,WIDTH  ; IF (X < WIDTH)
      blt CylinderX ; GOTO CylinderX

    add r2,WIDTH*2 ; Increment BG
    add r5,1 ; Increment Y
    cmp r5,HEIGHT ; IF (Y < HEIGHT)
    blt CylinderY ; GOTO CylinderY


  add r1,1 ; Increment X Offset
  cmp r1,WIDTH	 ; IF (X Offset >= WIDTH)
  subge r1,WIDTH ; X Offset -= WIDTH

  b Loop

CylinderMap: ; 240 Bytes (Repeat For 160 Scanlines)
  db 0
  db 10
  db 14
  db 17
  db 20
  db 22
  db 24
  db 26
  db 28
  db 30
  db 31
  db 33
  db 34
  db 36
  db 37
  db 39
  db 40
  db 41
  db 42
  db 44
  db 45
  db 46
  db 47
  db 48
  db 49
  db 50
  db 51
  db 52
  db 53
  db 54
  db 55
  db 56
  db 57
  db 58
  db 59
  db 60
  db 61
  db 62
  db 63
  db 63
  db 64
  db 65
  db 66
  db 67
  db 68
  db 68
  db 69
  db 70
  db 71
  db 72
  db 72
  db 73
  db 74
  db 75
  db 76
  db 76
  db 77
  db 78
  db 79
  db 79
  db 80
  db 81
  db 81
  db 82
  db 83
  db 84
  db 84
  db 85
  db 86
  db 86
  db 87
  db 88
  db 89
  db 89
  db 90
  db 91
  db 91
  db 92
  db 93
  db 93
  db 94
  db 95
  db 95
  db 96
  db 97
  db 97
  db 98
  db 99
  db 99
  db 100
  db 101
  db 101
  db 102
  db 103
  db 103
  db 104
  db 105
  db 105
  db 106
  db 107
  db 107
  db 108
  db 108
  db 109
  db 110
  db 110
  db 111
  db 112
  db 112
  db 113
  db 114
  db 114
  db 115
  db 116
  db 116
  db 117
  db 117
  db 118
  db 119
  db 119
  db 120
  db 121
  db 121
  db 122
  db 123
  db 123
  db 124
  db 124
  db 125
  db 126
  db 126
  db 127
  db 128
  db 128
  db 129
  db 130
  db 130
  db 131
  db 132
  db 132
  db 133
  db 133
  db 134
  db 135
  db 135
  db 136
  db 137
  db 137
  db 138
  db 139
  db 139
  db 140
  db 141
  db 141
  db 142
  db 143
  db 143
  db 144
  db 145
  db 145
  db 146
  db 147
  db 147
  db 148
  db 149
  db 149
  db 150
  db 151
  db 151
  db 152
  db 153
  db 154
  db 154
  db 155
  db 156
  db 156
  db 157
  db 158
  db 159
  db 159
  db 160
  db 161
  db 161
  db 162
  db 163
  db 164
  db 164
  db 165
  db 166
  db 167
  db 168
  db 168
  db 169
  db 170
  db 171
  db 172
  db 172
  db 173
  db 174
  db 175
  db 176
  db 177
  db 177
  db 178
  db 179
  db 180
  db 181
  db 182
  db 183
  db 184
  db 185
  db 186
  db 187
  db 188
  db 189
  db 190
  db 191
  db 192
  db 193
  db 194
  db 195
  db 196
  db 198
  db 199
  db 200
  db 201
  db 203
  db 204
  db 206
  db 207
  db 209
  db 210
  db 212
  db 214
  db 216
  db 218
  db 220
  db 223
  db 226
  db 230

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
BG: file 'BG.img' ; Include BG Image Data (76800 Bytes)