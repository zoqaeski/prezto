#
# Interactive shell bookmarks with FZF
#
# Adapted from 
# - http://dmitryfrank.com/articles/shell_shortcuts
# - https://github.com/urbainvaes/fzf-marks
#
# Authors:
#	Robbie Smith <zoqaeski@gmail.com>
#	Urban Vaes <https://github.com/urbainvaes>
#

if [[ -z $BOOKMARKS_FILE ]] ; then
    export BOOKMARKS_FILE="$HOME/.bookmarks"
fi

if [[ ! -f $BOOKMARKS_FILE ]]; then
    touch $BOOKMARKS_FILE
fi

fzf-bookmark-jump() {
    local jumpline jumpdir

    jumpline=$(cat ${BOOKMARKS_FILE} | $(__fzfcmd) --bind=ctrl-y:accept --tac)
    if [[ -n ${jumpline} ]]; then
        jumpdir=$(echo $jumpline | awk '{print $3}' | sed "s#~#$HOME#")
        # sed -i --follow-symlinks "\#${jumpline}#d" $BOOKMARKS_FILE
        # cd ${jumpdir} && echo ${jumpline} >> $BOOKMARKS_FILE
		cd ${jumpdir}
    fi
    zle && zle reset-prompt
}
zle -N fzf-bookmark-jump

fzf-bookmark() {
    echo $1 : $(pwd) >> $BOOKMARKS_FILE
}
zle -N fzf-bookmark

dmark()  {
    local marks_to_delete line

    marks_to_delete=$(cat $BOOKMARKS_FILE | $(__fzfcmd) -m --bind=ctrl-y:accept,ctrl-t:toggle-up --tac)

    if [[ -n ${marks_to_delete} ]]; then
        while read -r line; do
            sed -i --follow-symlinks "\#${line}#d" $BOOKMARKS_FILE
        done <<< "$marks_to_delete"

        echo "** The following marks were deleted **"
        echo ${marks_to_delete}
    fi
}


