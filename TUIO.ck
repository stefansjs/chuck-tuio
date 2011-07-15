public class TUIO
{
    OscRecv listener;
    3333 => int Port;
    10 => int NumTouches;
    
    -1 => int FrameSeq;
    
    0 => int debug;
    
    Touch @ TouchList;
    
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
            spork ~ aliveListener(listener.event(alivestring),i+1);
        }
        spork ~ setListener(listener.event("/tuio/2Dcur,s,i,f,f,f,f,f"));
    }
    
    function void aliveListener(OscEvent event, int NumIDs)
    {
        if(debug > 1)
            <<<"TUIO.ck, aliveListener(): listener started",NumIDs>>>;
        string message;
        while(true){
            event => now;
            if(debug > 1)
                <<<"TUIO.ck, aliveListener(): Alive event",NumIDs>>>;
            while(event.nextMsg() != 0){
                event.getString() => message;
                if(message == "fseq"){
                    if(TouchList == NULL)
                        <<<"TUIO.ck, aliveListener(): Null TouchList, fuck.",TouchList>>>;
                    TouchList.cleanupTouches(FrameSeq) @=> TouchList;
                    event.getInt() => FrameSeq;
                    if(debug > 1)
                        <<<"TUIO.ck, aliveListener(): fseq:",FrameSeq>>>;
                }
                else if(message == "alive"){
                    if(debug > 1)
                        <<<"TUIO.ck, aliveListener(): alive:",FrameSeq>>>;
                    for(0 => int count; count < NumIDs; count++){
                        if(debug > 5){
                            if(TouchList == NULL)
                                <<<"TUIO.ck, aliveListener(): Null TouchList, fuck.",TouchList>>>;
                            else
                                <<<"TUIO.ck, aliveListener(): non-null TouchList",TouchList,event>>>;
                        }
                        TouchList.aliveTouch(event.getInt(),FrameSeq);
                    }
                }
            }
        }
    }
    
    function void setListener(OscEvent event)
    {
        if(debug > 1)
            <<<"TUIO.ck, setListener(): Listener started">>>;
        string set;
        int ID;
        float x, y;
        float dxdt, dydt;
        float a;
        while(true){
            event => now;
            if(debug > 1)
                <<<"TUIO.ck, setListener(): Set event">>>;
            while(event.nextMsg() != 0){
                event.getString() => set;
                if(debug > 3)
                    <<<"TUIO.ck, aliveListener():",set>>>;
                if(set == "set"){
                    event.getInt() => ID;
                    event.getFloat() => x;
                    event.getFloat() => y;
                    event.getFloat() => dxdt;
                    event.getFloat() => dydt;
                    event.getFloat() => a;
                    if(debug > 2)
                        <<<"TUIO.ck, setListener(): Touch Update (setlistener)">>>;
                    TouchList.update(ID,FrameSeq,x,y,dxdt,dydt,a) @=> TouchList;
                }
            }
        }
    }
}
        