# Flexible Bars (PC Overhaul Fork)

A highly customizable tool to move, scale, and rotate your attribute bars (Health, Magicka, Stamina) in Elder Scrolls Online with great flexibility.

This addon is a heavily modified and optimized PC port of the original "Flexible Bars" created by @M0R_Gaming for Xbox/Console. Refactored and maintained by @Zerakthion with a heavy focus on testing and fine-tuning the Vertical bar layout preference.

## Key Differences & Overhaul Features (vs. Original Console Version)

* No Dependencies for Moving: Unlike the original console version, it removes the requirement of LibCombatAlerts to move bars[cite: 4]. Axis sliders (X/Y coordinates) are now fully integrated directly into the addon settings menu for pinpoint PC accuracy.
* Remade LAM2 Settings Menu: Console/gamepad dialog boxes are replaced with a clean LibAddonMenu-2.0 interface. Health, Magicka, and Stamina settings are neatly grouped into separate, clutter-free submenus.
* Advanced Text & Percentage Options: Replaced bulky default resource text with clean formatting (e.g., 15k). Added a standalone Percentage Label for each bar. Absolute values and percentages can be scaled, rotated, and offset completely independently. Added dynamic shield text for the Health bar.
* Stable UI Hiding: Implemented code-level overrides (ZO_PreHook on SetAlpha) to guarantee that the default base-game resource bars stay hidden during combat and do not randomly reappear[cite: 2].
* Optimized Vertical Preset: The built-in "Vertical" preset layout has been completely fine-tuned with proper text rotations and offsets, fully optimized for PC playstyles out of the box.

## Dependencies

* LibAddonMenu-2.0 (>= 40)

## Installation

1. Download and extract the repository.
2. Place the FlexibleBars folder into your ESO AddOns directory:
   Documents/Elder Scrolls Online/live/AddOns/
3. Launch the game and enable the addon.

## Credits

* Base Framework: @M0R_Gaming
* PC Port & Modifications: @Zerakthion 
