;===========
; GBA Sound
;===========
; Sound Registers
SOUND1CNT_L = $60 ; $4000060: Channel 1 Sweep register       (NR10)       (R/W)(Bit 0..15)
SOUND1CNT_H = $62 ; $4000062: Channel 1 Duty/Length/Envelope (Nr12, NR12) (R/W)(Bit 0..15)
SOUND1CNT_X = $64 ; $4000064: Channel 1 Frequency/Control    (NR13, NR14) (R/W)(Bit 0..15)
SOUND2CNT_L = $68 ; $4000068: Channel 2 Duty/Length/Envelope (NR21, NR22) (R/W)(Bit 0..15)
SOUND2CNT_H = $6C ; $400006C: Channel 2 Frequency/Control    (NR23, NR24) (R/W)(Bit 0..15)
SOUND3CNT_L = $70 ; $4000070: Channel 3 Stop/Wave RAM select (NR30)       (R/W)(Bit 0..15)
SOUND3CNT_H = $72 ; $4000072: Channel 3 Length/Volume        (NR31, NR32) (R/W)(Bit 0..15)
SOUND3CNT_X = $74 ; $4000074: Channel 3 Frequency/Control    (NR33, NR34) (R/W)(Bit 0..15)
SOUND4CNT_L = $78 ; $4000078: Channel 4 Length/Envelope      (NR41, NR42) (R/W)(Bit 0..15)
SOUND4CNT_H = $7C ; $400007C: Channel 4 Frequency/Control    (NR43, NR44) (R/W)(Bit 0..15)

SOUNDCNT_L   =   $80 ; $4000080: Control Stereo/Volume/Enable (NR50, NR51) (R/W)(Bit 0..15)
SOUNDR_VOL_1 =    $1 ; SOUNDCNT_L: Sound # 1-4 Master Volume RIGHT 1            (Bit 0..2)
SOUNDR_VOL_2 =    $2 ; SOUNDCNT_L: Sound # 1-4 Master Volume RIGHT 2            (Bit 0..2)
SOUNDR_VOL_3 =    $3 ; SOUNDCNT_L: Sound # 1-4 Master Volume RIGHT 3            (Bit 0..2)
SOUNDR_VOL_4 =    $4 ; SOUNDCNT_L: Sound # 1-4 Master Volume RIGHT 4            (Bit 0..2)
SOUNDR_VOL_5 =    $5 ; SOUNDCNT_L: Sound # 1-4 Master Volume RIGHT 5            (Bit 0..2)
SOUNDR_VOL_6 =    $6 ; SOUNDCNT_L: Sound # 1-4 Master Volume RIGHT 6            (Bit 0..2)
SOUNDR_VOL_7 =    $7 ; SOUNDCNT_L: Sound # 1-4 Master Volume RIGHT 7 (100%)     (Bit 0..2)
SOUNDL_VOL_1 =   $10 ; SOUNDCNT_L: Sound # 1-4 Master Volume LEFT  1            (Bit 4..6)
SOUNDL_VOL_2 =   $20 ; SOUNDCNT_L: Sound # 1-4 Master Volume LEFT  2            (Bit 4..6)
SOUNDL_VOL_3 =   $30 ; SOUNDCNT_L: Sound # 1-4 Master Volume LEFT  3            (Bit 4..6)
SOUNDL_VOL_4 =   $40 ; SOUNDCNT_L: Sound # 1-4 Master Volume LEFT  4            (Bit 4..6)
SOUNDL_VOL_5 =   $50 ; SOUNDCNT_L: Sound # 1-4 Master Volume LEFT  5            (Bit 4..6)
SOUNDL_VOL_6 =   $60 ; SOUNDCNT_L: Sound # 1-4 Master Volume LEFT  6            (Bit 4..6)
SOUNDL_VOL_7 =   $70 ; SOUNDCNT_L: Sound # 1-4 Master Volume LEFT  7 (100%)     (Bit 4..6)
SOUND1_RIGHT =  $100 ; SOUNDCNT_L: Sound # 1   Enable Flag   RIGHT              (Bit 8..11)
SOUND2_RIGHT =  $200 ; SOUNDCNT_L: Sound # 2   Enable Flag   RIGHT              (Bit 8..11)
SOUND3_RIGHT =  $400 ; SOUNDCNT_L: Sound # 3   Enable Flag   RIGHT              (Bit 8..11)
SOUND4_RIGHT =  $800 ; SOUNDCNT_L: Sound # 4   Enable Flag   RIGHT              (Bit 8..11)
SOUND1_LEFT  = $1000 ; SOUNDCNT_L: Sound # 1   Enable Flag   LEFT               (Bit 12..15)
SOUND2_LEFT  = $2000 ; SOUNDCNT_L: Sound # 2   Enable Flag   LEFT               (Bit 12..15)
SOUND3_LEFT  = $4000 ; SOUNDCNT_L: Sound # 3   Enable Flag   LEFT               (Bit 12..15)
SOUND4_LEFT  = $8000 ; SOUNDCNT_L: Sound # 4   Enable Flag   LEFT               (Bit 12..15)

