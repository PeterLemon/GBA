;===============
; GBA Interrupt
;===============
; Interrupt, Waitstate, and Power-Down Control
IE	= $200 ; $4000200: Interrupt Enable Register		     (R/W)(Bit 0..15)
IF_ACK	= $202 ; $4000202: Interrupt Request Flags / IRQ Acknowledge (R/W)(Bit 0..15)
WAITCNT = $204 ; $4000204: Game Pak Waitstate Control		     (R/W)(Bit 0..15)
IME	= $208 ; $4000208: Interrupt Master Enable Register	     (R/W)(Bit 0..15)
POSTFLG = $300 ; $4000300: Undocumented - Post Boot Flag	     (R/W)(Bit 0..7)
HALTCNT = $301 ; $4000301: Undocumented - Power Down Control	       (W)(Bit 0..7)
IMEMCNT = $800 ; $4000800: Undocumented - Internal Memory Control    (R/W)(Bit 0..31)

ISR = $3007FFC ; $3007FFC: Interrupt Service Routine IWRAM Address   (R/W)(Bit 0..31)