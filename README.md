# ShellScripts

Welcome to the ShellScript repository, where I document and share various shell scripting tasks that I work on as part of my learning process. These scripts are designed to automate different processes and tackle various challenges.

## Overview

This directory contains shell scripts that I’ve developed for learning and practice. Each script is intended to address specific tasks or problems in shell scripting and automation.

## Directory Structure

-**`inatall_command.sh`**: This will be used to set the script as command so that we can directly use the script system wide without needing or considering path of the script once it installed.

- **`usercreate_with_pemfile`**: Creates a PEM file for a specified user if it does not already exist. The script will ensure the directory is created if it doesn't exist and handle file creation accordingly.
  
- **`command_execution_loop`**: Executes a series of 10 predefined commands sequentially without using if-else statements directly.
  
- **`service_monitoring`**: Monitors a specified service (provided as the first argument) and sends an email (provided as the second argument) if the service fails or is stopped. The script will automatically restart the service and notify via email.
  
- **`file_organizing`**: Manages directories by organizing files into various categories without using associative arrays (dictionaries).

- **`file_organizing_v1`**: Same as file_organizing but with path validation and solved move overriding.THIS IS FINAL PRODUCT FOR FILE ORGANIZING
  
- **`file_organizing_using_arrey`**: Manages directories using associative arrays (dictionaries) for organizing files into various categories.

-**`Backup_Directory`**: Script to Backup single directory .File backup Task - if a new file is added, then only the script runs.

## Usage

To use these scripts, follow these steps:

1. **Clone the Repository**:
   git clone https://github.com/VDKamani/ShellScript.git

2. **Navigate to the Directory**:
   cd ShellScript

3. **Make a Script Executable**:
   chmod +x <script-name>.sh

4. **Run the Script**:
   ./<script-name>.sh

**Replace <script-name> with the specific script you want to run.**

## Contribution

If you have suggestions for improvements or new tasks, feel free to create a pull request or open an issue.

## Contact

For any questions or feedback, you can reach me at: viralkamani.it@gmail.com

# Happy scripting!
