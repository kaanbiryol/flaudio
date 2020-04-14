# flaudio [wip]

**flaudio** is a Flutter plugin for playing audio files.

## Motivation
there are already some audio plugins out there. it is best you use them for now, i just wanted to implement an audio plugin using swift and kotlin for my own side-projects. i might enhance this in the future.
## Example
```dart
final player =  FLAudio();
player.onPlayerStateChanged.listen((state) => {}); 
player.onTick.listen((playerTime) => { } 
Duration duration = await player.prepare( "audio_url");
player.seek(10); // seek by +t/-t
player.seekTo(100); // seek to t
player.setPlaybackSpeed(2.0); // 0.5 <= t <= 2.0
player.dispose();
```
