# Defa1lt's AltStore Source 

Welcome to **Defa1lt's AltStore Source** repository! Here, you can discover and install a variety of iOS applications via AltStore.

---

## Adding the Source to AltStore 📲

To add this source to AltStore:

1. **Open** the AltStore app on your iOS device.
2. **Navigate** to the **"Sources"** tab.
3. **Tap** the **"+"** button in the top-right corner.
4. **Enter** the following source URL:

   ```
   https://raw.githubusercontent.com/defa1lt/Defa1ltAltSource/main/source/v1/Source.json
   ```

5. **Tap** **"Add Source"**.

After adding the source, you can browse and install the available applications through AltStore. 🚀

---

## Using Git LFS for Large Files 📂

This repository uses **Git Large File Storage (Git LFS)** to manage large binary files, such as `.ipa` files. Git LFS ensures efficient version control and avoids exceeding file size limits in the repository.

### Setting Up Git LFS

1. **Install Git LFS**:

   - **macOS**:
     ```bash
     brew install git-lfs
     ```

   - **Ubuntu**:
     ```bash
     sudo apt-get install git-lfs
     ```

   - **Windows**:
     Download and install Git LFS from the [official site](https://git-lfs.github.com/).

2. **Initialize Git LFS** in the repository:
   ```bash
   git lfs install
   ```

3. **Track large files** (e.g., `.ipa` files):
   ```bash
   git lfs track "*.ipa"
   ```

   This adds the file pattern to the `.gitattributes` file.

4. **Commit and Push** large files using Git LFS:
   - Stage the `.gitattributes` file:
     ```bash
     git add .gitattributes
     ```
---

## Generation Scripts ⚙️

This repository includes scripts to automate the generation of the `Source.json` file and update the `README.md`:

- `generate_source.sh`: For Unix-like systems (Linux, macOS) 🐧🍏
- `generate_source.bat`: For Windows systems 🪟

### Prerequisites 📋

Ensure the following dependencies are installed:

- **Unix-like systems**:
  - `jq`: A lightweight and flexible command-line JSON processor. Install it using your package manager:

    - **macOS**:
      ```bash
      brew install jq
      ```

    - **Ubuntu**:
      ```bash
      sudo apt-get install jq
      ```

- **Windows systems**:
  - `jq`: Download the Windows executable from the [official repository](https://github.com/stedolan/jq/releases) and add it to your system's PATH.

### Using the Scripts 🛠️

1. **For Unix-like systems**:

   - **Open** a terminal.
   - **Navigate** to the repository directory.
   - **Make** the script executable:
     ```bash
     chmod +x generate_source.sh
     ```
   - **Run** the script with the desired flag:
     ```bash
     ./generate_source.sh -u
     ```
     or
     ```bash
     ./generate_source.sh -c
     ```

2. **For Windows systems**:

   - **Open** the Command Prompt.
   - **Navigate** to the repository directory.
   - **Run** the script with the desired flag:
     ```cmd
     generate_source.bat -u
     ```
     or
     ```cmd
     generate_source.bat -c
     ```

### Flag Descriptions 🏳️

- `-u`: Updates the latest version of the application. 🔄
- `-c`: Creates a new version of the application. 🆕

**Note:** Before running the scripts, ensure all necessary dependencies are installed. 📦

---

## License 📜

This project is licensed under the MIT License. For more details, see the `LICENSE` file.

If you have any questions or suggestions, please open an issue or submit a pull request. 🙌 

---

