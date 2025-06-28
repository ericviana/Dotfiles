# Enhanced scheduling function with frequency support
schedule() {
    local help_text="Usage: schedule [options] <time> <command> [frequency]
    
Options:
  -h, --help     Show this help
  -d, --dir DIR  Run command in specific directory (default: current)
  -n, --name     Give the job a name (for easier tracking)
  
Time formats:
  '8:30', '14:30', '2pm', '8:30am'
  
Frequency options:
  once           Run only once (default)
  daily          Every day at specified time
  weekdays       Monday through Friday
  weekends       Saturday and Sunday
  weekly         Every week on the same day
  monday         Every Monday
  tuesday        Every Tuesday
  wednesday      Every Wednesday
  thursday       Every Thursday
  friday         Every Friday
  saturday       Every Saturday
  sunday         Every Sunday
  monthly        First day of every month
  
Examples:
  schedule '8:30' 'mr'                    # Once today at 8:30
  schedule '8:30' 'mr' 'daily'           # Every day at 8:30
  schedule '2pm' 'npm test' 'weekdays'   # Weekdays at 2pm
  schedule '9am' 'backup.sh' 'weekly'    # Every week same day
  schedule '10pm' 'cleanup' 'friday'     # Every Friday at 10pm"
    
    local dir=$(pwd)
    local job_name=""
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                echo "$help_text"
                return 0
                ;;
            -d|--dir)
                dir="$2"
                shift 2
                ;;
            -n|--name)
                job_name="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done
    
    if [ $# -lt 2 ]; then
        echo "$help_text"
        return 1
    fi
    
    local time="$1"
    local command="$2"
    local frequency="${3:-once}"
    
    # Convert time to 24-hour format if needed
    local hour minute
    if [[ "$time" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
        hour="${BASH_REMATCH[1]}"
        minute="${BASH_REMATCH[2]}"
    elif [[ "$time" =~ ^([0-9]{1,2})am$ ]]; then
        hour="${BASH_REMATCH[1]}"
        minute="00"
        [[ "$hour" == "12" ]] && hour="00"
    elif [[ "$time" =~ ^([0-9]{1,2}):([0-9]{2})am$ ]]; then
        hour="${BASH_REMATCH[1]}"
        minute="${BASH_REMATCH[2]}"
        [[ "$hour" == "12" ]] && hour="00"
    elif [[ "$time" =~ ^([0-9]{1,2})pm$ ]]; then
        hour="${BASH_REMATCH[1]}"
        minute="00"
        [[ "$hour" != "12" ]] && hour=$((hour + 12))
    elif [[ "$time" =~ ^([0-9]{1,2}):([0-9]{2})pm$ ]]; then
        hour="${BASH_REMATCH[1]}"
        minute="${BASH_REMATCH[2]}"
        [[ "$hour" != "12" ]] && hour=$((hour + 12))
    else
        echo "❌ Invalid time format. Use: 8:30, 2pm, 14:30, etc."
        return 1
    fi
    
    # Ensure hour is 2 digits
    printf -v hour "%02d" "$hour"
    
    local full_command="cd '$dir' && $command"
    
    case "$frequency" in
        once)
            echo "$full_command" | at "${hour}:${minute}"
            if [ $? -eq 0 ]; then
                echo "✅ Scheduled once: '$command' at ${hour}:${minute}"
                [ -n "$job_name" ] && echo "🏷️  Job name: $job_name"
                echo "📍 Working directory: $dir"
                echo ""
                echo "📋 Current scheduled jobs:"
                atq
            fi
            ;;
        daily)
            _add_cron_job "$minute $hour * * *" "$full_command" "$job_name"
            ;;
        weekdays)
            _add_cron_job "$minute $hour * * 1-5" "$full_command" "$job_name"
            ;;
        weekends)
            _add_cron_job "$minute $hour * * 0,6" "$full_command" "$job_name"
            ;;
        weekly)
            local today_num=$(date +%u)  # 1=Monday, 7=Sunday
            [[ "$today_num" == "7" ]] && today_num="0"  # Convert to cron format (0=Sunday)
            _add_cron_job "$minute $hour * * $today_num" "$full_command" "$job_name"
            ;;
        monday)
            _add_cron_job "$minute $hour * * 1" "$full_command" "$job_name"
            ;;
        tuesday)
            _add_cron_job "$minute $hour * * 2" "$full_command" "$job_name"
            ;;
        wednesday)
            _add_cron_job "$minute $hour * * 3" "$full_command" "$job_name"
            ;;
        thursday)
            _add_cron_job "$minute $hour * * 4" "$full_command" "$job_name"
            ;;
        friday)
            _add_cron_job "$minute $hour * * 5" "$full_command" "$job_name"
            ;;
        saturday)
            _add_cron_job "$minute $hour * * 6" "$full_command" "$job_name"
            ;;
        sunday)
            _add_cron_job "$minute $hour * * 0" "$full_command" "$job_name"
            ;;
        monthly)
            _add_cron_job "$minute $hour 1 * *" "$full_command" "$job_name"
            ;;
        *)
            echo "❌ Invalid frequency: $frequency"
            echo "Valid options: once, daily, weekdays, weekends, weekly, monday-sunday, monthly"
            return 1
            ;;
    esac
}

# Helper function to add cron jobs
_add_cron_job() {
    local cron_schedule="$1"
    local command="$2"
    local job_name="$3"
    
    # Get current crontab
    local temp_cron=$(mktemp)
    crontab -l 2>/dev/null > "$temp_cron"
    
    # Add comment with job name if provided
    if [ -n "$job_name" ]; then
        echo "# Scheduled job: $job_name" >> "$temp_cron"
    fi
    
    # Add the new job
    echo "$cron_schedule $command" >> "$temp_cron"
    
    # Install new crontab
    crontab "$temp_cron"
    rm "$temp_cron"
    
    if [ $? -eq 0 ]; then
        echo "✅ Scheduled recurring: '$command'"
        echo "⏰ Schedule: $cron_schedule"
        [ -n "$job_name" ] && echo "🏷️  Job name: $job_name"
        echo "📍 Working directory: $(echo "$command" | grep -o "cd '[^']*'" | cut -d"'" -f2)"
        echo ""
        echo "📋 Current cron jobs:"
        crontab -l | tail -5
    else
        echo "❌ Failed to schedule recurring job"
    fi
}

# List all scheduled jobs (both at and cron)
scheduled() {
    echo "📋 One-time jobs (at):"
    if command -v atq >/dev/null && atq 2>/dev/null | grep -q .; then
        atq
    else
        echo "  No one-time jobs scheduled"
    fi
    
    echo ""
    echo "🔄 Recurring jobs (cron):"
    if crontab -l 2>/dev/null | grep -v '^#' | grep -q .; then
        crontab -l 2>/dev/null
    else
        echo "  No recurring jobs scheduled"
    fi
}

# Remove scheduled jobs
unschedule() {
    if [ $# -eq 0 ]; then
        echo "Usage: unschedule <job_id|'cron'>"
        echo "  job_id: Remove one-time job (use 'scheduled' to see IDs)"
        echo "  cron:   Remove all cron jobs"
        return 1
    fi
    
    if [ "$1" = "cron" ]; then
        crontab -r 2>/dev/null
        echo "✅ Removed all recurring jobs"
    else
        atrm "$1" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✅ Removed one-time job $1"
        else
            echo "❌ Failed to remove job $1"
        fi
    fi
    
    echo ""
    echo "📋 Remaining jobs:"
    scheduled
} 