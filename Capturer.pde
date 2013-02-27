import android.content.Context;
import apwidgets.*;
import ketai.camera.*;
import ketai.sensors.*;

class Capturer {
    DataStore data;
    KetaiSensor sensor;
    KetaiLocation location;
    KetaiCamera cam;

    APWidgetContainer widgetContainer; 
    APToggleButton recordButton;
    APButton resetButton;

    boolean record = false;

    Capturer(DataStore dataStore, PApplet context) {
        data = dataStore;
        
        cam = new KetaiCamera(context, 1024, 768, 24);
        sensor = new KetaiSensor(context);
        location = new KetaiLocation(context);

        recordButton = new APToggleButton(10, 10, 100, 50, "Record"); 
        resetButton = new APButton(120, 10, 100, 50, "Reset");

        widgetContainer = new APWidgetContainer(context);
        widgetContainer.addWidget(recordButton); 
        widgetContainer.addWidget(resetButton);

        sensor.start();
        cam.setSaveDirectory(imageFolder);
    }
    
    void draw() {
        drawStatusText();

        if (cam.isStarted()) {
            image(cam, 10, 70, 160, 120);
        } 
        else {
            try {
                cam.start();
                println("Starting camera.");
            } 
            catch(Exception e) {
                println("Can't start camera.");
            }
        }
    }

    void drawStatusText() {
        String status;

        if (isRecording()) {
            status = "Capturing data\nSession id:" + data.sessionId;
        } 
        else {
            status = "Not capturing data";

            if (record && position == null) status += "\n" + "Waiting for position";
            if (record && accelerometer == null) status += "\n" + "Waiting for accelerometer";
            if (record && !cam.isStarted()) status += "\n" + "Waiting for camera";
        }

        fill(0);
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

    void onCameraPreviewEvent() {
        cam.read();
    }

    void onClickWidget(APWidget widget) {
        if (widget == recordButton) { 
            if (recordButton.isChecked()) {
                startRecording();
            }
            
            else {
                startRecording();
            }
        }

        if (widget == resetButton) {
            println("Reset button clicked");
            recordButton.setChecked(false);
            stopRecording();
            data.reset();
        }
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

