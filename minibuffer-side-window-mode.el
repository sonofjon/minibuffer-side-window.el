;;; minibuffer-side-window-mode.el --- Side-window display for minibuffer packages -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Andreas Jonsson
;;
;; Author: Andreas Jonsson <ajdev8@gmail.com>
;; Maintainer: Andreas Jonsson <ajdev8@gmail.com>
;; URL: https://github.com/sonofjon/minibuffer-side-window-mode.el
;; Version: 0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: convenience

;;; Commentary:

;; This package provides a minor mode that configures vertico, embark, and
;; which-key to display in a bottom side-window instead of the standard
;; minibuffer.
;;
;; Emacs' built-in functions `display-buffer-in-side-window' and
;; `display-buffer-reuse-window' only honor the window-height parameter when
;; creating new windows, not when reusing existing ones.  This package works
;; around this limitation by adding advice to ensure side-windows are
;; properly resized each time they are reused.
;;
;; Usage:
;;
;;   (require 'minibuffer-side-window-mode)
;;   (minibuffer-side-window-mode 1)

;;; Code:

;;; External declarations

;; Functions
(declare-function vertico-buffer-mode "vertico-buffer" (&optional arg))

;; Variables
(defvar vertico-buffer-display-action nil "Defined in vertico-buffer.el.")
(defvar embark-verbose-indicator-display-action nil "Defined in embark.el.")
(defvar which-key-popup-type nil "Defined in which-key.el.")

;;; Customization

(defgroup minibuffer-side-window nil
  "Side-window display for minibuffer packages."
  :group 'convenience
  :prefix "minibuffer-side-window-")

;;; Internal variables

(defvar minibuffer-side-window--vertico-display-action-saved nil
  "Saved value of `vertico-buffer-display-action'.")

(defvar minibuffer-side-window--embark-display-action-saved nil
  "Saved value of `embark-verbose-indicator-display-action'.")

;;; Private functions

(defun minibuffer-side-window--resize-on-reuse (buffer alist)
  "Resize bottom side-window when reused.

Advises `display-buffer-in-side-window' and
`display-buffer-reuse-window' to honor the window-height parameter in
ALIST when reusing an existing window.

BUFFER is the buffer being displayed."
  (when-let* ((side (alist-get 'side alist))
              ((eq side 'bottom))
              (height (alist-get 'window-height alist))
              (window (get-buffer-window buffer)))
    (cond
     ((functionp height)
      (funcall height window))
     ((numberp height)
      (let* ((new-height (if (integerp height)
                             height
                           (round (* (frame-height) height))))
             (delta (- new-height (window-total-height window))))
        (when (and (not (zerop delta))
                   (window-resizable-p window delta))
          (window-resize window delta)))))))

(defun minibuffer-side-window--enable ()
  "Enable side-window display for vertico, embark, and which-key.

Configures all packages to display in the bottom side-window.

The function `display-buffer-in-side-window' can both create new
side-windows and reuse existing side-windows, but only honors
window-height when creating new side-windows.  The function
`display-buffer-reuse-window' only reuses windows and always ignores
window-height.  This function adds advice that resizes the side-window
when reusing.

Package-specific requirements:
  - Vertico: needs advice for display-buffer-in-side-window
  - Embark: needs advice for display-buffer-in-side-window
  - which-key: needs advice for both display-buffer-in-side-window and
    display-buffer-reuse-window"
  ;; General
  (advice-add 'display-buffer-in-side-window :after
              #'minibuffer-side-window--resize-on-reuse)
  (advice-add 'display-buffer-reuse-window :after
              #'minibuffer-side-window--resize-on-reuse)
  ;; Vertico
  (when (featurep 'vertico)
    (vertico-buffer-mode 1)
    (setq minibuffer-side-window--vertico-display-action-saved
          vertico-buffer-display-action)
    (setq vertico-buffer-display-action
          '(display-buffer-in-side-window
            (side . bottom)
            (window-parameters . ((mode-line-format . none))))))
  ;; Embark
  (when (featurep 'embark)
    (setq minibuffer-side-window--embark-display-action-saved
          embark-verbose-indicator-display-action)
    (setq embark-verbose-indicator-display-action
          '(display-buffer-in-side-window
            (side . bottom)
            (window-height . (lambda (window)
                               (fit-window-to-buffer
                                window
                                (floor (* 0.5 (frame-height))))))
            (window-parameters . ((no-other-window . t)
                                  (mode-line-format . none))))))
  ;; Which-key
  (when (featurep 'which-key)
    (setq which-key-popup-type 'side-window)))

(defun minibuffer-side-window--disable ()
  "Disable side-window display for vertico, embark, and which-key."
  ;; General
  (advice-remove 'display-buffer-in-side-window
                 #'minibuffer-side-window--resize-on-reuse)
  (advice-remove 'display-buffer-reuse-window
                 #'minibuffer-side-window--resize-on-reuse)
  ;; Vertico
  (when (featurep 'vertico)
    (vertico-buffer-mode -1)
    (setq vertico-buffer-display-action
          minibuffer-side-window--vertico-display-action-saved))
  ;; Embark
  (when (featurep 'embark)
    (setq embark-verbose-indicator-display-action
          minibuffer-side-window--embark-display-action-saved))
  ;; Which-key
  (when (featurep 'which-key)
    (setq which-key-popup-type 'minibuffer)))

;;; Public interface

;;;###autoload
(define-minor-mode minibuffer-side-window-mode
  "Toggle side-window display for vertico, embark, and which-key.

When enabled, these packages display in the bottom side-window.  When
disabled, they use standard minibuffer display."
  :global t
  :group 'minibuffer-side-window
  (if minibuffer-side-window-mode
      (minibuffer-side-window--enable)
    (minibuffer-side-window--disable)))

(provide 'minibuffer-side-window-mode)

;;; minibuffer-side-window-mode.el ends here
