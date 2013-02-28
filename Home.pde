class Home {
    ArrayList<Integer> sessions;
    ArrayList<SessionParticle> particles;
    
    Home(DataStore data) {
        sessions = data.getSessions();
        particles = new ArrayList();
        
        for(int i = 0; i < sessions.size(); i++) {
            int sessionId = sessions.get(i);
            float angle = ((i+1) / sessions.size()) * TWO_PI;
            float distance = (min(width, height) / 2) - 50;
            float x = width / 2 + sin(angle) * distance;
            float y = height / 2 + cos(angle) * distance;
            float radius = 10;
            PVector position = new PVector(x, y);
            
            SessionParticle particle = new SessionParticle(sessionId, position, radius);
            particles.add(particle);
        }
    }
    
    void draw() {
        background(0);
        
        fill(255);
        noStroke();
        textAlign(CENTER, CENTER);
        textSize(20);
        text("Record", width / 2, height / 2);
        
        for(SessionParticle particle : particles) {
            particle.draw();
        }
    }
    
    void mousePressed() {
        for(SessionParticle particle : particles) {
            float distance = PVector.dist(particle.position, new PVector(mouseX, mouseY));
            if(distance < 60) {
                showSession(particle.sessionId);
                break;
            }
        }
    }
}

class SessionParticle {
    PVector position;
    int sessionId;
    float radius;
    
    SessionParticle(int pSessionId, PVector pPosition, float pRadius) {
        position = pPosition;
        sessionId = pSessionId;
        radius = pRadius;
    }
    
    void draw() {
        fill(255);
        noStroke();
        ellipse(position.x, position.y, radius * 2, radius * 2);
    }
}
