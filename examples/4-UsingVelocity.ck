class SharedData {
    0.9 => float GlobalGain;
}
class TouchWithSharedData extends Touch {
    
    SinOsc singen;
    
    LPF amplpf;
    Step ampstep;
    LPF freqlpf;
    Step freqstep;
    
    0.9 => float MaxGain;
    0 => int NumTouches;
    SharedData shared;
    
    0.7071 => amplpf.Q;
    10 => amplpf.freq;
    0.0 => ampstep.next;
    
    0.7071 => freqlpf.Q;
    10 => freqlpf.freq;
    0.0 => freqstep.next;
    
    updateGain();

    function void beginTouch()
    {
        singen => dac;
        ampstep => amplpf => blackhole;
        freqstep => freqlpf => blackhole;
        
        updateTouch();
    }
    function void updateTouch()
    {
        positionToFrequency(x) => freqstep.next;
        freqlpf.last() => singen.freq;
        
        velocityToAmplitude(mag(dxdt,dydt)) * shared.GlobalGain => ampstep.next;
        amplpf.last() => singen.gain;
        
        spork ~ continueUpdating();
    }
    function void endTouch()
    {
        singen =< dac;
        //amplpf =< blackhole;
        //freqlpf =< blackhole;
    }
    
    function void continueUpdating()
    {
        for(0 => int i; i < 1000; i++){
            1::samp => now;
            amplpf.last() => singen.gain;
            freqlpf.last() => singen.freq;
        }
    }
    
    function float mag(float dxdt, float dydt){
        return Math.sqrt(dxdt * dxdt + dydt * dydt);
    }
    function float angle(float dxdt, float dydt){
        return Math.tan(dydt/dxdt);
    }
    
    function float velocityToAmplitude(float vel){
        -70 => float mindB;
        -1 => float maxdB;
        
        Math.tanh(vel/4) => vel;
        vel * (maxdB - mindB) + mindB => vel;
        Math.pow(10,vel/20) => vel;
        
        return vel;
    }
    function float positionToAmplitude(float pos){
        return (1-pos);
    }
    function float positionToFrequency(float pos)
    {
        200.0 => float min;
        1000.0 => float max;
        
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

while(true){
    5::second => now;
}