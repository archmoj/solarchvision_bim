// UI_mouseGuide - a "Ctrl+?"-triggered, click-outside-or-any-key-
// dismissed overlay drawing three touchpad illustrations - one per main
// viewport (WORLD, STUDY, WIN3D) - purely as a hover-driven reference,
// same spirit as UI_keyboardMap (uiKeyboardMap.pde): no highlighting of
// "currently active" state, no click-to-fire. Hovering a touchpad shows
// every mouse binding for that viewport (mouseMapBindings.pde) in the
// same overflow-safe multi-column hint list the keyboard guide already
// built - reused here via keyboardMapSplitLineForDisplay(), which is
// generic enough ("combo: description", bold the first part) to serve
// both guides without change.
//
// Scope is camera/view navigation only, same boundary
// mouseMapBindings.pde's own header comment explains - WIN3D's object-
// editing tool modes are a separate feature area.
//
// Uses its own dedicated pre_screen-style capture/restore field (NOT
// UI_menuBar's shared `pre_screen` global, and NOT UI_keyboardMap's own
// keyboardMap_pre_screen), same isolation reasoning as UI_keyboardMap's
// own header comment - and the same menu-dropdown-safe capture
// UI_keyboardMap only grew after a bug report: this class starts with
// that guard already in show(), rather than discovering the same bug a
// second time.
class UI_mouseGuide {

  boolean visible = false;
  PImage mouseGuide_pre_screen = null;

  final float OVERLAY_PADDING = 50;

  // One row per laid-out touchpad illustration: {viewport, x, y, w, h} -
  // same shape as UI_keyboardMap.LaidOutKey, just one rect per viewport
  // instead of one per physical key.
  class LaidOutPad {
    String viewport;
    float x, y, w, h;
    LaidOutPad (String viewport, float x, float y, float w, float h) {
      this.viewport = viewport;
      this.x = x; this.y = y; this.w = w; this.h = h;
    }
  }

  // Left-to-right drawing order - a 2D map, a 2D graph, then the 3D
  // view, matching the order the README itself introduces them in.
  final String[] PAD_ORDER = {"WORLD", "STUDY", "WIN3D"};

  // Same "True exactly when UI_menuBar's dropdown is still the last
  // thing actually painted on screen" guard as UI_keyboardMap's own
  // menuDropdownStillOnScreen() (that file's own comment explains the
  // click/Enter-handler ordering this depends on) - duplicated here
  // rather than shared, so this overlay stays self-contained the same
  // way UI_keyboardMap's own pre_screen field is deliberately not
  // shared with UI_menuBar's.
  boolean menuDropdownStillOnScreen () {
    return (UI_menuBar.selected_parent != -1) && (pre_screen != null);
  }

  void show () {
    if (this.visible) return;
    buildMouseMapBindingsIfNeeded();

    if (menuDropdownStillOnScreen()) {
      image(pre_screen, 0, pixel_A);
    }

    this.mouseGuide_pre_screen = get(0, 0, width, height);
    this.visible = true;
    redraw();
  }

  void hide () {
    if (!this.visible) return;
    this.visible = false;
    if (this.mouseGuide_pre_screen != null) {
      image(this.mouseGuide_pre_screen, 0, 0);
    }
    redraw();
  }

  // Identical to UI_keyboardMap.panelUnionBounds()/boundingBox() -
  // duplicated rather than called cross-class, so this overlay doesn't
  // depend on UI_keyboardMap existing or keeping the same API shape.
  float[] panelUnionBounds () {
    float left = Float.MAX_VALUE, top = Float.MAX_VALUE;
    float right = -Float.MAX_VALUE, bottom = -Float.MAX_VALUE;

    left = min(left, STUDY.cX); left = min(left, WORLD.cX); left = min(left, WIN3D.cX);
    top = min(top, STUDY.cY); top = min(top, WORLD.cY); top = min(top, WIN3D.cY);
    right = max(right, STUDY.cX + STUDY.dX / STUDY.ImageScale);
    right = max(right, WORLD.cX + WORLD.dX / WORLD.ImageScale);
    right = max(right, WIN3D.cX + WIN3D.dX / WIN3D.ImageScale);
    bottom = max(bottom, STUDY.cY + STUDY.dY / STUDY.ImageScale);
    bottom = max(bottom, WORLD.cY + WORLD.dY / WORLD.ImageScale);
    bottom = max(bottom, WIN3D.cY + WIN3D.dY / WIN3D.ImageScale);

    return new float[]{ left, top, right, bottom };
  }

