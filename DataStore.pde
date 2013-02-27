import ketai.data.*;
import android.content.Context;

class DataStore {
    String table;
    int sessionId = 0;
    KetaiSQLite db;
    
    DataStore(String tableName, Context context) {
        table = tableName;
        db = new KetaiSQLite(context);
        
        if(db.connect()) {
            println("Datastore: Connected to database");
            
            if(db.tableExists(tableName)) {
                String lastSession = db.getFieldMax(table, "sessionId");
                
                if(lastSession != null) {
                    println("Session id: " + sessionId);
                    sessionId = Integer.parseInt(lastSession);
                }
            } else {
                println("Table does not exist. Creating table " + table);
                createTable();
            }
        }
    }
    
    void createTable() {
        db.execute("CREATE TABLE " + table + "(" +
            "time INTEGER PRIMARY KEY," +
            "sessionId INTEGER NOT NULL," +
            "latitude FLOAT NOT NULL," +
            "longitude FLOAT NOT NULL," +
            "altitude FLOAT NOT NULL," +
            "accelerometerX FLOAT NOT NULL," +
            "accelerometerY FLOAT NOT NULL," +
            "accelerometerZ FLOAT NOT NULL" +
        ");");
    }
    
    void dropTable() {
        db.execute("DROP TABLE " + table);
    }
    
    void reset() {
        dropTable();
        createTable();
        sessionId = 0;
    }
    
    ArrayList<Sample> getSamples(int sessionId) {
        ArrayList<Sample> samples = new ArrayList();
        
        db.query("SELECT * from " + table + " WHERE sessionId='" + sessionId + "'");
        
        while (db.next()) {
            int time = db.getInt("time");
            PVector position = new PVector(db.getFloat("latitude"), db.getFloat("longitude"));
            PVector acclerometer = new PVector(db.getFloat("acclerometerX"), db.getFloat("acclerometerY"), db.getFloat("acclerometerZ"));
            
            Sample sample = new Sample(time, sessionId, position, acclerometer);
            
            samples.add(sample);
        }
        
        return samples;
    }
    
    int getLastSession() {
        return sessionId;
    }
    
    void store(int id, PVector position, PVector accelerometer) {
        String sql = "INSERT into " + table+ " ("+
            "`time`,"+
            "`sessionId`,"+
            "`latitude`,"+
            "`longitude`,"+
            "`altitude`,"+
            "`accelerometerX`,"+
            "`accelerometerY`,"+
            "`accelerometerZ`"+
        ") VALUES (" +
            "'" + id + "'," +
            "'" + sessionId + "'," +
            "'" + position.x + "'," +
            "'" + position.y + "'," +
            "'" + position.z + "'," +
            "'" + accelerometer.x + "'," +
            "'" + accelerometer.y + "'," +
            "'" + accelerometer.z + "'" +
        ")";
        
        if(db.execute(sql)) {
            println("Inserted row into database in session id: " + sessionId);
        }
    }
    
    void newSession() {
        sessionId++;
    }
}
