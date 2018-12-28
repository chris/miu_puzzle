# miu_puzzle

This is a mobile app (game) for the [MIU Puzzle](https://en.wikipedia.org/wiki/MU_puzzle) as described in Douglas Hofstadter's _[Gödel, Escher, Bach: an Eternal Golden Braid](https://en.wikipedia.org/wiki/G%C3%B6del,_Escher,_Bach)_ book.

Note, this is rather pointless (in terms of being able to solve the puzzle :), and was just a way to try out Flutter and Dart.

## Getting Started

This mobile app is built using [Flutter](https://flutter.io).

Open it in Android Studio and run for your chosen mobile device.

## My Personal Notes on Using Flutter

* The most critical thing to note right off is that Flutter does nothing to make your app appear native on the respective platform. It uses Material by default, which clearly is NOT what an iOS app should look like. So, that works great on Android, but not good for iOS. You can use the Cupertino widgets to make it look like iOS, but now either your Android app looks wrong, or you're going to need to write conditional logic (or similar) to pick the proper widget based on platform. And it should be noted that the corresponding widgets don't always use the same property names, so you can't as easily generic/template it. [This article](https://medium.com/flutter-io/do-flutter-apps-dream-of-platform-aware-widgets-7d7ed7b4624d) covers one way to create factory widgets that create the proper widget, and the comments on the article discuss some of Flutter's philosophy and issues around all this.
    * Depending on the app you're building, this could work out fine, if you are say doing a lot of very custom visual presentation of things (with then maybe minor use of native items for popup alerts or similar). This seems to be Flutter's intent too.
    * Otherwise it sounds like the suggestion is to use React Native, etc.
* It initially seemed to remind me of Java, with a lot of interfaces and builders and what seemed like an excessive use of classes, but it may not be too bad...
    * e.g. why do StatefulWidgets need a separate class to hold the state, but then that “state” class actually seems to always have nearly the entire implementation, vs. just holding the state and maybe doing state transforms (it instead does all the UI widget building, etc.). This feels backwards.
* There is a fairly good/significant use of passing functions around, and use of anonymous functions, etc., which feels fairly good in this context.
* Really wish their docs showed a visual example of each widget.
* I was able to get an app and running pretty quickly. Had to hack around a fair bit to figure out the best way to do the MIU string scrolling thing, with “buttons”/cells that “toggle”, etc., but pretty easy once determined the approach.
* I think to continue, one would need to spend some good time reading the Layout related tutorials and docs, to really get a good understanding of how to do complex/intricate layouts and achieve the positioning, as well as dynamic re-layout (e.g. for diff screen sizes, or when switching between portrait and landscape).
* In general, I'd say Flutter is relatively intuitive in terms of a Widget-based system and how I think about building UI heavy apps (certainly as compared to using HTML - I still find these widget or windowing style frameworks far more intuitive). 