  float[] boundingBox () {
    float[] box = panelUnionBounds();
    return new float[]{
      box[0] + OVERLAY_PADDING, box[1] + OVERLAY_PADDING,
      box[2] - OVERLAY_PADDING, box[3] - OVERLAY_PADDING
    };
  }

  boolean isInsideBounds (float x, float y) {
    if (!this.visible) return false;
    float[] box = boundingBox();
    return isInside(x, y, box[0], box[1], box[2], box[3]);
  }

  // Same base unit UI_keyboardMap.keyUnit() uses - keeps the two
  // overlays' type/pad sizes visually consistent with each other.
  float padUnit () {
    return 1.25 * 2.2 * MessageSize;
  }

  // Three touchpads, side by side, centered horizontally in the
  // overlay's own box. Rebuilt fresh every call (three rects - trivial
  // cost) rather than cached, same reasoning as
  // UI_keyboardMap.buildLayout().
  ArrayList<LaidOutPad> buildLayout () {
    ArrayList<LaidOutPad> pads = new ArrayList<LaidOutPad>();
    float unit = padUnit();
    float[] box = boundingBox();

    float padWidth = 6 * unit;
    float padHeight = 8 * unit;
    float gap = 2 * unit;

    float totalWidth = PAD_ORDER.length * padWidth + (PAD_ORDER.length - 1) * gap;
    float startX = box[0] + ((box[2] - box[0]) - totalWidth) / 2;
    float padTop = box[1] + 2 * unit;

    float x = startX;
    for (String viewport : PAD_ORDER) {
      pads.add(new LaidOutPad(viewport, x, padTop, padWidth, padHeight));
      x += padWidth + gap;
    }
    return pads;
  }

  LaidOutPad padAt (ArrayList<LaidOutPad> pads, float x, float y) {
    for (LaidOutPad p : pads) {
      if (isInside(x, y, p.x, p.y, p.x + p.w, p.y + p.h)) return p;
    }
    return null;
  }

  // Bottom edge of the lowest touchpad (+ its label underneath) - where
  // the hint list starts, same "measure what was actually drawn" idea as
  // UI_keyboardMap.mainClusterBottom(), just analytic here since every
  // pad shares one fixed height rather than needing a scan.
  float padClusterBottom (ArrayList<LaidOutPad> pads) {
    float bottom = 0;
    for (LaidOutPad p : pads) bottom = max(bottom, p.y + p.h);
    return bottom + 1.5 * padUnit(); // + room for the viewport-name label below each pad
  }

