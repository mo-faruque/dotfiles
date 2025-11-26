# Neovim Essential Keybindings Cheat Sheet

## 🎯 THE ABSOLUTE ESSENTIALS

### Mode Switching
```
Esc         → Return to NORMAL mode (from any mode)
i           → INSERT mode (before cursor)
a           → INSERT mode (after cursor)
v           → VISUAL mode (character selection)
V           → VISUAL LINE mode (line selection)
:           → COMMAND mode
```

### Save & Quit
```
:w          → Save (write)
:q          → Quit
:wq         → Save and quit
:q!         → Quit WITHOUT saving
ZZ          → Save and quit (fast)
```

## 🚶 MOVEMENT (Normal Mode)

### Basic Movement
```
h           → Left
j           → Down
k           → Up
l           → Right
```

### Word Movement
```
w           → Next word start
b           → Previous word start
e           → Next word end
```

### Line Movement
```
0           → Start of line
^           → First non-blank character
$           → End of line
```

### File Movement
```
gg          → First line of file
G           → Last line of file
42G         → Go to line 42
Ctrl+d      → Scroll down half page
Ctrl+u      → Scroll up half page
```

## ✂️ EDITING (Normal Mode)

### Delete
```
x           → Delete character under cursor
dd          → Delete entire line
dw          → Delete word
d$          → Delete to end of line
```

### Copy (Yank)
```
yy          → Copy entire line
yw          → Copy word
y$          → Copy to end of line
```

### Paste
```
p           → Paste after cursor
P           → Paste before cursor
```

### Change (Delete and Enter Insert Mode)
```
cw          → Change word
c$          → Change to end of line
cc          → Change entire line
```

### Undo/Redo
```
u           → Undo
Ctrl+r      → Redo
```

## 🔍 SEARCH

```
/text       → Search forward for "text"
?text       → Search backward for "text"
n           → Next search result
N           → Previous search result
*           → Search for word under cursor (forward)
#           → Search for word under cursor (backward)
```

## ⚡ LAZYVIM SHORTCUTS

### File Operations (Space + f + ?)
```
Space ff    → Find Files (fuzzy search)
Space fr    → Find Recent files
Space fb    → Find Buffers (open files)
Space fg    → Find by Grep (search in files)
Space e     → Toggle file Explorer
```

### Window Management (Space + w + ?)
```
Ctrl+h      → Move to left window
Ctrl+j      → Move to window below
Ctrl+k      → Move to window above
Ctrl+l      → Move to right window
Space w-    → Split horizontally
Space w|    → Split vertically
Space wd    → Delete (close) window
```

### Buffers & Tabs
```
Tab         → Next buffer
Shift+Tab   → Previous buffer
Space bd    → Delete (close) buffer
```

### Code Navigation (LSP)
```
gd          → Go to Definition
gr          → Go to References
K           → Show documentation (hover)
Space ca    → Code Actions
Space cr    → Code Rename
Space cf    → Format code
```

### Diagnostics
```
Space cd    → Show Diagnostics list
]d          → Next diagnostic
[d          → Previous diagnostic
```

### Terminal
```
Ctrl+/      → Toggle terminal
```

### Search & Replace
```
Space sg    → Search by Grep
Space sw    → Search Word under cursor
Space sr    → Search and Replace
```

### Git (if in git repo)
```
Space gg    → Open Lazygit
Space gc    → Git Commits
Space gs    → Git Status
```

## 💡 POWER USER TRICKS

### Repeat Commands
```
5j          → Move down 5 lines
3dd         → Delete 3 lines
10w         → Jump forward 10 words
.           → Repeat last change
```

### Visual Mode Selection
```
v + motion  → Select text (then d=delete, y=yank, c=change)
V           → Select entire line
Ctrl+v      → Block selection (rectangular)
```

### Insert Mode Special
```
o           → Open new line below (enter insert)
O           → Open new line above (enter insert)
A           → Append at end of line (enter insert)
I           → Insert at start of line (enter insert)
```

## 📝 MEMORIZATION STRATEGY

### Week 1: Master These Only
```
i, Esc, :wq
hjkl
dd, yy, p
u (undo)
/search
```

### Week 2: Add These
```
w, b (word movement)
0, $ (line start/end)
gg, G (file start/end)
Space ff (find files)
Space e (file explorer)
```

### Week 3: Add These
```
Ctrl+hjkl (window navigation)
gd, K (code navigation)
Space ca (code actions)
Space cf (format)
Ctrl+/ (terminal)
```

### Week 4: Power User
```
Repeat commands (5j, 3dd)
Visual mode (v, V, Ctrl+v)
Dot command (.)
Search & replace
Splits & buffers
```

## 🎓 PRACTICE EXERCISES

### Exercise 1: Basic Editing
1. Open file: `nvim practice.txt`
2. Press `i` → type "Hello"
3. Press `Esc` → press `o` → type "World"
4. Press `Esc` → type `:wq`

