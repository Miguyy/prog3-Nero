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
float baselineTorsoHeight = 0;
int calibrationSamples = 0;

// Relative thresholds are more stable than fixed pixels because they scale with
// the player's distance from the sensor.
final float JUMP_THRESHOLD_RATIO = 0.12;
final float CROUCH_THRESHOLD_RATIO = 0.12;
final int CALIBRATION_FRAMES = 20;

// How long after a crouch ends before a jump is allowed to trigger. Standing
// back up from a crouch naturally overshoots the head's baseline height for
// a frame or two (you push up off your legs), which was being read as a
// jump. A real jump, by contrast, isn't preceded by a crouch ending.
final int CROUCH_RECOVERY_COOLDOWN_MS = 350;
int lastCrouchEndMillis = -100000;
boolean wasCrouchingLastFrame = false;

final int DWELL_MS = 2000;

PVector pointerPos = new PVector();

void loadKinect() {
  try {
    kinect = new Kinect(this); // constructor starts the tracking thread itself
    println("Kinect initialized");
  }
  catch (Throwable e) {
   println("Kinect init failed, falling back to mouse/keyboard: " + e.getMessage());
   kinect = null;
  }
  kinectConnected = false; // becomes true once appearEvent fires with a tracked user
}

void resetKinectCalibration() {
  calibrated = false;
  calibrationSamples = 0;
  baselineHeadY = 0;
  baselineHipY = 0;
  baselineTorsoHeight = 0;
}

// Library-invoked event hooks -- each may only be defined once in the whole sketch.
// Only the first tracked body becomes the active player; extra bodies are ignored.
void appearEvent(SkeletonData skel) {
  if (skel.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) return;
  if (currentSkeleton != null) return;
  currentSkeleton = skel;
  kinectConnected = true;
  resetKinectCalibration();
}

void disappearEvent(SkeletonData skel) {
  if (currentSkeleton == null || currentSkeleton.dwTrackingID != skel.dwTrackingID) return;
  currentSkeleton = null;
  kinectConnected = false;
  resetKinectCalibration();
}

void moveEvent(SkeletonData oldSkel, SkeletonData skel) {
  if (oldSkel != null && oldSkel.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) return;
  if (skel.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) return;
  if (currentSkeleton == null) {
    currentSkeleton = skel;
    kinectConnected = true;
    resetKinectCalibration();
  } else if (currentSkeleton.dwTrackingID != skel.dwTrackingID) {
    return;
  }
  currentSkeleton = skel;
  kinectConnected = true;
  if (!calibrated && isJointTracked(skel, JOINT_HEAD) && isJointTracked(skel, JOINT_HIP_CENTER)) {
    baselineHeadY += screenYOfJoint(skel, JOINT_HEAD);
    baselineHipY += screenYOfJoint(skel, JOINT_HIP_CENTER);
    calibrationSamples++;
    if (calibrationSamples >= CALIBRATION_FRAMES) {
      baselineHeadY /= calibrationSamples;
      baselineHipY /= calibrationSamples;
      baselineTorsoHeight = max(1, baselineHipY - baselineHeadY);
      calibrated = true;
    }
  }
}

boolean isJointTracked(SkeletonData skel, int joint) {
  return skel.skeletonPositionTrackingState[joint] == Kinect.NUI_SKELETON_POSITION_TRACKED;
}

// The library's skeleton coordinates are normalized so that multiplying by
// the FULL width (x) and FULL height (y) maps them directly to the sketch's
// pixel space (confirmed against the library author's own bundled example,
// which does `_s.position.x*width, _s.position.y*height`, not width/2).
// The previous "/2" here was the bug behind the pointer only ever reaching
// half the screen: a raw value of 1.0 (fully to one side) was being mapped
// to width/2 instead of the actual screen edge, and constrain() below then
// clipped the other half to 0/width, so only one half of the screen was ever
// reachable.
float screenXOfJoint(SkeletonData skel, int joint) {
  return skel.skeletonPositions[joint].x * width;
}

float screenYOfJoint(SkeletonData skel, int joint) {
  return skel.skeletonPositions[joint].y * height;
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

  boolean crouchingNow = isCrouching();
  if (wasCrouchingLastFrame && !crouchingNow) {
    lastCrouchEndMillis = millis();
  }
  wasCrouchingLastFrame = crouchingNow;
}

boolean isKinectTracking() {
  return kinectConnected && currentSkeleton != null;
}

