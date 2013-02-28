class MapShape {
    final PVector topLeft = new PVector(0, 0);
    final PVector topRight = new PVector(width, 0);
    final PVector bottomLeft = new PVector(0, height);
    final PVector bottomRight = new PVector(width, height);
    
    ArrayList<PVector> points;
    int fillColor;
    
    MapShape(PVector point1, PVector point2, float angle1, float angle2) {
        fillColor = (int) random(0, 255);
        
        PVector line1start = point1;
        PVector line1end = new PVector(point1.x + cos(angle1) * 3000, point1.y + sin(angle1) * 3000);
        
        PVector line2start = point2;
        PVector line2end = new PVector(point2.x + cos(angle2) * 3000, point2.y + sin(angle2) * 3000);
        
        PVector edge1 = findEdgePoint(line1start, line1end);
        PVector edge2 = findEdgePoint(line2start, line2end);
        
        points = new ArrayList();
        points.add(point1);
        points.add(point2);
        points.add(edge2);
        points.add(edge1);
    }
    
    PVector findEdgePoint(PVector start, PVector end) {
        PVector intersectTop = segIntersection(start.x, start.y, end.x, end.y, topLeft.x, topLeft.y, topRight.x, topRight.y);
        if(intersectTop != null) return intersectTop;
        
        PVector intersectRight = segIntersection(start.x, start.y, end.x, end.y, topRight.x, topRight.y, bottomRight.x, bottomRight.y);
        if(intersectRight != null) return intersectRight;
        
        PVector intersectBottom = segIntersection(start.x, start.y, end.x, end.y, bottomRight.x, bottomRight.y, bottomLeft.x, bottomLeft.y);
        if(intersectBottom != null) return intersectBottom;
        
        PVector intersectLeft = segIntersection(start.x, start.y, end.x, end.y, bottomLeft.x, bottomLeft.y, topLeft.x, topLeft.y);
        if(intersectLeft != null) return intersectLeft;
        
        return null;
    }
    
    PVector segIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) { 
        float bx = x2 - x1; 
        float by = y2 - y1; 
        float dx = x4 - x3; 
        float dy = y4 - y3;
        float b_dot_d_perp = bx * dy - by * dx;
        if(b_dot_d_perp == 0) return null;
        
        float cx = x3 - x1;
        float cy = y3 - y1;
        float t = (cx * dy - cy * dx) / b_dot_d_perp;
        
        if(t < 0 || t > 1) return null;
        
        float u = (cx * by - cy * bx) / b_dot_d_perp;
        
        if(u < 0 || u > 1) return null;
        
        return new PVector(x1+t*bx, y1+t*by);
    }
}
