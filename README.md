# ShipFitting-template-creator

This tool is for turning EFT formatted ship fits into ShipFitting template for Uni Wiki.

## How to use

Just paste the EFT fit to the panel on the left. Set the options on the middle if you want to.
* Name shown on wiki - If no name is given the fit name is used
* ID - If no ID is given the name is used.
* Date - If no date is given the current date is used.
* Difficulty - 0/1/2 to tell how hard the fit is to use (skill or piloting talent).
* Alpha usable - Can alpha use this fit?
* Show skills by default - If enabled the skill tab will be expanded by default.
* Show notes by default - If enabled the notes tab will be expanded by default.
* Show on TOC - If enabled the fit will have entry on the table of contents of the page.
* Add loaded ammo to cargo - When enabled the loaded ammo are handled as if they were in cargo. If disabled the loaded ammo are ignored completely.
* Notes - Notes aboutthe fit. Each line willbe one note.
* Skills - Required skills. Each line will be one skill.

After pressing the "Parse input" button the finished template output will be on the panel on right. Copy paste it to wiki.

![alt text](https://i.imgur.com/acWhLH5.png "View on the tool")

If something doesn't seem to work look at the console. It will tell what has been done, what is being done and if there are any errors.

The tool will save cache at "user://item_cache.json". On Windows this is located at "\AppData\Roaming\Godot\app_userdata\ShipFitting template importer". On first runs the tool may seem slow due to it fetching module info from ESI. After they are cached the tool will be practically instant.

## Project requirement
Made with Godot 3.1. Will probably work on newer versions too. If you use the release versions this doesn't impact you.
https://godotengine.org/download
