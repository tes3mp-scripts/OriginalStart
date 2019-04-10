Fixes most of the issues related to vanilla game start. However, the tes3mp chargen style is kept, so a lot of the voiced dialogue is skipped.

Unlike my other scripts, doesn't require the [DataManager](https://github.com/tes3mp-scripts/DataManager) (but still supports it if installed).

To install, either `git pull` it, or download the reposetory as a folder, rename it to `OriginalStart` and then put it into your `server/scripts/custom`. After doing either of those, add `require("custom.OriginalStart.main)` to your `server/scripts/customScripts.lua`.

If you are using [DataManager](https://github.com/tes3mp-scripts/DataManager), you can edit `data/custom/__config_OriginalStart.json`, otherwise you can edit lines `3` and `4` of `main.lua`.  
* `START_ON_DOCK` if `false`, spawns you at the ship like in vanilla Morrowind. If `true`, you spawn standing at the dock and the ship is disabled.
* `CLEAN_ON_UNLOAD` whether the cell `-2, -9` should be cleaned of some chargen residue whenever it unloads (could cause performance issues if used on a large server). If you want to clean it manually instead, set this to `false` and call `Start.cleanDockCell(pid, cellDescription)` when you find appropriate.