SOUNDCNT_H        =   $82 ; $4000082: Control Mixing/DMA Control (R/W)(Bit 0..15)
SOUND_VOL_50      =    $1 ; SOUNDCNT_L: Sound # 1-4 Volume  50%       (Bit 0..1)
SOUND_VOL_100     =    $2 ; SOUNDCNT_L: Sound # 1-4 Volume 100%       (Bit 0..1)
SOUNDA_VOL_100    =    $4 ; SOUNDCNT_L: DMA Sound A Volume 100%       (Bit 2)
SOUNDB_VOL_100    =    $8 ; SOUNDCNT_L: DMA Sound B Volume 100%       (Bit 3)
SOUNDA_RIGHT      =  $100 ; SOUNDCNT_L: DMA Sound A Enable RIGHT      (Bit 8)
SOUNDA_LEFT       =  $200 ; SOUNDCNT_L: DMA Sound A Enable LEFT       (Bit 9)
SOUNDA_TM1        =  $400 ; SOUNDCNT_L: DMA Sound A Timer1 Select     (Bit 10)
SOUNDA_FIFO_RESET =  $800 ; SOUNDCNT_L: DMA Sound A Reset  FIFO       (Bit 11)
SOUNDB_RIGHT      = $1000 ; SOUNDCNT_L: DMA Sound B Enable RIGHT      (Bit 12)
SOUNDB_LEFT       = $2000 ; SOUNDCNT_L: DMA Sound B Enable LEFT       (Bit 13)
SOUNDB_TM1        = $4000 ; SOUNDCNT_L: DMA Sound B Timer1 Select     (Bit 14)
SOUNDB_FIFO_RESET = $8000 ; SOUNDCNT_L: DMA Sound B Reset  FIFO       (Bit 15)

SOUNDCNT_X   = $84 ; $4000084: Control Sound On/Off (NR52) (R/W)(Bit 0..8)
SOUND1       =  $1 ; SOUNDCNT_X: Sound 1 ON Flag           (R)  (Bit 0)
SOUND2       =  $2 ; SOUNDCNT_X: Sound 2 ON Flag           (R)  (Bit 1)
SOUND3       =  $4 ; SOUNDCNT_X: Sound 3 ON Flag           (R)  (Bit 2)
SOUND4       =  $8 ; SOUNDCNT_X: Sound 4 ON Flag           (R)  (Bit 3)
SOUND_ENABLE = $80 ; SOUNDCNT_X: PSG/FIFO Master Enable         (Bit 7)

SOUNDBIAS =   $88 ; $4000088: Sound PWM Control                               (BIOS) (Bit  0..15)
SAMPLE8   = $2000 ; SOUNDBIAS: Amplitude Resolution/Sampling Cycle 1 8bit/65.536kHz  (Bit 14..15)
SAMPLE7   = $4000 ; SOUNDBIAS: Amplitude Resolution/Sampling Cycle 2 7bit/131.072kHz (Bit 14..15)
SAMPLE6   = $8000 ; SOUNDBIAS: Amplitude Resolution/Sampling Cycle 3 6bit/262.144kHz (Bit 14..15)

WAVE_RAM = $90 ; $4000090: Channel 3 Wave Pattern RAM (2 Banks) (R/W)(2x16 Bytes)
FIFO_A   = $A0 ; $40000A0: Channel A FIFO, Data 0-3               (W)(Bit 0..31)
FIFO_B   = $A4 ; $40000A4: Channel B FIFO, Data 0-3               (W)(Bit 0..31)

