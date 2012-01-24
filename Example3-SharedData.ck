class SharedData {
    //Gain GlobalGain;
    0.9 => float GlobalGain;
}
class TouchWithSharedData extends Touch {
    SinOsc singen;
    
    0.9 => float MaxGain;
    0 => int NumTouches;
    SharedData shared;
    
    updateGain();
    //shared.GlobalGain => dac;
    

    function void beginTouch()
    {
        singen => dac;
        //float currentFreq;
        updateTouch();
    }
    function void updateTouch()
    {
        positionToAmplitude(y) * shared.GlobalGain => singen.gain;
        positionToFrequency(x) => singen.freq;
    }
    function void endTouch()
    {
        singen =< dac;
    }
    
    function float positionToAmplitude(float pos)
    {
        -90 => float mindB;
        -3 => float maxdB;
        
        1-pos => pos;
        pos * (maxdB - mindB) + mindB => pos;
        Math.pow(10,pos/20) => pos;
        
        return pos;
    }
    function float positionToFrequency(float pos)
    {
        200.0 => float fmin;
        1000.0 => float fmax;
        //return pos * (max - min) + min;
        
        "note" => string mapping;
        true => int quantized;
        
        //define bounds
        if(mapping == "note"){
            //treat position as MIDI note
            Std.ftom(fmin) => fmin;
            Std.ftom(fmax) => fmax;
        }
        else if(mapping == "pitch"){
            //mel frequency mapping (NOTE: note the right formula!!)
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
    function Touch createTouch(int id, int FSeq)
    {
        TouchWithSharedData newTouch;
        id => newTouch.id;
        FSeq => newTouch.FSeq;
        shared @=> newTouch.shared;
        
        return newTouch;
    }
    function void aliveTouch(int id, int FSeq, int NumTouches)
    {
        NumTouches => this.NumTouches;
        updateGain();
        updateTouch();
        aliveTouch(id,FSeq);
    }
    function void updateGain()
    {
        if(NumTouches > 0)
            MaxGain / NumTouches => shared.GlobalGain;
        else
            MaxGain => shared.GlobalGain;
    }
}

TUIO listener;
TouchWithSharedData list;
listener.init(list);
listener.startListening();
1 => listener.debug;
1 => list.debug;

while(true){
    //<<<"ping",now>>>;
    5::second => now;
}