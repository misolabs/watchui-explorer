import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class CircularMenuEntry {
    private var _label as String;
    private var _icon as WatchUi.Drawable;

    public function initialize(label as String, icon as WatchUi.Drawable) {
        _label = label;
        _icon = icon;
    }

    public function getLabel() as String {
        return _label;
    }

    public function getIcon() as WatchUi.Drawable {
        return _icon;
    }
}

class CircularMenuStyle {
    private var _backgroundColor as ColorType;
    private var _iconColor as ColorType;
    private var _selectionColor as ColorType;
    private var _labelColor as ColorType;

    public function initialize(
        backgroundColor as ColorType,
        iconColor as ColorType,
        selectionColor as ColorType,
        labelColor as ColorType
    ) {
        _backgroundColor = backgroundColor;
        _iconColor = iconColor;
        _selectionColor = selectionColor;
        _labelColor = labelColor;
    }

    public function getBackgroundColor() as ColorType {
        return _backgroundColor;
    }

    public function getIconColor() as ColorType {
        return _iconColor;
    }

    public function getSelectionColor() as ColorType {
        return _selectionColor;
    }

    public function getLabelColor() as ColorType {
        return _labelColor;
    }
}

class CircularMenuView extends WatchUi.View {
    private const DEFAULT_MAX_VISIBLE = 7;
    private const ICON_SIZE = 80;
    private const EDGE_MARGIN = 12;
    private const SELECTION_PADDING = 7;
    private const ANIMATION_FRAME_COUNT = 5;
    private const ANIMATION_FRAME_MS = 50;
    private const HAPTIC_DUTY_CYCLE = 20;
    private const HAPTIC_DURATION_MS = 35;
    private const HAPTIC_DEBOUNCE_MS = 80;
    private const MIN_DRAG_RADIUS = 48;

    private var _entries as Array<CircularMenuEntry>;
    private var _selectedIndex as Number = 0;
    private var _maxVisible as Number;
    private var _style as CircularMenuStyle;
    private var _animationSelectionDelta as Number = 0;
    private var _animationFrame as Number = 0;
    private var _animationStartRotation as Float = 0.0;
    private var _animationTargetRotation as Float = 0.0;
    private var _animationTimer as Timer.Timer?;
    private var _rotation as Float = 0.0;
    private var _pendingDelta as Number = 0;
    private var _dragging as Boolean = false;
    private var _lastDragAngle as Float = 0.0;
    private var _lastHapticTime as Number = 0;
    private var _centerX as Number = 0;
    private var _centerY as Number = 0;

    public function initialize(
        entries as Array<CircularMenuEntry>,
        maxVisible as Number?,
        style as CircularMenuStyle
    ) {
        View.initialize();
        _entries = entries;
        _maxVisible = maxVisible == null ? DEFAULT_MAX_VISIBLE : maxVisible;
        _style = style;
    }

    public function getSelectedEntry() as CircularMenuEntry? {
        if (_entries.size() == 0) {
            return null;
        }

        return _entries[_selectedIndex];
    }

    public function getSelectedIndex() as Number {
        return _selectedIndex;
    }

    public function moveSelection(delta as Number) as Void {
        var count = _entries.size();
        if (count == 0) {
            return;
        }

        if (_animationTimer != null) {
            _pendingDelta += delta;
            return;
        }

        startAnimation(delta);
    }

    public function onRotaryDrag(x as Number, y as Number) as Void {
        if (_entries.size() == 0 || _animationTimer != null) {
            return;
        }

        var offsetX = x - _centerX;
        var offsetY = y - _centerY;
        if (
            (offsetX * offsetX) + (offsetY * offsetY)
            < MIN_DRAG_RADIUS * MIN_DRAG_RADIUS
        ) {
            return;
        }

        var angle = Math.atan2(offsetY, offsetX).toFloat();
        if (!_dragging) {
            _dragging = true;
            _lastDragAngle = angle;
            return;
        }

        var delta = angle - _lastDragAngle;
        if (delta > Math.PI) {
            delta -= Math.PI * 2.0;
        } else if (delta < -Math.PI) {
            delta += Math.PI * 2.0;
        }

        _lastDragAngle = angle;
        var previousRotation = _rotation;
        _rotation += delta;
        if (crossedSlotBoundary(previousRotation, _rotation)) {
            playDetentHaptic();
        }

        WatchUi.requestUpdate();
    }

