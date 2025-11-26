# Tmux Quick Reference Guide

## What is Tmux and Why Use It?

**Tmux** (Terminal Multiplexer) is a tool that lets you run multiple terminal sessions inside a single window. Think of it as having multiple tabs and split screens for your terminal, but much more powerful.

### Key Benefits

1. **Multiple terminals in one window**
   - Split your screen into multiple panes (like having multiple monitors)
   - Have code editor, terminal, and logs all visible at once
   - No need to switch between different terminal windows

2. **Persistent sessions (The Killer Feature!)**
   - Your work survives if you close your terminal or lose connection
   - Start a long-running process, detach, close terminal, come back later - it's still running!
   - Perfect for SSH sessions that might disconnect
   - Resume exactly where you left off

3. **Better workflow organization**
   - Different tmux sessions for different projects
   - Each session maintains its own layout and running processes
   - Switch between projects instantly

4. **Seamless Neovim integration**
   - Navigate between Neovim splits and tmux panes with the same keys
   - Split your editor and terminal views perfectly

### Real-World Use Cases

**Scenario 1: Development Setup**
```
┌─────────────────┬──────────────┐
│                 │  npm run dev │
│   Neovim        │  (running)   │
│   (editing)     ├──────────────┤
│                 │  git status  │
│                 │  (commands)  │
└─────────────────┴──────────────┘
```
All in one terminal window, all visible at once!

**Scenario 2: Long-Running Processes**
```bash
# Start training a machine learning model
tmux new -s training
python train_model.py

# Detach and close terminal
Ctrl+a d

# Go home, come back tomorrow, reattach
tmux a -t training
# Model is still training! Progress still visible!
```

**Scenario 3: Multiple Projects**
```bash
# Working on frontend
tmux new -s frontend
cd ~/projects/frontend
nvim

# Switch to backend work
Ctrl+a d
tmux new -s backend
cd ~/projects/backend
nvim

# Jump between projects instantly
tmux a -t frontend
tmux a -t backend
```

**Scenario 4: SSH Work (Perfect for WSL!)**
```bash
# Connect to remote server
ssh user@server
tmux new -s work

# Connection drops? No problem!
# Reconnect and reattach
ssh user@server
tmux a -t work
# Everything is still there!
```

---

## Installation Complete! ✅
- **Tmux version**: 3.2a
- **Theme**: Tokyo Night Moon (matching your Neovim)
- **Neovim integration**: vim-tmux-navigator installed

## Key Configuration Changes
- **Prefix key**: Changed from `Ctrl+b` to `Ctrl+a` (easier to reach)
- **Mouse support**: Enabled
- **True color**: Enabled for beautiful colors
- **Vim keybindings**: Enabled in copy mode

---

## Essential Tmux Commands

### Starting Tmux
```bash
tmux                    # Start new session
tmux new -s myname      # Start new session with name
tmux a                  # Attach to last session
tmux a -t myname        # Attach to named session
tmux ls                 # List sessions
tmux kill-session -t myname  # Kill named session
```

### Prefix Key
All commands start with `Ctrl+a` (instead of default `Ctrl+b`)

### How to Type Shortcuts

**Two-Step Process:**
1. Press `Ctrl+a` together, then **RELEASE**
2. Press the next key

**Examples:**
- `Ctrl+a |` means: Hold Ctrl+a → Release → Press Shift+\ (for |)
- `Ctrl+a c` means: Hold Ctrl+a → Release → Press c
- `Ctrl+a -` means: Hold Ctrl+a → Release → Press -

**No pause needed!** Just release the prefix and immediately press the next key.

**Special case - Navigation:**
- `Ctrl+h/j/k/l` = Hold Ctrl and press h/j/k/l (NO prefix needed!)

---

## Window Management (Tabs)

