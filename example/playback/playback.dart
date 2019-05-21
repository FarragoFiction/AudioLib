import "dart:html";

import 'package:AudioLib/AudioLib.dart';

void main() {
    bool started = false;


    querySelector("#test").onClick.listen((Event e) {
        if (!started) {
            started = true;
            new Audio("sounds");
            Audio.createChannel("test");
        }
        Audio.play("toaster", "test");
        print("boop?");
    });
}
