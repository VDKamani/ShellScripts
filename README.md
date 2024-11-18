## ShellScripts

Welcome to the ShellScript repository, where I document and share various shell scripting tasks that I work on as part of my learning process. These scripts are designed to automate different processes and tackle various challenges.

## Overview

This directory contains shell scripts that I’ve developed for learning and practice. Each script is intended to address specific tasks or problems in shell scripting and automation.

## Directory Structure

- **`inatall_command.sh`**: This will be used to set the script as command so that we can directly use the script system wide without needing or considering path of the script once it installed.

- **`usercreate_with_pemfile`**: Creates a PEM file for a specified user if it does not already exist. The script will ensure the directory is created if it doesn't exist and handle file creation accordingly.
  
- **`command_execution_loop`**: Executes a series of 10 predefined commands sequentially without using if-else statements directly.
  
- **`service_monitoring`**: Monitors a specified service (provided as the first argument) and sends an email (provided as the second argument) if the service fails or is stopped. The script will automatically restart the service and notify via email.
  
- **`file_organizing`**: Manages directories by organizing files into various categories without using associative arrays (dictionaries).

- **`file_organizing_v1`**: Same as file_organizing but with path validation and solved move overriding.THIS IS FINAL PRODUCT FOR FILE ORGANIZING
  
- **`file_organizing_using_arrey`**: Manages directories using associative arrays (dictionaries) for organizing files into various categories.

- **`Backup_Directory`**: Script to Backup single directory .File backup Task - if a new file is added, then only the script runs.

- **`dyanamic_swap_creation`**: Script to create a swap memory with the size allocation via user also changing the swapiness value and catch-pressure value as well.

- **`swap_deletion`**: Script to delete the swap that we created and also change the swapiness and catch pressure to defaulte value.

- **`attach_ebs.sh`**: Make an Amazon EBS volume available for use

- **`attach_ebs_dynamic.sh`**: This script is designed to make an Amazon EBS (Elastic Block Store) volume available for use on an EC2 instance. It provides the flexibility to either directly mount the volume without formatting (useful if the volume already contains a file system and data) or format the volume before mounting. Additionally, the script allows users to make the mount permanent by adding the necessary configuration to /etc/fstab.

- **`detache_ebs.sh`**: This script is designed to safely unmount and detach an Amazon EBS (Elastic Block Store) volume from an EC2 instance. It provides options to ensure that the volume is unmounted, and it offers the flexibility to remove the corresponding entry from /etc/fstab if the mount was permanent, ensuring that the volume does not automatically remount after a reboot.

- **`ssh-servers.sh`**:This script provides a list of available servers for SSH access, prompts the user to select a server by entering its number, and then connects to the selected server by executing the corresponding SSH command. It validates the input to ensure a valid server number is chosen. If the input is invalid, it displays an error message indicating the correct range of options.

- **`move_to_s3.sh`**: This script will move all the logfile's gz file created by PM2 logrotate to S3 bucket and will delete that file after successfull uplodation. 

## Usage

To use these scripts, follow these steps:

1. **Clone the Repository**:
   ```git clone https://github.com/VDKamani/ShellScript.git```

2. **Navigate to the Directory**:
   ```cd ShellScript```

3. **Make a Script Executable**:
   ```chmod +x <script-name>.sh```

4. **Run the Script**:
  ``` ./<script-name>.sh```

**Replace <script-name> with the specific script you want to run.**

## Contribution

If you have suggestions for improvements or new tasks, feel free to create a pull request or open an issue.

## Contact

For any questions or feedback, you can reach me at: viralkamani.it@gmail.com

# Happy scripting!
### Viral D. Kamani