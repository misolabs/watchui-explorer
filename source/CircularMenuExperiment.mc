import Toybox.Lang;
import Toybox.WatchUi;

class CircularMenuExperiment {
    public static function createEntries() as Array<CircularMenuEntry> {
        return [
            new CircularMenuEntry(
                "Monitor",
                new WatchUi.Bitmap({
                    :rezId => Rez.Drawables.RotaryMonitor,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER
                })
            ),
            new CircularMenuEntry(
                "History",
                new WatchUi.Bitmap({
                    :rezId => Rez.Drawables.RotaryHistory,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER
                })
            ),
            new CircularMenuEntry(
                "Resonance",
                new WatchUi.Bitmap({
                    :rezId => Rez.Drawables.RotaryResonance,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER
                })
            ),
            new CircularMenuEntry(
                "Start\nSession",
                new WatchUi.Bitmap({
                    :rezId => Rez.Drawables.RotaryStartSession,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER
                })
            ),
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
