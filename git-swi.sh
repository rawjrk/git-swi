git-swi() {
    local FIRST_ARG='SEARCH_PHRASE';
    local SECOND_ARG='OPTION_NUMBER';
    local USAGE_MSG="Usage: git-swi $FIRST_ARG [$SECOND_ARG]";

    if [[ $# -lt 1 || $# -gt 2 ]]; then
        echo "$USAGE_MSG";
        return 1;
    fi;

    local SEARCH_PHRASE="$1";
    local OPTION_NUMBER="$2";

    local FIRST_CHAR=$(echo "$SEARCH_PHRASE" | cut -c1);
    if [[ "$FIRST_CHAR" == '-' ]]; then
        echo "Error: $FIRST_ARG must not start with dash!";
        return 1;
    fi;

    local OPTION_EXISTS=false;
    if [[ -n "$OPTION_NUMBER" ]]; then
        OPTION_EXISTS=true;
    fi;

    if $OPTION_EXISTS && [[ ! "$OPTION_NUMBER" =~ [0-9]+$ ]]; then
        echo "Error: $SECOND_ARG must be an integer!";
        return 1;
    fi;

    local BRANCH_RES;
    if ! BRANCH_RES="$(git branch)"; then
        return $?;
    fi;

    local LOOKUP_RES="$(
        echo "$BRANCH_RES" \
            | grep -F "$SEARCH_PHRASE" \
            | cut -c 3-
    )";

    local CHAR_COUNT="$(echo "$LOOKUP_RES" | wc -c | tr -d ' ')";

    if [[ $CHAR_COUNT -le 1 ]]; then
        echo "Error: Zero matches for '$SEARCH_PHRASE'" >&2;
        return 1;
    fi;

    local LINE_COUNT="$(echo "$LOOKUP_RES" | wc -l | tr -d ' ')";

    if [[ $LINE_COUNT -gt 1 ]]; then
        local OPTION_IN_RANGE=false;

        if $OPTION_EXISTS \
           && [[ $OPTION_NUMBER -ge 1 ]] \
           && [[ $OPTION_NUMBER -le $LINE_COUNT ]]; then
            OPTION_IN_RANGE=true;
        fi;

        if $OPTION_EXISTS && $OPTION_IN_RANGE; then
            git switch "$(
                echo -e "$LOOKUP_RES" \
                    | sed -n "${OPTION_NUMBER}p"
            )";
            return 0;
        fi;

        if $OPTION_EXISTS && ! $OPTION_IN_RANGE; then
            echo -n "Error: $SECOND_ARG '$OPTION_NUMBER'"
            echo " outside of range: 1..$LINE_COUNT";
        else
            echo "Error: Multiple matches for '$SEARCH_PHRASE',"
            echo "Specify $SECOND_ARG to choose from:";
        fi;

        i=1;
        while IFS= read -r line; do
            echo "  $i: $line";
            i=$(( i + 1 ));
        done <<< "$LOOKUP_RES";

        #echo "$USAGE_MSG";
        return 1;
    fi;

    if $OPTION_EXISTS; then
        echo "Warn: Single match, $SECOND_ARG ignored";
    fi;
    git switch "$LOOKUP_RES";
}
