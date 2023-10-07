# qb-vehicles

This repository contains a Lua script for converting and processing vehicle data. The script performs the following tasks:

1. Loads old vehicle data from a Lua file named `vehicles.lua`.
2. Removes lines with unwanted comments from the loaded data.
3. Converts the old data into a new format and organizes it.
4. Creates a JSON representation of the new vehicle data.
5. Saves the new data to a JSON file named `vehicles_new.json`.

## Usage

To use this script, follow these steps:

1. Ensure you have a file named `vehicles.lua` with the old vehicle data in the specified format.
2. Run the Lua script provided in this repository.

The script will convert the old data into a new format and save it as `vehicles_new.json`.

## License

This script is provided under the [MIT License](LICENSE).

## Disclaimer

Please note that this script assumes specific data structures and paths. Make sure to adapt it to your project's needs before use.

For any questions or issues, feel free to open an issue or contact the repository owner.

Happy coding!
