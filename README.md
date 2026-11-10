# Eclipse · Class Combat HUD

## English

**Version 0.3.3 — smaller class imports and HUD controls (prerelease).** One companion supports all nine classes, with independent preferences and automatic class loading. Import only the classes you play, or use the combined file. [Warlock only](dist/classes/Eclipse-Warlock.txt) is roughly 83% smaller than the combined import; [exact sizes](dist/classes/README.md) are generated with each build.

### Install or update

1. Install **[ForeverAuras](https://github.com/neroxrw/foreverauras)**. The current source checked here is 1.3.7; the Forever interface is `16001`.
2. Download the [release ZIP](https://github.com/tomqwu/wow_forever_weakaura/releases) and copy **`EclipseHUD/`** into your current client's `Interface/AddOns/`. The TOC belongs directly inside that folder.
3. Enable EclipseHUD and ForeverAuras, then **`/reload` before importing**.
4. Out of combat, open **`/fa` → Import** and paste your class file from **`imports/`** in the ZIP. Choose **Update** for an existing class group. It preserves the combined parent and other classes; avoid **Import as Copy** for updates.
5. A fresh class file also works standalone. The optional **`Eclipse-Class-Combat-HUD.txt`** installs/updates a combined group. Use class files for standalone class updates.
6. Use **`/eclipse`** or **`/ehud`** for controls. Existing positions/preferences survive; **Position → Reset position** changes only X/Y.

New class imports need the v0.3.3 companion or compatible import API. Existing v0.3.2 class strings remain compatible, so you can update one class at a time. The new compact wings and optional tracked-bar renderer need that class’s updated file. The ZIP includes nine class files, the combined file, and a size/SHA-256 manifest.

| Class | Smaller import |
| --- | --- |
| Warlock | [Warlock import](dist/classes/Eclipse-Warlock.txt) |
| Warrior | [Warrior import](dist/classes/Eclipse-Warrior.txt) |
| Mage | [Mage import](dist/classes/Eclipse-Mage.txt) |
| Priest | [Priest import](dist/classes/Eclipse-Priest.txt) |
| Rogue | [Rogue import](dist/classes/Eclipse-Rogue.txt) |
| Druid | [Druid import](dist/classes/Eclipse-Druid.txt) |
| Hunter | [Hunter import](dist/classes/Eclipse-Hunter.txt) |
| Shaman | [Shaman import](dist/classes/Eclipse-Shaman.txt) |
| Paladin | [Paladin import](dist/classes/Eclipse-Paladin.txt) |

### Configure cooldowns and preserve tracked bars

Open **`/eclipse` → Behavior → Cooldown layout → Forever**. Eclipse follows your learned native Essential/Utility/item categories and order, but shows cooldown icons **only while a real cooldown is running**, with GCD-only feedback excluded. The cooldown row is empty when no real cooldown is active. Ready, no-cooldown fillers such as Life Tap/Corruption do not occupy persistent cooldown slots. Instant-cast spells can still have genuine cooldowns. Native dynamic wings compact the shown icons. **Class plan** is an optional ability-row layout with its own priorities.

In the game's **Cooldown Settings**, arrange Essential, Utility, Items and Not Displayed as desired. Eclipse follows learned entries, not every gray entry shown by the configuration window. Changes made during combat apply after combat.

**To keep the game's right-hand Tracked Bars:**

1. In **`/fa`**, leave the top-toolbar **Hide Blizzard's CDM** checkbox **off**. It hides all four viewers, including Tracked Bars.
2. Keep the game's cooldown manager enabled. In **Game menu → Edit Mode**, set **Tracked Bars** to **Always**; keep Tracked Buffs visible too if you use them.
3. To remove only duplicate cooldown-icon rows, select the native **Essential** and **Utility** viewers individually and set their **Visibility → Hidden**. This differs from disabling the entire manager.
4. Leave **`/eclipse` → Modules → Tracked bars (Eclipse)** off if you want only the game's bars.

**To replace native bars with Eclipse bars:** enable **Tracked bars (Eclipse)** first. It uses native CDM aura progress for active entries from your Tracked Bars category, including DoTs/control/procs, in a stack to the right. Then you may use **Hide Blizzard's CDM** to hide the default viewers while keeping tracking enabled. Keep the native tracking viewers configured to Always for this route. Eclipse does not change these global settings automatically. To return to the default CDM later, clear the global hide and restore the relevant native viewer Visibility to Always.

Optional **`/fa cdmsetup`** / **Set Up CDM** asks to back up/copy the native layouts, track catalog entries, restore hidden spell cooldowns, set viewers to Always, hide all four default viewers and reload. It changes the layout/visibility choices above; use it deliberately rather than just to hide one row.

User-provided native configuration references (not Eclipse runtime validation):

| Cooldown categories | Tracked Bars |
| :---: | :---: |
| [<img src="docs/images/native-warlock-cooldowns.png" width="300" alt="Native Warlock cooldown configuration">](docs/images/native-warlock-cooldowns.png) | [<img src="docs/images/native-warlock-tracked-bars.png" width="300" alt="Native Warlock tracked bars">](docs/images/native-warlock-tracked-bars.png) |

### DoT duration versus spell cooldown

Corruption/Immolate can be active on a target while their ability is ready. Their **remaining effect duration** belongs in **Target effects** or **Tracked Bars**, not a fabricated spell cooldown. Enable **Modules → Target effects**, target an enemy and apply the learned spell. This row shows native player-owned target effects; missing/unreadable effects are not assigned guessed timers. You can use native bars, Eclipse's optional tracked-bar stack, or the compact target-effect icons. Disable a duplicate display if you only want one presentation.

### Choose a casting bar

Open **`/eclipse` → Behavior → Cast bar display**. Click the control to cycle:

| Choice | Eclipse casting | Game casting |
| --- | --- | --- |
| Default game bar | Off; trackers unload | Available normally |
| Eclipse bar | On | Suppressed while the Eclipse display is loaded/enabled |
| Both bars | On | Available normally |

The safe default is the **game bar only**. Old overlapping defaults migrate to it; an existing explicit Eclipse-suppression choice is retained. **Modules → Eclipse cast bar** also enables/disables the Eclipse choice. Disabling Eclipse or an unavailable imported cast display releases its ownership of the game bar. Another addon can retain its own ownership. Changes requested in combat wait until combat ends.

Illustrative mode previews, using sample values rather than the game client:

| Game bar only | Eclipse bar only | Both (explicit) |
| :---: | :---: | :---: |
| [<img src="preview/casting/warlock-default.png" width="260" alt="Game bar sample">](preview/casting/warlock-default.png) | [<img src="preview/casting/warlock-eclipse.png" width="260" alt="Eclipse bar sample">](preview/casting/warlock-eclipse.png) | [<img src="preview/casting/warlock-both.png" width="260" alt="Both bars sample">](preview/casting/warlock-both.png) |

### Expand, fold and move

- **Left-click the seal:** expand for inspection; **click again to fold** out of combat, including with the same target selected. A new target/combat edge restores automatic behavior. Click inspection remains pinned until cancelled; `/eclipse inspect` and the settings inspection button are temporary.
- Combat events start motion immediately; the slide/fade takes about half a second. Enable **Behavior → Unfold animation** for smooth motion. Layout refreshes preserve an in-progress transition. Combat exit folds immediately if no independent target/inspection condition holds; target loss alone has a five-second hold.
- Folding affects the main HUD. Active effects, tracked bars and casting keep independent rules.
- **Right-click:** settings. Unlock there, then drag the seal. X/Y, scale, opacity and module choices are per class; root changes defer in combat. **Reset position** preserves other preferences.
- Health is crimson, mana blue, energy gold and rage orange; labels provide another cue. Maintenance buffs sit beside the bar. Nameplate effects are off by default. Disabled modules unload their trackers.

Illustrative interaction/animation previews:

| Folded | During opening | Click-expanded | Optional tracked bars |
| :---: | :---: | :---: | :---: |
| [<img src="preview/states/warlock-idle.png" width="220" alt="Folded sample">](preview/states/warlock-idle.png) | [<img src="preview/states/warlock-opening.png" width="220" alt="Intermediate animation sample">](preview/states/warlock-opening.png) | [<img src="preview/states/warlock-click-open.png" width="220" alt="Expanded sample">](preview/states/warlock-click-open.png) | [<img src="preview/states/warlock-tracked-bars.png" width="220" alt="Tracked bars sample">](preview/states/warlock-tracked-bars.png) |

### Nine-class gallery and evidence

These are labelled browser fixtures with sample learned spells, active cooldowns/auras and values. They are not game-client screenshots or proof of full parity. The interactive [preview](https://github.com/tomqwu/wow_forever_weakaura/blob/main/preview/index.html) includes a leveling fixture with no invented real cooldowns, category/class-plan modes, bar choices, click toggling and resource-form colors.

| Warlock | Warrior | Mage |
| :---: | :---: | :---: |
| [<img src="preview/classes/warlock.png" width="260" alt="Warlock">](preview/classes/warlock.png) | [<img src="preview/classes/warrior.png" width="260" alt="Warrior">](preview/classes/warrior.png) | [<img src="preview/classes/mage.png" width="260" alt="Mage">](preview/classes/mage.png) |

| Priest | Rogue | Druid |
| :---: | :---: | :---: |
| [<img src="preview/classes/priest.png" width="260" alt="Priest">](preview/classes/priest.png) | [<img src="preview/classes/rogue.png" width="260" alt="Rogue">](preview/classes/rogue.png) | [<img src="preview/classes/druid.png" width="260" alt="Druid">](preview/classes/druid.png) |

| Hunter | Shaman | Paladin |
| :---: | :---: | :---: |
| [<img src="preview/classes/hunter.png" width="260" alt="Hunter">](preview/classes/hunter.png) | [<img src="preview/classes/shaman.png" width="260" alt="Shaman">](preview/classes/shaman.png) | [<img src="preview/classes/paladin.png" width="260" alt="Paladin">](preview/classes/paladin.png) |

Actual aura ownership, durations, stacks, cooldowns, charges, resource values and rendering belong to native ForeverAuras triggers. There is no combat-log reconstruction or guessed refresh window. Warlock armor is observed natively; an unknown armor aura never becomes a fabricated missing warning. [Live validation](docs/validation.md) remains pending; [the durable checklist](docs/feature-parity-plan.md) records source facts, implementations and evidence separately.

For problems, run **`/eclipse spells`** out of combat to print learned identities and native CDM categories/attachment diagnostics. This client's Lua errors are recorded in **`_forever_/Logs/General.log`**. The earlier mass-error popup also identified an independent AckisRecipeList health-prediction taint error; that addon is unchanged.

### Build and credits

Python 3.11+, Lua 5.1 and the build dependencies are required:

```bash
python -m pip install -r requirements-dev.txt
python scripts/build.py
python scripts/check.py
python scripts/preview.py
lua tests/native-schema.lua /path/to/ForeverAuras
```

Source: `src/catalog.py`, `scripts/build.py`, `src/EclipseHUD/`. Generated class files: `dist/classes/`; the combined export stays in `dist/`. CI verifies versions, codec/graphs/IDs, native schemas, package bytes and browser behavior. Every release updates the docs, relevant captures and changelog; published assets are immutable. See [design notes](docs/design.md) and [CHANGELOG](CHANGELOG.md).

Inspired by the supplied Guos Warrior HUD's feature organization. No Guos scripts, artwork, sounds or branding are bundled. Original AI-painted masters/prompts are in [assets/ai](https://github.com/tomqwu/wow_forever_weakaura/tree/main/assets/ai); builds reuse them. Game spell artwork remains Blizzard's property. GPL-2.0; see [LICENSE](LICENSE) and [vendor notices](https://github.com/tomqwu/wow_forever_weakaura/blob/main/vendor/README.md).

## 简体中文

**版本 0.3.3：独立职业导入与界面控制（预发布）。** 一套配套插件支持九职业，按当前角色自动加载，并分别保存设置。可只导入所玩职业，也可使用九职业合并文件。[术士独立导入](dist/classes/Eclipse-Warlock.txt)比合并文件约小 83%；[精确大小](dist/classes/README.md)由构建自动生成。

### 安装与更新

1. 先安装 **[ForeverAuras](https://github.com/neroxrw/foreverauras)**。当前校验的安装源码版本为 1.3.7，无限服接口版本为 `16001`。
2. 下载[发布 ZIP](https://github.com/tomqwu/wow_forever_weakaura/releases)，把 **`EclipseHUD/`** 放入当前客户端的 `Interface/AddOns/`，TOC 文件应直接位于该文件夹中。
3. 启用 EclipseHUD 与 ForeverAuras，**先输入 `/reload`，再导入字符串**。
4. 脱离战斗后打开 **`/fa` → 导入**，粘贴 ZIP 内 **`imports/`** 中对应职业的文件。已有职业组请选择 **更新（Update）**，不要导入为副本。更新仅涉及该职业，保留其原有合并父组及其他职业。
5. 首次安装也可只导入一个职业。可选的 **`Eclipse-Class-Combat-HUD.txt`** 用于安装或更新合并组；独立职业安装继续使用职业文件更新。
6. 输入 **`/eclipse`** 或 **`/ehud`** 配置。升级保留位置和偏好；**位置与缩放 → 重置位置** 只重置 X/Y。

新职业文件需要 0.3.3 配套插件或兼容的导入接口。原有 0.3.2 职业字符串仍可使用，因此可以逐个职业更新；新紧凑排列和可选持续时间条需要更新该职业文件。ZIP 同时包含九份独立文件、合并文件，以及大小和 SHA-256 清单。

| 职业 | 独立导入 |
| --- | --- |
| 术士 | [术士独立导入](dist/classes/Eclipse-Warlock.txt) |
| 战士 | [战士独立导入](dist/classes/Eclipse-Warrior.txt) |
| 法师 | [法师独立导入](dist/classes/Eclipse-Mage.txt) |
| 牧师 | [牧师独立导入](dist/classes/Eclipse-Priest.txt) |
| 盗贼 | [盗贼独立导入](dist/classes/Eclipse-Rogue.txt) |
| 德鲁伊 | [德鲁伊独立导入](dist/classes/Eclipse-Druid.txt) |
| 猎人 | [猎人独立导入](dist/classes/Eclipse-Hunter.txt) |
| 萨满祭司 | [萨满祭司独立导入](dist/classes/Eclipse-Shaman.txt) |
| 圣骑士 | [圣骑士独立导入](dist/classes/Eclipse-Paladin.txt) |

### 配置冷却管理器，并保留右侧持续时间条

打开 **`/eclipse` → 战斗行为 → 冷却排列 → 系统冷却管理器（Forever）**。Eclipse 沿用系统中已学技能的主要、辅助、装备分组与顺序，但默认**只在真实冷却运行时显示冷却图标，排除仅有公共冷却的情况**；没有真实冷却在运行时，该行为空。Life Tap、Corruption 等没有独立冷却的填充技能不会常驻占位；瞬发技能也可能有真实冷却，不能仅凭“瞬发”判断。原生动态组会紧凑排列当前显示的图标。可选的 **职业方案（Class plan）** 是另一种有固定优先级的技能展示布局。

在游戏的 **Cooldown Settings（冷却设置）** 中调整 Essential、Utility、Items 与 Not Displayed。配置窗口中的灰色条目不代表角色已学会；战斗中提出的修改在脱战后应用。

**保留游戏原有右侧 Tracked Bars：**

1. 在 **`/fa`** 顶部工具栏，**不要勾选 Hide Blizzard's CDM**。这个总开关会隐藏四类系统窗口，也包括持续时间条。
2. 保持游戏冷却管理器启用。在 **游戏菜单 → 编辑模式** 中，把 **Tracked Bars（持续时间条）** 的可见性设为 **Always（始终）**；需要系统增益图标时，也保留 Tracked Buffs。
3. 只想去掉重复的冷却图标时，分别选中系统 **Essential**、**Utility** 窗口，将其 **Visibility（可见性）设为 Hidden（隐藏）**，不要关闭整个冷却管理器。
4. 使用系统持续时间条时，可让 **`/eclipse` → 显示模块 → 持续时间条（Eclipse）** 保持关闭。

**改用 Eclipse 持续时间条：** 先启用 **持续时间条（Eclipse）**。它通过 ForeverAuras 原生 CDM 光环进度，在右侧显示你配置的 Tracked Bars 中当前激活的 DoT、控制效果和触发效果。确认启用后，才使用 **Hide Blizzard's CDM** 隐藏系统窗口；原生追踪继续开启，此方案下系统追踪窗口保持 Always。Eclipse 不会自动修改这些全局设置。之后返回系统 CDM 时，取消全局隐藏，并把相应系统窗口的可见性恢复为 Always。

可选命令 **`/fa cdmsetup`** 或 **Set Up CDM** 会先询问确认，再备份/复制布局、追踪目录条目、恢复隐藏的技能冷却、设为 Always、隐藏四类系统窗口并重载。它会改变前面的布局与可见性选择，不要把它当成“只隐藏某一排”的开关。

用户提供的游戏内配置参考图，**不代表 Eclipse 当前版本已通过游戏实测**：

| 冷却分组 | 持续时间条 |
| :---: | :---: |
| [<img src="docs/images/native-warlock-cooldowns.png" width="300" alt="术士系统冷却配置">](docs/images/native-warlock-cooldowns.png) | [<img src="docs/images/native-warlock-tracked-bars.png" width="300" alt="术士系统持续时间条">](docs/images/native-warlock-tracked-bars.png) |

### DoT 剩余时间与技能冷却是两回事

Corruption、Immolate 在目标身上持续生效时，技能本身可以已经可用。**效果剩余时间** 应在 **目标持续效果** 或 **持续时间条** 中显示，不应伪造成技能冷却。启用 **显示模块 → 目标持续效果**，选中敌对目标并施放已学技能；该行只显示原生观测到的自身施加效果，不会为缺失或不可读状态估算时间。你可以保留系统条、使用 Eclipse 条，或使用紧凑图标；只需要一种展示时，关闭重复的一项即可。

### 选择施法条

打开 **`/eclipse` → 战斗行为 → 施法条显示**，点击按钮循环选择：

| 选择 | Eclipse 施法条 | 系统施法条 |
| --- | --- | --- |
| 系统施法条 | 关闭并卸载追踪 | 正常保留 |
| Eclipse 施法条 | 启用 | 仅在 Eclipse 施法显示已加载且启用时抑制 |
| 同时显示 | 启用 | 正常保留 |

安全默认是**只保留系统施法条**。旧版默认同时显示的配置会迁移到此选项；之前明确启用 Eclipse 抑制系统条的设置会保留。**显示模块 → Eclipse 施法条** 也可启用或关闭 Eclipse 选项。禁用 Eclipse 或导入的施法显示不可用时，会释放对系统施法条的控制；其他插件可能仍有自己的控制。战斗中修改会等脱战后应用。

以下为使用样例数据的浏览器预览，不是游戏截图：

| 仅系统条 | 仅 Eclipse 条 | 明确同时显示 |
| :---: | :---: | :---: |
| [<img src="preview/casting/warlock-default.png" width="260" alt="系统施法条样例">](preview/casting/warlock-default.png) | [<img src="preview/casting/warlock-eclipse.png" width="260" alt="Eclipse 施法条样例">](preview/casting/warlock-eclipse.png) | [<img src="preview/casting/warlock-both.png" width="260" alt="同时显示样例">](preview/casting/warlock-both.png) |

### 展开、收起与移动

- **左键点击徽记：** 脱战时展开检查；**再点一次收起**，即使仍选中同一敌对目标也能收起。更换目标或进入战斗后恢复自动规则。点击展开会保持，直到取消；`/eclipse inspect` 和设置中的预览按钮则是临时展开。
- 战斗事件立即开始动画，滑动和淡入淡出约半秒完成。启用 **战斗行为 → 展开与收拢动画** 保留平滑效果；布局刷新不会跳到动画终点。脱战且没有目标/检查条件时立即开始收起，单独丢失目标则保留五秒延迟。
- 收起主要 HUD 时，生效中的持续效果、追踪条和施法条仍遵循各自规则。
- **右键打开设置。** 解锁后拖动徽记；X/Y、缩放、透明度与模块按职业保存。战斗中延迟根布局修改；重置位置保留其他选项。
- 生命为深红，法力为蓝色，能量为金色，怒气为橙色，并保留文字标签。常驻增益位于侧边；姓名板效果默认关闭。关闭模块会卸载其追踪。

交互与动画的示意预览：

| 收起 | 展开过程 | 点击展开 | 可选持续时间条 |
| :---: | :---: | :---: | :---: |
| [<img src="preview/states/warlock-idle.png" width="220" alt="收起样例">](preview/states/warlock-idle.png) | [<img src="preview/states/warlock-opening.png" width="220" alt="动画中间帧">](preview/states/warlock-opening.png) | [<img src="preview/states/warlock-click-open.png" width="220" alt="展开样例">](preview/states/warlock-click-open.png) | [<img src="preview/states/warlock-tracked-bars.png" width="220" alt="持续时间条样例">](preview/states/warlock-tracked-bars.png) |

### 九职业预览与验证范围

以下均为明确标注的浏览器样例，使用模拟已学技能、当前冷却、光环与数值，不是游戏截图，也不是完整功能对齐的证明。[交互预览](https://github.com/tomqwu/wow_forever_weakaura/blob/main/preview/index.html)包含无伪造真实冷却的升级样例、分组/职业方案、施法条选择、重复点击开合与形态资源颜色。

| 术士 | 战士 | 法师 |
| :---: | :---: | :---: |
| [<img src="preview/classes/warlock.png" width="260" alt="术士">](preview/classes/warlock.png) | [<img src="preview/classes/warrior.png" width="260" alt="战士">](preview/classes/warrior.png) | [<img src="preview/classes/mage.png" width="260" alt="法师">](preview/classes/mage.png) |

| 牧师 | 盗贼 | 德鲁伊 |
| :---: | :---: | :---: |
| [<img src="preview/classes/priest.png" width="260" alt="牧师">](preview/classes/priest.png) | [<img src="preview/classes/rogue.png" width="260" alt="盗贼">](preview/classes/rogue.png) | [<img src="preview/classes/druid.png" width="260" alt="德鲁伊">](preview/classes/druid.png) |

| 猎人 | 萨满祭司 | 圣骑士 |
| :---: | :---: | :---: |
| [<img src="preview/classes/hunter.png" width="260" alt="猎人">](preview/classes/hunter.png) | [<img src="preview/classes/shaman.png" width="260" alt="萨满祭司">](preview/classes/shaman.png) | [<img src="preview/classes/paladin.png" width="260" alt="圣骑士">](preview/classes/paladin.png) |

光环归属、持续时间、层数、冷却、充能、资源与受限数值渲染均交给 ForeverAuras 原生触发器；不使用战斗记录重建或猜测刷新时间。术士护甲按原生状态显示，不把未知状态当作“缺失”。[游戏内验证](docs/validation.md)仍待完成；[持久清单](docs/feature-parity-plan.md)分别记录源码事实、实现与证据。

排查时可脱战运行 **`/eclipse spells`**，打印已学技能、原生 CDM 分组及挂接诊断。此客户端的 Lua 错误位于 **`_forever_/Logs/General.log`**。此前大量错误弹窗还涉及独立的 AckisRecipeList 生命预测污染错误，本项目未修改该插件。

### 构建与版权

需要 Python 3.11+、Lua 5.1 和构建依赖：

```bash
python -m pip install -r requirements-dev.txt
python scripts/build.py
python scripts/check.py
python scripts/preview.py
lua tests/native-schema.lua /path/to/ForeverAuras
```

源码位于 `src/catalog.py`、`scripts/build.py` 和 `src/EclipseHUD/`；职业文件位于 `dist/classes/`，合并导出仍在 `dist/`。CI 校验版本、编码内容、图结构/ID、原生规则、包字节与浏览器行为。每次发布同步文档、相关截图和更新日志，已发布文件不可覆盖。详见[设计说明](docs/design.md)与[更新日志](CHANGELOG.md)。

功能组织参考用户提供的 Guos 战士 HUD，但不包含其脚本、图片、声音或品牌素材。原创 AI 绘画源图和提示词保存在 [assets/ai](https://github.com/tomqwu/wow_forever_weakaura/tree/main/assets/ai)，构建复用现有源图。游戏技能图标归暴雪所有。采用 GPL-2.0，见 [LICENSE](LICENSE)和[第三方声明](https://github.com/tomqwu/wow_forever_weakaura/blob/main/vendor/README.md)。
