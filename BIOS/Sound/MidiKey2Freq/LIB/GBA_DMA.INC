;=========
; GBA DMA
;=========
; DMA Transfer Channels
DMA0SAD = $B0 ; $40000B0: DMA 0 Source Address         (W)(Bit 0..31)
DMA0DAD = $B4 ; $40000B4: DMA 0 Destination Address    (W)(Bit 0..31)
DMA0CNT = $B8 ; $40000B8: DMA 0 Word Count & Control (R/W)(Bit 0..31)
DMA1SAD = $BC ; $40000BC: DMA 1 Source Address         (W)(Bit 0..31)
DMA1DAD = $C0 ; $40000C0: DMA 1 Destination Address    (W)(Bit 0..31)
DMA1CNT = $C4 ; $40000C4: DMA 1 Word Count & Control (R/W)(Bit 0..31)
DMA2SAD = $C8 ; $40000C8: DMA 2 Source Address         (W)(Bit 0..31)
DMA2DAD = $CC ; $40000CC: DMA 2 Destination Address    (W)(Bit 0..31)
DMA2CNT = $D0 ; $40000D0: DMA 2 Word Count & Control (R/W)(Bit 0..31)
DMA3SAD = $D4 ; $40000D4: DMA 3 Source Address         (W)(Bit 0..31)
DMA3DAD = $D8 ; $40000D8: DMA 3 Destination Address    (W)(Bit 0..31)
DMA3CNT = $DC ; $40000DC: DMA 3 Word Count & Control (R/W)(Bit 0..31)

DMA_DST_DEC   =   $200000 ; DMAXCNT: DMA Dest   Addr Control Decrement        (Bit 5..6)
DMA_DST_FIXED =   $400000 ; DMAXCNT: DMA Dest   Addr Control Fixed            (Bit 5..6)
DMA_DST_INCRE =   $600000 ; DMAXCNT: DMA Dest   Addr Control Increment/Reload (Bit 5..6)
DMA_SRC_DEC   =   $800000 ; DMAXCNT: DMA Source Addr Control Decrement        (Bit 7..8)
DMA_SRC_FIXED =  $1000000 ; DMAXCNT: DMA Source Addr Control Fixed            (Bit 7..8)
DMA_SRC_INCRE =  $1800000 ; DMAXCNT: DMA Source Addr Control Increment/Reload (Bit 7..8)
DMA_REPEAT    =  $2000000 ; DMAXCNT: DMA Repeat (Must Be Zero IF Bit 11 Set)  (Bit 9)
DMA_32        =  $4000000 ; DMAXCNT: DMA Transfer Type 32-Bit                 (Bit 10)
DMA3_DRQ      =  $8000000 ; DMAXCNT: Game Pak DRQ (DMA3 only)                 (Bit 11)
DMA_VBLANK    = $10000000 ; DMAXCNT: DMA Start Timing VBlank                  (Bit 12..13)
DMA_HBLANK    = $20000000 ; DMAXCNT: DMA Start Timing HBlank                  (Bit 12..13)
DMA_SPECIAL   = $30000000 ; DMAXCNT: DMA Start Timing Special                 (Bit 12..13)
DMA_IRQ       = $40000000 ; DMAXCNT: IRQ On End Of Word Count                 (Bit 14)
DMA_ENABLE    = $80000000 ; DMAXCNT: DMA Enable                               (Bit 15)
DMA_DISABLE   =        $0 ; DMAXCNT: DMA Disable                              (Bit 15)

macro DMA32 Source, Destination, Amount {
  mov r11,IO ; GBA I/O Base Offset
  imm32 r12,Source ; DMA Source
  str r12,[r11,DMA3SAD] ; Set DMA3 Source Address
  imm32 r12,Destination ; DMA Destination
  str r12,[r11,DMA3DAD] ; Set DMA3 Destination Address
  imm32 r12,DMA_ENABLE+DMA_32+Amount
  str r12,[r11,DMA3CNT] ; DMA Start
}

macro DMA32SRCFIXED Source, Destination, Amount {
  mov r11,IO ; GBA I/O Base Offset
  imm32 r12,Source ; DMA Source
  str r12,[r11,DMA3SAD] ; Set DMA3 Source Address
  imm32 r12,Destination ; DMA Destination
  str r12,[r11,DMA3DAD] ; Set DMA3 Destination Address
  imm32 r12,DMA_ENABLE+DMA_32+DMA_SRC_FIXED+Amount
  str r12,[r11,DMA3CNT] ; DMA Start
}

macro DMACLEAROAM {
  mov r11,IO ; GBA I/O Base Offset
  mov r12,0 ; DMA Zero Data
  str r12,[r11,DMA3SAD] ; Set DMA3 Source Address
  mov r12,OAM
  str r12,[r11,DMA3DAD] ; Set DMA3 Destination Address
  imm32 r12,DMA_ENABLE+DMA_32+DMA_SRC_FIXED+256
  str r12,[r11,DMA3CNT] ; DMA Start
}