    public function beginRotaryDrag(x as Number, y as Number) as Void {
        _dragging = false;
        onRotaryDrag(x, y);
    }

    public function endRotaryDrag() as Void {
        if (!_dragging) {
            return;
        }

        _dragging = false;
        var angleStep = getAngleStep();
        var selectionDelta = 0;
        var remainingRotation = _rotation;
        while (remainingRotation >= angleStep / 2.0) {
            selectionDelta--;
            remainingRotation -= angleStep;
        }
        while (remainingRotation <= -angleStep / 2.0) {
            selectionDelta++;
            remainingRotation += angleStep;
        }

        startAnimation(selectionDelta);
    }

    public function onHide() as Void {
        if (_animationTimer != null) {
            (_animationTimer as Timer.Timer).stop();
            _animationTimer = null;
        }
        _dragging = false;
    }

    public function onUpdate(dc as Dc) as Void {
        dc.setColor(
            _style.getLabelColor(),
            _style.getBackgroundColor()
        );
        dc.clear();

        if (_entries.size() == 0) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_SMALL,
                "No entries",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
        }

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        _centerX = centerX;
        _centerY = centerY;
        var radius = (dc.getWidth() / 2) - (ICON_SIZE / 2) - EDGE_MARGIN;
        var visibleCount = _entries.size() < _maxVisible
            ? _entries.size()
            : _maxVisible;
        var firstOffset = -(visibleCount / 2);
        var selectedAngle = -Math.PI / 6.0;
        var angleStep = getAngleStep();

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(centerX, centerY, radius);

