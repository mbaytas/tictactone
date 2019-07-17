class Target {
  float x; // x-coordinate of the centroid
  float y; // y-coordinate of the centroid
  float z; // z-coordinate of the centroid
  float h; // dimension in x-direction, for BOX targets
  float w; // dimension in y-driection, for BOX targets
  float d; // dimension in z-direction, for BOX targets
  float r; // radius, for SPHERE targets
  int type; // BOX or SPHERE
      
  SoundFile glowSound;
  SoundFile hitSound;
  SoundFile playSound;
  
  // Ctor for BOX targets
  Target(float x0, float y0, float z0, float h0, float w0, float d0) {
    x = x0;
    y = y0;
    z = z0;
    h = h0;
    w = w0;
    d = d0;
    type = BOX;
  }
  
  // Ctor for SPHERE targets
  Target(float x0, float y0, float z0, float r0) {
    x = x0;
    y = y0;
    z = z0;
    r = r0;
    type = SPHERE;
  }
}