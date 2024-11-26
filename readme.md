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
   https://raw.githubusercontent.com/defa1lt/Defa1ltAltSource/main/source/Source.json
   ```

5. **Tap** **"Add Source"**.

After adding the source, you can browse and install the available applications through AltStore. 🚀

---

## Generation Scripts ⚙️

This repository includes scripts to automate the generation of the `Source.json` file and update the `README.md`:

- `generate_source.sh`: For Unix-like systems (Linux, macOS) 🐧🍏
- `generate_source.bat`: For Windows systems 🪟

### Prerequisites 📋

Ensure the following dependencies are installed:


- [`jq`](https://stedolan.github.io/jq/) (for JSON processing):

  ```bash
  sudo apt-get install jq # For Linux
  brew install jq         # For macOS
  ```

- [GitHub CLI (`gh`)](https://cli.github.com/):

  ```bash
  brew install gh         # For macOS
  sudo apt install gh     # For Linux
  ```


### Using the Scripts 🛠️

1. **For Unix-like systems**:

   - **Open** a terminal.
   - **Navigate** to the repository directory.
   - **Make** the script executable:
     ```bash
     chmod +x generate_source.sh
     ```
   - **Run** the script:
     ```bash
     ./generate_source.sh 
     ```


## License 📜

This project is licensed under the MIT License. For more details, see the `LICENSE` file.

If you have any questions or suggestions, please open an issue or submit a pull request. 🙌 

---

