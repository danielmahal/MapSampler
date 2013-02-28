// map.png: 12.536, 55.6970, 12.5496, 55.7015
// map-ciid.png: 12.5915,55.6820,12.6021,55.6855

import apwidgets.*;
import ketai.camera.*;
import ketai.sensors.*;

final int HOME = 0;
final int CAPTURER = 1;
final int VIEWER = 2;

final String picturePath = "//sdcard/Pictures";
final String imageFolder = "mapSamplerPictures";

DataStore data;
Capturer capturer;
Viewer viewer;
Home home;

int section = HOME; 

void setup() {
    size(displayWidth, displayHeight);
    frameRate(24);
    orientation(LANDSCAPE);
    
    data = new DataStore("mapSamples", this);
//    capturer = new Capturer(data, this);
//    viewer = new Viewer(1, data);
    home = new Home(data);
}

void draw() {
    if(section == HOME) {
        home.draw();
    } else if(section == CAPTURER) {
//        capturer.draw();
    } else if(section == VIEWER) {
        viewer.draw();
    }
}

void mousePressed() {
    if(section == HOME) {
        home.mousePressed();
    } else if(section == CAPTURER) {
//        capturer.mousePressed();
    } else if(section == VIEWER) {
        viewer.mousePressed();
    }
}

void showHome() {
    section = HOME;
}

void showSession(int sessionId) {
    viewer = new Viewer(sessionId, data);
    section = VIEWER;
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
    if(capturer != null) {
        capturer.onLocationEvent(latitude, longitude, altitude);
    }
}

void exit() {
    capturer.exit();
    super.exit();
}
