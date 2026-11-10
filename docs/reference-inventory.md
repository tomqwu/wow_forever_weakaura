# Original warrior WA inventory

Static inventory of the supplied Guos Warrior Combat HUD v1.2.4: one root and 135 descendants. This records source facts, not live verification. Imported scripts and media are not reproduced.

| # | Region (source suffix) | Type | Trigger types / events | Custom action phases |
| --- | --- | --- | --- | --- |
| 1 | Primary Abilities | group | unit / Conditions |  |
| 2 | Primary Cooldowns | dynamicgroup | unit / Conditions |  |
| 3 | Primary Cooldown - Sweeping Strikes | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 4 | Primary Cooldown - Death Wish | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 5 | Primary Cooldown - Shield Block | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 6 | Primary Cooldown - Recklessness | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 7 | Primary Cooldown - Retaliation | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 8 | Primary Cooldown - Shield Wall | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 9 | Primary Cooldown - Last Stand | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 10 | Primary Cooldown - Bloodrage | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 11 | Primary Cooldown - Berserker Rage | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 12 | Primary Attacks | dynamicgroup | unit / Conditions |  |
| 13 | Primary Attack - Mortal Strike | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 14 | Primary Attack - Bloodthirst | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 15 | Primary Attack - Shield Slam | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 16 | Primary Attack - Overpower | icon | spell / Cooldown Progress (Spell), custom / status, spell / Spell Activation Overlay, spell / Action Usable | init |
| 17 | Primary Attack - Revenge | icon | spell / Cooldown Progress (Spell), custom / status, spell / Spell Activation Overlay, spell / Action Usable | init |
| 18 | Primary Attack - Whirlwind | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 19 | Primary Attack - Execute | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 20 | Primary Attack - Slam | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 21 | Primary Attack - Rend | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 22 | Primary Attack - Heroic Strike | icon | spell / Cooldown Progress (Spell), spell / Queued Action, custom / status | init |
| 23 | Primary Attack - Cleave | icon | spell / Cooldown Progress (Spell), spell / Queued Action, custom / status | init |
| 24 | Primary Attack - Thunder Clap | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 25 | Primary Attack - Sunder Armor | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 26 | Primary Attack - Spearing Strike | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 27 | Secondary Abilities | group | unit / Conditions |  |
| 28 | Utility Cooldowns | dynamicgroup | unit / Conditions |  |
| 29 | Secondary Cooldown - Retaliation | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 30 | Secondary Cooldown - Death Wish | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 31 | Secondary Cooldown - Sweeping Strikes | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 32 | Secondary Cooldown - Recklessness | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 33 | Secondary Cooldown - Shield Wall | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 34 | Secondary Cooldown - Shield Block | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 35 | Secondary Cooldown - Last Stand | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 36 | Secondary Cooldown - Bloodrage | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 37 | Secondary Cooldown - Berserker Rage | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 38 | Secondary Cooldown - Charge | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 39 | Secondary Cooldown - Intercept | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 40 | Secondary Cooldown - Disarm | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 41 | Secondary Cooldown - Intimidating Shout | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 42 | Secondary Cooldown - Challenging Shout | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 43 | Offensive Cooldowns | dynamicgroup | unit / Conditions |  |
| 44 | Execute - Available | icon | spell / Action Usable, spell / Spell Known | init |
| 45 | Secondary Cooldown - Pummel | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 46 | Secondary Cooldown - Shield Bash | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 47 | Secondary Cooldown - Taunt | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 48 | Secondary Cooldown - Mocking Blow | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 49 | Secondary Cooldown - Concussion Blow | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 50 | Secondary Cooldown - Spearing Strike | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 51 | Secondary Cooldown - Whirlwind | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 52 | Secondary Cooldown - Thunder Clap | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 53 | Secondary Cooldown - Slam | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 54 | Secondary Cooldown - Victory Rush | icon | spell / Cooldown Progress (Spell), custom / status | init |
| 55 | Queued Attack - Heroic Strike | icon | spell / Queued Action, spell / Queued Action, custom / status |  |
| 56 | Queued Attack - Cleave | icon | spell / Queued Action, spell / Queued Action, custom / status |  |
| 57 | Auras and Alerts | group | unit / Conditions |  |
| 58 | Active Buffs | group | unit / Conditions |  |
| 59 | Buff - Sweeping Strikes | icon | secretAura / Health | init |
| 60 | Buff - Recklessness | icon | secretAura / Health | init |
| 61 | Buff - Retaliation | icon | secretAura / Health | init |
| 62 | Buff - Death Wish | icon | secretAura / Health | init |
| 63 | Buff - Bloodrage | icon | secretAura / Health | init |
| 64 | Buff - Berserker Rage | icon | secretAura / Health | init |
| 65 | Buff - Shield Wall | icon | secretAura / Health | init |
| 66 | Buff - Last Stand | icon | secretAura / Health | init |
| 67 | Buff - Shield Block | icon | secretAura / Health | init |
| 68 | Combat Effects and Debuffs | group | unit / Conditions |  |
| 69 | Aura - Enrage | icon | secretAura / Health | init |
| 70 | Aura - Flurry | icon | secretAura / Health | init |
| 71 | Aura - Rend | icon | secretAura / Health | init |
| 72 | Rend - Missing | icon | secretAura / Health, custom / status | init |
| 73 | Aura - Sunder Armor | icon | secretAura / Health | init |
| 74 | Aura - Demoralizing Shout | icon | secretAura / Health | init |
| 75 | Aura - Thunder Clap | icon | secretAura / Health | init |
| 76 | Aura - Hamstring | icon | secretAura / Health | init |
| 77 | Aura - Piercing Howl | icon | secretAura / Health | init |
| 78 | Battle Shout Alerts | group | unit / Conditions |  |
| 79 | Battle Shout - Missing | icon | secretAura / Health, custom / status | init |
| 80 | Battle Shout - Expiring | icon | secretAura / Health | init |
| 81 | Proc Indicators | group | unit / Conditions |  |
| 82 | Overpower and Revenge - Left | texture | spell / Action Usable, spell / Action Usable, spell / Spell Known, spell / Spell Known, spell / Spell Activation Overlay, spell / Spell Activation Overlay |  |
| 83 | Overpower and Revenge - Right | texture | spell / Action Usable, spell / Action Usable, spell / Spell Known, spell / Spell Known, spell / Spell Activation Overlay, spell / Spell Activation Overlay |  |
| 84 | Victory Rush - Top | texture | spell / Action Usable, spell / Spell Known |  |
| 85 | Resources | group | unit / Conditions |  |
| 86 | Health Bar Assembly | group | unit / Conditions |  |
| 87 | Health | aurabar | unit / Health, custom / status | init |
| 88 | Rage Bar Assembly | group | unit / Conditions |  |
| 89 | Rage | aurabar | unit / Power, custom / status | init |
| 90 | Swing Timers | group | unit / Conditions |  |
| 91 | Single Swing - Background | texture | unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 92 | Dual Swing - Main-Hand Background | texture | unit / Swing Timer, unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 93 | Dual Swing - Off-Hand Background | texture | unit / Swing Timer, unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 94 | Single Swing - Main Hand | aurabar | unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 95 | Dual Swing - Main Hand | aurabar | unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 96 | Dual Swing - Off Hand | aurabar | unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 97 | Single Swing - Frame | texture | unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 98 | Dual Swing - Frame | texture | unit / Swing Timer, unit / Swing Timer, spell / Queued Action, custom / status, custom / status | init |
| 99 | Spellcasting | group | unit / Conditions |  |
| 100 | Player Cast | aurabar | unit / Cast |  |
| 101 | Central Artwork | group | unit / Conditions |  |
| 102 | Taotie Emblem | texture | unit / Conditions |  |
| 103 | HUD Controls | group | unit / Conditions |  |
| 104 | Ability Selection | empty | custom / Health | init, start, finish |
| 105 | Default Cast Bar Control | empty | custom / Health | init, start, finish |
| 106 | HUD Animation | empty | custom / Health | init |
| 107 | Resource Flow | empty | custom / Health | init, start, finish |
| 108 | Combat Animation | empty | custom / Health | init, start, finish |
| 109 | Voice Alerts | group | unit / Conditions |  |
| 110 | Voice Playback | empty | custom / Health | init |
| 111 | Voice Ready - Shield Wall | empty | spell / Cooldown Ready (Spell) | start |
| 112 | Voice Ready - Last Stand | empty | spell / Cooldown Ready (Spell) | start |
| 113 | Voice Ready - Recklessness | empty | spell / Cooldown Ready (Spell) | start |
| 114 | Voice Ready - Death Wish | empty | spell / Cooldown Ready (Spell) | start |
| 115 | Voice Ready - Retaliation | empty | spell / Cooldown Ready (Spell) | start |
| 116 | Voice Ready - Sweeping Strikes | empty | spell / Cooldown Ready (Spell) | start |
| 117 | Voice Ready - Challenging Shout | empty | spell / Cooldown Ready (Spell) | start |
| 118 | Voice Ready - Bloodrage | empty | spell / Cooldown Ready (Spell) | start |
| 119 | Voice Ready - Berserker Rage | empty | spell / Cooldown Ready (Spell) | start |
| 120 | Voice Ready - Pummel | empty | spell / Cooldown Ready (Spell) | start |
| 121 | Voice Ready - Shield Bash | empty | spell / Cooldown Ready (Spell) | start |
| 122 | Voice Ready - Taunt | empty | spell / Cooldown Ready (Spell) | start |
| 123 | Voice Ready - Mocking Blow | empty | spell / Cooldown Ready (Spell) | start |
| 124 | Voice Ready - Concussion Blow | empty | spell / Cooldown Ready (Spell) | start |
| 125 | Voice Ready - Disarm | empty | spell / Cooldown Ready (Spell) | start |
| 126 | Voice Ready - Intercept | empty | spell / Cooldown Ready (Spell) | start |
| 127 | Voice Ready - Intimidating Shout | empty | spell / Cooldown Ready (Spell) | start |
| 128 | Voice Active - Shield Wall | icon | secretAura / Health, custom / status |  |
| 129 | Voice Active - Last Stand | icon | secretAura / Health, custom / status |  |
| 130 | Voice Active - Recklessness | icon | secretAura / Health, custom / status |  |
| 131 | Voice Active - Death Wish | icon | secretAura / Health, custom / status |  |
| 132 | Voice Active - Retaliation | icon | secretAura / Health, custom / status |  |
| 133 | Voice Active - Sweeping Strikes | icon | secretAura / Health, custom / status |  |
| 134 | Voice Active - Bloodrage | icon | secretAura / Health, custom / status |  |
| 135 | Voice Active - Berserker Rage | icon | secretAura / Health, custom / status |  |