        var selectionX = centerX + (Math.cos(selectedAngle) * radius);
        var selectionY = centerY + (Math.sin(selectedAngle) * radius);
        dc.setColor(_style.getSelectionColor(), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(
            selectionX,
            selectionY,
            (ICON_SIZE / 2) + SELECTION_PADDING
        );

        for (var slot = 0; slot < visibleCount; slot++) {
            var offset = firstOffset + slot;
            var entryIndex = (_selectedIndex + offset + _entries.size()) % _entries.size();
            var angle = selectedAngle + (offset * angleStep) + _rotation;
            var iconX = centerX + (Math.cos(angle) * radius);
            var iconY = centerY + (Math.sin(angle) * radius);

            drawEntry(dc, _entries[entryIndex], iconX, iconY);
        }

        var selected = _entries[_selectedIndex];
        dc.setColor(_style.getLabelColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            centerY,
            Graphics.FONT_MEDIUM,
            selected.getLabel(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawEntry(
        dc as Dc,
        entry as CircularMenuEntry,
        x as Numeric,
        y as Numeric
    ) as Void {
        var buffer = Graphics.createBufferedBitmap({
            :width => ICON_SIZE,
            :height => ICON_SIZE
        }).get();
        var iconDc = buffer.getDc();
        iconDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        iconDc.clear();
        entry.getIcon().draw(iconDc);

        dc.drawBitmap2(
            x - (ICON_SIZE / 2),
            y - (ICON_SIZE / 2),
            buffer,
            {:tintColor => _style.getIconColor()}
        );
    }

    private function startAnimation(delta as Number) as Void {
        var angleStep = getAngleStep();
        _animationSelectionDelta = delta;
        _animationStartRotation = _rotation;
        _animationTargetRotation = -delta * angleStep;
        _animationFrame = 0;
        _animationTimer = new Timer.Timer();
        (_animationTimer as Timer.Timer).start(
            self.method(:onAnimationFrame),
            ANIMATION_FRAME_MS,
            true
        );
        WatchUi.requestUpdate();
    }

    private function getAngleStep() as Float {
        var visibleCount = _entries.size() < _maxVisible
            ? _entries.size()
            : _maxVisible;
        var hasOverflow = _entries.size() > visibleCount;
        var angleDivisions = hasOverflow ? visibleCount + 1 : visibleCount;
        return ((Math.PI * 2.0) / angleDivisions).toFloat();
    }

    private function crossedSlotBoundary(
        previousRotation as Float,
        currentRotation as Float
    ) as Boolean {
        var angleStep = getAngleStep();
        if (currentRotation > previousRotation) {
            return Math.floor(previousRotation / angleStep)
                != Math.floor(currentRotation / angleStep);
        }
        if (currentRotation < previousRotation) {
            return Math.ceil(previousRotation / angleStep)
                != Math.ceil(currentRotation / angleStep);
        }
        return false;
    }

    private function playDetentHaptic() as Void {
        var now = System.getTimer();
        if (now - _lastHapticTime < HAPTIC_DEBOUNCE_MS) {
            return;
        }

        _lastHapticTime = now;
        Attention.vibrate([
            new Attention.VibeProfile(
                HAPTIC_DUTY_CYCLE,
                HAPTIC_DURATION_MS
            )
        ]);
    }

    public function onAnimationFrame() as Void {
        _animationFrame++;
        var progress = _animationFrame.toFloat() / ANIMATION_FRAME_COUNT;
        var easedProgress = progress * progress * (3.0 - (2.0 * progress));
        _rotation = _animationStartRotation + (
            (_animationTargetRotation - _animationStartRotation)
            * easedProgress
        );

        if (_animationFrame < ANIMATION_FRAME_COUNT) {
            WatchUi.requestUpdate();
            return;
        }

        (_animationTimer as Timer.Timer).stop();
        _animationTimer = null;
        var selectionOffset = (
            _animationSelectionDelta % _entries.size()
        ) + _entries.size();
        _selectedIndex = (
            _selectedIndex + selectionOffset
        ) % _entries.size();
        _animationSelectionDelta = 0;
        _animationFrame = 0;
        _rotation = 0.0;

        if (_pendingDelta != 0) {
            var nextDelta = _pendingDelta < 0 ? -1 : 1;
            _pendingDelta -= nextDelta;
            startAnimation(nextDelta);
        } else {
            WatchUi.requestUpdate();
        }
    }
}

class CircularMenuDelegate extends WatchUi.BehaviorDelegate {
    private var _view as CircularMenuView;
    private var _onSelect as Method(
        entry as CircularMenuEntry,
        index as Number
    ) as Void;

    public function initialize(
        view as CircularMenuView,
        onSelect as Method(
            entry as CircularMenuEntry,
            index as Number
        ) as Void
    ) {
        BehaviorDelegate.initialize();
        _view = view;
        _onSelect = onSelect;
    }

    public function onNextPage() as Boolean {
        _view.moveSelection(1);
        return true;
    }

    public function onPreviousPage() as Boolean {
        _view.moveSelection(-1);
        return true;
    }

    public function onSelect() as Boolean {
        var entry = _view.getSelectedEntry();
        if (entry != null) {
            _onSelect.invoke(entry, _view.getSelectedIndex());
        }
        return true;
    }

    public function onDrag(event as WatchUi.DragEvent) as Boolean {
        var dragType = event.getType();
        if (dragType == WatchUi.DRAG_TYPE_STOP) {
            _view.endRotaryDrag();
        } else {
            var coordinates = event.getCoordinates();
            if (dragType == WatchUi.DRAG_TYPE_START) {
                _view.beginRotaryDrag(coordinates[0], coordinates[1]);
            } else {
                _view.onRotaryDrag(coordinates[0], coordinates[1]);
            }
        }
        return true;
    }

    public function onRelease(event as WatchUi.ClickEvent) as Boolean {
        _view.endRotaryDrag();
        return true;
    }

    public function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
