//Bresenham's line algorithm
public void CGLine(float f_x1, float f_y1, float f_x2, float f_y2) {
    int x1 = round(f_x1);
    int x2 = round(f_x2);
    int y1 = round(f_y1);
    int y2 = round(f_y2);

    boolean steep = abs(y2 - y1) > abs(x2 - x1);

    if (steep) {
        //swap(x1, y1);
        int tmp = x1;
        x1 = y1;
        y1 = tmp;

        //swap(x2, y2);
        tmp = x2;
        x2 = y2;
        y2 = tmp;
    }

    if (x1 > x2) {
        //swap(x1, y2);
        int tmp = x1;
        x1 = x2;
        x2 = tmp;

        //swap(y1, y2);
        tmp = y1;
        y1 = y2;
        y2 = tmp;
    }

    int delta_x = x2 - x1;
    int delta_y = abs(y2 - y1);
    int error = delta_x / 2;
    int ystep;
    int y = y1;

    if (y1 < y2) ystep = 1; else ystep =- 1;

    for (int x = x1; x <= x2; x++) {
        if (steep) drawPoint(y, x, color(0)); else drawPoint(x, y, color(0));
        error -= delta_y;
        if (error < 0) {
            y += ystep;
            error += delta_x;
        }
    }
}

//Bresenham's line algorithm
public void CGCircle(float f_x, float f_y, float f_r) {
    int xc = round(f_x);
    int yc = round(f_y);
    int r = round(f_r);
    int x = 0;
    int y = r;
    int d = 3 - 2 * r;

    while (y >= x) {
        drawPoint(xc + x, yc + y, color(0));
        drawPoint(xc - x, yc + y, color(0));
        drawPoint(xc + x, yc - y, color(0));
        drawPoint(xc - x, yc - y, color(0));
        drawPoint(xc + y, yc + x, color(0));
        drawPoint(xc - y, yc + x, color(0));
        drawPoint(xc + y, yc - x, color(0));
        drawPoint(xc - y, yc - x, color(0));

        if (d > 0) {
            y--;
            d = d + 4 * (x - y) + 10;
        } else {
            d = d + 4 * x + 6;
        }
        x++;
    }
}

//Midpoint ellipse drawing algorithm
public void CGEllipse(float xc, float yc, float rx, float ry) {
    float dx, dy, d1, d2, x, y;
    x = 0;
    y = ry;

    d1 = (ry * ry) - (rx * rx * ry) + (0.25f * rx * rx);
    dx = 2 * ry * ry * x;
    dy = 2 * rx * rx * y;

    while (dx < dy) {
        drawPoint(x + xc, y + yc, color(0));
        drawPoint(-x + xc, y + yc, color(0));
        drawPoint(x + xc, -y + yc, color(0));
        drawPoint(-x + xc, -y + yc, color(0));

        if (d1 < 0) 
        {
            x++;
            dx = dx + (2 * ry * ry);
            d1 = d1 + dx + (ry * ry);
        }
        else
        {
            x++;
            y--;
            dx = dx + (2 * ry * ry);
            dy = dy - (2 * rx * rx);
            d1 = d1 + dx - dy + (ry * ry);
        }
    }

    d2 = ((ry * ry) * ((x + 0.5f) * (x + 0.5f)))
        + ((rx * rx) * ((y - 1) * (y - 1)))
        - (rx * rx * ry * ry);

    while (y >= 0) {
        drawPoint(x + xc, y + yc, color(0));
        drawPoint(-x + xc, y + yc, color(0));
        drawPoint(x + xc, -y + yc, color(0));
        drawPoint(-x + xc, -y + yc, color(0));

        if (d2 > 0) {
            y--;
            dy = dy - (2 * rx * rx);
            d2 = d2 + (rx * rx) - dy;
        }
        else {
            y--;
            x++;
            dx = dx + (2 * ry * ry);
            dy = dy - (2 * rx * rx);
            d2 = d2 + dx - dy + (rx * rx);
        }
    }
}

public void CGCurve(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4) {
    float[] xCoeffs = {p1.x, p2.x, p3.x, p4.x};
    float[] yCoeffs = {p1.y, p2.y, p3.y, p4.y};

    int step = 100;
    float prev_x = p1.x;
    float prev_y = p1.y;

    for (float s = 1; s <= step; s++) {
        float t = (float) s / step;
        float curr_x = deCasteljau(t, xCoeffs);
        float curr_y = deCasteljau(t, yCoeffs);
        CGLine(prev_x, prev_y, curr_x, curr_y);
        prev_x = curr_x;
        prev_y = curr_y;
    }

}

public void CGEraser(Vector3 p1, Vector3 p2) {
    for (float x = p1.x; x <= p2.x; x += 0.5f) {
        for (float y = p1.y; y <= p2.y; y += 0.5f) {
            drawPoint(x, y, color(250));
        }
    }

}

public void drawPoint(float x, float y, color c) {
    stroke(c);
    point(x, y);
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

public float deCasteljau(float t, float[] coefficients) {
    float[] beta = coefficients.clone();
    int n = beta.length;
    for (int i = 1; i < n; i++) {
        for (int j = 0; j < (n - i); j++) {
            beta[j] = beta[j] * (1 - t) + beta[j + 1] * t;
        }
    }
    return beta[0];
}