| Keybinding | Action | Memory Trick |
|-----------|--------|--------------|
| `Ctrl+a c` | Create new window | **c**reate |
| `Ctrl+a ,` | Rename current window | comma for "change name" |
| `Ctrl+a n` | Next window | **n**ext |
| `Ctrl+a p` | Previous window | **p**revious |
| `Ctrl+a 0-9` | Switch to window number | Direct number access |
| `Ctrl+a w` | List all windows | **w**indows list |
| `Ctrl+a &` | Kill current window | & = "end it" |
| `Ctrl+a Ctrl+h` | Previous window (custom) | **h** = left/previous |
| `Ctrl+a Ctrl+l` | Next window (custom) | **l** = right/next |

---

## Pane Management (Splits)

### Creating Panes
| Keybinding | Action | Memory Trick |
|-----------|--------|--------------|
| `Ctrl+a \` | Split vertically (side by side) | **\\** looks like a vertical line! |
| `Ctrl+a -` | Split horizontally (top and bottom) | **-** looks like a horizontal line! |

**Note:** Press and release `Ctrl+a`, then press `\` or `-`

### Navigating Between Panes (Vim-style + Neovim aware!)
| Keybinding | Action | Memory Trick |
|-----------|--------|--------------|
| `Ctrl+h` | Move to left pane | **h** = left in Vim (like arrow ←) |
| `Ctrl+j` | Move to bottom pane | **j** = down in Vim (looks like ↓) |
| `Ctrl+k` | Move to top pane | **k** = up in Vim (opposite of j) |
| `Ctrl+l` | Move to right pane | **l** = right in Vim (like arrow →) |
| `Ctrl+a z` | Toggle pane zoom (fullscreen) | **z**oom in/out |
| `Ctrl+a x` | Kill current pane | **x** = close/exit |

### Resizing Panes
| Keybinding | Action | Memory Trick |
|-----------|--------|--------------|
| `Ctrl+a H` | Resize left (repeatable) | Capital **H** = BIG left |
| `Ctrl+a J` | Resize down (repeatable) | Capital **J** = BIG down |
| `Ctrl+a K` | Resize up (repeatable) | Capital **K** = BIG up |
| `Ctrl+a L` | Resize right (repeatable) | Capital **L** = BIG right |

**Tip:** Just add Shift to h/j/k/l for resizing!

---

## Session Management

| Keybinding | Action | Memory Trick |
|-----------|--------|--------------|
| `Ctrl+a d` | Detach from session | **d**etach (super important!) |
| `Ctrl+a $` | Rename session | $ = "set name" |
| `Ctrl+a (` | Previous session | ( goes left |
| `Ctrl+a )` | Next session | ) goes right |
| `Ctrl+a s` | List all sessions (interactive) | **s**essions list |
| `Ctrl+a ;` | Command mode | Enter tmux commands (easier than :) |

### Creating New Session from Inside Tmux

**Method 1: Detach and create (Recommended)**
```bash
Ctrl+a d              # Detach from current session
tmux new -s newname   # Create new session
```

**Method 2: Using command mode**
```bash
Ctrl+a ;              # Enter command mode (no pause!)
new -s sessionname    # Type this and press Enter
```

**Method 3: Create in background**
```bash
Ctrl+a ;
new-session -s newname -d    # Create in background
Ctrl+a s                     # List sessions and switch
```

### Switching Between Sessions

**From inside tmux:**
- `Ctrl+a s` - Interactive session list (use j/k to navigate, Enter to switch)
- `Ctrl+a (` - Previous session
- `Ctrl+a )` - Next session

**From terminal:**
```bash
tmux ls                 # List all sessions
tmux a -t sessionname   # Attach to specific session
```

---

## Copy Mode (Vim-style)

| Keybinding | Action | Memory Trick |
|-----------|--------|--------------|
| `Ctrl+a [` | Enter copy mode | [ = "start bracket" |
| `Space` or `v` | Start selection | **v**isual mode (like Vim!) |
| `Enter` or `y` | Copy selection | **y**ank (Vim copy) |
| `Ctrl+a ]` | Paste most recent | ] = "end bracket" |
| `Ctrl+a #` | View paste buffer history | # = "see clipboard" |
| `q` | Exit copy mode | **q**uit |
| `Ctrl+v` | Rectangle selection | **v**isual block (like Vim!) |

