import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:launcher_assist/launcher_assist.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends HookWidget {
  String title = "";

  MyHomePage({title});

  Widget build(BuildContext context) {
    var apps = useState([]);
    useEffect(() {
      LauncherAssist.getAllApps().then((x) => apps.value = x);
    }, [title]);

    var background = useState(null);
    useEffect(() {
      LauncherAssist.getWallpaper().then((x) => background.value = x);
    }, [title]);

    var shakes = useState(false);

    var controller = useAnimationController(
      duration: Duration(milliseconds: 500),
      lowerBound: 0,
      upperBound: 1,
    )..repeat();
    useMemoized(controller.forward, [controller]);
    var angle = useAnimation(controller);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: background.value == null
                ? Text("")
                : Image.memory(background.value),
          ),
          CustomScrollView(
            primary: false,
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.all(20.0),
                sliver: SliverGrid.count(
                  crossAxisSpacing: 10.0,
                  crossAxisCount: 3,
                  children: apps.value
                      .map((x) => Transform.rotate(
                          angle: shakes.value ? angle - .5 : .0,
                          child: GestureDetector(
                            onTap: () => LauncherAssist.launchApp(x['package']),
                            onLongPress: () => shakes.value = true,
                            child: Column(children: <Widget>[
                              Image.memory(
                                x['icon'],
                                width: 40,
                              ),
                              Text(
                                x['label'],
                                textAlign: TextAlign.center,
                              )
                            ]),
                          )))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
