parse_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  git branch 2>/dev/null | sed -n '/\* /s///p'
}
