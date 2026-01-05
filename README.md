# Flatpatch

Flatpatch is a bash script that automates applying launch parameters to dashboard links after an update.

## Usage

1. Download the script and save it to a location of your choice.
2. Open the script in a text editor and edit the `apps` array to include the applications you want to patch.
3. Save the script and make it executable by running `chmod +x flatpatch.sh`.
4. Run the script by typing `./flatpatch.sh` in the terminal.

## Configuration

The script uses a simple configuration system to specify the location of the desktop files and the string to check for.

To configure the script, edit the `apps` array in the script and add the following information for each application you want to patch:

- Location: The location of the desktop files. This can be a relative or absolute path.
- Application: The name of the application desktop file.
- String: The string to check for in the desktop file.

For example, to patch Vivaldi with the following parameters:

- Location: `/var/lib/flatpak/exports/share/applications`
- Application: `com.vivaldi.Vivaldi`
- String: `--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE`

You would add the following line to the `apps` array:

```
"loc=/var/lib/flatpak/exports/share/applications;app=com.vivaldi.Vivaldi;str=--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
```

## Contributing

Contributions are welcome! If you have any suggestions or improvements, please open an issue or submit a pull request.

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for more information. 