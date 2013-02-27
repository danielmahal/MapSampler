class Sample {
    int time;
    int sessionId;
    PVector position;
    PVector accelerometer;
    
    Sample(int pTime, int pSessionId, PVector pPosition, PVector pAccelerometer) {
        time = pTime;
        sessionId = pSessionId;
        position = pPosition;
        accelerometer = pAccelerometer;
    }
}
