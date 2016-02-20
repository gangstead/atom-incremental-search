## PLEASE CONTRIBUTE

**TL;DR**  Please submit pull requests and I will be grateful and very nice.

I (@gangstead) inherited this package by submitting a pull request when it was getting out of date.  I wasn't smart enough to make the original one, also I don't really know coffeescript, so it's a real struggle in my weekly 10 minutes of free time to try to figure out how to keep it up to date.

Atom is very good at providing helpful error messages, deprecation warnings, and suggest fixes.  Submitting their auto-generated issues is helpful, but not nearly as helpful as taking a stab at fixing it and submitting a pull request.

## How to run locally
To test changes in your fork locally simply uninstall the official package, then from the command line in the directory of your fork simply run `apm link`.  Now you will have the the package installed from your local directory.  Test it out, make some changes, reload the window (open the command pallette (`cmd/ctrl + shift + p`) and type `reload` to run `Window:reload`) and your changes will be live in your local editor.  When you are done you can do `apm unlink` and then you can install the official package again.
