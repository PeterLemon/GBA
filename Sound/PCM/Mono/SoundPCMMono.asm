; GBA 'Bare Metal' Sound 8-Bit PCM Mono DMA Playback Demo by krom (Peter Lemon):
format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
include 'LIB\SOUND.INC'
include 'LIB\TIMER.INC'
org $8000000
b Start
times $80000C0-($-0) db 0

Start:
  PlaySoundA SOUND, 48000 ; Play Sound Channel A Data

  imm16 r0,557 ; R0 = Number Of 1/16 Seconds To Wait
  Loop:
    TimerWait TM2CNT, Second16th ; Wait On Timer 2 For 1/16 Second
    subs r0,1 ; Number Of 1/16 Seconds To Wait--
    bne Loop ; IF (Number Of 1/16 Seconds To Wait != 0) Loop

  StopSoundA ; Stop Sound Channel A Data

  b Start ; Repeat Sound Playback

SOUND: ; 8-Bit 48000Hz Signed Mono Sound Sample
file 'audio.snd'