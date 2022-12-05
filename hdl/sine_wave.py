from math import cos, pi

samples = 256
bits = 11

for i in range(samples):
    value = int((-cos(2*pi*i/samples)+1) * (2**bits-1)/2)
    case = f"{i:b}".zfill(8)
    print("8'b" + case + " : " + "sine = " + str(value) + ";")
