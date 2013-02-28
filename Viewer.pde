class Viewer {
    int sessionId;
    ArrayList<Sample> samples;
    DataStore data;
    MercatorMap map;
    
    Viewer(int pSessionId, DataStore dataStore) {
        sessionId = pSessionId;
        data = dataStore;
        samples = data.getSamples(sessionId);
        
        float[] bounds = getBounds();
        map = createMap(width, height, bounds[0], bounds[1], bounds[2], bounds[3]);
    }
    
    float[] getBounds() {
        float latMin = 90;
        float latMax = 0;
        float lngMin = 180;
        float lngMax = -180;
        
        for(Sample sample : samples) {
            latMin = min(latMin, sample.position.y);
            latMax = max(latMax, sample.position.y);
            lngMin = min(lngMin, sample.position.x);
            lngMax = max(lngMax, sample.position.x);
        }
        
        return new float[] {latMin, lngMin, latMax, lngMax};
    }
    
    void draw() {
        PVector previousPosition = null;
        float radius = 5;
        
        background(255);
        
        noFill();
        
        for (Sample sample : samples) {
            PVector pixelPosition = map.getScreenLocation(sample.position);
            
            if(previousPosition != null) {
                float angle = atan2(previousPosition.y - pixelPosition.y, previousPosition.x - pixelPosition.x);
                float distance = PVector.dist(previousPosition, pixelPosition);
                
                pushMatrix();
                
                stroke(0);
                translate(pixelPosition.x, pixelPosition.y);
                rotate(angle);
                
                stroke(0, 50);
                ellipse(0, 0, radius * 2, radius * 2);
                
                stroke(0);
                line(0, 0, radius, 0);
                
                stroke(0, 50);
                line(0, 0, distance, 0);
            
                popMatrix();
            }
            
            previousPosition = pixelPosition;
        }
        
        for(int i = 0; i < samples.size() - 2; i++) {
            Sample sample1 = samples.get(i);
            Sample sample2 = samples.get(i + 1);
            Sample sample3 = samples.get(i + 2);
            
            PVector pixelPosition1 = map.getScreenLocation(sample1.position);
            PVector pixelPosition2 = map.getScreenLocation(sample2.position);
            PVector pixelPosition3 = map.getScreenLocation(sample3.position);
            
            float angle = atan2(pixelPosition3.y - pixelPosition1.y, pixelPosition3.x - pixelPosition1.x);
            float distance = PVector.dist(pixelPosition1, pixelPosition3);
            
            stroke(255, 255, 0);
            
            line(pixelPosition1.x, pixelPosition1.y, pixelPosition3.x, pixelPosition3.y);
            
            stroke(255, 0, 0, 30);
            pushMatrix();
            translate(pixelPosition2.x, pixelPosition2.y);
            rotate(angle + HALF_PI);
            line(0, 0, 1000, 0);
            popMatrix();
        }
        
        fill(0);
        noStroke();
        textAlign(LEFT, TOP);
        text("Back", 10, 10);
    }
    
    void mousePressed() {
        if(mouseX < 120 && mouseY < 80) {
            showHome();
        }
    }
    
    MercatorMap createMap(int w, int h, float leftLon, float bottomLat, float rightLon, float topLat) {
        return new MercatorMap(w, h, topLat, bottomLat, leftLon, rightLon);
    }
}
