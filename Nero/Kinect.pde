// ---------------------------------------------------------------------------
// Raw Kinect4WinSDK wiring, verified against the library's public source
// (github.com/chungbwc/Kinect4WinSDK: Kinect.java, SkeletonData.java,
// KinectConstants.java) and its bundled example sketch. The real class is
// `Kinect` (package kinect4WinSDK) -- not `Kinect4WinSDK`. Its constructor
// starts the tracking thread itself, no separate start() call exists.
// ---------------------------------------------------------------------------
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

Kinect kinect;
SkeletonData currentSkeleton = null;

// Mirrors kinect4WinSDK.KinectConstants.NUI_SKELETON_POSITION_* so the rest
// of the game doesn't need to import the library directly.
final int JOINT_HIP_CENTER = Kinect.NUI_SKELETON_POSITION_HIP_CENTER;
final int JOINT_SPINE = Kinect.NUI_SKELETON_POSITION_SPINE;
final int JOINT_SHOULDER_CENTER = Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER;
final int JOINT_HEAD = Kinect.NUI_SKELETON_POSITION_HEAD;
final int JOINT_SHOULDER_LEFT = Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT;
final int JOINT_ELBOW_LEFT = Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT;
final int JOINT_WRIST_LEFT = Kinect.NUI_SKELETON_POSITION_WRIST_LEFT;
final int JOINT_HAND_LEFT = Kinect.NUI_SKELETON_POSITION_HAND_LEFT;
final int JOINT_SHOULDER_RIGHT = Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT;
final int JOINT_ELBOW_RIGHT = Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT;
final int JOINT_WRIST_RIGHT = Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT;
final int JOINT_HAND_RIGHT = Kinect.NUI_SKELETON_POSITION_HAND_RIGHT;
final int JOINT_HIP_LEFT = Kinect.NUI_SKELETON_POSITION_HIP_LEFT;
final int JOINT_KNEE_LEFT = Kinect.NUI_SKELETON_POSITION_KNEE_LEFT;
final int JOINT_ANKLE_LEFT = Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT;
final int JOINT_FOOT_LEFT = Kinect.NUI_SKELETON_POSITION_FOOT_LEFT;
final int JOINT_HIP_RIGHT = Kinect.NUI_SKELETON_POSITION_HIP_RIGHT;
final int JOINT_KNEE_RIGHT = Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT;
final int JOINT_ANKLE_RIGHT = Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT;
final int JOINT_FOOT_RIGHT = Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT;

boolean kinectConnected = false;
boolean calibrated = false;
float baselineHeadY = 0;
float baselineHipY = 0;

// Placeholder tuning values -- need a live calibration/playtest pass once hardware is available.
final float JUMP_THRESHOLD_PX = 60;
final float CROUCH_THRESHOLD_PX = 50;

final int DWELL_MS = 2000;

PVector pointerPos = new PVector();

void loadKinect() {
  // Disabled for now -- the Kinect SDK 1.8 runtime's dependent native DLLs aren't
  // installed on this machine, so `new Kinect(this)` throws an UnsatisfiedLinkError
  // from its background tracking thread and takes the sketch down with it.
  // Once the Kinect runtime + sensor are available, uncomment this block; every
  // other function in this file already falls back to mouse/keyboard automatically
  // whenever kinectConnected is false, so nothing else needs to change.
  /*
  try {
   kinect = new Kinect(this); // constructor starts the tracking thread itself
  }
  catch (Throwable e) {
   println("Kinect init failed, falling back to mouse/keyboard: " + e.getMessage());
   kinect = null;
  }
  */
  kinectConnected = false; // becomes true once appearEvent fires with a tracked user
}

// Library-invoked event hooks -- each may only be defined once in the whole sketch.
// Only the first tracked body becomes the active player; extra bodies are ignored.
void appearEvent(SkeletonData skel) {
  if (skel.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) return;
  if (currentSkeleton != null) return;
  currentSkeleton = skel;
  kinectConnected = true;
  calibrated = false;
}

void disappearEvent(SkeletonData skel) {
  if (currentSkeleton == null || currentSkeleton.dwTrackingID != skel.dwTrackingID) return;
  currentSkeleton = null;
  kinectConnected = false;
  calibrated = false;
}

void moveEvent(SkeletonData oldSkel, SkeletonData skel) {
  if (skel.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) return;
  if (currentSkeleton == null || currentSkeleton.dwTrackingID != skel.dwTrackingID) return;
  currentSkeleton = skel;
  kinectConnected = true;
  if (!calibrated) {
    baselineHeadY = screenYOfJoint(skel, JOINT_HEAD);
    baselineHipY = screenYOfJoint(skel, JOINT_HIP_CENTER);
    calibrated = true;
  }
}

boolean isJointTracked(SkeletonData skel, int joint) {
  return skel.skeletonPositionTrackingState[joint] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED;
}

