CubeQuad:
  dw -2560, -2560, -2560 ; Quad 1 Front Top Left
  dw  2560, -2560, -2560 ; Quad 1 Front Top Right
  dw  2560,  2560, -2560 ; Quad 1 Front Bottom Right
  dw -2560,  2560, -2560 ; Quad 1 Front Bottom Left
  dw $0000000F ; Quad 1 Colour

  dw -2560, -2560,  2560 ; Quad 2 Back Top Left
  dw -2560, -2560, -2560 ; Quad 2 Front Top Left
  dw -2560,  2560, -2560 ; Quad 2 Front Bottom Left
  dw -2560,  2560,  2560 ; Quad 2 Back Bottom Left
  dw $000000FF ; Quad 2 Colour

  dw  2560, -2560, -2560 ; Quad 3 Front Top Right
  dw  2560, -2560,  2560 ; Quad 3 Back Top Right
  dw  2560,  2560,  2560 ; Quad 3 Back Bottom Right
  dw  2560,  2560, -2560 ; Quad 3 Front Bottom Right
  dw $0000F00F ; Quad 3 Colour

  dw -2560, -2560,  2560 ; Quad 4 Back Top Left
  dw  2560, -2560,  2560 ; Quad 4 Back Top Right
  dw  2560, -2560, -2560 ; Quad 4 Front Top Right
  dw -2560, -2560, -2560 ; Quad 4 Front Top Left
  dw $00000FFF ; Quad 4 Colour

  dw -2560,  2560, -2560 ; Quad 5 Front Bottom Left
  dw  2560,  2560, -2560 ; Quad 5 Front Bottom Right
  dw  2560,  2560,  2560 ; Quad 5 Back Bottom Right
  dw -2560,  2560,  2560 ; Quad 5 Back Bottom Left
  dw $0000FF00 ; Quad 5 Colour

  dw  2560, -2560,  2560 ; Quad 6 Back Top Right
  dw -2560, -2560,  2560 ; Quad 6 Back Top Left
  dw -2560,  2560,  2560 ; Quad 6 Back Bottom Left
  dw  2560,  2560,  2560 ; Quad 6 Back Bottom Right
  dw $00000F00 ; Quad 6 Colour
CubeQuadEnd:

PyramidTri:
  dw -10240,  2560, -2560 ; Tri 1 Base Triangle Bottom Mid
  dw  -7168,  2560,  2560 ; Tri 1 Base Triangle Bottom Right
  dw -13312,  2560,  2560 ; Tri 1 Base Triangle Bottom Left
  dw $0000000F ; Tri 1 Colour

  dw -10240, -2560,     0 ; Tri 2 Peak
  dw -13312,  2560,  2560 ; Tri 1 Base Triangle Bottom Left
  dw  -7168,  2560,  2560 ; Tri 1 Base Triangle Bottom Right
  dw $0000FF00 ; Tri 2 Colour

  dw -10240, -2560,     0 ; Tri 2 Peak
  dw -10240,  2560, -2560 ; Tri 1 Base Triangle Bottom Mid
  dw -13312,  2560,  2560 ; Tri 1 Base Triangle Bottom Left
  dw $0000F00F ; Tri 3 Colour

  dw -10240, -2560,     0 ; Tri 2 Peak
  dw  -7168,  2560,  2560 ; Tri 1 Base Triangle Bottom Right
  dw -10240,  2560, -2560 ; Tri 1 Base Triangle Bottom Mid
  dw $00000FFF ; Tri 4 Colour
PyramidTriEnd:

GrassLine:
  dw  7680, -2560, 0 ; Line 1 Top
  dw  8192,  2560, 0 ; Line 1 Bottom
  dw $00000000 ; Line 1 Colour

  dw  8960, -2560, 0 ; Line 2 Top
  dw  8960,  2560, 0 ; Line 2 Bottom
  dw $00000000 ; Line 2 Colour

  dw 10240, -2560, 0 ; Line 3 Top
  dw 10240,  2560, 0 ; Line 3 Bottom
  dw $00000000 ; Line 3 Colour

  dw 11520, -2560, 0 ; Line 4 Top
  dw 11008,  2560, 0 ; Line 4 Bottom
  dw $00000000 ; Line 4 Colour
GrassLineEnd:

StarPoint:
  dw  3840, -12800,  -1280 ; Point 1
  dw $0000000F ; Point 1 Colour
  dw -5120, -11520,  -1280 ; Point 2
  dw $0000000F ; Point 2 Colour
  dw  3840,  -7680,  -1280 ; Point 3
  dw $0000000F ; Point 3 Colour
  dw -5120,  -8960,  -1280 ; Point 4
  dw $0000000F ; Point 4 Colour
  dw -3072, -11520,  -1280 ; Point 5
  dw $0000000F ; Point 5 Colour
  dw -3072,  -8960,  -1280 ; Point 6
  dw $0000000F ; Point 6 Colour
StarPointEnd: