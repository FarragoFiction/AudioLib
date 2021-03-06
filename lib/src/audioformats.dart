import 'dart:async';
import "dart:html";
import "dart:typed_data";
import "dart:web_audio";

import "package:LoaderLib/Loader.dart";

import "audio.dart";

abstract class AudioFormats {
    static bool _init = false;

    static late AudioFormat mp3Format;
    static late AudioFormat oggFormat;

    static late StreamedAudioFormat streamedMp3Format;
    static late StreamedAudioFormat streamedOggFormat;

    static void init() {
        if (_init) { return; }
        _init = true;

        mp3Format = new MP3Format();
        oggFormat = new OggFormat();

        streamedMp3Format = new StreamedMP3Format();
        streamedOggFormat = new StreamedOggFormat();
    }
}

abstract class AudioFormat extends BinaryFileFormat<AudioBuffer> {
    @override
    Future<AudioBuffer> read(ByteBuffer input) async => Audio.SYSTEM.ctx.decodeAudioData(input);

    @override
    Future<ByteBuffer> write(AudioBuffer data) => throw Exception("Audio saving not yet implemented");
}

class MP3Format extends AudioFormat {
    @override
    String mimeType() => "audio/mpeg";

    @override
    String header() => "";
}

class OggFormat extends AudioFormat {
    @override
    String mimeType() => "audio/ogg";

    @override
    String header() => "";
}

// streamed versions, good for music and stuff where exact timings aren't 100% necessary

abstract class StreamedAudioFormat extends ElementFileFormat<AudioElement> {

    @override
    Future<AudioElement> read(String input) async {
        final AudioElement element = new AudioElement(input);
        await element.onCanPlayThrough.first;
        return element;
    }

    @override
    Future<String> write(AudioElement data) => throw Exception("Audio write not implemented");
}

class StreamedMP3Format extends StreamedAudioFormat {
    @override
    String mimeType() => "audio/mpeg";
}

class StreamedOggFormat extends StreamedAudioFormat {
    @override
    String mimeType() => "audio/ogg";
}