function __otp_show_keys
    # Tokenize the current process, up to the cursor.
    # -o means tokenize, -p means current process only, -c means stop at cursor.
    set tokens (commandline -opc)
    test (count $tokens) -eq 1
    or contains -- '-r' $tokens
    or contains -- '--remove' $tokens
end

complete -c otp --no-files --exclusive -s "l" -l "list" -d "List available OTP keys"
complete -c otp --no-files --exclusive -s "h" -l "help" -d "Display OTP help"
complete -c otp --no-files --exclusive -s "a" -l "add" -d "Add OTP key"
complete -c otp --no-files --exclusive -s "r" -l "remove" -d "Remove OTP key" --arguments "(otp --list)"
complete -c otp --no-files --arguments "(otp --list)"