### Exercise 2: Movement
1. Open any file
2. Practice: `5j` (down 5), `3w` (forward 3 words), `gg` (top), `G` (bottom)
3. Try: `0` (line start), `$` (line end)

### Exercise 3: Delete, Yank, Paste
1. Navigate to a line with `j/k`
2. Press `yy` to yank (copy) it
3. Move to another line
4. Press `p` to paste
5. Press `dd` to delete a line

### Exercise 4: Search
1. Press `/` then type a word
2. Press `Enter`
3. Press `n` to find next occurrence
4. Press `N` to go to previous

### Exercise 5: LazyVim
1. Press `Space` (wait for menu)
2. Press `f` then `f` (find files)
3. Type part of filename
4. Press `Enter` to open

## 🔥 MUST MEMORIZE FIRST

**If you only memorize 10 things, make it these:**

1. `Esc` - Get back to normal mode
2. `i` - Enter insert mode
3. `:wq` - Save and quit
4. `hjkl` - Basic movement
5. `dd` - Delete line
6. `yy` + `p` - Copy and paste line
7. `u` - Undo
8. `/text` - Search
9. `Space ff` - Find files
10. `Space e` - File explorer

**Practice these 10 commands for 5 minutes daily for a week!**

## 🧠 MEMORY TRICKS & MNEMONICS

### Movement Keys - The Home Row Story
```
     k (up)
     ↑
h ← → l
     ↓
     j (down)

Think: "J" looks like an arrow pointing DOWN ↓
       "K" kicks you UP
       "H" points LEFT (first letter = far left)
       "L" is on the right side of keyboard = RIGHT
```

### Word Movement - Think "Backwards & Forwards"
```
w = Word forward     (W goes forward in alphabet)
b = Back/Behind      (B for Backwards)
e = End of word      (E for End)
```

### Action + Motion Pattern
**THE GOLDEN RULE:** `<action><motion>`

```
d = Delete   |  w = word     →  dw = delete word
y = Yank     |  $ = end       →  y$ = yank to end
c = Change   |  3j = 3 down   →  c3j = change 3 lines down
```

**Think: "I want to DELETE a WORD" → d + w → `dw`**

### Insert Mode Mnemonics
```
i = Insert (before cursor)      - "I'll insert here"
a = Append (after cursor)        - "Add/Append after"
o = Open line below             - "Open below"
O = Open line above             - "Open above" (capital = opposite)
A = Append at end of line       - "Append at END" (capital A = go far)
I = Insert at start of line     - "Insert at START" (capital I = go far)
```

### Delete Variations
```
x = X marks the spot (delete ONE character)
dd = Double D = Delete entire line
D = Delete to end of line (capital = more powerful)
```

### Copy/Paste Memory Aid
```
yy = "Yeah Yeah, copy that!" (yank line)
yw = "Yank Word"
p = Put/Paste (after cursor)
P = Put before (capital = opposite direction)
```

### LazyVim Space Mnemonics
**Space is your SPACESHIP to everything!**

```
Space + f = File operations
  ff = Find Files
  fr = Find Recent
  fb = Find Buffers
  fg = Find by Grep (search)

Space + e = Explorer (file tree)

Space + w = Window operations
  w- = Window split horizontal (minus = horizontal line)
  w| = Window split vertical (pipe = vertical line)
  wd = Window Delete (close)

Space + c = Code operations
  ca = Code Actions
  cr = Code Rename
  cf = Code Format
  cd = Code Diagnostics

Space + g = Git operations
  gg = Git UI
  gc = Git Commits
  gs = Git Status

Space + s = Search operations
  sg = Search Grep
  sw = Search Word
  sr = Search Replace
```

### Search Commands
```
/ = Forward slash = search forward
? = Question mark = questioning backwards
n = Next (same direction)
N = Next (opposite direction, capital = opposite)
* = Asterisk = "star this word" (search current word forward)
# = Hash = "hashtag this word" (search current word backward)
```

### Undo/Redo
```
u = Undo (lowercase = go back)
Ctrl+r = Redo (R for Redo/Restore)
```

### Line Anchors
```
0 = Zero is the START (column 0)
$ = Dollar sign is at the END (like end of a price: $99.99$)
^ = Caret points UP to first non-blank character
```

### File Anchors
```
gg = "Go Go!" to top (double tap to start)
G = "Ground" level (capital = powerful jump to bottom)
42G = "Go to line 42" (G for Goto)
```

### Visual Mode
```
v = visual (lowercase = character selection)
V = VISUAL (capital = BIGGER = whole lines)
Ctrl+v = Vertical block (like drawing a rectangle)
```

## 🎮 GAMIFICATION TECHNIQUE

### Daily Challenge System

**Level 1 (Week 1):** "Survivor Mode"
- Goal: Never use mouse or arrow keys for 1 hour
- Practice: `hjkl`, `i`, `Esc`, `:wq`
- Reward: You can edit files without getting stuck!

