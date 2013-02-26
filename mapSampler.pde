import ketai.data.*;
import ketai.sensors.*;

KetaiSensor sensor;
KetaiLocation location;
KetaiSQLite db;

PVector position;
PVector accelerometer;
boolean isCapturing = false;
long timeLastSaved = 0;

void setup() {
    size(displayWidth, displayHeight);
    orientation(LANDSCAPE);

    db = new KetaiSQLite(this);
    sensor = new KetaiSensor(this);
    location = new KetaiLocation(this);
    
    sensor.start();

    if(db.connect()) {
        println("Connected to database");
        
        if(!db.tableExists("mapData")) {
            println("Table mapData does not exist. Creating table");
            
            db.execute(
                "CREATE TABLE mapData(" +
                "time INTEGER PRIMARY KEY," +
                "lat FLOAT NOT NULL," +
                "lng FLOAT NOT NULL," +
                "alt FLOAT NOT NULL," +
                "accelX FLOAT NOT NULL," +
                "accelY FLOAT NOT NULL," +
                "accelZ FLOAT NOT NULL);"
            );
        } else {
            println("Table mapData exists.");
        }
    } else {
        println("Cannot connect to database.");
    }
    
    fetchData();
}

void draw() {
    background(0);
    fill(255);
    noStroke();
    textSize(30);
    textAlign(CENTER, CENTER);
    text((isCapturing ? "Capturing data" : "Not capturing data") + "\n" + timeLastSaved, width / 2, height / 2);
}

void mousePressed() {
    isCapturing = !isCapturing;
    saveCurrent();
}

void onAccelerometerEvent(float x, float y, float z, long time, int accuracy) {
    accelerometer = new PVector(x, y, z);
}

void onLocationEvent(double latitude, double longitude, double altitude) {
    position = new PVector((float) latitude, (float) longitude, (float) altitude);
    saveCurrent();
}

void fetchData() {
    if(db.connect()) {
        db.query("SELECT * FROM mapData");
        
        println("Getting data from database:");
        
        while(db.next()) {
            println(db.getLong("time") + ", " + db.getFloat("lat") + ", " + db.getFloat("lng"));
        }
    }
}

void saveCurrent() {
    if(db.connect() && isCapturing && position != null && accelerometer != null) {
        String sql = "INSERT into mapData (`time`,`lat`,`lng`,`alt`,`accelX`,`accelY`,`accelZ`) VALUES (" +
                     "'" + System.currentTimeMillis() + "', '"+position.x+"', '"+position.y+"', '"+position.z+"', '"+accelerometer.x+"', '"+accelerometer.y+"', '"+accelerometer.z+"')";
        
        if(db.execute(sql)) {
            println("Recorded data");
            timeLastSaved = System.currentTimeMillis();
        } else {
            println("Failed to record data");
        }
    }
}
