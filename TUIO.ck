public class TUIO
{
    OscRecv listener;
    3333 => int Port;
    10 => int NumTouches;
    
    -1 => int FrameSeq;
    [false] @=> int updating[];
    
    Touch @ TouchList;
    
    0 => int debug;
    
    function void init(Touch CustomTouchObject)
    {
        CustomTouchObject @=> TouchList;
    }
    function void init(Touch CustomTouchObject, int PortNumber)
    {
        init(CustomTouchObject);
        PortNumber => Port;
    }
    function void init(Touch CustomTouchObject, int PortNumber, int NumberOfTouches)
    {
        init(CustomTouchObject, NumberOfTouches);
        NumberOfTouches => NumTouches;
    }
    
    function void startListening()
    {
        Port => listener.port;
        listener.listen();
        "/tuio/2Dcur,s" => string alivestring;
        for(0 => int i; i < NumTouches; i++){
            alivestring + ",i" => alivestring;
            spork ~ aliveListener(listener.event(alivestring),i+1,updating);
        }
        spork ~ setListener(listener.event("/tuio/2Dcur,s,i,f,f,f,f,f"),updating);
    }
    
    function void aliveListener(OscEvent event, int NumIDs, int updating[])
    {
        if(debug > 1)
            <<<"TUIO.ck, aliveListener(): listener started",NumIDs>>>;
        string message;
        int stopUpdating;
        while(true){
            event => now;
            false => stopUpdating;
            
            if(debug > 5)
                <<<"TUIO.ck, aliveListener(): Alive event",NumIDs>>>;
            
            while(event.nextMsg() != 0){
                event.getString() => message;
                
                if(debug > 6)
                    <<<"TUIO.ck, aliveListener()",message>>>;
                
                if(message == "fseq"){
                    if(!stopUpdating){
                        
                        if(TouchList == NULL && debug > 2)
                            <<<"TUIO.ck, aliveListener(): Null TouchList, fuck.",TouchList>>>;
                        
                        false => updating[0];
                        TouchList.cleanupTouches(FrameSeq) @=> TouchList;
                        event.getInt() => FrameSeq;
                        true => stopUpdating;//prevents multiple fseqs from the same event.
                        
                        if(debug > 5)
                            <<<"TUIO.ck, aliveListener(): fseq:",FrameSeq>>>;
                    }
                }
                else if(message == "alive"){
                    if(debug > 5)
                        <<<"TUIO.ck, aliveListener(): alive:",FrameSeq>>>;
                    for(0 => int count; count < NumIDs; count++){
                        if(debug > 5){
                            if(TouchList == NULL)
                                <<<"TUIO.ck, aliveListener(): Null TouchList, fuck.",TouchList>>>;
                            else
                                <<<"TUIO.ck, aliveListener(): non-null TouchList",TouchList,event>>>;
                        }
                        TouchList.aliveTouch(event.getInt(),FrameSeq,NumIDs);
                    }
                }
            }
        }
    }
    
    function void setListener(OscEvent event, int updating[])
    {
        if(debug > 1)
            <<<"TUIO.ck, setListener(): Listener started","2DCur">>>;
        string set;
        int ID;
        float x, y;
        float dxdt, dydt;
        float a;
        while(true){
            if(debug > 4)
                <<<"Tuio.ck, setListener(): Waiting for set event.">>>;
            
            event => now;
            while(updating[0])
                0.1::samp => now;//Wait for the next FSeq message.
            
            if(debug > 4)
                <<<"TUIO.ck, setListener(): Set event">>>;
            
            while(event.nextMsg() != 0){
                event.getString() => set;
                if(debug > 6)
                    <<<"TUIO.ck, setListener():",set>>>;
                if(set == "set"){
                    event.getInt() => ID;
                    event.getFloat() => x;
                    event.getFloat() => y;
                    event.getFloat() => dxdt;
                    event.getFloat() => dydt;
                    event.getFloat() => a;
                    if(debug > 5)
                        <<<"TUIO.ck, setListener(): Touch Update">>>;
                    TouchList.update(ID,FrameSeq,x,y,dxdt,dydt,a) @=> TouchList;
                }
                else{
                    <<<"Not a set message?",set>>>;
                }
            }
            true => updating[0];
        }
    }
}
        