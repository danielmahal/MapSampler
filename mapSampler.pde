import android.os.Environment;
import apwidgets.*;
import ketai.camera.*;
import ketai.sensors.*;

// 12.536, 55.6970, 12.5496, 55.7015

MercatorMap map;
KetaiSensor sensor;
KetaiLocation location;
KetaiCamera cam;
DataStore data;

APWidgetContainer widgetContainer; 
APToggleButton captureButton;
APButton resetButton;

//final String imagePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/mapSamplerPictures";
final String picturePath = "//sdcard/Pictures";
final String imageFolder = "mapSamplerPictures";

PVector position;
PVector accelerometer;
PImage mapBackground;

boolean capture = false;

void setup() {
    size(displayWidth, displayHeight);
    frameRate(24);
    orientation(LANDSCAPE);
    
    data = new DataStore("mapSamples", this);
    cam = new KetaiCamera(this, 1024, 768, 24);
    mapBackground = loadImage("map.png");
    map = createMap(width, height, 12.536, 55.6970, 12.5496, 55.7015);
    sensor = new KetaiSensor(this);
    location = new KetaiLocation(this);
     
    captureButton = new APToggleButton(10, 10, 100, 50, "Capture"); 
    resetButton = new APButton(120, 10, 100, 50, "Reset");
    
    widgetContainer = new APWidgetContainer(this);
    widgetContainer.addWidget(captureButton); 
    widgetContainer.addWidget(resetButton);
    
    sensor.start();
    cam.setSaveDirectory(imageFolder);
    
    printLatestData();
}

void printLatestData() {
    data.db.query("SELECT * from " + data.table + " WHERE sessionId='" + data.sessionId + "'");
    
    while(data.db.next()) {
        println("Sample from session " + data.sessionId + ": " + data.db.getLong("time") + ", " + data.db.getFloat("latitude") + ", " + data.db.getFloat("longitude"));
    }
}

void draw() {
    image(mapBackground, 0, 0);
    image(cam, 10, 70, 160, 120);
    drawStatusText();
    
    if(!cam.isStarted()) {
        try {
            cam.start();
            println("Starting camera.");
        } catch(Exception e) {
            println("Can't start camera.");
        }
    }
}

void drawStatusText() {
    String status;
    
    if(isCapturing()) {
        status = "Capturing data\nSession id:" + data.sessionId;
    } else {
        status = "Not capturing data";
        
        if(capture && position == null) status += "\n" + "Waiting for position";
        if(capture && accelerometer == null) status += "\n" + "Waiting for accelerometer";
        if(capture && !cam.isStarted()) status += "\n" + "Waiting for camera";
    }
    
    fill(0);
    noStroke();
    textSize(22);
    textAlign(LEFT, BOTTOM);
    text("Status: " + status, 10, height - 10);
}

boolean isCapturing() {
    boolean captureReady = position != null && accelerometer != null && cam.isStarted();
    return capture && captureReady;
}

MercatorMap createMap(int w, int h, float leftLon, float bottomLat, float rightLon, float topLat) {
    return new MercatorMap(w, h, topLat, bottomLat, leftLon, rightLon);
}

void onCameraPreviewEvent() {
    cam.read();
}

void exit() {
    if(cam.isStarted()) 
        cam.stop();
    
    super.exit();
}

void onClickWidget(APWidget widget) {
    if(widget == captureButton) { 
        if(captureButton.isChecked()) {
            startCapturing();
        } else {
            stopCapturing();
        }
    }
    
    if(widget == resetButton) {
        println("Reset button clicked");
        captureButton.setChecked(false);
        stopCapturing();
        data.reset();
    }
}

void saveImage(String filename) {
    if(cam.isStarted()) {
        if(cam.savePhoto(filename)) {
            println("Saved photo " + filename);
        } else {
            println("Could not save photo " + filename);
        }
    }
}

void startCapturing() {
    data.newSession();
    capture = true;
}

void stopCapturing() {
    capture = false;
}

void onAccelerometerEvent(float x, float y, float z, long time, int accuracy) {
    accelerometer = new PVector(x, y, z);
}

void onLocationEvent(double latitude, double longitude, double altitude) {
    position = new PVector((float) latitude, (float) longitude, (float) altitude);
    
    if(isCapturing()) {
        int id = (int) System.currentTimeMillis();
        
        data.store(id, position, accelerometer);
        saveImage(Integer.toString(id));
    }
}
