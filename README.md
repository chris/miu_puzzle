# MIU Puzzle

This is a mobile app (game) for the [MIU Puzzle](https://en.wikipedia.org/wiki/MU_puzzle) as described in Douglas Hofstadter's _[Gödel, Escher, Bach: an Eternal Golden Braid](https://en.wikipedia.org/wiki/G%C3%B6del,_Escher,_Bach)_ book.

Note, this is rather pointless (in terms of being able to solve the puzzle :), and was just a way to try out Flutter and Dart.

## Use/Build

The mobile app was developed using the [Flutter](https://flutter.io) framework, which uses the [Dart](https://www.dartlang.org/) language.

Build it in Android Studio and run for your chosen mobile device.

Note, when using the iOS Simulator, rotate the device after starting it (this will be done automatically for Android devices).


## Some Personal Notes on Using Flutter

Take these notes with a big grain of salt :).  I have my biases based on apps for mainstream consumer use and expectations of the highest caliber design with a bias for that design fitting the platform.


### Flutter does not use platform specific widgets

The most critical thing to note right off is that Flutter does nothing to make your app appear native on the respective platform. It draws its own widgets. It uses the Material design/style by default, which clearly is NOT what an iOS app should look like. So, that works great on Android, but not good for iOS. You can use the Cupertino widgets to make it look like iOS, but now either your Android app looks wrong, or you're going to need to write conditional logic to pick the proper widget based on platform. And it should be noted that the corresponding widgets don't always use the same property names, so you can't as easily generic/template it. [This article](https://medium.com/flutter-io/do-flutter-apps-dream-of-platform-aware-widgets-7d7ed7b4624d) covers one way to create factory widgets that create the proper widget, and the comments on the article discuss some of Flutter's philosophy and issues around all this. However, it seems that article is out of date, because the base class types of things like app bars and scaffolds vary considerably between the Material and Cupertino types - e.g. the things those return (such as the app bars) are not actually `Widget` types, but instead `PreferredSizeWidget` (or a subclass), so the abstract class factory doesn't work since it's base type is `Widget` and the scaffolds, etc. expect the more specific type. This led to me looking at doing a more specific factory for this case, or really, just the following code:

```dart
final body = Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      _buildItem1(),
      _buildItem2(),
      _buildItem3(),
    ],
  ),
);
final appBarTitle = Text(widget.title);

if (Platform.isAndroid) {
  return Scaffold(
    appBar: AppBar(title: appBarTitle),
    body: body,
  );
} else if (Platform.isIOS) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(middle: appBarTitle),
    child: body,
  );
}
throw "Unsupported Platform";

```

The above works, and seems relatively compact. But you'd definitely want the generics-based approach or similar if you were going to do that all over. And it turns out, you'd really pretty much have to do it for a ton of widgets, because things like `IconButton` don't exist in Cupertino, and they require having a Material based enclosing layout/container to even work (so, when using the above scaffold/page on iOS, IconButtons within the app don't work).

Thus, my take is that Flutter is not necessarily saving you much in terms of writing a single app that works across multiple platforms. Yes, you can certainly keep all your logic and data management platform agnostic, but you're most likely going to be writing all the UI/UX as separate code for each platform, unless you're ok having one of the platforms not look "correct".

 Alternatively if you have such a custom styled app that is purely the brand design, and doesn't try to conform to the native platform's look for anything, then it may work great for you (however then Material and/or Cupertino widget sets aren't necessarily going to help you out a ton here either). Or, if you have an extremely simple app that has very few UI widgets and thus the design difference may not be so noticeable, Flutter may work well. However, even basic things like an alert popup, or if you had some kind of settings, or even the basic navbar/app bar stuff, may look odd to people.

From what I've seen, it seems like people essentially say to use React Native if you want actual native widgets on each platform.

I'm curious what successful, commercial, consumer apps use Flutter - e.g. what apps that your typical consumer would find in the app stores use Flutter and don't have negative feedback in this area (or in these cases, do they thus build two different UI's within the one app, one for each platform)?

Overall, I'm left somewhat disappointed, as I'm not sure I'd pursue Flutter for consumer level apps, in that if I'm going to write the UI twice, the value proposition is diminished. That said, it's not out of the question, since a lot of the rest of the app would still be common code, and often you want somewhat different UI designs across iOS and Android. Therefore I wouldn't rule it out, but it definitely has some caveats for me.

### Other observations

* It initially seemed to remind me of Java, with a lot of interfaces and builders and what seemed like an excessive use of classes, but it may not be too bad...
    * e.g. why do StatefulWidgets need a separate class to hold the state, but then that “state” class actually seems to always have nearly the entire implementation, vs. just holding the state and maybe doing state transforms (it instead does all the UI widget building, etc.). This feels backwards.
* There is a fairly good/significant use of passing functions around, and use of anonymous functions, etc., which feels fairly nice in this context.
* Really wish their docs showed a visual example of each widget.
* I was able to get an app up and running quite quickly. Had to hack around a fair bit to figure out the best way to do the MIU string scrolling thing, with “buttons”/cells that “toggle”, etc., but pretty easy once I determined the approach to use.
* I think to continue, one would need to spend some good time reading the Layout related tutorials and docs. I probably spent the most time in this area, fiddling to get desired layout working. Thus I'd need to really get a good understanding of how to do complex/intricate layouts and achieve the positioning, as well as dynamic re-layout (e.g. for diff screen sizes, or when switching between portrait and landscape) for real apps.
* In general, I'd say Flutter is relatively intuitive in terms of a Widget-based system and how I think about building UI heavy apps (certainly as compared to using HTML - I still find these widget or windowing style frameworks far more intuitive).
