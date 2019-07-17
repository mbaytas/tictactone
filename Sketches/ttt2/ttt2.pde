import processing.sound.*;

import com.leapmotion.leap.Controller;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.FingerList;
import com.leapmotion.leap.Frame;
import com.leapmotion.leap.Gesture;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.KeyTapGesture;
import com.leapmotion.leap.Pointable;
import com.leapmotion.leap.PointableList;
import com.leapmotion.leap.Vector;
import com.leapmotion.leap.processing.LeapMotion;

import javax.activation.MimetypesFileTypeMap;

LeapMotion leapMotion;

// Targets
int targetSize = 100;
int margin = 10;
int nRows = 3;         // Grid size is 3x3x1 for TTT
int nCols = 3;         // Grid size is 3x3x1 for TTT
int nFloors = 1;       // Grid size is 3x3x1 for TTT
int yOffset = 200;     // Height from sensor
int zOffset = 100;     // Improves hand/gesture recognition
ArrayList<Target> targets = new ArrayList<Target>();
boolean spherical = false;

// Visual
ArrayList<PShape> shapes = new ArrayList<PShape>();

// Against dropping tap gestures
// http://stackoverflow.com/questions/31693994/missed-tap-gestures-from-leap-motion-in-java
Frame lastFrameProcessed = Frame.invalid();


void setup() {
  // Create grid of targets
  for (int f = 0; f < nFloors; f++) {
    for (int c = 0; c < nCols; c++) {
      for (int r = 0; r < nRows; r++) {
        float x = (c - (nCols - 1.0) / 2.0) * (targetSize + margin);
        float y = f * (targetSize + margin) + yOffset;
        float z = (r - (nRows - 1.0) / 2.0) * (targetSize + margin) - zOffset;
        Target target;
        target = new Target(x, y, z, targetSize, targetSize, targetSize);
        targets.add(target);
      }
    }
  }

  size(800, 600, P3D);
  frameRate(60);

  camera(-450, -450, 450, 0, -100, -100, 0, 1, 0);

  leapMotion = new LeapMotion(this);
}

void draw() {
  //// Graphics stuff
  clear();
  surface.setTitle(int(frameRate) + " fps");

  background(113);
  pointLight(200, 200, 200, 0, -400, 0);
  ambientLight(80, 80, 80);
  box(80, 12, 30); // Leap!

  // Draw targets
  for (Target target : targets) {
    pushMatrix();
    translate(target.x, -target.y, target.z);
    beginShape();
    int index = targets.indexOf(target);
    fill(map(index, 0, targets.size(), 255, 0),
         0,
         map(index, 0, targets.size(), 0, 255),
         80);
    box(target.h, target.w, target.d);
    endShape();
    popMatrix();
  }

  //// Leap stuff
  Controller controller = leapMotion.controller();
  Frame frame = controller.frame();

  // Play + draw + collision detection
  shapes.clear();
  if (frame.hands().isEmpty()) {
    nowPreviewing = -1;
  } else {
    for (Finger finger : frame.fingers()) {
      if (finger.type() == Finger.Type.TYPE_INDEX) {
        Vector tip = finger.tipPosition();
        float x = tip.getX();
        float y = tip.getY();
        float z = tip.getZ();
        // Draw
        PShape sphere = createShape(SPHERE, 6);
        sphere.translate(x, -y, z);
        shapes.add(sphere);
        // Detect collisions and set amplitude
        boolean collision = false;
        for (Target target : targets) {
          if (x > target.x - target.h/2 &&
            x < target.x + target.h/2 &&
            y > target.y - target.w/2 &&
            y < target.y + target.w/2 &&
            z > target.z - target.d/2 &&
            z < target.z + target.d/2) {
            collision = true;
            int index = targets.indexOf(target);
            nowPreviewing = index;
            println("Previewing", nowPreviewing);
          }
        }
        if (!collision) nowPreviewing = -1;
      }
    }
  }
  for (PShape sphere : shapes) {
    shape(sphere);
  }

  // Tap detection 
  for (Gesture gesture : frame.gestures(lastFrameProcessed)) {
    if (gesture.type().equals(Gesture.Type.TYPE_KEY_TAP)) {
      if (nowPreviewing >= 0) {
        SoundFile s = songs.get(nowPreviewing);
        s.stop();
        s.cue(0);
        nowPlaying = nowPreviewing;
        s.play();
      }
      println("TAP on", nowPreviewing, "- Confidence:", frame.hands().get(0).confidence());
    }
  }
  lastFrameProcessed = frame;

  // Sound!
  if (nowPreviewing >= 0) {
    // FIXME
    // for (SoundFile s : songs) {
    //   if (songs.indexOf(s) == nowPreviewing) s.amp(1);
    //   else s.amp(0);
    // }
  } else if (nowPlaying >= 0) {
    // FIXME
    // for (SoundFile s : songs) {
    //   if (songs.indexOf(s) == nowPlaying) s.amp(1);
    //   else s.amp(0);
    // }
  } else {
    // FIXME
    // for (SoundFile s : songs) {
    //   s.amp(0);
    // }
  }
}

void onInit(final Controller controller) {
  controller.enableGesture(Gesture.Type.TYPE_KEY_TAP);
}