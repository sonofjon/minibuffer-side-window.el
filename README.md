# minibuffer-side-window-mode

A minor mode that displays vertico, embark, and which-key in a bottom
side-window instead of the standard minibuffer.

## Overview

When these packages reuse a pre-existing bottom side-window, Emacs doesn't
properly resize it. This package adds advice to ensure the window is resized
correctly each time it is reused.

## Features

- Configures vertico, embark, and which-key to display in a bottom
  side-window
- Automatically resizes the side-window when reused by vertico, embark, or
  which-key

## Installation

### Requirements

- Emacs 29.1+
- Optional: vertico, embark, which-key (configured when loaded)

```elisp
(use-package minibuffer-side-window-mode
  ;; Load from a local copy
  :load-path "/path/to/minibuffer-side-window-mode.el"
  ;; ... or clone from GitHub
  ;; :vc (:url "https://github.com/sonofjon/minibuffer-side-window-mode.el.git"
  ;;          :rev :newest)
  :after (:any vertico embark which-key)
  :config
  (minibuffer-side-window-mode 1))
```

Note: The `:after` keyword ensures the mode is loaded after your completion
packages. You can list only the packages you actually use (e.g., `:after
vertico` if you only use vertico).

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

### Minibuffer Prompt Visibility

In terminal Emacs, the minibuffer prompt remains visible at the bottom of
the frame. (In GUI Emacs, the prompt is hidden correctly.) This appears to
be a limitation of vertico-buffer-mode's prompt-hiding mechanism, which uses
`set-window-vscroll` to hide the prompt. The exact cause is unclear but may
involve Emacs scroll configuration settings (such as `scroll-step` or
`scroll-conservatively`), terminal display limitations, or other factors.
