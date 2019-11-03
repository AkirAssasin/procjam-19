/* @pjs font='fonts/font.ttf' */ 

var myfont = loadFont("fonts/font.ttf"); 

/* canvas */
float width;
float height;
color bgColor;

/* graphic */
PGraphic rorschach;

void setup() {
    
    /* set canvas size to window size */
    width = window.innerWidth;
    height = window.innerHeight;
    size(width, height);

    /* set font */
    textFont(myfont);

    /* set canvas background */
    bgColor = color(255,255,200);
    background(bgColor);

    /* generate rorschach */
    rorschach = generateRorschach();

}

void randomizeVectorBiased (PVector _vector, float _width, float _height) {

    _vector.x = (1 - skewedRandom()) * _width;
    _vector.y = skewedToCenterRandom() * _height;

}

void randomOffsetVector (PVector _vector, float _width, float _height, float minDistance, float maxDistance) {

    PVector ran = PVector.random2D();
    ran.mult(random(minDistance,maxDistance));
    _vector.add(ran);

    if (_vector.x < 0 || _vector.x > _width || _vector.y < 0 || _vector > _height) {
        randomizeVectorBiased(_vector,_width,_height);
    }

}

Number.prototype.between = function (min, max) {
    return this > min && this < max;
};

PGraphic generateRorschach () {

    /* random amount of colors + white in between */
    int colorCount = 1 + round(random(2));
    colorCount *= 2;

    /* initialize color arrays */
    color[] colors = new color[colorCount];
    int[] counts = new int[colorCount];
    
    /* first color always black */
    colors[0] = color(0);
    counts[0] = 20;

    /* random shade of red / yellow for other colors */
    for (int i = 2; i < colorCount; i += 2) {
        float red = random(255);
        float green = random(red);
        colors[i] = color(red,green,random(min(red,green)));
        counts[i] = 5;
    }

    /* interlace whites in between */
    for (int i = 1; i < colorCount; i += 2) {
        colors[i] = bgColor;
        counts[i] = 1;
    }

    /* pick starting position */
    currentPosition = new PVector(0,0);
    randomizeVectorBiased(currentPosition,width/2,height);

    /* initialize graphic */
    PGraphic halfGraphic = createGraphics(width/2,height);

    /* generate half-rorschach */
    halfGraphic.noStroke();
    for (int col = 0; col < colorCount; ++col) {

        color c = colors[col];

        for (int ct = counts[col]; ct > 0; --ct) {

            halfGraphic.fill(c,3 + random(5));
            float r = 30 + random(50);

            if (random(1) < 0.2) {
                randomizeVectorBiased(currentPosition,width/2,height);
            } else randomOffsetVector(currentPosition,width/2,height,50,100);
    
            paintTimesSplit(halfGraphic,currentPosition.x,currentPosition.y,r,40);

        }

    }

    /* generate full rorschach */
    PGraphic fullGraphic = createGraphics(width,height);
    
    fullGraphic.background(bgColor);
    fullGraphic.image(halfGraphic,0,0);
    
    fullGraphic.pushMatrix();
    fullGraphic.scale(-1.0,1.0);
    fullGraphic.image(halfGraphic,-width,0);
    fullGraphic.popMatrix();

    return fullGraphic;

}

void draw () {

    /* actual render */

    background(bgColor);
    ellipse(0,0,5,5);
    image(rorschach,0,0);

}

void mouseClicked () {
    rorschach = generateRorschach();
}

float skewedRandom () {
    float r = random(1);
    return r * r * r;
}

float skewedToCenterRandom () {
    float r = random(2) - 1;
    return 0.5 + (0.5 * r * r * r);
}

void paintTimesSplit (PGraphic _target, float _x, float _y, float _radius, int _times) {

    /* generate polygon */
    ArrayList polygon = new ArrayList();
    createPolygon(polygon,10,random(TWO_PI),_radius);

    int count = 1 + round(random(3));
    float extraScale = (1 - (random(count) / 4)) * 2.5;
    
    for (int i = 0; i < count; ++i) {

        ArrayList strpoly = polygon.clone();
        stretchPolygonInDirection(strpoly,random(TWO_PI),1.5 + random(extraScale));
        for (int t = 0; t < _times; ++t) {
            paintPolygon(_target,strpoly,_radius / 4,_x,_y);
        }

    }

}

