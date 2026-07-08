import processing.sound.*;

SoundFile bgMusic;
SoundFile menuMusicFile, playMusicFile;
HashMap<String, SoundFile> sfxCache = new HashMap<String, SoundFile>();

float musicVolume = 0.7;
float sfxVolume = 0.8;

// All SoundFiles are preloaded here (same pattern as images/fonts elsewhere)
// instead of being constructed lazily on first use. A freshly-constructed
// SoundFile that gets amp()'d and played in that same call isn't guaranteed
// to have finished initializing yet, which is what let play_music/death/
// agachar/saltar silently ignore the volume sliders the first time each was
// triggered -- menu_music (built once at startup) and botoes (reused across
// many clicks) simply had enough time to warm up before anyone noticed.
void loadAudio() {
  menuMusicFile = new SoundFile(this, "menu_music.mp3");
  playMusicFile = new SoundFile(this, "play_music.mp3");

  preloadSFX("botoes.mp3");
  preloadSFX("agachar.mp3");
  preloadSFX("saltar.mp3");
  preloadSFX("death.mp3");

  loadSettings();
}

void preloadSFX(String name) {
  sfxCache.put(name, new SoundFile(this, name));
}

void playMusicForState(int state) {
  SoundFile target = musicFileForState(state);
  if (target == null) return;
  if (target == bgMusic && bgMusic.isPlaying()) return;

  if (bgMusic != null) bgMusic.stop();
  bgMusic = target;
  bgMusic.amp(musicVolume);
  bgMusic.loop();
}

SoundFile musicFileForState(int state) {
  switch (state) {
    case MENU:
    case SCORE:
    case OPTIONS:
      return menuMusicFile;
    case GAME:
    case WIN:
    case LOSE:
      return playMusicFile;
  }
  return null;
}

void playSFX(String name) {
  SoundFile sfx = sfxCache.get(name);
  if (sfx == null) {
    sfx = new SoundFile(this, name);
    sfxCache.put(name, sfx);
  }
  sfx.amp(sfxVolume);
  sfx.play();
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