**In copy mode, use Vim navigation:**
- `h` `j` `k` `l` - Move cursor
- `w` `b` - Jump word forward/backward
- `gg` `G` - Go to top/bottom
- `0` `$` - Start/end of line
- `/text` - Search for "text"
- `n` - Next search result

### Copying Terminal Output (Step-by-step)

1. `Ctrl+a [` - Enter copy mode
2. Navigate to the text (use `h/j/k/l` or arrow keys)
3. `v` - Start selection (or `Space`)
4. Move cursor to select text (use `h/j/k/l`)
5. `y` - Copy (yank) - automatically exits copy mode
6. `Ctrl+a ]` - Paste wherever you want

**Example:**
```bash
# After running a command with output:
Ctrl+a [          # Enter copy mode
k k k             # Move up 3 lines
v                 # Start selection
j j               # Select 2 more lines down
y                 # Copy (yank)
Ctrl+a ]          # Paste
```

### Viewing Clipboard History

Tmux keeps a history of copied items!

- `Ctrl+a #` - Show all paste buffers (list of copied items)
- Use `j/k` to navigate the list
- Press `Enter` to paste the selected item
- Press `q` to cancel

**From command line:**
```bash
tmux list-buffers    # List all buffers
tmux show-buffer     # Show the most recent buffer
tmux choose-buffer   # Interactive buffer selector
```

---

## Other Useful Commands

| Keybinding | Action | Memory Trick |
|-----------|--------|--------------|
| `Ctrl+a r` | Reload tmux config | **r**eload |
| `Ctrl+a ?` | List all keybindings | ? = help/question |
| `Ctrl+a t` | Show clock | **t**ime |
| `Ctrl+a q` | Show pane numbers | **q**uick numbers |

---

## Seamless Neovim Integration

The **vim-tmux-navigator** plugin allows you to navigate between tmux panes and Neovim splits using the same keys!

**How it works:**
- Press `Ctrl+h/j/k/l` to move between panes
- If you're in Neovim with splits, it moves between Neovim splits
- At the edge of Neovim, it moves to adjacent tmux panes
- No need to think about whether you're in tmux or Neovim!

---

## Recommended Workflow

### Development Setup
```bash
# Start tmux session for a project
tmux new -s myproject

# Split into 3 panes:
Ctrl+a |          # Split vertically
Ctrl+a -          # Split horizontally

# You now have 3 panes:
# - Left: Neovim for editing
# - Top right: Run tests/build
# - Bottom right: Git commands
```

### Working with Multiple Projects
```bash
tmux new -s frontend
Ctrl+a d                    # Detach

tmux new -s backend
Ctrl+a d                    # Detach

tmux a -t frontend          # Switch back to frontend
tmux a -t backend           # Switch to backend
```

---

## Status Bar Information

Your status bar shows:
- **Left**: Session name with icon
- **Center**: Window list (current window highlighted)
- **Right**: Date and time

---

## Tips & Tricks

1. **Mouse support is enabled**: You can click panes, resize with mouse, and scroll
2. **Persistent sessions**: Tmux keeps running even if you close the terminal
3. **Works great in WSL**: Perfect for your Ubuntu WSL setup
4. **True color support**: Matches your beautiful Tokyo Night theme
5. **Fast escape**: Optimized for Neovim (10ms escape time)

---

## Common Workflow Example

```bash
# Start tmux
tmux new -s coding

# Open Neovim in the main pane
nvim

# Split for terminal
Ctrl+a |

# Move to right pane and run build/tests
Ctrl+l
npm run dev

# Split terminal pane for git
Ctrl+a -

# Move to bottom right for git
Ctrl+j
git status

# Move back to Neovim
Ctrl+h

# Seamlessly navigate between Neovim splits and tmux panes!
```

---

## Configuration Files

- **Tmux config**: `~/.tmux.conf`
- **Neovim tmux plugin**: `~/.config/nvim/lua/plugins/tmux.lua`

Reload tmux config: `Ctrl+a r` or `tmux source ~/.tmux.conf`