  // Draws one touchpad: an outer rounded surface, a left-click zone and
  // a right-click zone split along the bottom edge (same left/right
  // layout a real laptop touchpad's own physical buttons use), and a
  // scroll button - a small vertical pill in the upper-right of the
  // surface, standing in for a scroll wheel/strip - purely illustrative,
  // every one of these three sub-shapes is part of the SAME hover region
  // (the whole pad), not separately hoverable: hovering anywhere on a
  // viewport's pad shows that viewport's complete mouse-binding list,
  // per this overlay's own header comment.
  void drawPad (LaidOutPad p, boolean isHovered) {
    noStroke();
    fill(isHovered ? color(0, 140, 255) : color(40));
    rect(p.x, p.y, p.w, p.h, 8);

    float buttonRowHeight = 0.22 * p.h;
    float buttonRowTop = p.y + p.h - buttonRowHeight;

    stroke(0, 120);
    strokeWeight(2);
    // Divider between the pad's main surface and its button row.
    line(p.x, buttonRowTop, p.x + p.w, buttonRowTop);
    // Divider between the left-click and right-click zones.
    line(p.x + p.w / 2, buttonRowTop, p.x + p.w / 2, p.y + p.h);
    noStroke();

    // Scroll button: a small vertical pill in the surface's upper-right,
    // clear of the button row below it.
    float scrollW = 0.16 * p.w;
    float scrollH = 0.34 * p.h;
    float scrollX = p.x + p.w - scrollW - 0.12 * p.w;
    float scrollY = p.y + 0.1 * p.h;
    fill(isHovered ? color(255) : color(90));
    rect(scrollX, scrollY, scrollW, scrollH, scrollW / 2);

    fill(255, 160);
    textAlign(CENTER, CENTER);
    textSize(0.22 * padUnit());
    text("Left-click", p.x + p.w * 0.25, buttonRowTop + buttonRowHeight / 2);
    text("Right-click", p.x + p.w * 0.75, buttonRowTop + buttonRowHeight / 2);

    fill(255, 220);
    textSize(0.3 * padUnit());
    text(p.viewport, p.x + p.w / 2, p.y + p.h + 0.8 * padUnit());
  }

  void draw () {
    if (!this.visible) return;

    if (this.mouseGuide_pre_screen != null) {
      image(this.mouseGuide_pre_screen, 0, 0);
    }

    float[] box = boundingBox();

    noStroke();
    fill(0, 191);
    rect(box[0], box[1], box[2] - box[0], box[3] - box[1]);

    ArrayList<LaidOutPad> pads = buildLayout();
    LaidOutPad hovered = padAt(pads, mouseX, mouseY);

    for (LaidOutPad p : pads) drawPad(p, p == hovered);

    ArrayList<String> lines = (hovered != null) ? mouseMapDescribeViewport(hovered.viewport) : new ArrayList<String>();
    if (lines.size() > 0) {
      // Same overflow-safe multi-column layout as UI_keyboardMap.draw()'s
      // own hint list (uiKeyboardMap.pde) - WIN3D alone can run to ~50
      // lines (mouseMapBindings.pde's own header comment explains why),
      // so this is exactly the "many lines, one hover target" case that
      // layout was built to handle.
      float hintTextSize = 0.45 * padUnit();
      float lineHeight = 1.4 * hintTextSize;
      float boxTop = padClusterBottom(pads);
      float bottomLimit = box[3] - 0.25 * padUnit();
      int linesPerColumn = max(1, (int) floor((bottomLimit - boxTop) / lineHeight));
      int columnCount = 3;
      float firstColumnX = box[0] + padUnit();
      float columnWidth = (box[2] - firstColumnX) / columnCount;

      textAlign(LEFT, TOP);
      textSize(hintTextSize);
      fill(255);
      float boldOffset = max(1, 0.04 * hintTextSize);
      int maxLines = min(lines.size(), linesPerColumn * columnCount);
      for (int i = 0; i < maxLines; i++) {
        int col = i / linesPerColumn;
        int row = i % linesPerColumn;
        float tx = firstColumnX + col * columnWidth;
        float ty = boxTop + row * lineHeight;

        // keyboardMapSplitLineForDisplay() (keyboardMapBindings.pde) is
        // generic over any "combo: description" line - there's no "+"
        // in a mouse action label, so its readable-punctuation rewrite
        // is simply a no-op here; reused as-is rather than duplicated.
        String[] parts = keyboardMapSplitLineForDisplay(lines.get(i));
        String combo = parts[0];
        String description = parts[1];

        text(combo, tx, ty);
        text(combo, tx + boldOffset, ty);
        text(": " + description, tx + textWidth(combo) + boldOffset, ty);
      }
    }
  }
}
