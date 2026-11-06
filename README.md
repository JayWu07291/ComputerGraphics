# Computer Graphics - Lab 1: 小畫家應用程式 (Painter Application)

## 完成的任務

在本次作業中，我完成了小畫家應用程式（`HW1/`）中所有基礎繪圖與擦除功能（位於 `HW1/util.pde`）：

- [x] **畫線演算法 (`CGLine`)**：實作布雷森漢姆直線演算法（Bresenham's line algorithm），使「畫線 (Draw Line)」、「畫多邊形 (Draw Polygon)」與「鉛筆 (Pencil)」按鈕具備功能。
- [x] **畫圓演算法 (`CGCircle`)**：實作布雷森漢姆畫圓演算法（Bresenham's circle algorithm），利用八分對稱性繪製圓形，使「畫圓 (Draw Circle)」按鈕具備功能。
- [x] **畫橢圓演算法 (`CGEllipse`)**：實作中點畫橢圓演算法（Midpoint ellipse drawing algorithm），分兩個區域繪製四分對稱的橢圓，使「畫橢圓 (Draw Ellipse)」按鈕具備功能。
- [x] **貝茲曲線演算法 (`CGCurve`)**：實作德卡斯特里奧演算法（De Casteljau's algorithm），將取樣點以 `CGLine` 連接繪出平滑的三次貝茲曲線，使「畫曲線 (Draw Curve)」按鈕具備功能。
- [x] **橡皮擦功能 (`CGEraser`)**：對 `p1` 到 `p2` 定義的矩形區域填入畫布背景色 `color(250)`，支援透過滑鼠滾輪調整橡皮擦大小，使「橡皮擦 (Eraser)」按鈕具備功能。

---

## 成果截圖

> TODO：請在此處替換或附上執行畫面截圖（例如：`![執行成果](screenshot.png)`）。

---

## 實作方法與關鍵程式碼說明

本作業遵循規範，不使用 `line()`、`circle()`、`ellipse()`、`bezier()`、`rect()` 等內建圖形繪製函式，所有圖形皆透過 `drawPoint(x, y, color)` 逐點繪製。

### 1. 畫線演算法 (`CGLine`)

我採用 **Bresenham's Line Algorithm** 實作直線繪製。為了處理所有象限與不同斜率的直線：
1. 先判斷斜率絕對值是否大於 1（`boolean steep = abs(y2 - y1) > abs(x2 - x1)`）。若較陡峭，則先將 `x` 與 `y` 座標互換。
2. 確保起點 `x1` 小於終點 `x2`（若 `x1 > x2` 則交換起終點）。
3. 使用整數誤差項 `error` 控制 `y` 的遞增或遞減方向（`ystep`），在迴圈中從 `x1` 走到 `x2` 並呼叫 `drawPoint` 繪製像素。

```java
boolean steep = abs(y2 - y1) > abs(x2 - x1);
if (steep) {
    // 交換 x 與 y
    int tmp = x1; x1 = y1; y1 = tmp;
    tmp = x2; x2 = y2; y2 = tmp;
}
if (x1 > x2) {
    // 交換起點與終點
    int tmp = x1; x1 = x2; x2 = tmp;
    tmp = y1; y1 = y2; y2 = tmp;
}

int delta_x = x2 - x1;
int delta_y = abs(y2 - y1);
int error = delta_x / 2;
int ystep = (y1 < y2) ? 1 : -1;
int y = y1;

for (int x = x1; x <= x2; x++) {
    if (steep) drawPoint(y, x, color(0));
    else drawPoint(x, y, color(0));
    error -= delta_y;
    if (error < 0) {
        y += ystep;
        error += delta_x;
    }
}
```

### 2. 畫圓演算法 (`CGCircle`)

我採用 **Bresenham's Circle Drawing Algorithm**。利用圓形的 **八分對稱性（Eight-way symmetry）**，只需要從 `(0, r)` 開始計算第一八分圓（直到 `x > y`），每計算出一個座標偏移 `(x, y)`，就同時相對於圓心 `(xc, yc)` 繪製 8 個對稱點，並根據決策參數 `d` 的正負決定下一步是否縮減 `y`。

```java
int x = 0, y = r;
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
```

### 3. 畫橢圓演算法 (`CGEllipse`)

我採用 **Midpoint Ellipse Drawing Algorithm**。由於橢圓具有四分對稱性，演算法在第一象限從 `(0, ry)` 開始計算，並根據切線斜率是否為 `-1`（即 `dx < dy`）分為兩個區域：
- **區域 1（`dx < dy`）**：切線斜率絕對值小於 1，每次迭代固定 `x++`，並由決策參數 `d1` 判斷是否需要 `y--`。
- **區域 2（`y >= 0`）**：切線斜率絕對值大於等於 1，每次迭代固定 `y--`，並由決策參數 `d2` 判斷是否需要 `x++`。
每次迭代都會相對於中心 `(xc, yc)` 畫出 4 個象限的對稱點。