**Level 2 (Week 2):** "Speed Demon"
- Challenge: Navigate to any line in under 5 keystrokes
- Practice: `gg`, `G`, `42G`, `w`, `b`, `0`, `$`
- Reward: You're faster than using a mouse!

**Level 3 (Week 3):** "Copy Master"
- Challenge: Copy 5 different things without using mouse
- Practice: `yy`, `yw`, `y$`, `p`, `P`
- Reward: You can refactor code blazingly fast!

**Level 4 (Week 4):** "Combo King"
- Challenge: Use 3+ keystroke combos
- Practice: `d3w`, `y5j`, `c$`, `3dd`, `.`
- Reward: You look like a hacker in movies!

## 🎯 SPACED REPETITION FLASH CARDS

### Day 1-3: Learn these by heart
```
What does 'dd' do?     → Delete line
What does 'yy' do?     → Copy (yank) line
What does 'p' do?      → Paste
How to undo?           → u
How to save and quit?  → :wq
```

### Day 4-7: Add these
```
Move to next word?     → w
Move to prev word?     → b
Start of line?         → 0
End of line?           → $
Find files in LazyVim? → Space ff
```

### Day 8-14: Master these
```
Delete a word?         → dw
Change a word?         → cw
Jump to top?           → gg
Jump to bottom?        → G
Go to definition?      → gd
```

## 💪 MUSCLE MEMORY EXERCISES

### 5-Minute Daily Drills

**Drill 1: hjkl Navigation (1 min)**
- Open any file
- Navigate using ONLY hjkl
- No arrow keys!
- Try: `10j`, `5k`, `20h`, `15l`

**Drill 2: Delete & Undo (1 min)**
- Delete 3 random lines with `dd`
- Undo with `u`
- Redo with `Ctrl+r`
- Repeat 10 times

**Drill 3: Copy/Paste (1 min)**
- Copy a line with `yy`
- Paste it 5 times with `p`
- Delete all copies with `dd`

**Drill 4: Word Movement (1 min)**
- Jump through a paragraph using only `w` and `b`
- Count how many words you can skip in 30 seconds

**Drill 5: LazyVim Shortcuts (1 min)**
- `Space ff` → open a file
- `Space e` → toggle explorer
- `Ctrl+h` → back to file
- Repeat 5 times

## 🧩 PATTERN RECOGNITION

### Common Patterns to Internalize

**Pattern: "I want to change/delete/copy X"**
```
Action + Motion = Result
d + w = delete word
d + $ = delete to end of line
d + d = delete entire line (special case)
c + w = change word
y + y = yank line (special case)
```

**Pattern: "Do this N times"**
```
Number + Action = Repeat
5 + j = move down 5 lines
3 + dd = delete 3 lines
2 + yy = copy 2 lines
```

**Pattern: "Space + Category + Action"**
```
Space + f + f = File Find
Space + f + r = File Recent
Space + c + a = Code Action
Space + g + s = Git Status
```

## 🎪 SILLY STORIES (Memory Palace Technique)

**The Insert Mode Story:**
Imagine typing a letter. You can:
- **i**nsert from the **i**nside (before cursor)
- **a**dd from the **a**fter (after cursor)
- **o**pen a door below (new line below)
- **O**pen a skylight above (new line above)

**The Delete Story:**
Think of a demolition crew:
- **x** marks the spot - destroy ONE thing
- **dd** is the demolition team - destroy the WHOLE LINE
- **D** is the BIG demolition - destroy everything TO THE RIGHT

**The Copy Story:**
"Yeah, I want that!" → **yy** (yank)
Where to put it? → **p** for "put it here"

## 🔄 THE 5-DAY MASTERY PLAN

**Monday:** hjkl only - no arrow keys allowed
**Tuesday:** dd, yy, p - delete, copy, paste mastery
**Wednesday:** w, b, 0, $ - word and line movement
**Thursday:** Space ff, Space e - LazyVim shortcuts
**Friday:** Combine everything - do real work!

**Saturday/Sunday:** Challenge yourself to do ALL editing in Neovim!

---

**Quick Reference:**
- Normal mode = Navigation & Commands
- Insert mode = Typing text
- Visual mode = Selecting text
- Command mode = Execute commands (`:`)

**Remember:** Press `Space` and wait - LazyVim will show you options!

## 🎨 VISUALIZATION AIDS

**The Keyboard Layout:**
```
┌─────────────────────────────────┐
│  Your keyboard IS the interface │
│                                  │
│  hjkl = arrows on home row      │
│  Space = command palette        │
│  Esc = return to safety         │
└─────────────────────────────────┘
```

**The Vim Mindset:**
```
Think in ACTIONS + MOTIONS:

"I want to delete 3 words"
↓
Action: d (delete)
Motion: 3w (3 words)
Result: d3w
```
