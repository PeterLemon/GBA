; GBA 'Bare Metal' Sound 8-Bit PCM Stereo DMA Playback Demo by krom (Peter Lemon):
format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_SOUND.INC' ; Include GBA Sound Macros
include 'LIB\GBA_TIMER.INC' ; Include GBA Timer Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

Start:
  PlaySoundAB SOUNDL, SOUNDR, 48000 ; Play Sound Channel A & B Data

  imm16 r0,557 ; R0 = Number Of 1/16 Seconds To Wait
  Loop:
    TimerWait TM2CNT, Second16th ; Wait On Timer 2 For 1/16 Second
    subs r0,1 ; Number Of 1/16 Seconds To Wait--
    bne Loop ; IF (Number Of 1/16 Seconds To Wait != 0) Loop

  StopSoundAB ; Stop Sound Channel A & B Data

  b Start ; Repeat Sound Playback

SOUNDL: ; 8-Bit 48000Hz Signed Stereo Left Sound Sample
file 'audioL.snd'
SOUNDR: ; 8-Bit 48000Hz Signed Stereo Right Sound Sample
file 'audioR.snd'