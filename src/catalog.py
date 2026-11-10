"""Identity candidates, never proof of training. Discovery.lua matches localized
client metadata against learned ranks/overrides or a learned native CDM identity.
"""

CLASSES = {
    "WARLOCK": dict(name="Warlock", zh="术士", color="#ac89ef", accent="#b5f471", icon="Spell_Shadow_Metamorphosis",
        primary=[(17877,"Shadowburn"),(1293817,"Conflagrate"),(6789,"Death Coil"),(18288,"Amplify Curse"),(18708,"Fel Domination"),(6353,"Soul Fire")],
        utility=[(5484,"Howl of Terror"),(5782,"Fear"),(710,"Banish"),(6229,"Shadow Ward"),(5697,"Unending Breath"),(698,"Ritual of Summoning")],
        dots=[(172,"Corruption"),(348,"Immolate"),(980,"Bane of Agony"),(603,"Bane of Doom"),(18265,"Siphon Life"),(1316697,"Wrack"),(1225228,"Bane of Havoc")],
        buffs=[(17941,"Shadow Trance"),(34936,"Backlash")],
        pet=True, extra="shards"),
    "WARRIOR": dict(name="Warrior", zh="战士", color="#cc9b70", accent="#ffd69a", icon="Ability_Warrior_BattleShout",
        primary=[(12294,"Mortal Strike"),(23881,"Bloodthirst"),(23922,"Shield Slam"),(1680,"Whirlwind"),(7384,"Overpower"),(6572,"Revenge")],
        utility=[(6552,"Pummel"),(871,"Shield Wall"),(1719,"Recklessness"),(12292,"Sweeping Strikes"),(12328,"Death Wish"),(12975,"Last Stand")],
        dots=[(772,"Rend"),(6343,"Thunder Clap"),(7386,"Sunder Armor"),(1160,"Demoralizing Shout"),(1715,"Hamstring"),(12323,"Piercing Howl")],
        buffs=[(12319,"Flurry"),(18499,"Berserker Rage"),(2565,"Shield Block"),(1719,"Recklessness"),(6673,"Battle Shout")], extra="swing"),
    "MAGE": dict(name="Mage", zh="法师", color="#69d5ee", accent="#b5eeff", icon="Spell_Frost_FrostBolt02",
        primary=[(2136,"Fire Blast"),(12043,"Presence of Mind"),(12042,"Arcane Power"),(11129,"Combustion"),(120,"Cone of Cold"),(11113,"Blast Wave")],
        utility=[(11958,"Ice Block"),(12472,"Cold Snap"),(1953,"Blink"),(12051,"Evocation"),(11426,"Ice Barrier"),(122,"Frost Nova")],
        dots=[(11366,"Pyroblast"),(22959,"Improved Scorch")],
        buffs=[(44445,"Hot Streak"),(44544,"Fingers of Frost"),(44401,"Missile Barrage"),(12042,"Arcane Power")]),
    "PRIEST": dict(name="Priest", zh="牧师", color="#e6dcce", accent="#f4ca7d", icon="Spell_Holy_WordFortitude",
        primary=[(8092,"Mind Blast"),(10060,"Power Infusion"),(14751,"Inner Focus"),(13908,"Desperate Prayer"),(402174,"Penance"),(401859,"Prayer of Mending")],
        utility=[(8122,"Psychic Scream"),(15487,"Silence"),(6346,"Fear Ward"),(724,"Lightwell"),(586,"Fade"),(32375,"Mass Dispel")],
        dots=[(589,"Shadow Word: Pain"),(2944,"Devouring Plague"),(15286,"Vampiric Embrace")],
        buffs=[(15473,"Shadowform"),(10060,"Power Infusion"),(33151,"Surge of Light")]),
    "ROGUE": dict(name="Rogue", zh="盗贼", color="#f1d461", accent="#fff1ac", icon="Ability_Stealth",
        primary=[(13750,"Adrenaline Rush"),(13877,"Blade Flurry"),(14177,"Cold Blood"),(5277,"Evasion"),(1856,"Vanish"),(1766,"Kick")],
        utility=[(2983,"Sprint"),(14185,"Preparation"),(408,"Kidney Shot"),(1776,"Gouge"),(2094,"Blind"),(1725,"Distract")],
        dots=[(703,"Garrote"),(1943,"Rupture"),(16511,"Hemorrhage")],
        buffs=[(5171,"Slice and Dice"),(13750,"Adrenaline Rush"),(13877,"Blade Flurry")], extra="combo"),
    "DRUID": dict(name="Druid", zh="德鲁伊", color="#efaa63", accent="#b5ed9a", icon="Spell_Nature_HealingTouch",
        primary=[(5217,"Tiger's Fury"),(18562,"Swiftmend"),(16188,"Nature's Swiftness"),(16914,"Hurricane"),(22812,"Barkskin"),(5211,"Bash")],
        utility=[(29166,"Innervate"),(20484,"Rebirth"),(740,"Tranquility"),(16689,"Nature's Grasp"),(22845,"Frenzied Regeneration"),(5209,"Challenging Roar")],
        dots=[(8921,"Moonfire"),(1822,"Rake"),(1079,"Rip"),(770,"Faerie Fire")],
        buffs=[(16870,"Clearcasting"),(22812,"Barkskin"),(5217,"Tiger's Fury")], extra="combo"),
    "HUNTER": dict(name="Hunter", zh="猎人", color="#aad575", accent="#e1f4a7", icon="Ability_Hunter_AimedShot",
        primary=[(19434,"Aimed Shot"),(2643,"Multi-Shot"),(3045,"Rapid Fire"),(19574,"Bestial Wrath"),(19306,"Counterattack"),(1495,"Mongoose Bite")],
        utility=[(5384,"Feign Death"),(19263,"Deterrence"),(19503,"Scatter Shot"),(781,"Disengage"),(1510,"Volley"),(13809,"Frost Trap")],
        dots=[(1978,"Serpent Sting"),(3034,"Viper Sting"),(3043,"Scorpid Sting"),(1130,"Hunter's Mark")],
        buffs=[(3045,"Rapid Fire"),(19574,"Bestial Wrath"),(19263,"Deterrence")], pet=True, extra="swing"),
    "SHAMAN": dict(name="Shaman", zh="萨满祭司", color="#6eafff", accent="#b4f2ed", icon="Spell_Nature_Lightning",
        primary=[(17364,"Stormstrike"),(16166,"Elemental Mastery"),(16188,"Nature's Swiftness"),(8050,"Flame Shock"),(8042,"Earth Shock"),(408521,"Riptide")],
        utility=[(16190,"Mana Tide Totem"),(20608,"Reincarnation"),(8177,"Grounding Totem"),(8143,"Tremor Totem"),(1535,"Fire Nova Totem"),(2484,"Earthbind Totem")],
        dots=[(8050,"Flame Shock"),(17364,"Stormstrike")],
        buffs=[(324,"Lightning Shield"),(974,"Earth Shield"),(53817,"Maelstrom Weapon")], extra="totems"),
    "PALADIN": dict(name="Paladin", zh="圣骑士", color="#ed9cba", accent="#fff0ac", icon="Spell_Holy_SealOfMight",
        primary=[(1311606,"Holy Shock"),(20216,"Divine Favor"),(20925,"Holy Shield"),(26573,"Consecration"),(24275,"Hammer of Wrath"),(853,"Hammer of Justice")],
        utility=[(642,"Divine Shield"),(1022,"Blessing of Protection"),(1044,"Blessing of Freedom"),(633,"Lay on Hands"),(20066,"Repentance"),(2878,"Turn Undead")],
        dots=[(20184,"Judgement of Justice"),(20185,"Judgement of Light"),(20186,"Judgement of Wisdom")],
        buffs=[(20925,"Holy Shield"),(20216,"Divine Favor"),(31884,"Avenging Wrath")]),
}