macro PlaySoundA Source, Frequency {
  mov r11,IO ; GBA I/O Base Offset
  imm32 r12,Source
  str r12,[r11,DMA1SAD] ; Sound A Sample Source To DMA1 Source Address
  imm16 r12,SOUNDA_FIFO_RESET or SOUNDA_LEFT or SOUNDA_RIGHT or SOUNDA_VOL_100
  strh r12,[r11,SOUNDCNT_H] ; Sound A FIFO Reset, Sound A Timer 0, Right & Left Enable, 100% Volume
  mov r12,SOUND_ENABLE
  strb r12,[r11,SOUNDCNT_X] ; PSG/FIFO Master Enable
  orr r12,r11,FIFO_A
  str r12,[r11,DMA1DAD] ; Sound A FIFO To DMA1 Destination Address
  imm32 r12,DMA_ENABLE or DMA_32 or DMA_SPECIAL or DMA_REPEAT or DMA_DST_FIXED
  str r12,[r11,DMA1CNT] ; DMA1 Control
  mov r12,TM_ENABLE ; Timer 0 Enable, Sound Frequency
  orr r12,(65536 - (16777216 / Frequency)) and $FF
  orr r12,(65536 - (16777216 / Frequency)) and $FF00
  str r12,[r11,TM0CNT] ; Play Sound A
}

macro PlaySoundB Source, Frequency {
  mov r11,IO ; GBA I/O Base Offset
  imm32 r12,Source
  str r12,[r11,DMA2SAD] ; Sound B Sample Source To DMA2 Source Address
  imm16 r12,SOUNDB_FIFO_RESET or SOUNDB_TM1 or SOUNDB_LEFT or SOUNDB_RIGHT or SOUNDB_VOL_100 or SOUNDA_LEFT or SOUNDA_RIGHT or SOUNDA_VOL_100
  strh r12,[r11,SOUNDCNT_H] ; Sound B FIFO Reset, Sound B Timer 1, Right & Left Enable, 100% Volume
  mov r12,SOUND_ENABLE
  strb r12,[r11,SOUNDCNT_X] ; PSG/FIFO Master Enable
  orr r12,r11,FIFO_B
  str r12,[r11,DMA2DAD] ; Sound B FIFO To DMA2 Destination Address
  imm32 r12,DMA_ENABLE or DMA_32 or DMA_SPECIAL or DMA_REPEAT or DMA_DST_FIXED
  str r12,[r11,DMA2CNT] ; DMA2 Control
  mov r12,TM_ENABLE ; Timer 1 Enable, Sound Frequency
  orr r12,(65536 - (16777216 / Frequency)) and $FF
  orr r12,(65536 - (16777216 / Frequency)) and $FF00
  str r12,[r11,TM1CNT] ; Play Sound B
}

macro PlaySoundAB SourceA, SourceB, Frequency {
  mov r11,IO ; GBA I/O Base Offset
  imm32 r12,SourceA
  str r12,[r11,DMA1SAD] ; Sound A Sample Source To DMA1 Source Address
  imm32 r12,SourceB
  str r12,[r11,DMA2SAD] ; Sound B Sample Source To DMA2 Source Address
  imm16 r12,SOUNDB_FIFO_RESET or SOUNDA_FIFO_RESET or SOUNDB_TM1 or SOUNDB_RIGHT or SOUNDA_LEFT or SOUNDB_VOL_100 or SOUNDA_VOL_100
  strh r12,[r11,SOUNDCNT_H] ; Sound A/B FIFO Reset, Sound B Timer 1, Sound A Timer 0, Right & Left Enable, 100% Volume
  mov r12,SOUND_ENABLE
  strb r12,[r11,SOUNDCNT_X] ; PSG/FIFO Master Enable
  orr r12,r11,FIFO_A
  str r12,[r11,DMA1DAD] ; Sound A FIFO To DMA1 Destination Address
  orr r12,r11,FIFO_B
  str r12,[r11,DMA2DAD] ; Sound B FIFO To DMA2 Destination Address
  imm32 r12,DMA_ENABLE or DMA_32 or DMA_SPECIAL or DMA_REPEAT or DMA_DST_FIXED
  str r12,[r11,DMA1CNT] ; DMA1 Control
  str r12,[r11,DMA2CNT] ; DMA2 Control
  mov r12,TM_ENABLE ; Timer 0/1 Enable, Sound Frequency
  orr r12,(65536 - (16777216 / Frequency)) and $FF
  orr r12,(65536 - (16777216 / Frequency)) and $FF00
  str r12,[r11,TM0CNT] ; Play Sound A
  str r12,[r11,TM1CNT] ; Play Sound B
}

