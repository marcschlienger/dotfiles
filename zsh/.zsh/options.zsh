# changing directories
setopt		AUTO_CD					\
			AUTO_PUSHD				\
			PUSHD_IGNORE_DUPS		\
			PUSHD_SILENT

# completion
setopt		ALWAYS_TO_END			\
			AUTO_LIST				\
			AUTO_MENU				\
			AUTO_NAME_DIRS			\
			AUTO_PARAM_SLASH		\
			AUTO_REMOVE_SLASH		\
			BASH_AUTO_LIST			\
			COMPLETE_ALIASES		\
			COMPLETE_IN_WORD		\
			GLOB_COMPLETE			\
			LIST_AMBIGUOUS			\
			LIST_PACKED				\
			LIST_TYPES

# expansion and globbing
setopt		BAD_PATTERN				\
			EXTENDED_GLOB			\
			GLOB					\
			GLOB_DOTS
unsetopt    NOMATCH

# history
setopt		APPEND_HISTORY			\
			BANG_HIST				\
			INC_APPEND_HISTORY		\
			HIST_SAVE_NO_DUPS		\
			HIST_REDUCE_BLANKS		\
			HIST_VERIFY				\
			HIST_IGNORE_ALL_DUPS    \
            SHARE_HISTORY

# input/ouput
setopt		CORRECT					\
			PATH_DIRS				\
			PRINT_EXIT_VALUE
unsetopt	CLOBBER					\
			MAIL_WARNING			\
			BEEP

# job control
setopt		NOTIFY
unsetopt	BG_NICE					\
			HUP

# prompting
setopt		PROMPT_BANG				\
			PROMPT_PERCENT			\
			PROMPT_SUBST

