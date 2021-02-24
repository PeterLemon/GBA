; GBA 'Bare Metal' Sound 8-Bit PCM Mono DMA Playback Demo by krom (Peter Lemon):
format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_SOUND.INC' ; Include GBA Sound Macros
include 'LIB\GBA_TIMER.INC' ; Include GBA Timer Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

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