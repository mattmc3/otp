0=${(%):-%N}
path+=(${0:a:h}/bin)

__otp_keys() {
  reply=($(otp --list))
}

compctl -K __otp_keys otp
