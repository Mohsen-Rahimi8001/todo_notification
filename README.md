# todo_notification
A todo app written in bash script using zenity

## How To Setup
* make todo.sh and setup.sh executable
  `chmod +x todo.sh`
  `chmod +x setup.sh`
* change todo.sh file
  change `LONG_TERM_TODO` and `DAILY_TODO` variables to your own local directories
* run setup.sh
  it requires sudo access
  
## create a cronjob to run the nofication app periodically
* define cronjob
  1. `crontab -e`
  2. add this line to your crontab file `0 */2 * * * DISPLAY=:0 todo_notif` to run the app every 2 hours

### *you can update the Icon in desktop_file and run the setup script again to apply changes*
