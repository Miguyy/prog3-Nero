import processing.sound.*;

SoundFile bgMusic;
int bgMusicState = -1;
HashMap<String, SoundFile> sfxCache = new HashMap<String, SoundFile>();

float musicVolume = 0.7;
float sfxVolume = 0.8;

void loadAudio() {
  loadSettings();
}

void playMusicForState(int state) {
  // Music files (music_menu.mp3/music_game.mp3) not delivered yet -- SoundFile
  // throws from inside amp()/loop() when the file is missing, so this is disabled
  // for now. Uncomment once the .mp3 files are added to data/.
  /*
  String file = musicFileForState(state);
  if (file == null) return;
  if (state == bgMusicState && bgMusic != null && bgMusic.isPlaying()) return;

  if (bgMusic != null) bgMusic.stop();
  bgMusic = new SoundFile(this, file);
  bgMusic.amp(musicVolume);
  bgMusic.loop();
  bgMusicState = state;
  */
}

String musicFileForState(int state) {
  switch (state) {
    case MENU:
    case SCORE:
    case OPTIONS:
      return "music_menu.mp3";
    case GAME:
    case WIN:
    case LOSE:
      return "music_game.mp3";
  }
  return null;
}

void playSFX(String name) {
  // SFX files (e.g. sfx_select.wav) not delivered yet -- disabled for now.
  // Uncomment once they're added to data/.
  /*
  SoundFile sfx = sfxCache.get(name);
  if (sfx == null) {
    sfx = new SoundFile(this, name);
    sfxCache.put(name, sfx);
  }
  sfx.amp(sfxVolume);
  sfx.play();
  */
}

float getMusicVolume() {
  return musicVolume;
}

float getSFXVolume() {
  return sfxVolume;
}

void setMusicVolume(float v) {
  musicVolume = constrain(v, 0, 1);
  if (bgMusic != null) bgMusic.amp(musicVolume);
}

void setSFXVolume(float v) {
  sfxVolume = constrain(v, 0, 1);
}

void loadSettings() {
  JSONObject j = loadJSONObject("settings.json");
  if (j != null) {
    musicVolume = j.getFloat("musicVolume", 0.7);
    sfxVolume = j.getFloat("sfxVolume", 0.8);
  }
  if (bgMusic != null) bgMusic.amp(musicVolume);
}

void saveSettings() {
  JSONObject j = new JSONObject();
  j.setFloat("musicVolume", musicVolume);
  j.setFloat("sfxVolume", sfxVolume);
  saveJSONObject(j, dataPath("settings.json"));
}
