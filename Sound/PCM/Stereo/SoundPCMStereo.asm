; GBA 'Bare Metal' Sound 8-Bit PCM Stereo DMA Playback Demo by krom (Peter Lemon):
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