void updateKinectCalibration() {
  if (!isKinectTracking() || calibrated) return;
  if (!isJointTracked(currentSkeleton, JOINT_HEAD) || !isJointTracked(currentSkeleton, JOINT_HIP_CENTER)) return;

  baselineHeadY += screenYOfJoint(currentSkeleton, JOINT_HEAD);
  baselineHipY += screenYOfJoint(currentSkeleton, JOINT_HIP_CENTER);
  calibrationSamples++;

  if (calibrationSamples >= CALIBRATION_FRAMES) {
    baselineHeadY /= calibrationSamples;
    baselineHipY /= calibrationSamples;
    baselineTorsoHeight = max(1, baselineHipY - baselineHeadY);
    calibrated = true;
  }
}

boolean isJumping() {
  if (isKinectTracking() && calibrated && isJointTracked(currentSkeleton, JOINT_HEAD)) {
    float headY = screenYOfJoint(currentSkeleton, JOINT_HEAD);
    return (baselineHeadY - headY) > baselineTorsoHeight * JUMP_THRESHOLD_RATIO;
  }
  return fallbackUpHeld;
}

// Use this instead of isJumping() to trigger an actual jump -- it filters out
// the "stood up from a crouch" false positive described above.
boolean isJumpTriggered() {
  if (millis() - lastCrouchEndMillis < CROUCH_RECOVERY_COOLDOWN_MS) return false;
  return isJumping();
}

boolean isCrouching() {
  if (isKinectTracking() && calibrated && isJointTracked(currentSkeleton, JOINT_HIP_CENTER)) {
    float hipY = screenYOfJoint(currentSkeleton, JOINT_HIP_CENTER);
    return (hipY - baselineHipY) > baselineTorsoHeight * CROUCH_THRESHOLD_RATIO;
  }
  return fallbackDownHeld;
}

PVector getHandScreenPos() {
  return pointerPos;
}

boolean isHandPointing() {
  if (isKinectTracking()) {
    return isJointTracked(currentSkeleton, JOINT_HAND_RIGHT);
  }
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
    float bodyTop = 0.16 + crouchOffset + jumpOffset;
    float shoulderY = 0.30 + crouchOffset + jumpOffset;
    float hipY = 0.52 + crouchOffset + jumpOffset;
    float kneeY = 0.73 + crouchOffset * 0.6;
    float footY = 0.92;

    pts[JOINT_HEAD] = new PVector(0.5, bodyTop);
    pts[JOINT_SPINE] = new PVector(0.5, 0.39 + crouchOffset + jumpOffset);
    pts[JOINT_SHOULDER_CENTER] = new PVector(0.5, shoulderY);
    pts[JOINT_SHOULDER_LEFT] = new PVector(0.42, shoulderY);
    pts[JOINT_SHOULDER_RIGHT] = new PVector(0.58, shoulderY);
    pts[JOINT_ELBOW_LEFT] = new PVector(0.37, 0.41 + crouchOffset + jumpOffset);
    pts[JOINT_ELBOW_RIGHT] = new PVector(0.63, 0.41 + crouchOffset + jumpOffset);
    pts[JOINT_WRIST_LEFT] = new PVector(0.34, 0.49 + crouchOffset + jumpOffset);
    pts[JOINT_WRIST_RIGHT] = new PVector(0.66, 0.49 + crouchOffset + jumpOffset);
    pts[JOINT_HAND_LEFT] = new PVector(0.32, 0.46 + crouchOffset + jumpOffset);
    pts[JOINT_HAND_RIGHT] = new PVector(0.68, 0.46 + crouchOffset + jumpOffset);
    pts[JOINT_HIP_CENTER] = new PVector(0.5, hipY);
    pts[JOINT_HIP_LEFT] = new PVector(0.45, hipY);
    pts[JOINT_HIP_RIGHT] = new PVector(0.55, hipY);
    pts[JOINT_KNEE_LEFT] = new PVector(0.43, kneeY);
    pts[JOINT_KNEE_RIGHT] = new PVector(0.57, kneeY);
    pts[JOINT_ANKLE_LEFT] = new PVector(0.43, 0.85 + crouchOffset * 0.25);
    pts[JOINT_ANKLE_RIGHT] = new PVector(0.57, 0.85 + crouchOffset * 0.25);
    pts[JOINT_FOOT_LEFT] = new PVector(0.42, footY);
    pts[JOINT_FOOT_RIGHT] = new PVector(0.58, footY);
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