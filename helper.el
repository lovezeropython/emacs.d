;;; package --- Summary

;;; Commentary:

;;; Code:

(defvar help-message
  "== Help ==\
\n
Specific commands:
\n
C-x C-f         ->find-files.
M-l             ->eshell-history.
C-c h           ->helm-mini.
M-x             ->smex.
M-l             ->helm-locate.
M-t             ->helm-top.
C-x h           ->emacs-bindings-help.
C-c p d         ->display all dirs in the project.


== Help Map ==
key             binding
---             -------

C-x o           switch-window
C-x <up>        windmove-up
C-x <down>      windmove-down
C-x <right>     windmove-right
C-x <left>      windmove-left
C-c SPC         ace-jump-word-mode
C-c TAB         ace-jump-line-mode
C-c m           mark-next-like-this
C-c n           mark-previous-like-this
C-c ;           edit-lines
M-h             mark-paragraph
M-{             backward-paragraph
m-}             forward-paragraph
M-%             anzu-query-replace
C-M-%           anzu-query-replace-regexp
M-e             eshell
C-c e           run-ipython
C-x C-b         ibuffer
C-x C-a         ag-project
M <up/down>     drag-stuff
C-c x           expand-region
C-<up>          smart-up
C-<down>        smart-down
C-<left>        smart-backward
C-<right>       smart-forward
C-x C-r         open-recentf-file
C-c t           isend-send
C-c y           isend-associate
M-i             change-inner
M-o             change-outer
C-z             undo
C-c b           switch-to-previous-buffer
M-n             hold-line-scroll-up
M-p             hold-line-scroll-down
C-c v           func/class list
C-c f           toggle-fullscreen ; Only for GUI
C-c G           search github
C-c g           search google
C-c j           add or delete comment
C-c k           align-text by =
C-c w           hs-hide-block
C-c W           hs-show-block
C-c s           hs-hide-all
C-c S           hs-show-all
C-c c           hs-toggle-hiding
")

(defcustom help-scroll-amount nil
  "Scroll amount when scrolling other window in a help session."
  :type 'integer)

(defun help-internal (bufname insert-content-fn)
  "Show long message during `' session in BUFNAME.
INSERT-CONTENT-FN is the function that insert
text to be displayed in BUFNAME."
  (let ((winconf (current-frame-configuration)))
    (unwind-protect
         (progn
           (switch-to-buffer (get-buffer-create bufname))
           (delete-other-windows)
           (erase-buffer)
           (funcall insert-content-fn)
           (setq cursor-type nil)
           (goto-char 1)
           (help-event-loop))
      (set-frame-configuration winconf))))

(defun help-event-loop ()
  (let ((prompt (propertize
                 "[SPC,C-v,down:NextPage b,M-v,up:PrevPage C-s/r:Isearch Other:Exit]"))
        (scroll-error-top-bottom t))
    (condition-case _err
        (cl-loop for event = (read-key prompt) do
              (cl-case event
                ((?\C-v ? down) (scroll-up-command help-scroll-amount))
                ((?\M-v ?b up) (scroll-down-command help-scroll-amount))
                ((?\C-s)        (isearch-forward))
                ((?\C-r)        (isearch-backward))
                (t (cl-return))))
      (beginning-of-buffer (message "Beginning of buffer"))
      (end-of-buffer       (message "End of Buffer")))))

(defun my-help ()
  "Help."
  (interactive)
  (save-selected-window
    (help-internal " *My Help*"
    (lambda ()
       (insert help-message)))))

(defun help-window-base (command &optional scroll-amount)
  (setq scroll-amount (unless (eq scroll-amount 'noscroll)
                        help-scroll-amount))
  (with-selected-window (current-buffer)
    (funcall command scroll-amount)))

(defun help-scroll-window ()
  "Scroll help window upward."
  (interactive)
  (help-window-base 'scroll-up))

(defun help-scroll-window-down ()
  "Scroll other window downward."
  (interactive)
  (help-window-base 'scroll-down))