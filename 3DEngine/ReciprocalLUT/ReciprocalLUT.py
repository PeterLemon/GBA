# Reciprocal LUT Generation Fixed Point Unsigned Fraction 32-Bit

i = 0
while i < 1048576:
    if i == 0:
        r = 0
    else:
        r = round((1/i) * 4294967296)
    print ("dw", r, "; 1 /", i)
    i += 1
