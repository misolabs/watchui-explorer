# WatchUi Explorer

A Garmin Connect IQ watch app for trying UI concepts on the Forerunner 165 and
Forerunner 165 Music.

## Build

The build script automatically selects the newest SDK installed by Connect IQ
SDK Manager and uses the developer key at `../garmin dev/developer_key`.

```sh
./scripts/build.sh          # Forerunner 165
./scripts/build.sh fr165m   # Forerunner 165 Music
```

Override the defaults with `CONNECTIQ_SDK_ROOT` or `DEVELOPER_KEY_PATH`.

In VS Code, run the default **Connect IQ: Build FR165** build task. The Garmin
Monkey C extension can also use `monkey.jungle` directly.

## Run in the simulator

Build the app, launch or focus the simulator, and install the latest build:

```sh
./scripts/simulate.sh          # Forerunner 165
./scripts/simulate.sh fr165m   # Forerunner 165 Music
```

Run the same command after editing to rebuild and reload the app. In VS Code,
use **Connect IQ: Run/Reload FR165 Simulator**. The command stays attached
while the app runs so runtime logs remain visible; press Ctrl-C to detach.

## Add an experiment

1. Add a `MenuItem` before `Exit` in `ExperimentMenu.initialize()`.
2. Handle its symbol in `ExperimentMenuDelegate.onSelect()`.
3. Add its drawing code to `ExperimentView.onUpdate()`, or push a dedicated
   view and delegate for interactive prototypes.

The device Back action returns from an experiment to the menu. Selecting the
final **Exit** item closes the app.

### Circular menu component

`CircularMenuView` accepts an array of `CircularMenuEntry` values containing a
label and any `WatchUi.Drawable`. Its delegate keeps the selected entry near
the START button, animates clockwise or counterclockwise through entries with
UP/DOWN, and invokes a callback when START is pressed. Set `maxVisible` to
control the rotating window size. `CircularMenuStyle` configures the
background, `drawBitmap2` icon tint, selection ring, and center-label colors.
