# 🎣 takenncs-fishing

Fishing script for QBcore, ox_lib, ox_target, and ox_inventory. Includes a fishing license system that can be purchased and is saved in SQL.

## ✨ Features

✅ **Fishing Rod Prop** - `prop_fishing_rod_02` appears in hand  
✅ **Skillbar** - 3 attempts to catch fish (uses takenncs-skillbar)  
✅ **Progress Bar** - "Preparing to fish" animation  
✅ **Fishing Spots** - 3 locations with blips on map  
✅ **Fish Variety** - 8 different fish with different chances  
✅ **Sell System** - sell all fish at once to NPC  
✅ **Ox_target Support** - interact with fishing spots and seller  
✅ **Ox_lib Menu** - beautiful context menu for selling  
✅ **Multi-language** - Estonian (ee) included, easy to add more  

## 🔧 Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)
- [takenncs-skillbar](https://github.com/Takennncs/takenncs-skillbar)

## Add items to ox_inventory (copy to ox_inventory/data/items.lua):

```lua
['fishingrod'] = {
    label = 'Fishing Rod',
    weight = 1850,
    stack = true,
    close = true,
    description = "Used to catch fish..",
    client = {
        export = 'takenncs-fishing.UseFishingRod'
    }
},
['fishinglicense'] = {
    label = 'Fishing License',
    weight = 50,
    stack = false,
    close = true,
    description = 'Fishing license to show to police',
    client = {
        image = 'fishinglicense.png'
    }
},
['fishingbass'] = {
    label = 'Bass',
    weight = 700,
    stack = true,
    close = true,
    description = 'Common freshwater fish.'
},
['fishingcod'] = {
    label = 'Cod',
    weight = 1500,
    stack = true,
    close = true,
    description = 'One of the most common fish.'
},
['fishingmackerel'] = {
    label = 'Mackerel',
    weight = 1250,
    stack = true,
    close = true,
    description = 'Common mackerel, predatory fish.'
},
['fishingbluefish'] = {
    label = 'Bluefish',
    weight = 1300,
    stack = true,
    close = true,
    description = 'Not actually blue, but still a fish.'
},
['fishingflounder'] = {
    label = 'Flounder',
    weight = 970,
    stack = true,
    close = true,
    description = 'Straight from the North Pole.'
},
['fishingshark'] = {
    label = 'Small Shark',
    weight = 2500,
    stack = true,
    close = true,
    description = 'After it bites you, it won\'t be so small.'
},
['fishingdolphin'] = {
    label = 'Small Dolphin',
    weight = 2750,
    stack = true,
    close = true,
    description = 'So cute you want to throw it back.'
},
['fishingwhale'] = {
    label = 'Small Whale',
    weight = 3500,
    stack = true,
    close = true,
    description = 'Small whale, sadly doesn\'t fit in bag.'
}
```

## Fishing Spots
- Blips appear on map at fishing locations
- Go to any fishing spot
- Approach the water and look for the target zone
- Press E to start fishing

## 👨‍💻 Author
- Takenncs

## 🙏 Credits
- QBcore Framework
- Overextended (ox_lib, ox_target, ox_inventory, oxmysql)
