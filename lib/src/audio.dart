import "dart:html";
import "dart:web_audio";

import "package:CommonLib/Logging.dart";
import "package:CommonLib/Random.dart";
import "package:LoaderLib/Loader.dart";

import "audioformats.dart";

class Audio {
    static final Logger log = new Logger("Audio");
    static Audio SYSTEM;

    static bool canPlayMP3 = false;
    static bool canPlayOgg = false;
    static String extension;
    static AudioFormat format;

    String path;

    AudioContext ctx;

    GainNode volumeNode;
    AudioParam volumeParam;

    num get volume => volumeParam.value;
    set volume(num val) => volumeParam.value = val;

    final Map<String, AudioChannel> channels = <String, AudioChannel>{};

    Random rand = new Random();

    // ######################################################################################################################
    // Init
    // ######################################################################################################################

    factory Audio([String path]) {
        if (SYSTEM == null) {
            // initialise the audio file formats *first*
            AudioFormats.init();

            // check ability to play formats
            final AudioElement testElement = new AudioElement();

            canPlayMP3 = testElement.canPlayType("audio/mpeg") != "";
            canPlayOgg = testElement.canPlayType("audio/ogg") != "";

            if (canPlayOgg) {
                extension = "ogg";
                format = AudioFormats.oggFormat;
            } else if (canPlayMP3) {
                extension = "mp3";
                format = AudioFormats.mp3Format;
            } else {
                throw Exception("Browser does not support ogg or mp3, somehow?");
            }

            // instantiate audio system
            SYSTEM = new Audio._(path == null || path.isEmpty ? "" : "$path/");
        } else {
            log.warn("Constructor invoked when audio system already exists, returning instance");
        }

        return SYSTEM;
    }

    Audio._(String this.path) {
        this.ctx = new AudioContext();
        this.volumeNode = new GainNode(ctx)..gain.value=1.0;
        this.volumeParam = volumeNode.gain;
        this.volumeNode.connectNode(ctx.destination);
    }

    AudioChannel iCreateChannel(String name, [double defaultVolume = 1.0]) {
        if (channels.containsKey(name)) {
            throw Exception("Audio channel already exists!");
        }

        final AudioChannel channel = new AudioChannel(name, this, defaultVolume);
        channel.volumeNode.connectNode(volumeNode);
        channels[name] = channel;
        return channel;
    }

    static AudioChannel createChannel(String name, [double defaultVolume = 1.0]) => SYSTEM.iCreateChannel(name, defaultVolume);

    // ######################################################################################################################
    // Playback
    // ######################################################################################################################

    Future<AudioBuffer> load(String sound) async {
        log.debug("Load sound: $sound");
        return Loader.getResource("$path$sound.$extension", format: format);
    }

    Future<AudioBufferSourceNode> iPlay(String sound, String channel, {double pitchVar = 0.0, bool loop = false}) async {
        log.debug("test");
        if (channels.containsKey(channel)) {
            return channels[channel].play(sound, pitchVar: pitchVar, loop: loop);
        }
        log.debug("Playback failed, channel $channel does not exist!");
        return null;
    }

    static Future<AudioBufferSourceNode> play(String sound, String channel, {double pitchVar = 0.0, bool loop = false}) async => SYSTEM.iPlay(sound, channel, pitchVar: pitchVar, loop: loop);

    // ######################################################################################################################
    // Utility
    // ######################################################################################################################

    MediaElementAudioSourceNode nodeFromElement(AudioElement element) => ctx.createMediaElementSource(element);

    static InputElement slider(dynamic param, [double min = 0.0, double max = 1.0, double increment = 0.01]) {
        if (!(param is AudioParam || param is AudioEffect )) {
            throw Exception("Unsupported type for Audio.slider, should be an AudioParam or AudioEffect");
        }

        final InputElement s = new RangeInputElement()
            ..min = min.toString()
            ..max = max.toString()
            ..step = increment.toString()
            ..valueAsNumber = param.value.clamp(min,max);

        s.onInput.listen((Event e) {
            param.value = s.valueAsNumber.toDouble();
        });
        s.onChange.listen((Event e) {
            param.value = s.valueAsNumber.toDouble();
        });

        return s;
    }
}

class AudioChannel {
    final Audio system;
    final String name;
    final GainNode volumeNode;
    AudioParam volumeParam;

    num get volume => volumeParam.value;
    set volume(num val) => volumeParam.value = val;

    AudioChannel(String this.name, Audio this.system, [double defaultVolume = 1.0]) : volumeNode = system.ctx.createGain() {
        this.volumeNode.connectNode(system.volumeNode);
        this.volumeParam = this.volumeNode.gain;
        this.volume = defaultVolume;
    }

    Future<AudioBufferSourceNode> play(String sound, {double pitchVar = 0.0, bool loop = false}) async {

        final AudioBuffer buffer = await system.load(sound);

        final AudioBufferSourceNode node = system.ctx.createBufferSource()
            ..buffer = buffer
            ..loop = loop
            ..connectNode(volumeNode);

        if (pitchVar > 0.0) {
            final double variance = system.rand.nextDouble() * pitchVar;

            if (system.rand.nextBool()) {
                // pitch up
                node.playbackRate.value = 1.0 + variance;
            } else {
                // pitch down
                node.playbackRate.value = 1.0 / (1.0 + variance);
            }
        }

        node.start(0);

        return node;
    }
}

abstract class AudioEffect {
    double value;
}
