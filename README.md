# Master Drawer Controller
`License : MIT`
`Credits : Skylord`

## What is the `Master Drawer Controller`?
It's a digiline program created to handle multiple drawer controllers simultaniously to get items quickly.
It features:
- Giving access to users to use the screen
- Selecting drawer or chest to get the items (dual teleport tubes)
- Very easy to understand code (I hope)

## How to setup this program?
- Connect a digiline touchscreen, two teleport tubes, a drawer controller and a lua controller (luac) to some insulating digiline material
- Make sure correct channels are entered into each component (i.e. drawer controller | DC<number>, digiline touchscreen | screen, etc)
- In the luac, pastle the conents of `file.lua` into it. Make adjustments to the code (such as changing owners, staff, max drawers and teleport tube channels)
- (Optional): Add extra shortcut (alias) names
- Hit the execute button
- And enjoy

<i>Probably did a crappy job at explaining, but once the settings tab is fully operational, it will make sense</i>

## Todo list for V2 (Potentially final) update(s)
- Key : ? = Thinking
- Make DC's take different types of items (i.e. craftitems is taken by DC1, node is taken by DC2, etc)
- Use of mithril stuff for automatically getting stuff instead of selecting what draw has what
- A textlist containing all shortcut items
- Instead of using a declared table, use luac's sandbox memory to dump shortcut items and add a screen for players to add their own shortcuts instead of using the table (i.e. mem.drawer_shortcuts). Same for setting owners, staff and setting up tubes (settings tab)

<b>Once the todo list for V2 is complete, this will became a maintain-only project (unless I come up with some new ideas)</b>