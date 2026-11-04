;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Increase garbage collector threshold during startup for faster boot
(setq gc-cons-threshold (* 64 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))))

;; Inhibit splash screen and startup noise before rendering
(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil)

;; Remove GUI clutter before frame creation to eliminate flicker
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Font default frame alist
(push '(font . "Iosevka Nerd Font-13") default-frame-alist)

(provide 'early-init)
;;; early-init.el ends here
