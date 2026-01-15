# minibuffer-side-window

A minor mode that displays vertico, embark, and which-key in a bottom
side-window instead of the standard minibuffer.

## Overview

When these packages reuse a pre-existing bottom side-window, Emacs doesn't
properly resize it. This package adds advice to ensure the window is resized
correctly each time it is reused.

## Features

- Displays vertico, embark, and which-key in a bottom side-window
- Automatically resizes the side-window when reused by vertico, embark, or
  which-key

## Installation

### Requirements

- Emacs 29.1+
- Optional: vertico, embark, which-key (configured when loaded)

### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/sonofjon/minibuffer-side-window.el.git
   ```

2. Add the directory to your Emacs `load-path`:
   ```elisp
   (add-to-list 'load-path "/path/to/minibuffer-side-window.el")
   ```

3. Load and enable the mode:
   ```elisp
   (require 'minibuffer-side-window)
   (minibuffer-side-window-mode 1)
   ```

### Using use-package

If you use `use-package`, you can install directly from GitHub:

```elisp
(use-package minibuffer-side-window
  :vc (:url "https://github.com/sonofjon/minibuffer-side-window.el.git")
  :config
  (minibuffer-side-window-mode 1))
```

## Usage

### Basic Usage

Enable the mode globally:

```elisp
(minibuffer-side-window-mode 1)
```

Disable the mode:

```elisp
(minibuffer-side-window-mode -1)
```

Toggle the mode:

```elisp
M-x minibuffer-side-window-mode
```

## How It Works

Emacs' built-in functions `display-buffer-in-side-window` and
`display-buffer-reuse-window` only honor the window-height parameter when
creating new windows, not when reusing existing ones. This package works
around this limitation by adding advice to ensure side-windows are properly
resized each time they are reused.

Each package is configured to display in the bottom side-window:

- **Vertico**: Enables `vertico-buffer-mode` and sets
  `vertico-buffer-display-action` to use a bottom side-window. No height is
  specified, so Emacs uses its default side-window height.

- **Embark**: Sets `embark-verbose-indicator-display-action` to display in
  the bottom side-window and dynamically fit to buffer content (up to 50% of
  frame height).

- **Which-key**: Sets `which-key-popup-type` to `'side-window`. Height is
  managed by which-key's own customization variable
  `which-key-side-window-max-height`.

When disabled, the mode restores each package to its original configuration.

## Known Issues

- The minibuffer prompt may remain visible at the bottom of the frame when
  displaying in the side-window. This is a cosmetic issue and does not
  affect functionality.