void paintTimes (PGraphic _target, float _x, float _y, float _radius, int _times) {

    /* generate polygon */
    ArrayList polygon = new ArrayList();
    createPolygon(polygon,10,random(TWO_PI),_radius);
    stretchPolygonInDirection(polygon,random(TWO_PI),random(1,4));
    
    /* draw deformations */

    for (int t = 0; t < _times; ++t) {

        // paint(_target,_x,_y,_radius);
        paintPolygon(_target,polygon,_radius / 4,_x,_y);

    }

}

void paint (PGraphic _target, float _x, float _y, float _radius) {

    /* generate polygon */
    ArrayList polygon = new ArrayList();
    createPolygon(polygon,10,random(TWO_PI),_radius);
    stretchPolygonInDirection(polygon,random(TWO_PI),3);
    paintPolygon(_target,polygon,_radius / 8,_x,_y);

}

void paintPolygon (PGraphic _target, ArrayList _polygon, float _defRadius, float _x, float _y) {

    ArrayList defpoly = _polygon.clone();
    deformPolygonTimes(defpoly,_defRadius,3);

    /* draw polygon */
    _target.beginShape();
        for (int i = 0; i < defpoly.size(); ++i) {
            PVector vector = defpoly.get(i);
            _target.vertex(_x + vector.x,_y + vector.y);
        }
    _target.endShape();   

}

void createPolygon (ArrayList _polygon, int _sides, float _startRadian, float _radius) {

    _polygon.clear();
    float deltaRadian = TWO_PI / _sides;
    for (int i = 0; i < _sides; ++i) {

        float rad = _startRadian + (deltaRadian * i);
        _polygon.add(new PVector(cos(rad) * _radius,sin(rad) * _radius));

    }

}

void stretchPolygonInDirection (ArrayList _polygon, float _radian, float _scale) {

    float c = cos(_radian);
    float s = sin(_radian);

    for (int i = 0; i < _polygon.size(); ++i) {

        PVector original = _polygon.get(i);
        
        /* convert to rotated coordinate system */
        PVector result = new PVector(original.x * c + original.y * s, original.x * -s + original.y * c);
        original = result;

        if (original.x < 0) continue;

        /* scale in first axis of rotated coordinate system */
        PVector result = new PVector(original.x * _scale,original.y);
        original = result;

        PVector result = new PVector(original.x * c - original.y * s, original.x * s + original.y * c);
        _polygon.set(i,result);

    }

}

void deformPolygonTimes (ArrayList _polygon, float _scale, int _times) {

    for (int i = 0; i < _times; ++i) {
        deformPolygon(_polygon,_scale);
    }

}

void deformPolygon (ArrayList _polygon, float _scale) {

    int originalSize = _polygon.size();
    for (int i = 0; i < originalSize; ++i) {

        int actualIndex = i * 2;
        PVector next = _polygon.get((i + 1 < originalSize) ? (actualIndex + 1) : 0).get();
        PVector midpoint = _polygon.get(actualIndex).get();
        midpoint.add(next);
        midpoint.mult(0.5);

        PVector offset = PVector.random2D();
        offset.mult(_scale);
        midpoint.add(offset);

        _polygon.add(actualIndex + 1, midpoint);

    }

}

