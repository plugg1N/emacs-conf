;;; init.el --- Minimalist Emacs configuration -*- lexical-binding: t; -*-

;; =============================================================================
;; 1. ПАКЕТНЫЙ МЕНЕДЖЕР (PACKAGE ARCHIVES & USE-PACKAGE)
;; =============================================================================
(require 'package)
(setq package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

;; Автоматически устанавливать пакеты, если их нет
(require 'use-package)
(setq use-package-always-ensure t)

;; =============================================================================
;; 2. ВНЕШНИЙ ВИД И UI (MINIMALIST UI & FONTS)
;; =============================================================================
;; Убираем лишние элементы интерфейса
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Отключаем приветственный экран и очищаем стартовый буфер
(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil)

;; Релятивные (относительные) номера строк
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Перемещение между окнами стрелками с зажатым Shift (Shift+Left/Right/Up/Down)
(windmove-default-keybindings)

;; Отключаем номера строк там, где они мешают
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                dired-mode-hook
                doc-view-mode-hook
                pdf-view-mode-hook
                image-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Подсветка текущей строки и парных скобок
(global-hl-line-mode 1)
(show-paren-mode 1)
(column-number-mode 1)

;; Шрифт Iosevka Nerd Font
(when (find-font (font-spec :name "Iosevka Nerd Font"))
  (set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 130))

;; Тема Gruber Darker
(use-package gruber-darker-theme
  :config
  (load-theme 'gruber-darker t))

;; Плавный скроллинг (Emacs 29+)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; =============================================================================
;; 3. РАЦИОНАЛЬНЫЕ НАСТРОЙКИ РЕДАКТИРОВАНИЯ (SENSIBLE DEFAULTS)
;; =============================================================================
;; Замена выделенного текста при вводе нового (как во всех современных редакторах)
(delete-selection-mode 1)

;; Интеграция с системным буфером обмена (Clipboard)
(setq select-enable-clipboard t
      select-enable-primary t
      save-interprogram-paste-before-kill t)

;; Синхронизация буфера обмена даже при работе в терминале (X11 / Wayland)
(use-package xclip
  :config
  (xclip-mode 1))

;; Автоматическое закрытие скобок и кавычек
(electric-pair-mode 1)

;; Хранение резервных копий (backup files ~) в одной папке, чтобы не мусорить в проектах
(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves" user-emacs-directory) t))
      create-lockfiles nil
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; Сохранение позиции курсора в файлах между сессиями
(save-place-mode 1)

;; Сохранение истории команд минибуфера
(savehist-mode 1)

;; Список недавно открытых файлов
(recentf-mode 1)
(setq recentf-max-saved-items 100)

;; Автоматическое обновление буфера, если файл изменился на диске (git checkout и т.д.)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; Кодировка по умолчанию UTF-8
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;; Поддержка русской раскладки для всех хоткеев (C-x, M-x, C-s и др. работают в русской раскладке)
(use-package reverse-im
  :custom
  (reverse-im-input-methods '("russian-computer"))
  :config
  (reverse-im-mode t))

;; Удобная навигация по параграфам/пустым строкам (без конфликтов с Alt+Shift)
(global-set-key (kbd "C-<up>")   'backward-paragraph)
(global-set-key (kbd "C-<down>") 'forward-paragraph)
(global-set-key (kbd "C-c [")    'backward-paragraph)
(global-set-key (kbd "C-c ]")    'forward-paragraph)

;; Быстрое создание строки ниже/выше (аналог 'o' и 'O' в Vim)
(defun my/open-line-below ()
  "Создать новую строку ниже с правильным отступом (аналог 'o' в Vim)."
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defun my/open-line-above ()
  "Создать новую строку выше с правильным отступом (аналог 'O' в Vim)."
  (interactive)
  (beginning-of-line)
  (open-line 1))

(global-set-key (kbd "C-c o") 'my/open-line-below)
(global-set-key (kbd "C-c O") 'my/open-line-above)
(global-set-key (kbd "<S-return>") 'my/open-line-below)
(global-set-key (kbd "<C-S-return>") 'my/open-line-above)

;; =============================================================================
;; 4. МИНИБУФЕР И НАВИГАЦИЯ (VERTICO, ORDERLESS, CONSULT, MARGINALIA)
;; =============================================================================
;; Vertico: минималистичный вертикальный список дополнений в минибуфере
(use-package vertico
  :init
  (vertico-mode 1)
  :custom
  (vertico-cycle t)
  (vertico-count 12))

;; Orderless: раздельный поиск (вводите слова через пробел в любом порядке)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia: информативные подсказки в минибуфере (размер файла, тип, хоткеи, дока)
(use-package marginalia
  :init
  (marginalia-mode 1))

;; Consult: улучшенные команды поиска, буферов и навигации
(use-package consult
  :bind (;; Замена стандартного C-s на мгновенный превью-поиск по строкам
         ("C-s" . consult-line)
         ;; Удобное переключение буферов с превью
         ("C-x b" . consult-buffer)
         ;; Просмотр истории копирования (kill-ring) с возможностью выбора
         ("M-y" . consult-yank-pop)
         ;; Быстрый переход на строку
         ("M-g g" . consult-goto-line)
         ;; Переход к функциям / заголовкам внутри файла (imenu)
         ("M-g i" . consult-imenu)
         ;; Поиск по всему проекту через ripgrep
         ("C-c s p" . consult-ripgrep)))

;; Corfu: легкое и быстрое всплывающее окно автодополнения кода в буфере
(use-package corfu
  :custom
  (corfu-auto t)                 ; Показывать автодополнение автоматически
  (corfu-auto-delay 0.15)        ; Задержка перед показом (сек)
  (corfu-auto-prefix 2)          ; Начинать дополнять после 2 символов
  (corfu-cycle t)                ; Циклический перебор списка
  :init
  (global-corfu-mode 1))

;; Which-Key: подсказка доступных комбинаций клавиш при паузе (в Emacs 30 встроен)
(when (fboundp 'which-key-mode)
  (setq which-key-idle-delay 0.4)
  (which-key-mode 1))

;; =============================================================================
;; 5. MULTIPLE-CURSORS И УДОБНЫЙ МОНТАЖ ТЕКСТА
;; =============================================================================
(use-package multiple-cursors
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m l" . mc/edit-lines)))

;; Avy: мгновенные прыжки по символам и словам на экране (аналог f/t и Leap/Flash в Neovim)
(use-package avy
  :bind (("C-c f" . avy-goto-char-in-line) ; Точный аналог 'f' в Vim (в пределах строки)
         ("M-j"   . avy-goto-char-timer)   ; Прыжок в любую точку экрана (вводите 1-2 буквы)
         ("C-c j" . avy-goto-char)         ; Прыжок по 1 символу на всем экране
         ("C-c w" . avy-goto-word-1)))     ; Прыжок к слову по первой букве

;; =============================================================================
;; 6. ЯЗЫКИ ПРОГРАММИРОВАНИЯ И ФОРМАТЫ
;; =============================================================================

;; Встроенный LSP клиент (Eglot)
(use-package eglot
  :ensure nil
  :hook ((c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (python-mode . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)))

;; --- C / C++ ---
(use-package cc-mode
  :ensure nil
  :config
  (setq-default c-basic-offset 4)
  (setq c-default-style "linux"))

;; --- ASM (MASM) ---
(use-package asm-mode
  :ensure nil
  :mode ("\\.\\(asm\\|inc\\|masm\\)\\'" . asm-mode)
  :hook (asm-mode . (lambda ()
                      ;; В MASM комментарии начинаются с точки с запятой ';'
                      (setq asm-comment-char ?\;)
                      (setq tab-width 8)
                      (setq indent-tabs-mode nil))))

;; --- Python ---
(use-package python
  :ensure nil
  :custom
  (python-indent-offset 4)
  (python-indent-guess-indent-offset nil))

;; --- Markdown ---
(use-package markdown-mode
  :mode ("\\.\\(?:md\\|markdown\\)\\'" . markdown-mode)
  :custom
  (markdown-header-scaling t))

;; --- LaTeX (AUCTeX) ---
(use-package tex
  :ensure auctex
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t))

;; =============================================================================
;; 7. УПРАВЛЕНИЕ ПРОЕКТАМИ И GIT (PROJECT.EL & MAGIT)
;; =============================================================================
;; Встроенный project.el: C-x p f (поиск файла в проекте), C-x p p (сменить проект)
(use-package project
  :ensure nil)

;; Легендарный Magit для работы с Git
(use-package magit
  :bind ("C-x g" . magit-status))

;; =============================================================================
;; 8. СБОРКА, ЗАПУСК И ТЕРМИНАЛ (COMPILE & TERMINAL)
;; =============================================================================
;; Автоматическая прокрутка вывода компиляции
(setq compilation-scroll-output t)

;; Быстрые клавиши сборки и перезапуска (как у Tsoding / в IDE)
(global-set-key (kbd "<f5>") 'compile)
(global-set-key (kbd "<f6>") 'recompile)
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-c r") 'recompile)

;; Функция открытия терминала в нижнем сплите
(defun my/open-terminal-bottom ()
  "Открыть терминал (eshell) в нижней части экрана высотой в 12 строк."
  (interactive)
  (let ((term-window (split-window-below -12)))
    (select-window term-window)
    (eshell)))

(global-set-key (kbd "C-c t") 'my/open-terminal-bottom)

;; Функция открытия файла-шпаргалки в соседнем сплите
(defun my/open-cheat-sheet ()
  "Открыть файл-шпаргалку по Emacs."
  (interactive)
  (find-file-other-window "~/EMACS_CHEAT_SHEET.md"))

(global-set-key (kbd "C-c h") 'my/open-cheat-sheet)

(provide 'init)
;;; init.el ends here
