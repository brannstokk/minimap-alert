# Minimap Alert for WoW Classic

## Summary

This is a fork of Loelalol's Minimap Alert available on
[Curse](https://www.curseforge.com/wow/addons/minimap-alert).  I'm not
sure where else it may be available or where the source code is
hosted, if anywhere.

I based this off the Minimap_Alert_6.zip for the 8.0.1 client,
downloaded from
[Curse](https://www.curseforge.com/wow/addons/minimap-alert).  I knew
the WoW Classic client was based on the 8.0 retail client, so expected
this version would Just Work.

## Documentation

See: [Curse](https://www.curseforge.com/wow/addons/minimap-alert)

## Changes from upstream

* Replaced Legion/BfA trackables list with list of all Classic herbs
* Changed the alert sound from the Raid Warning sound to the PVP Queue pop sound

## Useful macros

GatherMate2 minimap tracking interferes with this addon's operation,
so those must be disabled for it to work.  This macro will toggle
GM2's minimap icons off and launch the Minimap Alert GUI:

    /run GatherMate2.db.profile["showMinimap"] = false; GatherMate2:GetModule("Config"):UpdateConfig()
    /minimapalert

To re-enable the minimap icons, you can either bind the button in
Interface -> Addons -> GatherMate2, or use this macro:

    /run GatherMate2.db.profile["showMinimap"] = true; GatherMate2:GetModule("Config"):UpdateConfig()

## To-do

* Add Classic mining node IDs
* Add macro to programmatically stop Minimap Alert scan and close the GUI
* Add an alert sound picker to the addon's configuration dialog
* Add helper macros to this document for disabling minimap icons for Gatherer, etc.

