import "package:flutter/material.dart";

class CustomScaffold extends StatefulWidget {
  CustomScaffold({
    Key key,
  }) : super(key: key);

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {

  double _start = 0;
  double _update = 0;
  double _height = -1;
  ScrollPhysics _physics;
  ScrollController _controller = ScrollController();

  double _clamp(double min, double max, double value) {
    if (value < min) return min;
    else if (value > max) return max;
    else return value;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_height == -1)
      _height = (MediaQuery.of(context).size.height/2) - 80;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 80,
            color: Colors.red,
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                Expanded(
                  child: Container(
                    color: Colors.blue,
                  ),
                )
              ],
            ),
          ), ///AppBar
          Expanded(
            child: GestureDetector(
                onVerticalDragStart: (details) {
                  _start = details.globalPosition.dy;
                },
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _update = _start - details.globalPosition.dy;
                  });
                },
                onVerticalDragEnd: (details) {
                  double velocity = details.primaryVelocity;
                  _update = 0;
                  setState(() {
                    if (velocity != 0.0) {
                      if (velocity > 0) {
                        _height = (MediaQuery.of(context).size.height/2) - 80;
                      } else {
                        _height = 0;
                      }
                    } else {
                      print(_height);
                      if (_height > (MediaQuery.of(context).size.height/2) - 80) {
                        _height = (MediaQuery.of(context).size.height/2) - 80;
                      } else {
                        _height = 0;
                      }
                    }
                  });
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 50),
                      height: _clamp(0, (MediaQuery.of(context).size.height/2) - 80, _height-_update),
                      color: Colors.blueGrey,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.orange,
                        child: NotificationListener(
                          onNotification: (Notification notification) {
                            if (notification is UserScrollNotification) {
                              double pixels = notification.metrics.pixels;
                              int direction = notification.direction.index;
                              print("$pixels et $direction");
                              setState(() {
                                if (pixels == 0.0 && direction == 1)
                                  _physics = NeverScrollableScrollPhysics();
                              });
                            }

                            return true;
                          },
                          child: SingleChildScrollView(
                            physics: _physics,
                            controller: _controller,
                            child: Column(
                              children: [
                                SizedBox(height: 50,),
                                Container(
                                  height: 1000,
                                  color: Colors.black12,
                                )
                              ],
                            ),
                          ),
                        )
                      ),
                    )
                  ],
                )
            ),
          )
        ],
      )
    );
  }
}