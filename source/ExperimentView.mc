import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ExperimentView extends WatchUi.View {
    private var _experiment as Symbol;
    private var _title as String;

    public function initialize(experiment as Symbol, title as String) {
        View.initialize();
        _experiment = experiment;
        _title = title;
    }

    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.drawText(
            width / 2,
            24,
            Graphics.FONT_SMALL,
            _title,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (_experiment == :colors) {
            drawColors(dc, width, height);
        } else if (_experiment == :typography) {
            drawTypography(dc, width);
        } else {
            drawComponents(dc, width);
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height - 38,
            Graphics.FONT_XTINY,
            "BACK to menu",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    private function drawColors(dc as Dc, width as Number, height as Number) as Void {
        var colors = [
            0x00ffff,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_RED,
            Graphics.COLOR_PURPLE
        ];
        var swatchWidth = 50;
        var gap = 8;
        var totalWidth = (swatchWidth * colors.size()) + (gap * (colors.size() - 1));
        var left = (width - totalWidth) / 2;
        var top = (height / 2) - 48;

        for (var i = 0; i < colors.size(); i++) {
            dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(left + (i * (swatchWidth + gap)), top, swatchWidth, 96, 12);
        }
    }

    private function drawTypography(dc as Dc, width as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 92, Graphics.FONT_XTINY, "XTINY / LABEL", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, 132, Graphics.FONT_SMALL, "Small text", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, 184, Graphics.FONT_MEDIUM, "Medium", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, 248, Graphics.FONT_LARGE, "Large", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawComponents(dc as Dc, width as Number) as Void {
        var left = 48;
        var cardWidth = width - 96;

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(left, 86, cardWidth, 94, 18);
        dc.fillRoundedRectangle(left, 194, cardWidth, 94, 18);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + 20, 102, Graphics.FONT_XTINY, "HEART RATE", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(left + 20, 128, Graphics.FONT_LARGE, "142", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(left + 20, 210, Graphics.FONT_XTINY, "RECOVERY", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(left + 20, 238, Graphics.FONT_MEDIUM, "18 hours", Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(left + cardWidth - 34, 133, 10);
        dc.setColor(0x00ffff, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(left + cardWidth - 34, 241, 10);
    }
}

class ExperimentViewDelegate extends WatchUi.BehaviorDelegate {
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
