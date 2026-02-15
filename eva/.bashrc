# -----------------------------------------------
# 🚀 Evangelion Terminal Prompt (by you + GPT)
# -----------------------------------------------

# 🧠 Evangelion Quote of the Day
EVA_QUOTES=(
  "Man fears the darkness, and so he scrapes away at the edges of it with fire."
  "The fate of destruction is also the joy of rebirth."
  "God's in his heaven. All's right with the world."
  "Anywhere can be paradise, as long as you have the will to live."
  "You won't die... I'll protect you."
  "The Eva series was created to usher in a new world."
  "There is no such thing as truth or lies. There is only what you believe."
  "This is the Human Instrumentality Project."
  "I am the vessel of SEELE’s wish."
  "I mustn't run away."
  "Sometimes you need a little wishful thinking to keep on living."
  "Part of growing up means finding a way to interact with others while distancing pain."
  "Mankind's greatest fear is mankind itself."
  "Anywhere can be a paradise as long as you have the will to live."
  "Don't make others suffer for your personal hatred."
  "Mankind fears the darkness, so he scrapes away at the edge of it with fire."
  "Pain is something man must endure in his heart."
)

# 🔁 Show one on shell startup
echo -e "\n Evangelion says: \"${EVA_QUOTES[$RANDOM % ${#EVA_QUOTES[@]}]}\"\n"

# 📥 Command to get another quote anytime
eva() {
  echo -e "\n EVA: \"${EVA_QUOTES[$RANDOM % ${#EVA_QUOTES[@]}]}\"\n"
}

# 💡 Define themes: [name:foreground:background]
THEMES=(
#  "EVA01:\[\033[1;92m\]:\[\033[48;5;129m\]"   # green on purple
# Add Sinji theme
  "REI:\[\033[1;97m\]:\[\033[48;5;69m\]"      # white on cool blue
  "LILITH:\[\033[1;97m\]:\[\033[48;5;60m\]"   # white on deep indigo
  "NERV:\[\033[1;97m\]:\[\033[48;5;160m\]"    # white on red
  "SEELE:\[\033[1;91m\]:\[\033[48;5;235m\]"   # soft red on dark
#  "KOWARU:\[\033[1;97m\]:\[\033[48;5;183m\]"  # white on rose gray 
  "ASUKA:\[\033[1;97m\]:\[\033[48;5;160m\]" # ASUKA THEME
)

# 🔁 Pick a random theme each time
pick_random_theme() {
    local random=$((RANDOM % ${#THEMES[@]}))
    IFS=":" read -r theme_name fg bg <<< "${THEMES[$random]}"
    export PROMPT_THEME_NAME="$theme_name"
    export PROMPT_FG="$fg"
    export PROMPT_BG="$bg"
}

# 🔴 Asuka theme for Python virtualenv
#ASUKA_TEXT="\[\033[1;97m\]"
#ASUKA_BG="\[\033[48;5;160m\]"
EVA01_TEXT="\[\033[1;92m\]"
EVA01_BG="\[\033[48;5;129m\]"

# 🧠 Top box with theme label, user@host, and time
get_box_info() {
    pick_random_theme
    local label="${PROMPT_FG}${PROMPT_BG} [$PROMPT_THEME_NAME] \[\033[0m\]"
    local userhost="${PROMPT_FG}${PROMPT_BG} \u@\h \[\033[0m\]"
    local timebox="${PROMPT_FG}${PROMPT_BG} \A \[\033[0m\]"
    echo -ne "$label─$userhost─$timebox"
}

# 🐍 If virtualenv active, show (env) in Asuka colors
get_venv_info() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        echo -ne "${EVA01_TEXT}${EVA01_BG} ($venv_name) \[\033[0m\]─"
    fi
}

# 📁 Show current path in themed box
get_box_path() {
    local dir="${PWD/#$HOME/~}"
    echo -ne "${PROMPT_FG}${PROMPT_BG} $dir \[\033[0m\]"
}

get_git_branch() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
        echo -ne "\[\033[1;97m\033[48;5;244m\]  $branch \[\033[0m\]"
    fi
}


# 🎨 Apply the full styled prompt
PROMPT_COMMAND='PS1="\n\[\033[1;97m\]╭─ $(get_box_info)\n\
\[\033[1;97m\]│\n\
\[\033[1;97m\]│─ $(get_venv_info)$(get_box_path) $(get_git_branch)
\[\033[1;97m\]│\n\
\[\033[1;97m\]╰─⮞ \[\033[0m\]"'

# 💻 Optional: Colorful ls
alias ls='ls --color=auto'
fastfetch #--logo "$HOME/.config/fastfetch/ascii/rei.txt"
export PATH="$HOME/bin:$PATH"

. "$HOME/.local/bin/env"
