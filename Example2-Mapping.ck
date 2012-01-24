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
        -60 => float mindB;
        -3 => float maxdB;
        
        1-pos => pos;
        pos * (maxdB - mindB) + mindB => pos;
        Math.pow(10,pos/20) => pos;
        
        return pos;
    }
    function float positionToFrequency(float pos)
    {
        "pitch" => string mapping;
        false => int quantized;
        20.0 => float fmin;//Hz
        1200.0 => float fmax;//Hz
        
        //define bounds
        if(mapping == "note"){
            //treat position as MIDI note
            Std.ftom(fmin) => fmin;
            Std.ftom(fmax) => fmax;
        }
        else if(mapping == "pitch"){
            //mel frequency mapping
            2595 * Math.log10(1 + (fmin/700)) => fmin;
            2595 * Math.log10(1 + (fmax/700)) => fmax;
        }
        
        //linear map from fmin to fmax
        pos * (fmax-fmin) + fmin => pos;
        
        //convert back to frequency
        if(mapping == "note"){
            //quantize if necessary
            if(quantized){
                Math.round(pos) => pos;//round by MIDI pitch
            }
            Std.mtof(pos) => pos;
        }
        else if(mapping == "pitch"){
            700 * (Math.pow(10,pos/2595) - 1) => pos;
        }
        
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
    10::second => now;
}