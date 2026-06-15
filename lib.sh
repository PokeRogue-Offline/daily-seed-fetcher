# Shared shell functions for daily-seed-fetcher.
#
# Source this file to get access to log_msg, e.g.:
#   . "$(dirname "$0")/lib.sh"

# log_msg writes a structured log line matching supercronic's logrus output:
#   time="2026-06-15T03:34:52Z" level=info msg="..."
#
# Usage: log_msg "your message here"
log_msg() {
  printf 'time="%s" level=info msg="%s"\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$1"
}
