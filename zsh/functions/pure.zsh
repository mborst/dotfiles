# Pure
# by Sindre Sorhus
# https://github.com/sindresorhus/pure
# MIT License

# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
prompt_pure_human_time_to_var() {
	local human=" " total_seconds=$1 var=$2
	local days=$(( total_seconds / 60 / 60 / 24 ))
	local hours=$(( total_seconds / 60 / 60 % 24 ))
	local minutes=$(( total_seconds / 60 % 60 ))
	local seconds=$(( total_seconds % 60 ))
	(( days > 0 )) && human+="${days}d "
	(( hours > 0 )) && human+="${hours}h "
	(( minutes > 0 )) && human+="${minutes}m "
	human+="${seconds}s"

	# store human readable time in variable as specified by caller
	typeset -g "${var}"="${human}"
}

# stores (into prompt_pure_cmd_exec_time) the exec time of the last command if set threshold was exceeded
prompt_pure_check_cmd_exec_time() {
	integer elapsed
	(( elapsed = EPOCHSECONDS - ${prompt_pure_cmd_timestamp:-$EPOCHSECONDS} ))
	prompt_pure_cmd_exec_time=
	(( elapsed > ${PURE_CMD_MAX_EXEC_TIME:=5} )) && {
		prompt_pure_human_time_to_var $elapsed "prompt_pure_cmd_exec_time"
	}
}

prompt_pure_clear_screen() {
	# enable output to terminal
	zle -I
	# clear screen and move cursor to (0, 0)
	print -n '\e[2J\e[0;0H'
	# print preprompt
	prompt_pure_preprompt_render precmd
}

prompt_pure_set_title() {
	# emacs terminal does not support settings the title
	(( ${+EMACS} )) && return

	# tell the terminal we are setting the title
	print -n '\e]0;'
	# show hostname if connected through ssh
	[[ -n $SSH_CONNECTION ]] && print -Pn '(%m) '
	case $1 in
		expand-prompt)
			print -Pn $2;;
		ignore-escape)
			print -rn $2;;
	esac
	# end set title
	print -n '\a'
}

prompt_pure_preexec() {
	prompt_pure_cmd_timestamp=$EPOCHSECONDS

	# shows the current dir and executed command in the title while a process is active
	prompt_pure_set_title 'ignore-escape' "$PWD:t: $2"
}