# Functional plans: four cooldown/support slots left and four attacks/heals
# right. Each slot is an ordered learned fallback, not a rotation instruction.
# Warrior reproduces the audited source's choices; other classes are Eclipse
# adaptations. Candidate IDs are checked against the live book before use.
WARRIOR_EXTRA = [(2687,'Bloodrage'),(20230,'Retaliation'),(18499,'Berserker Rage'),
    (78,'Heroic Strike'),(772,'Rend'),(6343,'Thunder Clap'),(7386,'Sunder Armor'),
    (1310222,'Spearing Strike'),(1464,'Slam'),(5308,'Execute'),(2565,'Shield Block'),
    (845,'Cleave'),(72,'Shield Bash'),(355,'Taunt'),(694,'Mocking Blow'),
    (12809,'Concussion Blow'),(402927,'Victory Rush'),(100,'Charge'),(20252,'Intercept'),
    (676,'Disarm'),(5246,'Intimidating Shout'),(1161,'Challenging Shout')]
LEVELING = {
    'WARLOCK': [(686,'Shadow Bolt'),(689,'Drain Life'),(1454,'Life Tap'),(755,'Health Funnel'),(1120,'Drain Soul'),(5676,'Searing Pain'),(5740,'Rain of Fire')],
    'MAGE': [(133,'Fireball'),(116,'Frostbolt'),(2139,'Counterspell'),(1449,'Arcane Explosion')],
    'PRIEST': [(585,'Smite'),(2061,'Flash Heal'),(17,'Power Word: Shield')],
    'ROGUE': [(1752,'Sinister Strike'),(2098,'Eviscerate'),(53,'Backstab'),(8676,'Ambush')],
    'DRUID': [(5176,'Wrath'),(2912,'Starfire'),(5185,'Healing Touch'),(5221,'Shred'),(1082,'Claw'),(6807,'Maul')],
    'HUNTER': [(75,'Auto Shot'),(3044,'Arcane Shot'),(2973,'Raptor Strike'),(2974,'Wing Clip'),(5116,'Concussive Shot')],
    'SHAMAN': [(403,'Lightning Bolt'),(8004,'Lesser Healing Wave'),(331,'Healing Wave'),(8056,'Frost Shock')],
    'PALADIN': [(635,'Holy Light'),(19750,'Flash of Light'),(20271,'Judgement'),(879,'Exorcism')],
}
# Full source-audited Warrior rank sets where the base ID is not sufficient.
RANKS = {
    'Heroic Strike':[78,284,285,1608,11564,11565,11566,11567,25286],
    'Rend':[772,6546,6547,6548,11572,11573,11574],
    'Slam':[1240193,1464,8820,11604,11605],
    'Mortal Strike':[12294,21551,21552,21553],
    'Bloodthirst':[23881,23892,23893,23894],
    'Shield Slam':[23922,23923,23924,23925],
    'Overpower':[7384,7887,11584,11585], 'Revenge':[6572,6574,7379,11600,11601,25288],
    'Execute':[5308,20658,20660,20661,20662],
    'Sunder Armor':[7386,7405,8380,11596,11597], 'Thunder Clap':[6343,8198,8204,8205,11580,11581],
    'Cleave':[845,7369,11608,11609,20569], 'Pummel':[6552,6554], 'Shield Bash':[72,1671,1672],
}