macro PlayLZSoundA Source, Destination, Frequency {
  imm32 r0,Source ; LZ77 Compressed Sound Sample Source
  imm32 r1,Destination ; Uncompressed Sound Sample Destination
  swi $110000 ; Bios: LZ77 Uncompress Data 32-Bit
  mov r11,IO ; GBA I/O Base Offset
  imm32 r12,Destination
  str r12,[r11,DMA1SAD] ; Sound A Sample Source To DMA1 Source Address
  imm16 r12,SOUNDA_FIFO_RESET or SOUNDA_LEFT or SOUNDA_RIGHT or SOUNDA_VOL_100
  strh r12,[r11,SOUNDCNT_H] ; Sound A FIFO Reset, Sound A Timer 0, Right & Left Enable, 100% Volume
  mov r12,SOUND_ENABLE
  strb r12,[r11,SOUNDCNT_X] ; PSG/FIFO Master Enable
  orr r12,r11,FIFO_A
  str r12,[r11,DMA1DAD] ; Sound A FIFO To DMA1 Destination Address
  imm32 r12,DMA_ENABLE or DMA_32 or DMA_TIMING_SPECIAL or DMA_REPEAT or DMA_DEST_FIXED
  str r12,[r11,DMA1CNT] ; DMA1 Control
  mov r12,TM_ENABLE * 65536 ; Timer 0 Enable, Sound Frequency
  orr r12,(65536 - (16777216 / Frequency)) and $FF
  orr r12,(65536 - (16777216 / Frequency)) and $FF00
  str r12,[r11,TM0CNT] ; Play Sound A
}

macro PlayLZSoundB Source, Destination, Frequency {
  imm32 r0,Source ; LZ77 Compressed Sound Sample Source
  imm32 r1,Destination ; Uncompressed Sound Sample Destination
  swi $110000 ; Bios: LZ77 Uncompress Data 32-Bit
  mov r11,IO ; GBA I/O Base Offset
  imm32 r12,Destination
  str r12,[r11,DMA2SAD] ; Sound B Sample Source To DMA2 Source Address
  imm16 r12,SOUNDB_FIFO_RESET or SOUNDB_TM1 or SOUNDB_LEFT or SOUNDB_RIGHT or SOUNDB_VOL_100 or SOUNDA_LEFT or SOUNDA_RIGHT or SOUNDA_VOL_100
  strh r12,[r11,SOUNDCNT_H] ; Sound B FIFO Reset, Sound B Timer 1, Right & Left Enable, 100% Volume
  mov r12,SOUND_ENABLE
  strb r12,[r11,SOUNDCNT_X] ; PSG/FIFO Master Enable
  orr r12,r11,FIFO_B
  str r12,[r11,DMA2DAD] ; Sound B FIFO To DMA2 Destination Address
  imm32 r12,DMA_ENABLE or DMA_32 or DMA_TIMING_SPECIAL or DMA_REPEAT or DMA_DEST_FIXED
  str r12,[r11,DMA2CNT] ; DMA2 Control
  mov r12,TM_ENABLE * 65536 ; Timer 1 Enable, Sound Frequency
  orr r12,(65536 - (16777216 / Frequency)) and $FF
  orr r12,(65536 - (16777216 / Frequency)) and $FF00
  str r12,[r11,TM1CNT] ; Play Sound B
}

macro StopSoundA {
  mov r11,IO ; GBA I/O Base Offset
  mov r12,DMA_DISABLE
  str r12,[r11,DMA1CNT] ; Stop Sound A
}

macro StopSoundB {
  mov r11,IO ; GBA I/O Base Offset
  mov r12,DMA_DISABLE
  str r12,[r11,DMA2CNT] ; Stop Sound B
}

macro StopSoundAB {
  mov r11,IO ; GBA I/O Base Offset
  mov r12,DMA_DISABLE
  str r12,[r11,DMA1CNT] ; Stop Sound A
  str r12,[r11,DMA2CNT] ; Stop Sound B
}