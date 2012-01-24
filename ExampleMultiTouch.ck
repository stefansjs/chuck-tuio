class SinTouch extends Touch {
    
    SinOsc singen;
    //You MUST override createTouch()!

    function Touch createTouch(int id, int FSeq)
    {
        if(debug > 1)
            <<<"SinTouch, createTouch()",id,FSeq>>>;
        SinTouch newTouch;
        id => newTouch.id;
        FSeq => newTouch.FSeq;
        return newTouch;
    }
    
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
        positionToAmplitude(y) => singen.gain;
        positionToFrequency(x) => singen.freq;
        if(debug > 1)
            <<<"gain:",singen.gain(),"freq:",singen.freq()>>>;
    }
    function void endTouch()
    {
        singen =< dac;
    }
    
    function float positionToAmplitude(float pos)
    {
        0.9 => float peak;
        return peak * (1-pos);
    }
    function float positionToFrequency(float pos)
    {
        "note" => string mapping;
        false => int quantized;
        50.0 => float fmin;//Hz
        750.0 => float fmax;//Hz
        
        //linear map from fmin to fmax
        pos * (fmax-fmin) + fmin => pos;
        
        return pos;
    }
}

TUIO listener;
SinTouch list;
listener.init(list);
listener.startListening();
0 => int debug;
debug => listener.debug;

while(true){
    //<<<"ping",now>>>;
    10:: second => now;
}