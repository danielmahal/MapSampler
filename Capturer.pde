import android.content.Context;
import ketai.camera.*;
import ketai.sensors.*;

class Capturer {
    DataStore data;
    KetaiSensor sensor;
    KetaiLocation location;
    KetaiCamera cam;

    boolean record = false;
    PVector position;
    PVector accelerometer;

    Capturer(DataStore dataStore, PApplet context) {
        data = dataStore;
        
        cam = new KetaiCamera(context, 1024, 768, 24);
        sensor = new KetaiSensor(context);
        location = new KetaiLocation(context);
        
        cam.setSaveDirectory(imageFolder);
    }
    
    boolean sensorsStarted() {
        return sensor.isStarted() && position != null && cam.isStarted();
    }
    
    void stopSensors() {
        if(sensor.isStarted()) sensor.stop();
        if(cam.isStarted()) cam.stop();
    }
    
    void startSensors() {
        image(cam, 10, 70, 160, 120); // Camera don't work without drawing first (ketai bug)
        
        if(!sensor.isStarted()) sensor.start();
        if(position == null) location.start();
        if(!cam.isStarted()) try { cam.start(); } catch(Exception e) {};
    }
    
    void draw() {
        if(!sensorsStarted()) {
            println("Sensors is not started. Start sensors");
            startSensors();
        }
        
        background(0);
        drawStatusText();
        image(cam, 10, 70, 160, 120);
        
        fill(255);
        noStroke();
        textAlign(RIGHT, BOTTOM);
        text("End", width - 10, height - 10);
    }

    void drawStatusText() {
        String status;

        if (isRecording()) {
            status = "Capturing data\nSession id:" + data.sessionId;
        } else {
            status = "Not capturing data";

            if (record && position == null) status += "\n" + "Waiting for position";
            if (record && accelerometer == null) status += "\n" + "Waiting for accelerometer";
            if (record && !cam.isStarted()) status += "\n" + "Waiting for camera";
        }

        fill(255);
        noStroke();
        textSize(22);
        textAlign(LEFT, BOTTOM);
        text("Status: " + status, 10, height - 10);
    }

    boolean isRecording() {
        boolean ready = position != null && accelerometer != null && cam.isStarted();
        return record && ready;
    }

    void saveImage(String filename) {
        if (cam.isStarted()) {
            if (cam.savePhoto(filename)) {
                println("Saved photo " + filename);
            } 
            else {
                println("Could not save photo " + filename);
            }
        }
    }

    void startRecording() {
        data.newSession();
        record = true;
    }

    void stopRecording() {
        record = false;
    }
    
    void mousePressed() {
        if(mouseX > width - 120 && mouseY > height - 100) {
            stopRecording();
            stopSensors();
            showHome();
        }
    }

    void onCameraPreviewEvent() {
        cam.read();
    }

    void onAccelerometerEvent(float x, float y, float z, long time, int accuracy) {
        accelerometer = new PVector(x, y, z);
    }

    void onLocationEvent(double latitude, double longitude, double altitude) {
        position = new PVector((float) latitude, (float) longitude, (float) altitude);

        if (isRecording()) {
            int id = (int) System.currentTimeMillis();

            data.store(id, position, accelerometer);
            saveImage(Integer.toString(id));
        }
    }
    
    void exit() {
        if (cam.isStarted()) {
            cam.stop();
        }
    }
}

