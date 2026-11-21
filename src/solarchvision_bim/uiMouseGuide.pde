// UI_mouseGuide - a "Ctrl+?"-triggered, click-outside-or-any-key-
// dismissed overlay drawing three touchpad illustrations - one per main
// viewport (WORLD, STUDY, WIN3D) - purely as a hover-driven reference,
// same spirit as UI_keyboardMap (uiKeyboardMap.pde): no highlighting of
// "currently active" state, no click-to-fire. Each touchpad is itself
// split into separately-hoverable sub-zones - a left/middle/right-click
// button row along its top edge, with a scroll wheel nested inside the
// middle third itself - and hovering one shows only that
// zone's own mouse bindings for that viewport (mouseMapBindings.pde),
// same per-part granularity as UI_keyboardMap's own per-key hover,
// rather than the whole viewport's list at once. The hint list itself
// uses the same overflow-safe multi-column layout the keyboard guide
// already built - reused here via keyboardMapSplitLineForDisplay(),
// which is generic enough ("combo: description", bold the first part)
// to serve both guides without change.
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

  final float OVERLAY_PADDING = 10;

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
  //
  // Moved up close to the overlay's own top edge (0.5 unit, down from
  // 2) rather than centered with a tall gap above - the extra vertical
  // room goes to the hint list below instead of to empty space above.
  // The pad itself only needs to be tall enough for its own button row
  // (now two-line labels, buttonThirdRect()'s own comment) plus a lower
  // body for the viewport-name label (drawPad()'s own comment) - a
  // horizontal rectangle, wider than tall, rather than a square or
  // portrait shape. The scroll wheel no longer needs its own room below
  // the button row - it's nested inside the middle third itself now
  // (scrollZoneRect()'s own comment) - which is what leaves this lower
  // body free for the viewport-name label to move back into.
  ArrayList<LaidOutPad> buildLayout () {
    ArrayList<LaidOutPad> pads = new ArrayList<LaidOutPad>();
    float unit = padUnit();
    float[] box = boundingBox();

    float padWidth = 6 * unit;
    float padHeight = 4 * unit; // horizontal rectangle - just tall enough for the button row + scroll wheel (buttonThirdRect()/scrollZoneRect()), stretched up from the square/portrait shapes this used to be
    float gap = 2 * unit;

    float totalWidth = PAD_ORDER.length * padWidth + (PAD_ORDER.length - 1) * gap;
    float startX = box[0] + ((box[2] - box[0]) - totalWidth) / 2;
    float padTop = box[1] + 0.5 * unit;

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

  // Bottom edge of the lowest touchpad - where the hint list starts,
  // same "measure what was actually drawn" idea as
  // UI_keyboardMap.mainClusterBottom(), just analytic here since every
  // pad shares one fixed height rather than needing a scan. The
  // viewport-name label moved back inside the pad (drawPad()'s own
  // comment), so there's nothing left below the pad to reserve room
  // for - just a little breathing room before the hint list starts,
  // same small gap the square-pad layout used.
  float padClusterBottom (ArrayList<LaidOutPad> pads) {
    float bottom = 0;
    for (LaidOutPad p : pads) bottom = max(bottom, p.y + p.h);
    return bottom + 0.6 * padUnit();
  }

  // Bounding box of one of the button row's three equal thirds -
  // third 0 = left-click, 1 = middle-click, 2 = right-click. The button
  // row itself sits at the TOP of the pad (where a real mouse's own
  // buttons are, near the front/top of its body) rather than along the
  // bottom edge. Height is a fixed multiple of padUnit() rather than a
  // fraction of p.h - each third ends up roughly square (thirdWidth is
  // also ~2 units), which is all the two-line Left/Middle/Right Click
  // labels (drawPad()'s own comment) need, independent of whatever the
  // pad's own total height is. Computed from p's own fields rather than
  // cached on LaidOutPad, and called identically from drawPad() (to
  // draw it) and subZoneAt() (to hit-test it), so the two can never
  // drift apart - same reasoning modify3D.pde's countLessThan()-style
  // shared helpers follow.
  float[] buttonThirdRect (LaidOutPad p, int third) {
    float buttonRowHeight = 2 * padUnit();
    float thirdWidth = p.w / 3;
    float zoneLeft = p.x + third * thirdWidth;
    return new float[]{ zoneLeft, p.y, zoneLeft + thirdWidth, p.y + buttonRowHeight };
  }

  // Bounding box of the scroll wheel ("dragger") pill - nested inside
  // the middle-click third itself now, right where the "Middle\nClick"
  // label used to sit (drawPad()'s own comment dropped that label so
  // the pill could move in), rather than as a separate zone below the
  // button row. Sized to sit comfortably within one third's own
  // square-ish bounds (buttonThirdRect()'s own comment) with a visible
  // margin on every side, centered on that third's center point.
  float[] scrollZoneRect (LaidOutPad p) {
    float[] middleThird = buttonThirdRect(p, 1);
    float thirdWidth = middleThird[2] - middleThird[0];
    float thirdHeight = middleThird[3] - middleThird[1];
    float scrollW = 0.5 * thirdWidth;
    float scrollH = 0.6 * thirdHeight;
    float centerX = (middleThird[0] + middleThird[2]) / 2;
    float centerY = (middleThird[1] + middleThird[3]) / 2;
    float scrollX = centerX - scrollW / 2;
    float scrollY = centerY - scrollH / 2;
    return new float[]{ scrollX, scrollY, scrollX + scrollW, scrollY + scrollH };
  }

  // Which part of this one touchpad the given point is inside - one of
  // "LEFT", "MIDDLE", "RIGHT" (the button row's three thirds, at the
  // pad's top edge), "SCROLL" (the dragger pill, now nested inside the
  // middle third itself - scrollZoneRect()'s own comment), "GENERAL"
  // (anywhere else on the pad's own surface - the lower body below the
  // button row, where the "Hover"/"Drag" bindings that aren't tied to
  // any one button apply, and where the viewport-name label now sits -
  // drawPad()'s own comment), or null if the point isn't on this pad at
  // all. SCROLL is checked first purely because it sits inside what
  // would otherwise fall into MIDDLE, not because of any real overlap
  // between MIDDLE and the other thirds.
  String subZoneAt (LaidOutPad p, float mx, float my) {
    float[] scroll = scrollZoneRect(p);
    if (isInside(mx, my, scroll[0], scroll[1], scroll[2], scroll[3])) return "SCROLL";
    float[] left = buttonThirdRect(p, 0);
    if (isInside(mx, my, left[0], left[1], left[2], left[3])) return "LEFT";
    float[] middle = buttonThirdRect(p, 1);
    if (isInside(mx, my, middle[0], middle[1], middle[2], middle[3])) return "MIDDLE";
    float[] right = buttonThirdRect(p, 2);
    if (isInside(mx, my, right[0], right[1], right[2], right[3])) return "RIGHT";
    if (isInside(mx, my, p.x, p.y, p.x + p.w, p.y + p.h)) return "GENERAL";
    return null;
  }

  // The internal viewport keys (PAD_ORDER, and every row in
  // mouseMapBindings.pde) stay WORLD/STUDY/WIN3D - that's the lookup key
  // mouseMapDescribeViewportZone() is keyed on, so renaming those would
  // break the hint lookup. Only what's actually painted on screen uses
  // the API's own viewport-type naming instead.
  String viewportDisplayLabel (String viewport) {
    if ("WORLD".equals(viewport)) return "Map Viewport";
    if ("STUDY".equals(viewport)) return "2D Viewport";
    if ("WIN3D".equals(viewport)) return "3D Viewport";
    return viewport;
  }

  // Draws one touchpad: an outer rounded surface, a three-way button
  // row (left/middle/right-click) along the TOP edge - where a real
  // mouse's own buttons sit, near the front of its body, rather than
  // along the bottom - with a scroll wheel ("dragger") pill nested
  // inside the middle third itself, rather than as a separate zone of
  // its own. Purely illustrative
  // past the button row's own three zones, which really are separately
  // hoverable now (hoveredZone, one of this class's subZoneAt()
  // results, or null if this pad isn't the one being hovered at all):
  // only the exact zone the mouse is over lights up, same "the thing
  // you're pointing at, not the whole widget" idea as
  // UI_keyboardMap.draw()'s own per-key isHovered check.
  void drawPad (LaidOutPad p, String hoveredZone) {
    noStroke();
    // A faint overall tint whenever the mouse is anywhere on this pad
    // (hoveredZone != null), with the specific hovered zone drawn
    // brighter on top of it below.
    fill(hoveredZone != null ? color(0, 90, 150) : color(40));
    rect(p.x, p.y, p.w, p.h, 8);

    color zoneHighlight = color(0, 140, 255);
    if ("LEFT".equals(hoveredZone) || "MIDDLE".equals(hoveredZone) || "RIGHT".equals(hoveredZone)) {
      int third = "LEFT".equals(hoveredZone) ? 0 : ("MIDDLE".equals(hoveredZone) ? 1 : 2);
      float[] z = buttonThirdRect(p, third);
      fill(zoneHighlight);
      rect(z[0], z[1], z[2] - z[0], z[3] - z[1]);
    }

    float buttonRowHeight = 2 * padUnit();
    float buttonRowBottom = p.y + buttonRowHeight;
    float thirdWidth = p.w / 3;

    stroke(0, 120);
    strokeWeight(2);
    // Divider between the button row and the rest of the pad's surface.
    line(p.x, buttonRowBottom, p.x + p.w, buttonRowBottom);
    // Dividers between the left/middle and middle/right thirds.
    line(p.x + thirdWidth, p.y, p.x + thirdWidth, buttonRowBottom);
    line(p.x + 2 * thirdWidth, p.y, p.x + 2 * thirdWidth, buttonRowBottom);
    noStroke();

    // Left/Right Click labels, centered on their own third of the
    // button row (where the buttons they name actually are). The
    // middle third drops its own text label - the scroll wheel pill
    // sits there instead (scrollZoneRect()'s own comment) - but keeps
    // the same shared textSize the other two use, so Left/Right Click
    // stay visually consistent with each other. Each wraps onto two
    // lines ("Right\nClick") so a bigger size still fits a third's
    // width - text()'s own "\n" support centers both lines under
    // textAlign(CENTER, CENTER), no manual layout needed.
    float buttonLabelSize = 0.3 * padUnit();
    float buttonLabelY = p.y + buttonRowHeight / 2;
    fill(255, 160);
    textAlign(CENTER, CENTER);
    textSize(buttonLabelSize);
    text("Left\nClick", p.x + thirdWidth / 2, buttonLabelY);
    text("Right\nClick", p.x + 2.5 * thirdWidth, buttonLabelY);

    // Scroll wheel, nested inside the middle third itself now - right
    // where the "Middle\nClick" label used to sit - highlighted the
    // same way a hovered button-row third is.
    float[] scroll = scrollZoneRect(p);
    float scrollW = scroll[2] - scroll[0];
    float scrollH = scroll[3] - scroll[1];
    fill("SCROLL".equals(hoveredZone) ? color(255) : color(90));
    rect(scroll[0], scroll[1], scrollW, scrollH, scrollW / 2);

    // Viewport name, back inside the pad - centered in the lower body
    // below the button row, the space the scroll wheel's move up into
    // the middle third just freed up. Bigger than the button-row labels
    // since it names the whole pad, and shown with the API's own
    // viewport-type wording (Map/2D/3D Viewport) via
    // viewportDisplayLabel() rather than the internal WORLD/STUDY/WIN3D
    // key p.viewport itself holds.
    fill(255, 220);
    textSize(0.4 * padUnit());
    text(viewportDisplayLabel(p.viewport), p.x + p.w / 2, buttonRowBottom + (p.h - buttonRowHeight) / 2);
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
    LaidOutPad hoveredPad = padAt(pads, mouseX, mouseY);
    String hoveredZone = (hoveredPad != null) ? subZoneAt(hoveredPad, mouseX, mouseY) : null;

    for (LaidOutPad p : pads) drawPad(p, (p == hoveredPad) ? hoveredZone : null);

    // Filtered to the one sub-region (button/wheel/body) actually being
    // hovered, not the whole viewport's list at once - same "show only
    // what's relevant to what you're pointing at" idea as
    // UI_keyboardMap's own per-key hover.
    ArrayList<String> lines = (hoveredPad != null && hoveredZone != null)
      ? mouseMapDescribeViewportZone(hoveredPad.viewport, hoveredZone)
      : new ArrayList<String>();
    if (lines.size() > 0) {
      // Same overflow-safe multi-column layout as UI_keyboardMap.draw()'s
      // own hint list (uiKeyboardMap.pde) - WIN3D alone can run to ~50
      // lines total across all its zones (mouseMapBindings.pde's own
      // header comment explains why), so this is exactly the "many
      // lines, one hover target" case that layout was built to handle.
      // 2 wider columns instead of 3 narrower ones, same reasoning as
      // UI_keyboardMap's own hint list.
      float hintTextSize = 0.45 * padUnit();
      float lineHeight = 1.4 * hintTextSize;
      float boxTop = padClusterBottom(pads);
      float bottomLimit = box[3] - 0.25 * padUnit();
      int linesPerColumn = max(1, (int) floor((bottomLimit - boxTop) / lineHeight));
      int columnCount = 2;
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