# string length ignoring ansi escapes
prompt_pure_string_length_to_var() {
	local str=$1 var=$2 length
	# perform expansion on str and check length
	length=$(( ${#${(S%%)str//(\%([KF1]|)\{*\}|\%[Bbkf])}} ))

	# store string length in variable as specified by caller
	typeset -g "${var}"="${length}"
}

prompt_pure_preprompt_render() {
	# store the current prompt_subst setting so that it can be restored later
	local prompt_subst_status=$options[prompt_subst]

	# make sure prompt_subst is unset to prevent parameter expansion in preprompt
	setopt local_options no_prompt_subst

	# check that no command is currently running, the preprompt will otherwise be rendered in the wrong place
	[[ -n ${prompt_pure_cmd_timestamp+x} && "$1" != "precmd" ]] && return

	# construct preprompt, beginning with path
	local preprompt="%F{blue}%~%f"
	# username and machine if applicable
	preprompt+=$prompt_pure_username
	# execution time
	preprompt+="%F{yellow}${prompt_pure_cmd_exec_time}%f"

	# make sure prompt_pure_last_preprompt is a global array
	typeset -g -a prompt_pure_last_preprompt

	# if executing through precmd, do not perform fancy terminal editing
	if [[ "$1" == "precmd" ]]; then
		print -P "${preprompt}"
	else
		# only redraw if the expanded preprompt has changed
		[[ "${prompt_pure_last_preprompt[2]}" != "${(S%%)preprompt}" ]] || return

		# calculate length of preprompt and store it locally in preprompt_length
		integer preprompt_length lines
		prompt_pure_string_length_to_var "${preprompt}" "preprompt_length"

		# calculate number of preprompt lines for redraw purposes
		(( lines = ( preprompt_length - 1 ) / COLUMNS + 1 ))

		# calculate previous preprompt lines to figure out how the new preprompt should behave
		integer last_preprompt_length last_lines
		prompt_pure_string_length_to_var "${prompt_pure_last_preprompt[1]}" "last_preprompt_length"
		(( last_lines = ( last_preprompt_length - 1 ) / COLUMNS + 1 ))

		# clr_prev_preprompt erases visual artifacts from previous preprompt
		local clr_prev_preprompt
		if (( last_lines > lines )); then
			# move cursor up by last_lines, clear the line and move it down by one line
			clr_prev_preprompt="\e[${last_lines}A\e[2K\e[1B"
			while (( last_lines - lines > 1 )); do
				# clear the line and move cursor down by one
				clr_prev_preprompt+='\e[2K\e[1B'
				(( last_lines-- ))
			done

			# move cursor into correct position for preprompt update
			clr_prev_preprompt+="\e[${lines}B"
		# create more space for preprompt if new preprompt has more lines than last
		elif (( last_lines < lines )); then
			# move cursor using newlines because ansi cursor movement can't push the cursor beyond the last line
			printf $'\n'%.0s {1..$(( lines - last_lines ))}
		fi

		# disable clearing of line if last char of preprompt is last column of terminal
		local clr='\e[K'
		(( COLUMNS * lines == preprompt_length )) && clr=

		# modify previous preprompt
		print -Pn "${clr_prev_preprompt}\e[${lines}A\e[${COLUMNS}D${preprompt}${clr}\n"

		if [[ $prompt_subst_status = 'on' ]]; then
			# re-enable prompt_subst for expansion on PS1
			setopt prompt_subst
		fi

		# redraw prompt (also resets cursor position)
		zle && zle .reset-prompt
	fi

	# store both unexpanded and expanded preprompt for comparison
	prompt_pure_last_preprompt=("$preprompt" "${(S%%)preprompt}")
}

prompt_pure_precmd() {
	# check exec time and store it in a variable
	prompt_pure_check_cmd_exec_time

	# set timestamp so preprompt_render knows a command is not running
	prompt_pure_cmd_timestamp=

	# shows the full path in the title
	prompt_pure_set_title 'expand-prompt' '%~'

	# print the preprompt
	prompt_pure_preprompt_render "precmd"

	# remove the prompt_pure_cmd_timestamp, indicating that precmd has completed
	unset prompt_pure_cmd_timestamp
}

prompt_pure_setup() {
	# prevent percentage showing up if output doesn't end with a newline
	export PROMPT_EOL_MARK=''

	prompt_opts=(subst percent)

	zmodload zsh/datetime
	zmodload zsh/zle
	zmodload zsh/parameter

	autoload -Uz add-zsh-hook

	add-zsh-hook precmd prompt_pure_precmd
	add-zsh-hook preexec prompt_pure_preexec

	# if the user has not registered a custom zle widget for clear-screen,
	# override the builtin one so that the preprompt is displayed correctly when
	# ^L is issued.
	if [[ $widgets[clear-screen] == 'builtin' ]]; then
		zle -N clear-screen prompt_pure_clear_screen
	fi

	# show username@host if logged in through SSH
	[[ "$SSH_CONNECTION" != '' ]] && prompt_pure_username=' %F{242}%n@%m%f'

	# show username@host if root, with username in white
	[[ $UID -eq 0 ]] && prompt_pure_username=' %F{white}%n%f%F{242}@%m%f'

	# prompt turns red if the previous command didn't exit with 0
	PROMPT="%(?.%F{magenta}.%F{red})${PURE_PROMPT_SYMBOL:-❯}%f "
}

prompt_pure_setup "$@"
