import subprocess
from  colorama import Fore, Style, init

init(autoreset=True)

def main():
    print("\033[1;34m" + "="*30)
    print("\033[1;32m1. SCRIPT RUNNER MENU\033[0m")
    print("\033[1;34m" + "="*30)
    print("""
          
     ██╗██████╗ ███╗   ███╗    ███████╗██████╗ ███████╗███████╗███████╗███████╗██████╗ 
     ██║██╔══██╗████╗ ████║    ██╔════╝██╔══██╗██╔════╝██╔════╝╚══███╔╝██╔════╝██╔══██╗
     ██║██║  ██║██╔████╔██║    █████╗  ██████╔╝█████╗  █████╗    ███╔╝ █████╗  ██████╔╝
     ██║██║  ██║██║╚██╔╝██║    ██╔══╝  ██╔══██╗██╔══╝  ██╔══╝   ███╔╝  ██╔══╝  ██╔══██╗
     ██║██████╔╝██║ ╚═╝ ██║    ██║     ██║  ██║███████╗███████╗███████╗███████╗██║  ██║
     ╚═╝╚═════╝ ╚═╝     ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
                                                            BY ZIEDEV 2024  
        """)
    
    print("\033[1;32m1. Batch file\033[0m")

    
    choice = input("ENTER YOUR CHOICE (1): ")
    
    if choice == '1':
        run_batch_file()
        print("Invalid choice. Please enter 1 or 2.")

def run_batch_file():
    try:
        subprocess.run(["cmd.exe", "/c", "zied.cmd"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running the batch file: {e}")

if __name__ == "__main__":
    main()
