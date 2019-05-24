import "dart:html";

import 'package:AudioLib/AudioLib.dart';

void main() {
    bool started = false;


    querySelector("#test").onClick.listen((Event e) async {
        if (!started) {
            started = true;
            new Audio("sounds");
            Audio.createChannel("test", 0.25);
        }
        /*try {
            await Audio.play("nottoaster", "test");
        } on ProgressEvent catch(e) {
            print(e);
        }*/

        Playlist testlist = new Playlist(<String>["tone","toaster"]);
        testlist.output.connectNode(Audio.SYSTEM.channels["test"].volumeNode);
        testlist.play();

        //(await Audio.play("tone", "test")).loop=true;

        print("boop?");
    });
}
