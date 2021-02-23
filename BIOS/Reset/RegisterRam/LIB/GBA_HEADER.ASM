;============
; GBA Header
;============
; ROM Entry Point ($8000000..$8000003) (4 Bytes)
b copycodeIWRAMEND

; NINTENDO LOGO ($8000004..$80000BF) (156 Bytes)
db $24, $FF, $AE, $51, $69, $9A, $A2, $21, $3D, $84, $82, $0A, $84, $E4, $09, $AD
db $11, $24, $8B, $98, $C0, $81, $7F, $21, $A3, $52, $BE, $19, $93, $09, $CE, $20
db $10, $46, $4A, $4A, $F8, $27, $31, $EC, $58, $C7, $E8, $33, $82, $E3, $CE, $BF
db $85, $F4, $DF, $94, $CE, $4B, $09, $C1, $94, $56, $8A, $C0, $13, $72, $A7, $FC
db $9F, $84, $4D, $73, $A3, $CA, $9A, $61, $58, $97, $A3, $27, $FC, $03, $98, $76
db $23, $1D, $C7, $61, $03, $04, $AE, $56, $BF, $38, $84, $00, $40, $A7, $0E, $FD
db $FF, $52, $FE, $03, $6F, $95, $30, $F1, $97, $FB, $C0, $85, $60, $D6, $80, $25
db $A9, $63, $BE, $03, $01, $4E, $38, $E2, $F9, $A2, $34, $FF, $BB, $3E, $03, $44
db $78, $00, $90, $CB, $88, $11, $3A, $94, $65, $C0, $7C, $63, $87, $F0, $3C, $AF
db $D6, $25, $E4, $8B, $38, $0A, $AC, $72, $21, $D4, $F8, $07

; Game Title (Uppercase ASCII, Max 12 Characters) ($80000A0..$80000AB) (12 Bytes)
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; Game Code (Uppercase ASCII, Max 4 Characters) ($80000AC..$80000AF) (4 Bytes)
db $00, $00, $00, $00

; Maker Code (Uppercase ASCII, Max 2 Characters) ($80000B0..$80000B1) (2 Bytes)
db $00, $00

; Fixed Value $96 ($80000B2) (1 Byte)
db $96

; Main Unit Code ($80000B3) (1 Byte)
db $00

; Device Type (Bit 7 = DACS/Debug Related) ($80000B4) (1 Byte)
db $80

; Reserved Area ($80000B5..$80000BB) (7 Bytes)
db $00, $00, $00, $00, $00, $00, $00

; Software Version ($80000BC) (1 Byte)
db $00

; Complement Check (Header Checksum) ($80000BD) (1 Byte) 
db $D1

; Reserved Area ($80000BE..$80000BF) (2 Bytes)
db $00, $00