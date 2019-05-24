import "dart:web_audio";
import "dart:html";

import "audio.dart";

class Playlist {
    final AudioNode output = Audio.SYSTEM.ctx.createGain();

    final Iterable<String> soundNames;

    String currentSoundName;
    AudioBufferSourceNode currentSound;

    Iterator<String> _iterator;
    bool _playing = false;
    bool loop = false;

    Playlist(Iterable<String> this.soundNames) {
        _iterator = soundNames.iterator;
    }

    Future<void> play() async {
        if (!_playing) {
            final bool iter = _iterator.moveNext();
            if (loop) {
                if (!iter) {
                    _iterator = soundNames.iterator..moveNext();
                }
            }

            final String name = _iterator.current;

            currentSound = await _makeBufferSource(name);
            currentSound.connectNode(output);
            _playing = true;
            if (iter || loop) {
                currentSound.onEnded.listen((Event e) {
                    if (_playing) {
                        play();
                    }
                });
            }
            currentSound.start(0);

        } else {
            stop();
            return play();
        }
    }

    void stop() {
        if (currentSound != null) {
            currentSound.stop();
        }
        _playing = false;
    }

    Future<AudioBufferSourceNode> _makeBufferSource(String sound) async {
        final AudioBufferSourceNode node = Audio.SYSTEM.ctx.createBufferSource();
        node.buffer = await Audio.SYSTEM.load(sound);
        return node;
    }
}