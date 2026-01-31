# BRUCE shell helpers (manual-docs)
# Purpose: make copyback boundaries obvious in terminal output.
# Usage:
#   bruce_block <<'SH'
#   echo "hello"
#   SH

bruce_block() {
  printf '\n\033[1;35m========== BRUCE COPYBACK BEGIN ==========\033[0m\n'
  bash -lc "$(cat)"
  rc=$?
  printf '\033[1;35m=========== BRUCE COPYBACK END ===========\033[0m\n\n'
  return $rc
}
