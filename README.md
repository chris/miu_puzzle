# MIU Puzzle

This is a mobile app (game) for the [MIU Puzzle](https://en.wikipedia.org/wiki/MU_puzzle) as described in Douglas Hofstadter's _[Gödel, Escher, Bach: an Eternal Golden Braid](https://en.wikipedia.org/wiki/G%C3%B6del,_Escher,_Bach)_ book.

Note, this is rather pointless (in terms of being able to solve the puzzle :), and was just a way to try out Flutter and Dart.

A key note - this is not high quality sample code - I'm just goofing around and trying things out, so there is definite cleanup that's needed, there may be non-idiomatic things (I'm just learning Dart & Flutter), blah blah blah. Read with discretion :)

A few feature notes:

* The current state of the game is in a horizontal scrolling view, drag to scroll it if needed.
* You can undo all the way back to the start of the game.
* Signing up will create a user, and save the current state of the game for that user.
* Logging in just logs in, and will wipe out your current game state (hopefully I'll change this at some point to either prompt, or to ask if you want to replace it, etc.).
* It uses a Firebase database subscription, such that if you login to two different devices, and play, that play will stay synchronized.


## Use/Build

The mobile app was developed using the [Flutter](https://flutter.io) framework, which uses the [Dart](https://www.dartlang.org/) language. It also use Firebase services for auth and database. You will need to add your own google-services.json and GoogleService-Info.plist files to use your own Firebase account.

Build it in Android Studio and run for your chosen mobile device.

Note, when using the iOS Simulator, rotate the device after starting it (this will be done automatically for Android devices).


## Some Personal Notes on Using Flutter

Take these notes with a big grain of salt :).  I have my biases based on apps for mainstream consumer use and expectations of the highest caliber design with a bias for that design fitting the platform.

### Flutter Notes

* Compiles two ways, depending on what doing: AOT for building a shippable app (gives better performance, etc.), and JIT for development/hot-reload (enables super fast re-compile/hot-reload).
* Hot Reload is awesome, and is incredibly fast with this. I've used hot reload with some other frameworks/systems, and none are as fast. Also, it's stateful, so your app doesn't revert to it's startup state, it stays right where it was, with all existing state, etc. This alone is I think hugely underappreciated. I've done the native app dev cycle on both iOS and Android, and the time it takes to compile, then fire up the app again, etc. is just excruciating in comparison.
* Flutter renders all its own widgets. It does not use native widgets. However, it is also does not need a "bridge" like React Native or various others do, and this leads to higher performance (60fps rendering ability). There are also some other advantages for example any widget you use will work on any OS/platform, and when a new widget comes out, it will work on older OS's, etc. Disadvantage may be lack of access to some platform specific widget you need, that they don't have (???).
* Initially the non-native widgets aspect really bothered me. But as I look at apps these days, and think about many of the apps I really like using (HotelTonight, Gmail are two interesting examples in this vein), either they have a ton of custom UI and branding and the platform-specific UI aspects are very minor (e.g. HotelTonight), or I notice that it's not native (at least on iOS), but the app works very well, is intuitive to use, and the UI elements, again while I notice don't look native, I just quickly move past (Gmail).
    * This is one of the big things talked about around Flutter, i.e. their claim that mobile apps are getting away from "cookie cutter", and moving towards heavily branded, highly designed apps that aren't just a combo of native widgets.
* Layout - seems more complicated (to some degree - need to learn all the diff containers and options), but more powerful than FlexBox, and actually behaves better. Also, it’s all in code, you aren’t mixing XML/JSX and code, etc., so while I don’t find JSX too bad, I think this is better and also easier to read.
* Tree-shaking compiler, thus removes dead/unused code.
* Dart initially seemed to remind me of Java, with a lot of interfaces and builders and what seemed like an excessive use of classes, but it may not be too bad...
    * e.g. why do StatefulWidgets need a separate class to hold the state, but then that “state” class actually seems to always have nearly the entire implementation, vs. just holding the state and maybe doing state transforms (it instead does all the UI widget building, etc.). This feels backwards.
* There is a fairly good/significant use of passing functions around, and use of anonymous functions, etc., which feels fairly nice in this context.
* Really wish their docs showed a visual example of each widget.
* I was able to get an app up and running quite quickly. Had to hack around a fair bit to figure out the best way to do the MIU string scrolling thing, with “buttons”/cells that “toggle”, etc., but pretty easy once I determined the approach to use.
* I think to continue, one would need to spend some good time reading the Layout related tutorials and docs. I probably spent the most time in this area, fiddling to get desired layout working. Thus I'd need to really get a good understanding of how to do complex/intricate layouts and achieve the positioning, as well as dynamic re-layout (e.g. for diff screen sizes, or when switching between portrait and landscape) for real apps.
* In general, I'd say Flutter is relatively intuitive in terms of a Widget-based system and how I think about building UI heavy apps (certainly as compared to using HTML (or even JSX) - I still find these widget or windowing style frameworks far more intuitive).

### More on Flutter not using platform specific widgets

So, per above, while the trend may be towards pure custom and away from all native widgets, I still think there are expectations to how an app behaves on a given platform. These often just make the app slight faster to use by the user, as with native controls there is no slight pause to notice it's different, or find something in a different place, etc. Thus, I would strive to at least be using native alert dialogs, iconography, placement of standard controls, and striving for using a layout that is intuitive to the platform. Therefore I'm still a bit torn on some of the challenges of using the "proper" looking widgets on iOS (using Material on Android you're fine, this really has to do with iOS)...

You can use the Cupertino widgets to make it look like iOS, but now either your Android app looks wrong, or you're going to need to write conditional logic to pick the proper widget based on platform. And it should be noted that the corresponding widgets don't always use the same property names, so you can't as easily generic/template it. [This article](https://medium.com/flutter-io/do-flutter-apps-dream-of-platform-aware-widgets-7d7ed7b4624d) covers one way to create factory widgets that create the proper widget, and the comments on the article discuss some of Flutter's philosophy and issues around all this. However, it seems that article is out of date, because the base class types of things like app bars and scaffolds vary considerably between the Material and Cupertino types - e.g. the things those return (such as the app bars) are not actually `Widget` types, but instead `PreferredSizeWidget` (or a subclass), so the abstract class factory doesn't work since it's base type is `Widget` and the scaffolds, etc. expect the more specific type. This led to me looking at doing a more specific factory for this case, or really, just the following code:

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

Or, see the example in the code at the bottom of main.dart, where it uses an iOS specific alert dialog on iOS (and Material style on all other).

The above works, and seems relatively compact. But you'd definitely want the generics-based approach or similar if you were going to do that all over. And it turns out, you'd really pretty much have to do it for a ton of widgets, because things like `IconButton` don't exist in Cupertino, *and* they require having a Material based enclosing Widget to even work (so, when using the above scaffold/page on iOS, IconButtons within the app don't work).

Thus, my take is that Flutter is always saving you much in terms of writing a single app that works across multiple platforms. Yes, you can certainly keep all your logic and data management platform agnostic, but you may be writing some or a lot of the UI/UX as separate code for each platform, unless you're ok having one of the platforms not look "correct", or your app is nearly all custom UI (or UI that isn't using standard a lot of the standard UI controls that look different across platforms).

Alternatively if you have such a custom styled app that is purely the brand design, and doesn't try to conform to the native platform's look for anything, then it may work great for you. Or, if you have an extremely simple app that has very few UI widgets and thus the design difference may not be so noticeable, Flutter may work well.

From what I've seen, it seems like people essentially say to use React Native if you want actual native widgets on each platform. I cannot really comment much on React Native. I've read their getting started, etc. and it certaily seems a viable platform, but has some downsides (arguably), such as the JS bridge, slower rendering, and then it may depend on your like of JavaScript and JSX (I'm not a big fan, although can think of worse, but it's one thing that lead me to look for alternatives).

I'm curious what successful, commercial, consumer apps use Flutter - e.g. what apps that your typical consumer would find in the app stores use Flutter and don't have negative feedback in this area (or in these cases, do they thus build two different UI's within the one app, one for each platform)?

Initially this whole issue was a bit of a negative/turn-off for me. However, as I've studied a few apps, thought about it further, and considered how it might fit for my personal needs (I'm evaluating this more for personal projects), it's pretty interesting. Oddly, I almost think that there's a middle ground that is what it doesn't fit. Tiny apps, or personal projects, where you want to cover multiple platforms, Flutter will make your life a lot easier. Commercial, highly polished, very professional apps, it could work great too, as you'd like have enough design and hand crafted UX that you can special case the few noticeable cases of native widget look you need. So, the middle ground of sort of "average" apps that don't have a lot of special UI, and use a lot of standard platform widgets, etc., may be the more painful arena.

