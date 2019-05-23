import "dart:html";

import 'package:AudioLib/AudioLib.dart';

void main() {
    bool started = false;


    querySelector("#test").onClick.listen((Event e) async {
        if (!started) {
            started = true;
            new Audio("sounds");
            Audio.createChannel("test");
        }
        try {
            await Audio.play("nottoaster", "test");
        } on ProgressEvent catch(e) {
            print(e);
        }
        print("boop?");
    });
}
