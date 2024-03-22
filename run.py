import os
import inquirer
import subprocess


def list_python_scripts(directory):
    """List all Python scripts in the specified directory."""
    return [f for f in os.listdir(directory) if f.endswith('.py')]


def execute_script(script_path):
    """Execute the specified Python script."""
    result = subprocess.run(['python3', script_path], check=True)
    if result.returncode == 0:
        # Print success message in green
        print("\033[92mThe script executed successfully!\033[0m\n")
    else:
        # Print error message in red
        print("\033[91mThere was an error executing the script.\033[0m\n")


def main():
    actions = ['Retrieve', 'Upload', 'Exit']
    questions = [
        inquirer.List('action',
                      message="Choose an action",
                      choices=actions,
                      ),
    ]

    while True:
        answers = inquirer.prompt(questions)
        action = answers['action']

        if action == 'Retrieve':
            scripts = list_python_scripts('crawlers')
            if scripts:
                script_question = [
                    inquirer.List('script',
                                  message="Select a script to execute",
                                  choices=scripts,
                                  ),
                ]
                script_answer = inquirer.prompt(script_question)
                execute_script(os.path.join(
                    'crawlers', script_answer['script']))
            else:
                print("No Python scripts found in the 'crawlers' directory.")
        elif action == 'Upload':
            confirm_question = [
                inquirer.Confirm(
                    'confirm', message="Are you sure you want to upload?", default=False),
            ]
            confirm_answer = inquirer.prompt(confirm_question)
            if confirm_answer['confirm']:
                execute_script('utils/upload.py')
                exit()
            else:
                print("Upload canceled.")
        elif action == 'Exit':
            print("Exiting...")
            break


if __name__ == "__main__":
    main()
