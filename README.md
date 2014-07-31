# incremental-search package

An incremental search package for Atom designed for fast navigation.

Press `cmd-i` and start typing what you want to find - the package will highlight all instances what you've typed
so far and move the cursor to the closest result.  Each time you type a character or change
the search string, the results are updated and the cursor is moved on the fly.

To move the cursor forward to the next result, press `cmd-i` again.  To move backwards to a
previous result press `shift-cmd-i`.  Using these while in the find editor will quickly move
you through file.

When you've found the text you are looking for, press `enter` to stop the search and leave the
cursor on the search result.  To cancel the search and return to where you started, press `esc`.

## Options

The package supports both case sensitive searching and regular expressions.  The state of the
options are displayed next to the search pane's title:

![no options](http://mkleehammer.github.com/atom-incremental-search/images/label-no-options.png)

![options](http://mkleehammer.github.com/atom-incremental-search/images/label-options.png)

You can toggle the options using the buttons on the right of the pane or using `cmd-r` (regular
expression) and `cmd-c` (case sensitivity):

![buttons](http://mkleehammer.github.com/atom-incremental-search/images/buttons.png)

These options are normally turned off when a search is stopped or canceled so the next search
starts without them.  The package setting "Keep Options After Search" will cause the options to
be kept for the next search.

## Selection and History

When you start a search the search editor is normally empty.  Pressing `cmd-i` or `shift-cmd-i`
again will populate the search with the last used search.

If you have selected text before starting a search, the search will default to your selection.

At this time only 1 previous search is remembered and it is not stored between sessions.
In an update, more history will be stored and each history item will record the options used.
The history will also be stored between sessions.

## Key Binding Summary

### OS X

To start an incremental search:

* `cmd-i` - start a forward incremental search
* `shift-cmd-i` - start a backward incremental search

Once you've started an incremental search:

* type text characters to search - the results are updated
* `cmd-i` - move cursor forward to next result
* `shift-cmd-i` - move cursor backward to previous result
* `return` - stop the search and leave the cursor where it is
* `esc` - cancel the search and return the cursor to where it was before searching
* `cmd-r` - toggle regular expressions
* `cmd-c` - toggle case sensitivity
* `cmd-e` - set focus to the code editor without canceling search

## Differences From Atom's Find

This is heavily based on Atom's find-and-replace package and I appreciate their hard work.
There is no reason the features of this package cannot be merged into the find-and-replace
package if the functionality is found useful.

The intention of this package is to improve *navigation*.  Advanced users of editors like vi
and emacs often excel at moving around in files - in fact, often incremental search is the
 *default* method of moving around.  Pressing arrow keys 10 times or waiting for key repeat
timers is very slow.

This leads to these design elements:

* Searching must be incremental - the editor location must move while you type.
* The input cursor must stay in the search control so the search text can be quickly updated.
* Stopping the search and staying should be easy (Enter).
* Canceling the search and returning to the original location must also be easy (Esc).
* It must be easy to stop a search, make a change, and restart the search (e.g. cmd-i twice)

There are additional features planned which you can add to in the Github issues list.
