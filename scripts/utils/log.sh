#!/bin/bash
# ---------------------------------------------------------
# LichUI Logging System
# ---------------------------------------------------------

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Indentation variable (can be set by other scripts)
# LOG_INDENT=""

log_info()    { echo -e "${LOG_INDENT}${BLUE}[I]${NC} $1" >&2; }
log_success() { echo -e "${LOG_INDENT}${GREEN}[S]${NC} $1" >&2; }
log_warning() { echo -e "${LOG_INDENT}${YELLOW}[W]${NC} $1" >&2; }
log_error()   { echo -e "${LOG_INDENT}${RED}[E]${NC} $1" >&2; }

# Simple echo wrapper
log() {
    echo -e "$1"
}