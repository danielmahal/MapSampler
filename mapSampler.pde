// map.png: 12.536, 55.6970, 12.5496, 55.7015
// map-ciid.png: 12.5915,55.6820,12.6021,55.6855

import apwidgets.*;
import ketai.camera.*;
import ketai.sensors.*;

final String picturePath = "//sdcard/Pictures";
final String imageFolder = "mapSamplerPictures";

MercatorMap map;
DataStore data;
Capturer capturer;

PVector position;
PVector accelerometer;
PImage mapBackground;

void setup() {
    size(displayWidth, displayHeight);
    frameRate(24);
    orientation(LANDSCAPE);
    noLoop();
    
    data = new DataStore("mapSamples", this);
//    capturer = new Capturer(data, this);
    
    map = createMap(width, height, 12.5915, 55.6820, 12.6021, 55.6855);
    mapBackground = loadImage("map-ciid.png");
}

void draw() {
    image(mapBackground, 0, 0);
    drawLatestData();
    
//    capturer.draw();
}

void drawLatestData() {
    data.db.query("SELECT * from " + data.table + " WHERE sessionId='" + data.sessionId + "'");
    
    noFill();
    
    float radius = 5;
    PVector prev = null;
    
    while(data.db.next()) {
        PVector latLng = new PVector(data.db.getFloat("latitude"), data.db.getFloat("longitude"));
        PVector pixelPos = map.getScreenLocation(latLng);
        
        if(prev != null) {
            float angle = atan2(prev.y - pixelPos.y, prev.x - pixelPos.x);
            float distance = PVector.dist(prev, pixelPos);
            
            pushMatrix();
            
            stroke(0);
            
            translate(pixelPos.x, pixelPos.y);
            rotate(angle);
            
            stroke(0, 50);
            ellipse(0, 0, radius * 2, radius * 2);
            
            stroke(0);
            line(0, 0, radius, 0);
            
            stroke(0, 50);
            line(0, 0, distance, 0);
            
            popMatrix();
        }
        
        prev = pixelPos;
    }
}

MercatorMap createMap(int w, int h, float leftLon, float bottomLat, float rightLon, float topLat) {
    return new MercatorMap(w, h, topLat, bottomLat, leftLon, rightLon);
}

void onCameraPreviewEvent() {
    capturer.onCameraPreviewEvent();
}

void onClickWidget(APWidget widget) {
    capturer.onClickWidget(widget);
}

void onAccelerometerEvent(float x, float y, float z, long time, int accuracy) {
    capturer.onAccelerometerEvent(x, y, z, time, accuracy);
}

void onLocationEvent(double latitude, double longitude, double altitude) {
    capturer.onLocationEvent(latitude, longitude, altitude);
}

void exit() {
    capturer.exit();
    super.exit();
}