/*
class Node {
    float x;
    float y;
    float vx;
    float vy;
    float r;
    float orir;
    float dr;
    boolean toMove = true;
    boolean death = false;
    float tick = 0;
    color c;

    Node(or,ox,oy,oc) {
        if (or == 0) {
          orir = dist(sx,sy,mouseX,mouseY);
          x = sx;
          y = sy;
          vx = (mouseX - x)/50;
          vy = (mouseY - y)/50;
          c = color(random(150,255),random(150,255),random(150,255));
        } else {
          orir = or;
          x = ox;
          y = oy;
          c = oc;
        }
        r = orir;
        dr = orir;
    };

    void splitc(s) {
        if (dist(x,y,mouseX,mouseY) <= orir*3/4 && orir - dist(x,y,mouseX,mouseY) >= 15) {
          nodes.add(new Node(orir - dist(x,y,mouseX,mouseY),mouseX,mouseY,lerpColor(c,color(255),0.5)));
          orir -= orir/4 - dist(x,y,mouseX,mouseY)/4;
          c = lerpColor(c,color(0),0.25);
          tick = 0;
          vx = 0;
          vy = 0;
        }
    }

    void kill() {
        if (dist(x,y,mouseX,mouseY) <= orir && nodes.size() > 1) {
          death = true;
        }
    }

    void update() {
        if (tick < 255) {tick += 1;}
        bgl = lerpColor(bgl,color(255 - red(c),255 - green(c),255 - blue(c)),0.5);
        toMove = true;
        for (int i=nodes.size()-1; i>=0; i--) {
          Particle n = (Node) nodes.get(i);
          if (dist(n.x,n.y,x,y) <= (orir + n.orir) && dist(n.x,n.y,x,y) != 0 && !n.death && !death) {
            if ((n.orir <= orir/2 && n.tick >= 255) || (orir <= 15 && n.orir <= 15)) {
              vx += (n.x - x)/1000;
              vy += (n.y - y)/1000;
              n.vx += (x - n.x)/1000;
              n.vy += (y - n.y)/1000;
              if (dist(n.x,n.y,x,y) < orir || (orir <= 15 && n.orir <= 15)) {
                dr = orir;
                orir += n.orir;
                c = lerpColor(c,n.c,0.33);
                n.death = true;
                vx /= 2;
                vy /= 2;
              }
            } else {
              vx += (x - n.x)/1000;
              vy += (y - n.y)/1000;
              x += vx;
              y += vy;
              toMove = false;
              c = lerpColor(c,n.c,0.03);
              //n.c = lerpColor(n.c,c,0.03);
              orir = lerp(orir,n.orir,0.015);
              dr = orir/5;
            }
          }
        }
        if (toMove && vx > -0.1 && vy > -0.1 && vx < 0.1 && vy < 0.1 && tick >= 255 && orir >= 30) {
          float dx = random(-1,1);
          float dy = random(-1,1);
          nodes.add(new Node(orir/2,x + dx,y + dy,lerpColor(c,color(255),0.5)));
          orir /= 2;
          c = lerpColor(c,color(0),0.25);
          tick = 0;
          x -= dx;
          y -= dy;
          vx = 0;
          vy = 0;
        }
        if (toMove) {dr = orir*3/2;}
        if (nodes.size() == 1 && orir < min(width,height)/5) {
          vx = 0;
          vy = 0;
          x += (width/2 - x)/50;
          y += (height/2 - y)/50;
          orir += ((min(width,height)/5) - orir)/10;
          if (orir < (min(width,height)/5 - 1)) {
            tick = 0;
            c = lerpColor(c,color(random(150,255),random(150,255),random(150,255)),0.35);
            dr = 0;
          }
        }
        if (x < orir) {orir -= 2; vx = -vx; dr = orir/5; x = orir;}
        if (y < orir) {orir -= 2; vy = -vy; dr = orir/5; y = orir;}
        if (x > (width - orir)) {orir -= 2; vx = -vx; dr = orir/5; x = width - orir;}
        if (y > (height - orir)) {orir -= 2; vy = -vy; dr = orir/5; y = height - orir;}
        if (death) {
          if (dist(orir,0,0,0) > 1) {orir -= orir/10;}
          dr = 0;
          vx /= 2;
          vy /= 2;
        }
        if (dist(sx,sy,mouseX,mouseY) > dist(sx,sy,x,y)) {valids = false;}
        x += vx;
        y += vy;

        dr *= height/pheight;
        if (dist(r,0,dr,0) > 1) {r += (dr - r)/10;}
        fill(c);
        stroke(c);
        ellipse(x,y,r,r);
        fill(0,0);
        ellipse(x,y,orir*2,orir*2);
    }
}
*/