### 4. 貝茲曲線演算法 (`CGCurve`)

我使用 **De Casteljau's Algorithm** 計算三次貝茲曲線上的座標點：
1. 編寫輔助函式 `deCasteljau(float t, float[] coefficients)`，在內部透過 `coefficients.clone()` 複製控制點座標陣列（避免改寫到原始控制點陣列），並透過線性插值遞迴縮減陣列長度，回傳參數 $t \in [0, 1]$ 對應的座標值。
2. 在 `CGCurve` 中將 $t$ 從 $0$ 到 $1$ 切分為 `100` 個步長（`step = 100`），分別算出相鄰取樣點的 `x` 與 `y`，並呼叫前面實作的 `CGLine(prev_x, prev_y, curr_x, curr_y)` 將取樣點連接成連續且無斷點的曲線。

```java
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
```

### 5. 橡皮擦 (`CGEraser`) 與發現的問題

在實作 `CGEraser(Vector3 p1, Vector3 p2)` 時，我使用雙重迴圈走訪 `p1` 到 `p2` 的矩形範圍，並呼叫 `drawPoint(x, y, color(250))` 塗上畫布背景色。
- **發現的問題**：一開始使用整數步長 `1` 走訪時，發現 Processing 的 `point(x, y)` 因預設筆刷與反鋸齒渲染特性，單次擦過時像素之間會有微小空隙，看起來像半透明、無法一次完全擦掉黑色筆畫。
- **解決方式**：將走訪步長縮小為 `0.5f`，讓繪製點緊密重疊，即可一次將筆畫完全擦除乾淨。

```java
public void CGEraser(Vector3 p1, Vector3 p2) {
    for (float x = p1.x; x <= p2.x; x += 0.5f) {
        for (float y = p1.y; y <= p2.y; y += 0.5f) {
            drawPoint(x, y, color(250));
        }
    }
}
```

---

## AI 工具協助說明

在完成本次作業的過程中，我使用了 AI 助教（Gemini）協助我理解框架與排錯，具體使用方式如下：
1. **理解專案架構與 Processing 語法**：在開始實作前，我請 AI 幫我梳理 `HW1` 模板程式碼中各個 `.pde` 檔案（如 `Renderer`、`Shape`、`Button`）之間的呼叫關係，並整理完成 `util.pde` 所需的 Processing 基本語法與數學函式，同時設定 VS Code 的 `.pde` 語法高亮環境。
2. **演算法邏輯與偽代碼參考**：在我自行以 Bresenham 直線演算法完成 `CGLine()` 後，我請 AI 提供 Bresenham 畫圓演算法的偽代碼，幫助我釐清八分對稱點與決策參數更新的邏輯。
3. **De Casteljau 演算法除錯**：我找到一段 Java 的 `deCasteljau` 演算法範例後，詢問 AI 如何將其整合進 `CGCurve()`。AI 幫我指出了原範例中 `double[] beta = coefficients;` 會直接覆寫原始控制點陣列的指標問題，並建議我使用 `.clone()` 複製陣列以及搭配 `CGLine` 連接取樣點。
4. **排查橡皮擦半透明與效能問題**：當我發現橡皮擦第一次擦過筆畫時呈現半透明、無法擦乾淨，以及畫面上累積過多像素時會變卡頓，我和 AI 討論了 Processing 底層 `point()` 反鋸齒渲染與每幀重繪 `shapes` 的機制，進而調整了橡皮擦的實作方式。

---

## 參考網站

- **直線**：[布雷森漢姆直線演算法 - 維基百科，自由的百科全書](https://zh.wikipedia.org/wiki/%E5%B8%83%E9%9B%B7%E6%A3%AE%E6%BC%A2%E5%A7%86%E7%9B%B4%E7%B7%9A%E6%BC%94%E7%AE%97%E6%B3%95)
- **圓**：[Bresenham’s circle drawing algorithm - GeeksforGeeks](https://www.geeksforgeeks.org/c/bresenhams-circle-drawing-algorithm/)
- **橢圓**：[Midpoint ellipse drawing algorithm - GeeksforGeeks](https://www.geeksforgeeks.org/dsa/midpoint-ellipse-drawing-algorithm/)
- **曲線**：[Bezier curve](https://javascript.info/bezier-curve#de-casteljau-s-algorithm)、[De Casteljau's algorithm - Wikipedia](https://en.wikipedia.org/wiki/De_Casteljau%27s_algorithm)
