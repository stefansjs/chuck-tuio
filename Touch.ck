//2-D touches
//singly linked list
public class Touch
{
    // --------------- member variables ---------------
    //these are mostly dictated by the TUIO protocol
    //       http://www.tuio.org/?specification
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
    
    //UGen ugenInstance;
    //Note to self, ugens have: gain() last() channels() chan()
    
    
    // --------------- preconstructor ---------------
    -1 => id;
    -1 => FSeq;
    
    //set default parameters
    0 => x;
    0 => y;
    
    0 => dxdt;
    0 => dydt;
    
    0 => a;
    
    //Debug output level
    0 => int debug;
    
    
    // --------------- member functions ---------------
    
    //Private Functions---------------
    //These 3 private functions serve as the multi-touch instrument
    //They're responsible for audio synthesis
    function void beginTouch()
    {
        if(debug > 1)
            <<<"Touch.ck: beginTouch()",id>>>;
        //connect to DAC and play note attack
        //ugenInstance => dac;
        //perform some prescribed attack (maybe based on parameters)
        //for this base class it does nothing
    }
    
    function void updateTouch()
    {
        if(debug > 1)
            <<<"Touch.ck: updateTouch()",id>>>;
        //update parameters of UGen (using static functions)
        //for this base class it does nothing
        /*
        for(0 => int i; i < ugenInstance.channels(); i++){
            ugenInstance.chan(i).gain(transformPosition(x));
        }
        */
    }
    
    function void endTouch()
    {
        if(debug > 1)
            <<<"Touch.ck: endTouch()",id>>>;
        //play note release and disconnect from DAC
        //perform some prescribed release (maybe based on parameters)
        //for this base class it does nothing
    }
    
    
        
    
    //Public Interface---------------
    function Touch update(int id, int FSeq, float x, float y, float dxdt, float dydt, float a)
    {
        if(debug > 5)
            <<<"Touch.ck, update():", id, "updating;", this.id>>>;
        if(id == this.id){
            if(debug > 1)
                <<<"Touch.ck, update(): Updated",id>>>;
            
            //chuck the parameters
            FSeq => this.FSeq;
            x => this.x;
            y => this.y;
            dxdt => this.dxdt;
            dydt => this.dydt;
            a => this.a;
            
            //update the UGen
            updateTouch();
            
            return this;//success
        }
        else if(id > this.id){
            if(nextTouch == null){
                createTouch(id,FSeq,x,y,dxdt,dydt,a) @=> nextTouch;
                
                return this;
            }
            else {
                nextTouch.update(id, FSeq, x, y, dxdt, dydt, a) @=> nextTouch;
                return this;
            }
        }
        else if(id < this.id){
            createTouch(id, FSeq, x, y, dxdt, dydt, a) @=> Touch NewTouch;
            
            this @=> NewTouch.nextTouch;
            return NewTouch;
        }
        else {
            <<<"Touch.ck, update(): something went seriously">>>;
            return null;
        }
    }
    
    function void aliveTouch(int id, int FSeq)
    {
        if(debug > 1)
            <<<"Touch.ck aliveTouch()",this.id,id,FSeq>>>;
        if(id == this.id){
            FSeq => this.FSeq;
            updateTouch();
        }
        else if(id > this.id){
            if(nextTouch != null)
                nextTouch.aliveTouch(id,FSeq);
            else
                <<<id,"Wasn't found in the list of Touches\n  aliveTouch(),",this.id,",",FSeq>>>;
        }
        /*
            else
                createTouch(id, FSeq) @=> nextTouch;
        }
        else if(id < this.id){
            createTouch(id, FSeq, x, y, dxdt, dydt, a) @=> Touch NewTouch;
            nextTouch @=> NewTouch.nextTouch;
            this @=> NewTouch.nextTouch;
        }
        else {
            <<<"something went seriously wrong in aliveTouch()">>>;
            //return null;
        }
        */
    }
    
    function Touch cleanupTouches(int FSeq)
    {
        if(debug > 1)
            <<<"Touch.ck cleanupTouches()",id,FSeq>>>;
        if(nextTouch != null)
            nextTouch.cleanupTouches(FSeq) @=> nextTouch;
        if(FSeq > this.FSeq && this.id != -1){
            spork ~ endTouch();
            //ChucK is garbage collected so this isn't a big deal, right?
            return nextTouch;
        }
        //else case:
        return this;
    }
    
    
    
    // --------------- static methods ---------------
    //just a helper function that returns a new touch given the parameters
    function Touch createTouch(int id, int FSeq)
    {
        if(debug > 1)
            <<<"Touch.ck, createTouch():",id>>>;
        
        Touch newTouch;
        id => newTouch.id;
        FSeq => newTouch.FSeq;
        return newTouch;
    }
    function Touch createTouch(int id, int FSeq, float x, float y, float dxdt, float dydt, float a)
    {
        createTouch(id,FSeq) @=> Touch newTouch;
        
        FSeq => newTouch.FSeq;
        x => newTouch.x;
        y => newTouch.y;
        dxdt => newTouch.dxdt;
        dydt => newTouch.dydt;
        a => newTouch.a;
        
        spork ~ newTouch.beginTouch();
        //spork ~ newTouch.updateTouch();
        
        return newTouch;
    }
    
    //The rest of these functions are just for performing 
    //manipulations between input paremeters and UGen parameters.
    //not necessary, but I thought might be helpful (esp. if overridden)
    function float transformPosition(float pos)
    {
        return pos;
    }
    function float transformPosition(float axis1, float axis2)
    {
        //euclidean distance
        return Math.sqrt(axis1 * axis1 + axis2 * axis2);
    }
    function float transformPosition(float axis1, float axis2, float axis3)
    {
        //euclidean distance
        return Math.sqrt(axis1 * axis1 + axis2 * axis2 + axis3 * axis3);
    }
    
    function float transformVelocity(float vel)
    {
        return vel;
    }
    function float transformVelocity(float axis1, float axis2)
    {
        //vector addition
        return Math.sqrt(axis1 * axis1 + axis2 * axis2);
    }
    
    function float transformAcceleration(float acel)
    {
        return acel;
    }
}