def slots(*names):
    return [name.split('|') for name in names]

WARRIOR_PLANS = {
    'Leveling': [slots('Bloodrage','Retaliation','Shield Wall','Berserker Rage'),slots('Heroic Strike|Rend','Overpower','Thunder Clap','Sunder Armor')],
    'ArmsEarly': [slots('Sweeping Strikes','Retaliation','Bloodrage','Shield Wall'),slots('Heroic Strike|Rend','Overpower','Thunder Clap','Spearing Strike|Sunder Armor')],
    'Arms': [slots('Sweeping Strikes','Recklessness|Retaliation','Bloodrage','Shield Wall'),slots('Mortal Strike','Overpower','Slam','Rend')],
    'FuryEarly': [slots('Death Wish','Retaliation','Bloodrage','Shield Wall'),slots('Heroic Strike|Rend','Overpower','Whirlwind|Thunder Clap','Sunder Armor')],
    'Fury': [slots('Death Wish','Recklessness|Retaliation','Bloodrage','Shield Wall'),slots('Bloodthirst','Whirlwind','Execute','Heroic Strike')],
    'Protection': [slots('Shield Block','Shield Wall','Last Stand','Bloodrage'),slots('Shield Slam|Sunder Armor|Heroic Strike','Revenge','Thunder Clap','Sunder Armor|Rend')],
}
SCHOOLS = {
    'WARRIOR':['Arms','Fury','Protection'], 'WARLOCK':['Affliction','Demonology','Destruction'],
    'MAGE':['Arcane','Fire','Frost'], 'PRIEST':['Discipline','Holy','Shadow'],
    'ROGUE':['Assassination','Combat','Subtlety'], 'DRUID':['Balance','Feral','Restoration'],
    'HUNTER':['Beast Mastery','Marksmanship','Survival'], 'SHAMAN':['Elemental','Enhancement','Restoration'],
    'PALADIN':['Holy','Protection','Retribution'],
}
PLANS = {
    'WARRIOR':WARRIOR_PLANS,
    'WARLOCK': {
        'Leveling':[slots('Life Tap','Shadow Ward','Fear|Howl of Terror','Health Funnel'),slots('Shadow Bolt','Immolate','Corruption','Drain Life|Drain Soul')],
        'Affliction':[slots('Amplify Curse|Life Tap','Death Coil|Shadow Ward','Howl of Terror|Fear','Fel Domination|Health Funnel'),slots('Siphon Life|Corruption','Bane of Agony','Shadow Bolt','Drain Life|Drain Soul')],
        'Demonology':[slots('Fel Domination|Life Tap','Shadow Ward','Death Coil|Fear','Health Funnel'),slots('Shadow Bolt','Corruption','Immolate','Drain Soul|Drain Life')],
        'Destruction':[slots('Shadowburn|Life Tap','Death Coil|Shadow Ward','Howl of Terror|Fear','Fel Domination|Health Funnel'),slots('Conflagrate|Immolate','Shadow Bolt','Soul Fire|Drain Life','Corruption')],
    },
    'MAGE': {
        'Arcane':[slots('Presence of Mind','Arcane Power','Evocation','Blink'),slots('Arcane Explosion|Fireball','Fire Blast','Counterspell','Cone of Cold|Frostbolt')],
        'Fire':[slots('Combustion','Presence of Mind','Ice Block','Blink'),slots('Pyroblast|Fireball','Fire Blast','Blast Wave|Arcane Explosion','Counterspell')],
        'Frost':[slots('Cold Snap','Ice Barrier','Ice Block','Blink'),slots('Frostbolt','Cone of Cold','Frost Nova','Counterspell')],
    },
    'PRIEST': {
        'Discipline':[slots('Power Infusion','Inner Focus','Power Word: Shield','Fade'),slots('Penance|Smite','Flash Heal','Mind Blast','Shadow Word: Pain')],
        'Holy':[slots('Inner Focus','Desperate Prayer','Fear Ward','Fade'),slots('Flash Heal','Smite','Prayer of Mending','Psychic Scream')],
        'Shadow':[slots('Inner Focus','Silence','Power Word: Shield','Fade'),slots('Mind Blast','Shadow Word: Pain','Devouring Plague|Smite','Psychic Scream')],
    },
    'ROGUE': {
        'Assassination':[slots('Cold Blood','Evasion','Vanish','Sprint'),slots('Backstab|Sinister Strike','Eviscerate','Rupture','Kick')],
        'Combat':[slots('Adrenaline Rush','Blade Flurry','Evasion','Sprint'),slots('Sinister Strike','Eviscerate','Rupture','Kick')],
        'Subtlety':[slots('Preparation','Vanish','Evasion','Sprint'),slots('Hemorrhage|Sinister Strike','Ambush|Backstab','Eviscerate','Kidney Shot|Kick')],
    },
    'DRUID': {
        'Balance':[slots('Innervate','Barkskin','Nature\'s Grasp','Rebirth'),slots('Starfire|Wrath','Moonfire','Wrath','Hurricane')],
        'Feral':[slots("Tiger's Fury",'Barkskin','Frenzied Regeneration','Bash'),slots('Shred|Claw|Maul','Rake','Rip','Faerie Fire')],
        'Cat':[slots("Tiger's Fury",'Barkskin','Innervate','Bash'),slots('Shred|Claw','Rake','Rip','Faerie Fire')],
        'Bear':[slots('Challenging Roar','Barkskin','Frenzied Regeneration','Bash'),slots('Maul','Faerie Fire')],
        'Caster':[slots('Innervate','Barkskin','Rebirth',"Nature's Grasp"),slots('Wrath','Moonfire','Healing Touch','Hurricane')],
        'Restoration':[slots("Nature's Swiftness",'Innervate','Barkskin','Rebirth'),slots('Swiftmend|Healing Touch','Tranquility','Healing Touch','Moonfire')],
    },
    'HUNTER': {
        'Beast Mastery':[slots('Bestial Wrath','Rapid Fire','Feign Death','Deterrence'),slots('Arcane Shot|Auto Shot','Multi-Shot','Concussive Shot','Serpent Sting')],
        'Marksmanship':[slots('Rapid Fire','Scatter Shot','Feign Death','Disengage'),slots('Aimed Shot|Arcane Shot|Auto Shot','Multi-Shot','Arcane Shot','Serpent Sting')],
        'Survival':[slots('Deterrence','Feign Death','Disengage','Frost Trap'),slots('Counterattack|Mongoose Bite|Raptor Strike|Auto Shot','Multi-Shot','Wing Clip|Concussive Shot','Serpent Sting')],
    },
    'SHAMAN': {
        'Elemental':[slots('Elemental Mastery',"Nature's Swiftness",'Grounding Totem','Tremor Totem'),slots('Lightning Bolt','Flame Shock','Earth Shock','Frost Shock')],
        'Enhancement':[slots('Grounding Totem','Tremor Totem','Fire Nova Totem','Earthbind Totem'),slots('Stormstrike|Lightning Bolt','Earth Shock','Flame Shock','Frost Shock')],
        'Restoration':[slots("Nature's Swiftness",'Mana Tide Totem','Grounding Totem','Tremor Totem'),slots('Riptide|Lesser Healing Wave','Healing Wave','Earth Shock','Lightning Bolt')],
    },
    'PALADIN': {
        'Holy':[slots('Divine Favor','Divine Shield','Blessing of Protection','Lay on Hands'),slots('Holy Shock|Flash of Light|Holy Light','Holy Light','Judgement','Hammer of Justice')],
        'Protection':[slots('Holy Shield','Divine Shield','Blessing of Freedom','Lay on Hands'),slots('Consecration|Judgement','Judgement','Exorcism','Hammer of Justice')],
        'Retribution':[slots('Divine Shield','Blessing of Freedom','Blessing of Protection','Lay on Hands'),slots('Judgement','Consecration','Hammer of Wrath|Exorcism','Hammer of Justice')],
    },
}

