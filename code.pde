/* @pjs font='fonts/font.ttf' */ 

var myfont = loadFont("fonts/font.ttf"); 

/* canvas */
float width;
float height;

/* nodes */
// ArrayList nodes;

void setup() {
    
    /* set canvas size to window size */
    width = window.innerWidth;
    height = window.innerHeight;
    size(width, height);

    /* initialize array list */
    // nodes = new ArrayList();

    /* set font */
    textFont(myfont);

    /* clear canvas */
    background(color(255));

}

Number.prototype.between = function (min, max) {
    return this > min && this < max;
};

void draw () {
    
    noStroke();
    fill(0,0,0,10);

    paint(mouseX,mouseY,40);

}

void paint (float _x, float _y, float _radius) {

    /* generate polygon */
    ArrayList polygon = new ArrayList();
    createPolygon(polygon,10,random(TWO_PI),_radius);
    deformPolygonTimes(polygon,_radius / 8,3);

    /* draw polygon */
    beginShape();
    for (int i = 0; i < polygon.size(); ++i) {
        PVector vector = polygon.get(i);
        vertex(mouseX + vector.x,mouseY + vector.y);
    }
    endShape();

}

void createPolygon (ArrayList _polygon, int _sides, float _startRadian, float _radius) {

    _polygon.clear();
    float deltaRadian = TWO_PI / _sides;
    for (int i = 0; i < _sides; ++i) {

        float rad = _startRadian + (deltaRadian * i);
        _polygon.add(new PVector(cos(rad) * _radius,sin(rad) * _radius));

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
