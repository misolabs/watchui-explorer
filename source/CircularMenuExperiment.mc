import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class CircularMenuExperiment {
    public static function createEntries() as Array<CircularMenuEntry> {
        return [
            new CircularMenuEntry(
                "Heart\nMonitor",
                new WatchUi.Bitmap({
                    :rezId => Rez.Drawables.RotaryHeartMonitor,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER
                })
            ),
            new CircularMenuEntry("Bike", new CircularMenuDemoIcon("B", Graphics.COLOR_GREEN)),
            new CircularMenuEntry("Music", new CircularMenuDemoIcon("M", Graphics.COLOR_PURPLE)),
            new CircularMenuEntry("Weather", new CircularMenuDemoIcon("W", Graphics.COLOR_YELLOW)),
            new CircularMenuEntry("Timer", new CircularMenuDemoIcon("T", Graphics.COLOR_ORANGE)),
            new CircularMenuEntry("Wallet", new CircularMenuDemoIcon("$", Graphics.COLOR_BLUE)),
            new CircularMenuEntry("Controls", new CircularMenuDemoIcon("C", 0x00ffff)),
            new CircularMenuEntry(
                "Settings",
                new WatchUi.Bitmap({
                    :rezId => Rez.Drawables.RotarySettings,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER
                })
            )
        ];
    }
}

class CircularMenuDemoIcon extends WatchUi.Drawable {
    private var _glyph as String;
    private var _color as ColorType;

    public function initialize(glyph as String, color as ColorType) {
        Drawable.initialize({});
        _glyph = glyph;
        _color = color;
    }

    public function draw(dc as Dc) as Void {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        dc.setColor(_color, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY, (dc.getWidth() / 2) - 2);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            centerY,
            Graphics.FONT_SMALL,
            _glyph,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
