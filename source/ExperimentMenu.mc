import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ExperimentMenu extends WatchUi.Menu2 {
    public function initialize() {
        Menu2.initialize({:title => "UI Experiments"});

        addItem(new WatchUi.MenuItem("Color palette", "AMOLED colors", :colors, null));
        addItem(new WatchUi.MenuItem("Typography", "Built-in fonts", :typography, null));
        addItem(new WatchUi.MenuItem("Components", "Cards and controls", :components, null));
        addItem(new WatchUi.MenuItem("Circular menu", "Rotary quick launch", :circularMenu, null));
        addItem(new WatchUi.MenuItem("Exit", null, :exit, null));
    }
}

class ExperimentMenuDelegate extends WatchUi.Menu2InputDelegate {
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Symbol;

        if (id == :exit) {
            System.exit();
            return;
        }

        if (id == :circularMenu) {
            var circularMenu = new CircularMenuView(
                CircularMenuExperiment.createEntries(),
                7,
                new CircularMenuStyle(
                    0x324f63,
                    0xadcade,
                    0x3f5d6e,
                    0xd0d4b4
                )
            );
            WatchUi.pushView(
                circularMenu,
                new CircularMenuDelegate(
                    circularMenu,
                    self.method(:onCircularMenuSelect)
                ),
                WatchUi.SLIDE_LEFT
            );
            return;
        }

        var title = "Experiment";
        if (id == :colors) {
            title = "Color palette";
        } else if (id == :typography) {
            title = "Typography";
        } else if (id == :components) {
            title = "Components";
        }

        WatchUi.pushView(
            new ExperimentView(id, title),
            new ExperimentViewDelegate(),
            WatchUi.SLIDE_LEFT
        );
    }

    public function onCircularMenuSelect(
        entry as CircularMenuEntry,
        index as Number
    ) as Void {
        WatchUi.showToast("Selected " + entry.getLabel(), {});
    }
}
