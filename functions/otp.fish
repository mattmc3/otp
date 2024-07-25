function otp --description "One-time passwords"
    # variables
    if not set -q OTP_HOME
        set -q XDG_DATA_HOME
        and set -gx OTP_HOME $XDG_DATA_HOME/otp
        or set -gx OTP_HOME $HOME/.local/share/otp
    end
    set -l dirname
    if not test -e $OTP_HOME
        mkdir -p $dirname
        chmod 700 $dirname
    end

    # requirements
    if not type -q oathtool
        echo >&2 "otp: 'oathtool' not found. Install oathtool or oath-toolkit, depending on your OS."
        return 1
    end
    if not type -q gpg
        echo >&2 "otp: 'gpg' not found. Install, and create a key with 'gpg --gen-key' if you don't already have one."
        return 1
    end
    if not set -q OTP_GPG_KEYS
        echo >&2 "otp: 'OTP_GPG_KEYS' variable not set."
        return 1
    end

    # declare vars
    set -l usage "usage: otp [-h | --help] [-l | --list] [-a | --add] [-r | --remove] [--rekey] <key>"
    set -l recp
    set -l recipients
    for recp in (string split ' ' $OTP_GPG_KEYS)
        set -a recipients --recipient $recp
    end

    # parse arguments
    argparse --name=otp h/help l/list a/add r/remove rekey -- $argv
    or return

    if test -n "$_flag_help"
        # help
        echo $usage
        return
    else if test -n "$_flag_list"
        # list
        set -l files $OTP_HOME/*.otp.asc
        if test (count $files) -eq 0
            echo >&2 "otp: No one-time password keys found."
            return 1
        end
        for file in $files
            path basename $file | string replace '.otp.asc' ''
        end
        return
    else if test -n "$_flag_rekey"
        # rekey
        set -l file
        for file in $OTP_HOME/*.otp.asc
            set -l totpkey (gpg --quiet --decrypt $file)
            mv -f $file $file.bak
            echo "$totpkey" | gpg $recipients --armor --encrypt --output $file
            command rm -- $file.bak
        end
    else if test -z "$argv"
        echo >&2 "otp: Expecting <key> argument."
        echo >&2 $usage
        return 1
    else if test -n "$_flag_add"
        read -s -l key --prompt-str="Enter the otp key for '$argv': "
        command rm -f $OTP_HOME/$argv.otp.asc
        echo "$key" | gpg $recipients --armor --encrypt --output $OTP_HOME/$argv.otp.asc
    else if not test -e "$OTP_HOME/$argv.otp.asc"
        echo >&2 "otp: Key not found '$argv'."
        return 1
    else if test -n "$_flag_remove"
        command rm -f $OTP_HOME/$argv.otp.asc
    else
        set -l totpkey (gpg $recipients --quiet --decrypt $OTP_HOME/$argv.otp.asc)
        oathtool --totp --b $totpkey | tee /dev/stderr | pbcopy
    end
end
