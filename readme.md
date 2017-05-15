This is a [TUIO](http://www.tuio.org/?specification) implementation for [ChucK](http://chuck.cs.princeton.edu/) that enables building multi-touch music applications.

# Quick Start #

Unfortunately, this implementation is very particular to following a specific procedure. You can start by [Implementing a Touch subclass](documentation/touch-class.md). Once you've done that you'll need to [Create a TUIO application for ChucK](documentation/TUIO-Application.md). To get this application and your Touch class running:

  1. Add Touch.ck to the virtual machine
  1. Add TUIO.ck to the virtual machine
  1. Add your [custom class](documentation/touch-class.md) to the virtual machine
  1. Add your [application](documentation/TUIO-Application.md) to the virtual machine



# Introduction #

This implementation allows you to create a ChucK class which listens to TUIO touch events to create a powerful envent-driven music application. ChucK was chosen as a programming language because of it's "strongly-timed" real-time sound synthesis capabilities. Combined with an active DIY community on creating multi-touch tables, some academic [papers](http://www.nime.org/proceedings/2011/nime2011_008.pdf) and [theses](http://mue.music.miami.edu/wp-content/uploads/2012/11/StefanThesis.pdf).

TUIO is a multi-touch messaging protocol build on [OSC](http://opensoundcontrol.org/spec-1_0). Its purpose is to communicate between a multi-touch capable device and an application. 


## Using ChucK TUIO ##

In order to use this class, take a look at [the documentation on creating a touch class](documentation/touch-class.md) or the [examples](examples/). Also take a look at the [documentation on creating an a TUIO listener shread](documentation/TUIO-application.md). These are the only two pieces of documentation you need to use this library.


## Understanding the Code ##

More details on how the ChucK TUIO library functions are implemented are documented in [documentation/implementation.md](documentation/implementation.md)