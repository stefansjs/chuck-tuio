class SinTouch extends Touch {
    
    //You MUST override nextTouch!
    //SinTouch @ nextTouch;
    //also, you can't do much interesting without overriding ugenInstance
    SinOsc singen;

    //It is also expected to override the following 3:
    function void beginTouch()
    {
        if(debug > 1)
            <<<"SinTouch: Begin Touch">>>;
        singen => dac;
        //float currentFreq;
        updateTouch();
    }
    function void updateTouch()
    {
        positionToAmplitude(y,1) => singen.gain;
        positionToFrequency(x) => singen.freq;
        if(debug > 1)
            <<<"gain:",singen.gain(),"freq:",singen.freq()>>>;
    }
    function void endTouch()
    {
        singen =< dac;
    }
    
    
    function float positionToAmplitude(float pos, int numTouches)
    {
        0.9 => float peak;
        return peak * pos / numTouches;
    }
    function float positionToFrequency(float pos)
    {
        200.0 => float min;
        1000.0 => float max;
        return pos * (max - min) + min;
    }
    function Touch createTouch(int id, int FSeq)
    {
        if(debug > 1)
            <<<"SinTouch, createTouch()",id,FSeq>>>;
        SinTouch newTouch;
        id => newTouch.id;
        FSeq => newTouch.FSeq;
        return newTouch;
    }
    /*
    function Touch createTouch(int id, int FSeq, float x, float y, float dxdt, float dydt, float a)
    {
        createTouch(id) @=> SinTouch newTouch;
        
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
    */
}

/*
Machine.add("Touch.ck");
Machine.add("TUIO.ck");
*/


TUIO listener;
SinTouch list;
listener.init(list);
listener.startListening();
0 => int debug;
debug => listener.debug;

//SinOsc sinetone => dac;
//100 => sinetone.freq;
//0.5 => sinetone.gain;
while(true){
    <<<"ping",now>>>;
    9::second => now;
    //400 => sinetone.freq;
    1:: second => now;
    //100 => sinetone.freq;
}