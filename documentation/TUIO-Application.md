To get your application to register to receive TUIO events, you'll first need to [create your own "touch" class](touch-class.md). This document will describe the basics of what some TUIO event listener ChucK implementation would look like

# Create a listener #

  1. Instantiate TUIO
  1. Instantiate [your own touch class](touch-class.md)
  1. Initialize the TUIO instance with your TUIO listener class
  1. Start listening
  1. [Advance time](http://chuck.cs.princeton.edu/doc/language/time.html#advance)

Example:

```
TUIO listener;
CustomTouch Touches;
listener.init(Touches);
listener.startListening();

while(true){
    <<<"ping",now>>>;
    10::second => now;
}
```

Note that the ping message is not important, it just indicates that the shred is still running.
