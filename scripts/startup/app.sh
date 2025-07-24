DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
PARENT_DIR=$(dirname "$PARENT_DIR")
source "$PARENT_DIR/lib.sh"

aria2_path=$HOME/.config/aria2/aria2.sh
if check_and_cd "$aria2_path"; then
    sh "$aria2_path" "true"
fi

if ((is_windows)); then
    clash_verge_rev_path="$HOME/scoop/apps/clash-verge-rev/current/clash-verge.exe"
    if check_and_cd "$clash_verge_rev_path"; then
        launch "$clash_verge_rev_path"
    fi
fi

if ((is_windows)); then
    copyq_path="$HOME/scoop/apps/copyq/current/copyq.exe"
    if check_and_cd "$copyq_path"; then
        launch "$copyq_path"
    fi
fi

if ((is_windows)); then
    everything_path="$HOME/scoop/apps/everything-alpha/current/Everything.exe"
    if check_and_cd "$everything_path"; then
        launch "$everything_path" "true"
    fi
fi

if ((is_windows)); then
    flow_launcher_path="$HOME/scoop/apps/flow-launcher/current/Flow.Launcher.exe"
    if check_and_cd "$flow_launcher_path"; then
        launch "$flow_launcher_path"
    fi
fi

if ((is_windows)); then
    mykeymap_path="$HOME/scoop/apps/mykeymap/current/MyKeymap.exe"
    if check_and_cd "$mykeymap_path"; then
        launch "$mykeymap_path" "true"

        komorebi_script_path="$HOME/.config/komorebi/komorebi.ahk"
        if check_and_cd "$komorebi_script_path"; then
            # rm -rf "$LOCALAPPDATA/komorebi"
            launch "$mykeymap_path" "true" "$komorebi_script_path"
        fi
    fi
fi

if ((is_windows)); then
    reminder_path="D:/Tools/Reminder/reminder.exe"
    if check_and_cd "$reminder_path"; then
        launch "$reminder_path"
    fi
fi

if ((is_windows)); then
    sharex_path="$HOME/scoop/apps/sharex/current/ShareX.exe"
    if check_and_cd "$sharex_path"; then
        launch "$sharex_path" "true"
    fi
fi

if ((is_windows)); then
    snow_shot_path="$HOME/scoop/apps/snow-shot/current/app.exe"
    if check_and_cd "$snow_shot_path"; then
        launch "$snow_shot_path" "true"
    fi
fi

if ((is_windows)); then
    env=~/.ssh/agent.env

    agent_load_env() { test -f "$env" && . "$env" >|/dev/null; }

    agent_start() {
        (
            umask 077
            ssh-agent >|"$env"
        )
        . "$env" >|/dev/null
    }

    agent_load_env

    # agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
    agent_run_state=$(
        ssh-add -l >|/dev/null 2>&1
        echo $?
    )

    if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
        agent_start
        ssh-add
    elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
        ssh-add
    fi

    unset env
fi

if ((is_windows)); then
    yarr_path="$HOME/scoop/apps/yarr/current/yarr.exe"
    if check_and_cd "$yarr_path"; then
        launch "$yarr_path"
    fi
fi