PREPARATION = {5697,698,20608} # breathing, summoning, passive reincarnation

# Native aura-driven effect identities. These do not assert a buff exists.
EFFECTS = {
    'WARRIOR': {'low':[12880], 'blood':[2687], 'eyes':[18499], 'medium':[12292,20230], 'major':[1719,12328], 'defense':[871,12975]},
    'WARLOCK': {'low':[17941], 'medium':[18288], 'major':[18708], 'defense':[6229]},
    'MAGE': {'low':[12536], 'medium':[11129], 'major':[12042], 'defense':[11426,11958]},
    'PRIEST': {'low':[33151], 'medium':[14751], 'major':[10060], 'defense':[17]},
    'ROGUE': {'low':[5171], 'medium':[13877], 'major':[13750], 'defense':[5277]},
    'DRUID': {'low':[16870], 'medium':[5217], 'major':[16188], 'defense':[22812,22845]},
    'HUNTER': {'low':[3045], 'major':[19574], 'defense':[19263]},
    'SHAMAN': {'low':[53817], 'medium':[16188], 'major':[16166], 'defense':[974]},
    'PALADIN': {'medium':[20216], 'major':[31884], 'defense':[642,1022,20925]},
}
ALERTS = {
    'WARRIOR':[(871,97),(12975,94),(1719,91),(12328,88),(20230,85),(12292,82),(1161,79),(2687,76),
        (18499,73),(6552,73),(72,73),(355,70),(694,67),(12809,64),(676,61),(20252,58),(5246,52)],
    'WARLOCK':[(6789,90),(18708,85),(6229,80),(5484,75),(18288,70),(17877,65),(1293817,60)],
    'MAGE':[(11958,95),(11426,90),(12042,85),(11129,80),(12043,75),(12472,70),(2139,65)],
    'PRIEST':[(13908,95),(10060,90),(14751,85),(6346,80),(15487,75),(8122,70)],
    'ROGUE':[(5277,95),(1856,90),(13750,85),(13877,80),(14177,75),(1766,70)],
    'DRUID':[(22812,95),(29166,90),(20484,85),(18562,80),(16188,75),(5211,70)],
    'HUNTER':[(5384,95),(19263,90),(19574,85),(3045,80),(19503,75)],
    'SHAMAN':[(16190,95),(16188,90),(16166,85),(8177,80),(17364,75)],
    'PALADIN':[(642,95),(633,90),(1022,85),(1044,80),(20216,75),(1311606,70)],
}
UPKEEP = {
    'MAGE':[([1459,23028],'Arcane Intellect',True),([168,7302,6117],'Mage armor',False)],
    'PRIEST':[([1243,21562],'Fortitude',True),([588],'Inner Fire',False)],
    'DRUID':[([1126,21849],'Mark of the Wild',True)],
    'HUNTER':[([13163,13165],'Aspect',False)],
    'PALADIN':[([19740,19742,20217],'Blessing',False)],
}

def candidates(cls):
    c=CLASSES[cls]
    result={}
    for seed,name in c['primary']+c['utility']+c['dots']+LEVELING.get(cls,[])+(WARRIOR_EXTRA if cls=='WARRIOR' else []):
        if seed not in PREPARATION:
            # Prefer existing IDs/names. The learned client supplies displayed text.
            result.setdefault(name,seed)
    return [(seed,name) for name,seed in result.items()]
