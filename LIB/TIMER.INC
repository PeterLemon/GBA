; Timer Registers
TM0CNT = $100 ; $4000100: Timer 0 Counter/Reload/Control
TM1CNT = $104 ; $4000104: Timer 1 Counter/Reload/Control
TM2CNT = $108 ; $4000108: Timer 2 Counter/Reload/Control
TM3CNT = $10C ; $400010C: Timer 3 Counter/Reload/Control

TM_FREQ_64   =  $10000 ; TMXCNT_H: Prescaler Selection F/64   (Bit 0-1)
TM_FREQ_256  =  $20000 ; TMXCNT_H: Prescaler Selection F/256  (Bit 0-1)
TM_FREQ_1024 =  $30000 ; TMXCNT_H: Prescaler Selection F/1024 (Bit 0-1)
TM_ENABLE    = $800000 ; TMXCNT_H: Timer Start                (Bit 7)
TM_DISABLE   =      $0 ; TMXCNT_H: Timer Stop                 (Bit 7)

Second1024th = $0010
Second512th  = $0020
Second256th  = $0040
Second128th  = $0080
Second64th   = $0100
Second32th   = $0200
Second16th   = $0400
Second8th    = $0800
Second4th    = $1000
SecondHalf   = $2000
Second1      = $4000
Second2      = $8000
Second3      = $C000
Second4      = $FF00

macro TimerWait Timer, Time {
  local .Loop
  mov r11,IO ; GBA I/O Base Offset
  orr r11,Timer ; Timer Control Register
  mov r12,TM_ENABLE or TM_FREQ_1024 ; Timer Enable, Frequency/1024
  str r12,[r11] ; Start Timer
  .Loop:
    ldrh r12,[r11] ; Current Timer Position
    cmp r12,Time ; Compare Time
    bne .Loop
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer Control
}