#!/bin/bash
# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later
# Credit Salvogiangri

source "$dir_work/scripts/utils/utils.sh"

# SMALI_PATCH <base_name> <smali_path> <operation> [method] [value] [replacement]
# Dynamically patches the provided smali file with the supplied arguments.
#
# Arguments:
# - base_name: The name of the decompiled directory (e.g., SecSettings, services)
# - smali_path: Path to the smali file relative to the decompiled directory root
# - operation: null, remove, replace, replaceall, return, strip
#
# Usage:
# - null <method>: Deletes the contents of supplied method in the provided smali file
# - remove: Deletes the provided smali file entirely
# - replace <method> <value> <replacement>: Replaces the occurence of the supplied string in the provided method
# - replaceall <value> <replacement>: Replaces all the occurences of the supplied string in the whole smali file
# - return <method> <value>: Patches the supplied method in order to return the desidered value
# - strip <method>: Deletes the supplied method in the provided smali file
SMALI_PATCH()
{
    check_param "BASE_NAME" "$1" || return 1
    check_param "SMALI" "$2" || return 1
    check_param "OPERATION" "$3" || return 1

    local BASE_NAME="$1"
    local SMALI="$2"
    local OPERATION="$3"
    
    local DECOMPILE_DIR="${dir_work}/out/apktool/working"
    local FILE_PATH="$DECOMPILE_DIR/$BASE_NAME"

    if [[ "$OPERATION" != "null" ]] && [[ "$OPERATION" != "remove" ]] && \
        [[ "$OPERATION" != "replace" ]] && [[ "$OPERATION" != "replaceall" ]] && \
            [[ "$OPERATION" != "return" ]] && [[ "$OPERATION" != "strip" ]]; then
        log_error "Operation not valid: \"$OPERATION\""
        return 1
    fi

    if [[ "$OPERATION" == "replaceall" ]]; then
        check_param "VALUE" "$4" || return 1
        local VALUE="$4"
        local REPLACEMENT="$5"
    elif [[ "$OPERATION" != "remove" ]]; then
        check_param "METHOD" "$4" || return 1
        local METHOD="$4"

        if ! [[ "$METHOD" =~ ^[A-Za-z0-9\$\<\-].*\(.*\).* ]]; then
            log_error "Method name not valid: \"$METHOD\""
            return 1
        fi
    fi

    if [[ "$OPERATION" == "return" ]]; then
        check_param "VALUE" "$5" || return 1
        local VALUE="$5"
    fi

    if [[ "$OPERATION" == "replace" ]]; then
        check_param "VALUE" "$5" || return 1
        local VALUE="$5"
        local REPLACEMENT="$6"
    fi

    # Check if provided smali exists
    if [ ! -f "$FILE_PATH/$SMALI" ]; then
        log_error "Smali not found: \"$BASE_NAME/$SMALI\""

        local MATCHES
        MATCHES="$(find "$FILE_PATH" -type f -name "*${SMALI##*/}")"

        if [ "$MATCHES" ]; then
            echo -e "\n\033[0;31mPossible matches?" >&2
            echo -e -n "$(head -n 10 <<< "${MATCHES//$FILE_PATH\//    }")" >&2
            [ "$(wc -l <<< "$MATCHES")" -gt 10 ] && \
                echo -e -n "\n    ...and other $(($(wc -l <<< "$MATCHES") - 10)) matches"  >&2
            echo -e "\033[0m" >&2
        fi

        return 1
    elif [[ "$OPERATION" == "remove" ]]; then
        local USED
        USED="$(find "$FILE_PATH" ! -path "*$SMALI" -type f -exec grep -r -n -- "$(cut -d "." -f "1" <<< "${SMALI#*/}");" {} \+ || true)"
        USED="$(cut -d ":" -f 1-2 <<< "$USED")"

        if [ "$USED" ]; then
            log_error "Cannot remove \"$SMALI\" from $BASE_NAME as it is used elsewhere"
            echo -e "\n\033[0;31mMatches:" >&2
            echo -e -n "$(head -n 10 <<< "${USED//$FILE_PATH\//    - }")" >&2
            [ "$(wc -l <<< "$USED")" -gt 10 ] && \
                echo -e -n "\n    ...and other $(($(wc -l <<< "$USED") - 10)) matches" >&2
            echo -e "\033[0m" >&2
            return 1
        fi

        log_warning "- Removing \"$SMALI\" from $BASE_NAME"
        eval "LC_ALL=C rm \"$FILE_PATH/${SMALI//$/\\$}\"" || return 1
        return 0
    fi

    # Check if provided method is method and exists inside smali
    if ! grep "^\.method.*" "$FILE_PATH/$SMALI" | grep -q -F -- "$METHOD" "$FILE_PATH/$SMALI"; then
        log_error "Method \"$METHOD\" not found in $BASE_NAME/$SMALI"

        local MATCHES
        MATCHES="$(grep -r "^\.method.*$METHOD" "$FILE_PATH")"

        if [ "$MATCHES" ]; then
            echo -e "\n\033[0;31mPossible matches?" >&2
            echo -e "$(head -n 10 <<< "${MATCHES//$FILE_PATH\//    - }")" >&2
            [ "$(wc -l <<< "$MATCHES")" -gt 10 ] && \
                echo -n "    ...and other $(($(wc -l <<< "$MATCHES") - 10)) matches" >&2
            echo -e "\033[0m" >&2
        fi

        return 1
    fi

    local BEFORE
    local AFTER

    BEFORE="$(sha1sum "$FILE_PATH/$SMALI" | cut -d " " -f 1)"

    # Remove the method completely
    if [[ "$OPERATION" == "strip" ]]; then
        local USED
        USED="$(grep -r -n -- "invoke.*$(basename "$SMALI" | cut -d "." -f "1");" "$FILE_PATH")"
        USED="$(grep -F "$METHOD" <<< "$USED" | cut -d ":" -f 1-2)"

        if [ "$USED" ]; then
            log_error "Cannot strip method \"$METHOD\" in $BASE_NAME/$SMALI as it is used elsewhere"
            echo -e "\n\033[0;31mMatches:" >&2
            echo -e -n "$(head -n 10 <<< "${USED//$FILE_PATH\//    - }")" >&2
            [ "$(wc -l <<< "$USED")" -gt 10 ] && \
                echo -e -n "\n    ...and other $(($(wc -l <<< "$USED") - 10)) matches" >&2
            echo -e "\033[0m" >&2
            return 1
        fi

        log_warning "- Stripping method \"$METHOD\" in $BASE_NAME/$SMALI"

        awk -v FN="$METHOD" '
            BEGIN { inside = 0; skip = 0 }
            /^\.method/ && index($0, FN) {
                inside = 1
                next
            }
            inside && /^\.end method/ {
                inside = 0
                skip = 1
                next
            }
            inside { next }
            {
                if (skip) {
                    skip = 0
                    next
                }
                print
            }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI" | cut -d " " -f 1)"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            log_error "Failed to strip method \"$METHOD\" in $BASE_NAME/$SMALI"
            return 1
        fi
    # Remove the contents of method, leave declaration
    elif [[ "$OPERATION" == "null" ]]; then
        local RET
        local LOC=".locals 0"

        RET="${METHOD#*)}"
        if [[ "$RET" != "V" ]]; then
            log_error "Cannot nullify non-void method \"$METHOD\" in $BASE_NAME/$SMALI"
            return 1
        else
            RET="return-void"
        fi

        log_warning "- Nullifying method \"$METHOD\" in $BASE_NAME/$SMALI"

        awk -v FN="$METHOD" -v LOC="$LOC" -v RET="$RET" '
            BEGIN { inside = 0 }
            /^\.method/ && index($0, FN) {
                print
                print "    " LOC
                print "    "
                print "    " RET
                inside = 1
                next
            }
            inside && /^\.end method/ {
                print
                inside = 0
                next
            }
            inside { next }
            { print }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI" | cut -d " " -f 1)"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            log_error "Failed to nullify method \"$METHOD\" in $BASE_NAME/$SMALI"
            return 1
        fi
    # Replace the method contents with a single return
    elif [[ "$OPERATION" == "return" ]]; then
        local RET
        local REG
        local LOC

        # Decide on register
        REG="p0"
        LOC=".locals 0"
        if [[ "$(grep "^\.method.*" "$FILE_PATH/$SMALI" | \
                    grep -F -- "$METHOD" "$FILE_PATH/$SMALI")" == *" static "* ]] && \
                [[ "$METHOD" == *"()"* ]]; then
            REG="v0"
            LOC=".locals 1"
        fi

        # Decide return type
        RET="${METHOD#*)}"
        if [[ "$RET" == "V" ]]; then
            log_error "Cannot change return value of void method \"$METHOD\" in $BASE_NAME/$SMALI"
            return 1
        elif [[ "$RET" == "Ljava/lang/String;" ]]; then
            VALUE="\"$VALUE\""
            RET="return-object $REG"
        elif [[ "$RET" =~ ^\[*[ZBCSIJFD]$ ]]; then
            # Boolean type
            if [[ "$RET" == "Z" ]]; then
                if [[ "$VALUE" == "true" ]]; then
                    VALUE="0x1"
                elif [[ "$VALUE" == "false" ]]; then
                    VALUE="0x0"
                fi

                if [[ "$VALUE" != "0x0" ]] && [[ "$VALUE" != "0x1" ]]; then
                    log_error "Cannot use a constant value for method \"$METHOD\" in $BASE_NAME/$SMALI"
                    return 1
                fi
            fi

            # Convert decimal value to hex
            if [[ "$VALUE" =~ ^-?[0-9]+$ ]]; then
                VALUE="0x$(printf "%x" "$VALUE")"
            fi

            if [[ "$VALUE" =~ ^\".*\"$ ]]; then
                log_error "Cannot use a string value for method \"$METHOD\" in $BASE_NAME/$SMALI"
                return 1
            fi

            # Long type
            if [[ "$RET" == "J" ]]; then
                RET="return-wide $REG"
            else
                RET="return $REG"
            fi
        else
            if [[ "$VALUE" == "null" ]]; then
                VALUE="0x0"
            fi

            if [[ "$VALUE" != "0x0" ]]; then
                log_error "Cannot use a constant value for method \"$METHOD\" in $BASE_NAME/$SMALI"
                return 1
            fi

            RET="return-object $REG"
        fi

        # Decide what to return
        local hex
        local num
        if [[ "$VALUE" =~ ^-?0x[0-9a-fA-F]+$ ]]; then
            # Hexadecimal value
            if [[ "$VALUE" == "-"* ]]; then
                hex="${VALUE#-0x}"
                num="$((-16#$hex))"
            else
                hex="${VALUE#0x}"
                num="$((16#$hex))"
            fi
            if [[ "$RET" == "return-wide"* ]]; then
                VALUE="const-wide/16 $REG, $VALUE"
            elif [ "$num" -gt "-8" ] && [ "$num" -lt "8" ]; then
                VALUE="const/4 $REG, $VALUE"
            else
                VALUE="const/16 $REG, $VALUE"
            fi
        elif [[ "$VALUE" =~ ^\".*\"$ ]]; then
            # String value
            VALUE="const-string $REG, $VALUE"
        else
            log_error "Return value for method \"$METHOD\" in $BASE_NAME/$SMALI not valid: \"$VALUE\""
            return 1
        fi

        log_warning "- Replacing return value of method \"$METHOD\" in $BASE_NAME/$SMALI to \"$VALUE\""

        awk -v FN="$METHOD" -v LOC="$LOC" -v VAL="$VALUE" -v RET="$RET" '
            BEGIN { inside = 0 }
            /^\.method/ && index($0, FN) {
                print
                print "    " LOC
                print ""
                print "    " VAL
                print ""
                print "    " RET
                inside = 1
                next
            }
            inside && /^\.end method/ {
                print
                inside = 0
                next
            }
            inside { next }
            { print }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI" | cut -d " " -f 1)"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            log_error "Failed to replace return value of method \"$METHOD\" in $BASE_NAME/$SMALI to \"$VALUE\""
            return 1
        fi
    # Replace a string with another string inside the method
    # or Replace a line with another line inside the method
    elif [[ "$OPERATION" == "replace" ]]; then
        log_warning "- Replacing value \"$VALUE\" of method \"$METHOD\" in $BASE_NAME/$SMALI with \"$REPLACEMENT\""

        awk -v FN="$METHOD" -v STR="$VALUE" -v REP="$REPLACEMENT" '
            BEGIN { inside = 0; isline = (index(REP, "\n") > 0) }
            /^\.method/ && index($0, FN) { inside = 1 }
            inside {
                if (isline) {
                    if (index($0, STR)) {
                        gsub(/\\n/, "\n", REP)
                        print REP
                        next
                    }
                } else if ($0 ~ /^[[:space:]]*const-string(\/jumbo)?/) {
                    sub("\"" STR "\"", "\"" REP "\"")
                } else {
                    line = $0
                    gsub(/^[ \t]+|[ \t]+$/, "", line)

                    if (line == STR) {
                        match($0, /^[ \t]+/)
                        indent = substr($0, RSTART, RLENGTH)
                        $0 = indent REP
                    }
                }
            }
            inside && /^\.end method/ { inside = 0 }
            { print }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI" | cut -d " " -f 1)"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            log_error "Failed to replace value \"$VALUE\" of method \"$METHOD\" in $BASE_NAME/$SMALI with \"$REPLACEMENT\""
            return 1
        fi
    # Replace all occurrences of value with another
    #TODO: Improve, add more failchecks, currently it is unsafe
    elif [[ "$OPERATION" == "replaceall" ]]; then
        log_warning "- Replacing all occurrences of \"$VALUE\" with \"$REPLACEMENT\" in $BASE_NAME/$SMALI"

        eval "sed -i \"s|$VALUE|$REPLACEMENT|g\" \"$FILE_PATH/${SMALI//$/\\$}\"" || return 1

        AFTER="$(sha1sum "$FILE_PATH/$SMALI" | cut -d " " -f 1)"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            log_error "Failed to replace all occurrences of \"$VALUE\" with \"$REPLACEMENT\" in $BASE_NAME/$SMALI"
            return 1
        fi
    fi

    return 0
}
