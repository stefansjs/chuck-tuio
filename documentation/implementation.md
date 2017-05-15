Details on the contents of the ChucK Code files.

# [Touch.ck](../Touch.ck)

The Touch class is a linked list containing all the data associated with the [TUIO 2DCur](http://tuio.org/?specification) profile, as well as a variable for the current Frame Sequence ID (or fseq). It is the base class for multi-touch applications. Below is the complete list of member functions and variables.

The functions labeled "public interface" are the methods which are called by the TUIO class. The functions labeled "private functions" are only intended to be accessed by this class. These are your callback functions. They're discussed a bit further below. The functions labeled "static methods" are functions which don't depend on the member data of the class.

```
public class Touch
{
    int id;
    int FSeq;
    //position
    float x;
    float y;
    //velocity
    float dxdt;
    float dydt;
    //acceleration
    float a;
    
    Touch @ nextTouch;
    
    int debug;

    //Private Functions---------------
    function void beginTouch()
    function void updateTouch()
    function void endTouch()
    
    //Public Interface---------------
    function Touch update(int id, int FSeq, float x, float y, float dxdt, float dydt, float a)
    function void aliveTouch(int id, int FSeq)
    function Touch cleanupTouches(int FSeq)
    
    // --------------- static methods ---------------
    //just a helper function that returns a new touch given the parameters
    function Touch createTouch(int id, int FSeq)
    function Touch createTouch(int id, int FSeq, float x, float y, float dxdt, float dydt, float a)
    //Helper functions to perform mathematical manipulations on parameters
    function float transformPosition(float pos)
    function float transformPosition(float axis1, float axis2)
    function float transformPosition(float axis1, float axis2, float axis3)
    function float transformVelocity(float vel)
    function float transformVelocity(float axis1, float axis2)
    function float transformAcceleration(float acel)
}
```


## Public Interface

The `update()` method searches for the touch with the given ID. If it's found, the member data for that touch object is updated given the parameters passed into the update() function. If not, a new touch is created and inserted in order by id into the linked list.

The `aliveTouch()` method simply looks for a node with the give ID. If it's found, that object's `FSeq` variable is update. If not it is ignored.

`cleanupTouches()` recursively moves through the linked list and removes any objects whose `FSeq` is less than the given `FSeq` and returns the new list. The one exception is objects with an id < 0 are ignored. This is because this linked list makes the assumption that the first object in the list will always exist so that it can create new objects of the same type to add to the list. This becomes a little more clear once you see how the TUIO class operates.


## Private Functions (callbacks)

The private functions in this class are simultaneously the most important functions in the Touch class and the ones that do the least on their own. Their implementation in this class do absolutely nothing. These are abstract methods which are intended to be overridden by an extended class of the Touch class. In order to do anything interesting with unit generators, you probably want to override these callback functions.

## Static Methods

I don't think ChucK actually lets you call methods on an uninstantiated class, so the don't really function as static methods. The only one(s) used by this class by default are `createTouch()`. This is actually the most important method to override when you create a derived class of the Touch class. More on that later.

The other methods are just methods to perform arithmetic on the TUIO parameters. They are not used at all by this base class. They are just there to provide an example for use in the abstract callback methods (private functions). The [1-BasicMultiTouch.ck](../examples/1-BasicMultiTouch.ck) example demonstrates use of these types of static methods.

# [TUIO.ck](TUIO.ck)

The TUIO class is the one that does all the work of listening for TUIO events and calling the right methods on a Touch object (or some derived object). Below you can see all the member variables and functions.

```
public class TUIO
{
    OscRecv listener;
    3333 => int Port;
    10 => int NumTouches;
    
    -1 => int FrameSeq;
    
    0 => int debug;
    
    Touch @ TouchList;
    
    function void init(Touch CustomTouchObject)
    function void init(Touch CustomTouchObject, int PortNumber)
    function void init(Touch CustomTouchObject, int PortNumber, int NumberOfTouches)
    
    function void startListening()
    function void aliveListener(OscEvent event, int NumIDs)
    function void setListener(OscEvent event)
}
```

The only things you need to be worried about are `init()` and `startListening()` which must be called in that order on a TUIO object. You'll notice that the `init()` function requires a Touch object. It is expected that you will pass it a derived object of the Touch class. If you don't use a derived object of the Touch class, and instead pass a Touch object of the base class, the TUIO class will still function and the Touch list will be updated for any current touches, but no output will be generated, since the Touch class has empty callback methods.

Once the `startListening()` function is called, the TUIO class will spork shreds for the `aliveListener()` and `setListener()` functions. ChucK has this really unfortunate limitation with OSC listeners, where the format string must match exactly the right format and cannot use any sort of regex in the format string. This is only an issue because TUIO sends an "alive" message containing a variable number of integers representing the ID for each currently living touch. Since ChucK can't do a variable number of integers for an OSC event listener, the TUIO class creates one event for each possible number of alive IDs up to the `NumberOfTouches` variable passed into the init function.

The `aliveListener()` function listens for both alive messages and `FSeq` messages of the TUIO protocol. When an `FSeq` message is received it calls `cleanupTouches()` on the list to remove any old touches, and then updates the `FrameSeq` variable. When an alive message is received the `aliveTouch()` method is called on the list to update touches' `FSeq` variable.
