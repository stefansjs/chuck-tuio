This document will give you help on creating a custom TUIO class for ChucK using this module. To do this, it would be a good idea to read about [How ChucK TUIO Works](TUIO-application.md)

There's a lot of details on [how this library works](implementation.md). The most important thing is the [Touch](../Touch.ck) class which should be subclassed to deal with TUIO multi-touch events.

The most important thing that you ALWAYS need to do when overriding the Touch class is override the createTouch(int id, int FSeq) method. This method is what will allow your custom class to create new touches of the proper type (i.e. your class) to add to the linked list. It is not necessary to override createTouch(int id, int FSeq, float x, float y, float dxdt, float dydt, float a) because this method calls createTouch(int id, int FSeq) in the process. If this method is not overridden to return the custom touch object of your extended Touch class, then the list will be populated with Touch objects (of the base class), and none of your methods will be called. Nothing interesting will happen.

It is not strictly required to override anything else, but you'll probably want to override the `createTouch()` `updateTouch()` and `removeTouch()` methods. These are your callback functions and they will be called every time a touch starts, moves, or stops respectively.

DO NOT override any methods of the public interface. If you do things will almost certainly break.

There are several good examples of how this can be done in the [examples](../examples/) directory.