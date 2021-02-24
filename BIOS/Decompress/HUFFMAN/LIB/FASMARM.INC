;================
; FASMARM Macros
;================
; PC Relative Addressing
macro adr reg,location {
  add reg,pc,location-$-8
}

macro adreq reg,location {
  addeq reg,pc,location-$-8
}

macro adrne reg,location {
  addne reg,pc,location-$-8
}

macro adrcs reg,location {
  addcs reg,pc,location-$-8
}

macro adrcc reg,location {
  addcc reg,pc,location-$-8
}

macro adrmi reg,location {
  addmi reg,pc,location-$-8
}

macro adrpl reg,location {
  addpl reg,pc,location-$-8
}

macro adrvs reg,location {
  addvs reg,pc,location-$-8
}

macro adrvc reg,location {
  addvc reg,pc,location-$-8
}

macro adrhi reg,location {
  addhi reg,pc,location-$-8
}

macro adrls reg,location {
  addls reg,pc,location-$-8
}

macro adrge reg,location {
  addge reg,pc,location-$-8
}

macro adrlt reg,location {
  addlt reg,pc,location-$-8
}

macro adrgt reg,location {
  addgt reg,pc,location-$-8
}

macro adrle reg,location {
  addle reg,pc,location-$-8
}

macro adrl reg,location {
  sub reg,pc,(-location+$+8) and ($FF shl 2)
  sub reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrleq reg,location {
  subeq reg,pc,(-location+$+8) and ($FF shl 2)
  subeq reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlne reg,location {
  subne reg,pc,(-location+$+8) and ($FF shl 2)
  subne reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlcs reg,location {
  subcs reg,pc,(-location+$+8) and ($FF shl 2)
  subcs reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlcc reg,location {
  subcc reg,pc,(-location+$+8) and ($FF shl 2)
  subcc reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlmi reg,location {
  submi reg,pc,(-location+$+8) and ($FF shl 2)
  submi reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlpl reg,location {
  subpl reg,pc,(-location+$+8) and ($FF shl 2)
  subpl reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlvs reg,location {
  subvs reg,pc,(-location+$+8) and ($FF shl 2)
  subvs reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlvc reg,location {
  subvc reg,pc,(-location+$+8) and ($FF shl 2)
  subvc reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlhi reg,location {
  subhi reg,pc,(-location+$+8) and ($FF shl 2)
  subhi reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlls reg,location {
  subls reg,pc,(-location+$+8) and ($FF shl 2)
  subls reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlge reg,location {
  subge reg,pc,(-location+$+8) and ($FF shl 2)
  subge reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrllt reg,location {
  sublt reg,pc,(-location+$+8) and ($FF shl 2)
  sublt reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlgt reg,location {
  subgt reg,pc,(-location+$+8) and ($FF shl 2)
  subgt reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

macro adrlle reg,location {
  suble reg,pc,(-location+$+8) and ($FF shl 2)
  suble reg,reg,(-location+$+4) and ($FFFFFF00 shl 2)
}

; Immediate Loading
macro imm16 reg,immediate {
  mov reg,(immediate) and $FF
  orr reg,(immediate) and $FF00
}

macro imm16eq reg,immediate {
  moveq reg,(immediate) and $FF
  orreq reg,(immediate) and $FF00
}

macro imm16ne reg,immediate {
  movne reg,(immediate) and $FF
  orrne reg,(immediate) and $FF00
}

macro imm16cs reg,immediate {
  movcs reg,(immediate) and $FF
  orrcs reg,(immediate) and $FF00
}

macro imm16cc reg,immediate {
  movcc reg,(immediate) and $FF
  orrcc reg,(immediate) and $FF00
}

macro imm16mi reg,immediate {
  movmi reg,(immediate) and $FF
  orrmi reg,(immediate) and $FF00
}

macro imm16pl reg,immediate {
  movpl reg,(immediate) and $FF
  orrpl reg,(immediate) and $FF00
}

macro imm16vs reg,immediate {
  movvs reg,(immediate) and $FF
  orrvs reg,(immediate) and $FF00
}

macro imm16vc reg,immediate {
  movvc reg,(immediate) and $FF
  orrvc reg,(immediate) and $FF00
}

macro imm16hi reg,immediate {
  movhi reg,(immediate) and $FF
  orrhi reg,(immediate) and $FF00
}

macro imm16ls reg,immediate {
  movls reg,(immediate) and $FF
  orrls reg,(immediate) and $FF00
}

macro imm16ge reg,immediate {
  movge reg,(immediate) and $FF
  orrge reg,(immediate) and $FF00
}

macro imm16lt reg,immediate {
  movlt reg,(immediate) and $FF
  orrlt reg,(immediate) and $FF00
}

macro imm16gt reg,immediate {
  movgt reg,(immediate) and $FF
  orrgt reg,(immediate) and $FF00
}

macro imm16le reg,immediate {
  movle reg,(immediate) and $FF
  orrle reg,(immediate) and $FF00
}

macro imm32 reg,immediate {
  mov reg,(immediate) and $FF
  orr reg,(immediate) and $FF00
  orr reg,(immediate) and $FF0000
  orr reg,(immediate) and $FF000000
}

macro imm32eq reg,immediate {
  moveq reg,(immediate) and $FF
  orreq reg,(immediate) and $FF00
  orreq reg,(immediate) and $FF0000
  orreq reg,(immediate) and $FF000000
}

macro imm32ne reg,immediate {
  movne reg,(immediate) and $FF
  orrne reg,(immediate) and $FF00
  orrne reg,(immediate) and $FF0000
  orrne reg,(immediate) and $FF000000
}

macro imm32cs reg,immediate {
  movcs reg,(immediate) and $FF
  orrcs reg,(immediate) and $FF00
  orrcs reg,(immediate) and $FF0000
  orrcs reg,(immediate) and $FF000000
}

macro imm32cc reg,immediate {
  movcc reg,(immediate) and $FF
  orrcc reg,(immediate) and $FF00
  orrcc reg,(immediate) and $FF0000
  orrcc reg,(immediate) and $FF000000
}

macro imm32mi reg,immediate {
  movmi reg,(immediate) and $FF
  orrmi reg,(immediate) and $FF00
  orrmi reg,(immediate) and $FF0000
  orrmi reg,(immediate) and $FF000000
}

macro imm32pl reg,immediate {
  movpl reg,(immediate) and $FF
  orrpl reg,(immediate) and $FF00
  orrpl reg,(immediate) and $FF0000
  orrpl reg,(immediate) and $FF000000
}

macro imm32vs reg,immediate {
  movvs reg,(immediate) and $FF
  orrvs reg,(immediate) and $FF00
  orrvs reg,(immediate) and $FF0000
  orrvs reg,(immediate) and $FF000000
}

macro imm32vc reg,immediate {
  movvc reg,(immediate) and $FF
  orrvc reg,(immediate) and $FF00
  orrvc reg,(immediate) and $FF0000
  orrvc reg,(immediate) and $FF000000
}

macro imm32hi reg,immediate {
  movhi reg,(immediate) and $FF
  orrhi reg,(immediate) and $FF00
  orrhi reg,(immediate) and $FF0000
  orrhi reg,(immediate) and $FF000000
}

macro imm32ls reg,immediate {
  movls reg,(immediate) and $FF
  orrls reg,(immediate) and $FF00
  orrls reg,(immediate) and $FF0000
  orrls reg,(immediate) and $FF000000
}

macro imm32ge reg,immediate {
  movge reg,(immediate) and $FF
  orrge reg,(immediate) and $FF00
  orrge reg,(immediate) and $FF0000
  orrge reg,(immediate) and $FF000000
}

macro imm32lt reg,immediate {
  movlt reg,(immediate) and $FF
  orrlt reg,(immediate) and $FF00
  orrlt reg,(immediate) and $FF0000
  orrlt reg,(immediate) and $FF000000
}

macro imm32gt reg,immediate {
  movgt reg,(immediate) and $FF
  orrgt reg,(immediate) and $FF00
  orrgt reg,(immediate) and $FF0000
  orrgt reg,(immediate) and $FF000000
}

macro imm32le reg,immediate {
  movle reg,(immediate) and $FF
  orrle reg,(immediate) and $FF00
  orrle reg,(immediate) and $FF0000
  orrle reg,(immediate) and $FF000000
}