// The library's skeleton coordinates are pre-normalized so that multiplying by
// width/2 (x) and height/2 (y) maps them directly to the sketch's pixel space --
// this is the exact mapping used in the library's own bundled example sketch.
float screenXOfJoint(SkeletonData skel, int joint) {
  return skel.skeletonPositions[joint].x * width / 2;
}

float screenYOfJoint(SkeletonData skel, int joint) {
  return skel.skeletonPositions[joint].y * height / 2;
}

// ---------------------------------------------------------------------------
// Public input abstraction used by the rest of the game. Nothing outside this
// file touches SkeletonData/raw joints directly.
// ---------------------------------------------------------------------------

void updateKinectInput() {
  if (isKinectTracking() && isJointTracked(currentSkeleton, JOINT_HAND_RIGHT)) {
    pointerPos.set(
      constrain(screenXOfJoint(currentSkeleton, JOINT_HAND_RIGHT), 0, width),
      constrain(screenYOfJoint(currentSkeleton, JOINT_HAND_RIGHT), 0, height)
      );
  } else {
    pointerPos.set(mouseX, mouseY);
  }
}

boolean isKinectTracking() {
  return kinectConnected && currentSkeleton != null;
}

boolean isJumping() {
  if (isKinectTracking() && calibrated) {
    float headY = screenYOfJoint(currentSkeleton, JOINT_HEAD);
    return (baselineHeadY - headY) > JUMP_THRESHOLD_PX;
  }
  return fallbackUpHeld;
}

boolean isCrouching() {
  if (isKinectTracking() && calibrated) {
    float hipY = screenYOfJoint(currentSkeleton, JOINT_HIP_CENTER);
    return (hipY - baselineHipY) > CROUCH_THRESHOLD_PX;
  }
  return fallbackDownHeld;
}

PVector getHandScreenPos() {
  return pointerPos;
}

boolean isHandPointing() {
  // Mouse fallback is always "pointing"; a tracked Kinect hand counts as pointing whenever visible.
  return true;
}

void resetDwellState() {
  for (DwellTarget t : allDwellTargets) t.reset();
}

PVector[] getSkeletonJointsNormalized() {
  PVector[] pts = new PVector[20];
  if (isKinectTracking()) {
    for (int j = 0; j < 20; j++) {
      if (!isJointTracked(currentSkeleton, j)) continue;
      float sx = screenXOfJoint(currentSkeleton, j);
      float sy = screenYOfJoint(currentSkeleton, j);
      pts[j] = new PVector(constrain(map(sx, 0, width, 0, 1), 0, 1), constrain(map(sy, 0, height, 0, 1), 0, 1));
    }
  } else {
    // Synthesized fallback pose driven by keyboard state so the HUD preview is never empty during dev testing.
    float crouchOffset = fallbackDownHeld ? 0.15 : 0;
    float jumpOffset = fallbackUpHeld ? -0.1 : 0;
    pts[JOINT_HEAD] = new PVector(0.5, 0.2 + crouchOffset + jumpOffset);
    pts[JOINT_SHOULDER_CENTER] = new PVector(0.5, 0.32 + crouchOffset + jumpOffset);
    pts[JOINT_HAND_LEFT] = new PVector(0.35, 0.45 + crouchOffset + jumpOffset);
    pts[JOINT_HAND_RIGHT] = new PVector(0.65, 0.45 + crouchOffset + jumpOffset);
    pts[JOINT_HIP_CENTER] = new PVector(0.5, 0.55 + crouchOffset + jumpOffset);
    pts[JOINT_KNEE_LEFT] = new PVector(0.42, 0.75 + crouchOffset * 0.5);
    pts[JOINT_KNEE_RIGHT] = new PVector(0.58, 0.75 + crouchOffset * 0.5);
    pts[JOINT_FOOT_LEFT] = new PVector(0.42, 0.92);
    pts[JOINT_FOOT_RIGHT] = new PVector(0.58, 0.92);
  }
  return pts;
}

// ---------------------------------------------------------------------------
// Reusable dwell-time (2s hold) selection target -- shared by every
// selectable element in the game (Menu buttons, Options sliders'
// +/-/Cancel/Save, Score's Menu button).
// ---------------------------------------------------------------------------

ArrayList<DwellTarget> allDwellTargets = new ArrayList<DwellTarget>();

class DwellTarget {
  float x, y, w, h;
  float hoverStart = -1;
  float progress = 0;

  DwellTarget(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    allDwellTargets.add(this);
  }

  boolean contains(PVector p) {
    return p.x >= x && p.x <= x + w && p.y >= y && p.y <= y + h;
  }

  // Returns true exactly once, the frame a continuous 2s hover completes.
  boolean update(PVector pointer, boolean pointing) {
    if (contains(pointer) && pointing) {
      if (hoverStart < 0) hoverStart = millis();
      progress = constrain((millis() - hoverStart) / (float) DWELL_MS, 0, 1);
      if (progress >= 1) {
        reset();
        return true;
      }
    } else {
      reset();
    }
    return false;
  }

  void reset() {
    hoverStart = -1;
    progress = 0;
  }
}
