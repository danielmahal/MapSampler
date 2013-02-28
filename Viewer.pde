class Viewer {
    int sessionId;
    ArrayList<Sample> samples;
    ArrayList<MapShape> mapShapes;
    DataStore data;
    MercatorMap map;
    
    Viewer(int pSessionId, DataStore dataStore) {
        sessionId = pSessionId;
        data = dataStore;
        
        samples = data.getSamples(sessionId);
        
        float[] bounds = getBounds(samples);
        map = createMap(width, height, bounds[0], bounds[1], bounds[2], bounds[3]);
        
        samples = cleanSamples(samples, 20);
        
        mapShapes = calculateMapShapes(samples);
    }
    
    float[] getBounds(ArrayList<Sample> samples) {
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
    
    ArrayList<Sample> cleanSamples(ArrayList<Sample> dirtySamples, float minDistance) {
        Sample previous = dirtySamples.get(0);
        ArrayList<Sample> cleanedSamples = new ArrayList();
                
        for (Sample dirtySample : dirtySamples) {
            PVector previousPosition = map.getScreenLocation(previous.position);
            PVector samplePosition = map.getScreenLocation(dirtySample.position);
            float distance = PVector.dist(previousPosition, samplePosition);
            
            if (distance > minDistance) {
                previous = dirtySample;
                cleanedSamples.add(dirtySample);
            }
        }
    
        return cleanedSamples;
    }
    
    ArrayList<MapShape> calculateMapShapes(ArrayList<Sample> samples) {
        ArrayList<MapShape> mapShapes = new ArrayList();
        ArrayList<PVector> seperatorPoints = new ArrayList();
        ArrayList<Float> seperatorAngles = new ArrayList();
        
        for(int i = 0; i < samples.size() - 2; i++) {
            Sample sample1 = samples.get(i);
            Sample sample2 = samples.get(i + 1);
            Sample sample3 = samples.get(i + 2);
            
            PVector pixelPosition1 = map.getScreenLocation(sample1.position);
            PVector pixelPosition2 = map.getScreenLocation(sample2.position);
            PVector pixelPosition3 = map.getScreenLocation(sample3.position);
            
            float angle = atan2(pixelPosition3.y - pixelPosition1.y, pixelPosition3.x - pixelPosition1.x);
            
            seperatorPoints.add(pixelPosition2);
            seperatorAngles.add(angle + HALF_PI);
        }
        
        for(int i = 0; i < seperatorPoints.size() - 1; i++) {
            PVector point1 = seperatorPoints.get(i);
            PVector point2 = seperatorPoints.get(i + 1);
            float angle1 = seperatorAngles.get(i);
            float angle2 = seperatorAngles.get(i + 1);
            
            mapShapes.add(new MapShape(point1, point2, angle1, angle2));
        }
        
        return mapShapes;
    }
    
    void draw() {
        background(255);
        
        for(MapShape mapShape : mapShapes) {
            colorMode(HSB);
            fill(mapShape.fillColor, 127, 127);
            colorMode(RGB);
            noStroke();
            
            beginShape();
            
            for(PVector point : mapShape.points) {
                vertex(point.x, point.y);
            }
            
            vertex(mapShape.points.get(0).x, mapShape.points.get(0).y);
            vertex(mapShape.points.get(1).x, mapShape.points.get(1).y);
            vertex(mapShape.points.get(3).x, mapShape.points.get(3).y);
            vertex(mapShape.points.get(2).x, mapShape.points.get(2).y);
            endShape(CLOSE);
            
            stroke(0, 255, 0);
            fill(255);
            ellipse(mapShape.points.get(2).x, mapShape.points.get(2).y, 20, 20);
            ellipse(mapShape.points.get(3).x, mapShape.points.get(3).y, 20, 20);
        }
        
        fill(0);
        noStroke();
        textAlign(LEFT, TOP);
        text("Back", 10, 10);
    }
    
    void drawDebugSamples() {
        PVector previousPosition = null;
        float radius = 5;
        
        noFill();
        
        for(Sample sample : samples) {
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
