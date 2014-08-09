# incremental-search package

An incremental search package for Atom designed for fast navigation.

Press `cmd-i` (OS X) or `ctrl-i` (Windows & Linux) and start typing what you want to find - the
package will highlight all instances of what you've typed so far and scroll to the closest
result.  Each time you type a character or change the search string, the results are updated
on the fly and the editor is scrolled to the new results.

To move the cursor forward to the next result, press `cmd-i`/`ctrl-i` again.  To move backwards
to a previous result press `shift-cmd-i` / `shift-ctrl-i`.  Using these while in the find
editor will quickly move you through file.

When you've found the text you are looking for, press `enter` to stop the search and leave the
cursor on the search result.  To cancel the search and return to where you started, press `esc`.

## Slurping

In the find control, pressing `cmd-e` (OS X) or `ctrl-e` (Windows & Linux) will copy text from
the text editor into the find control.

When a search is started, the find control is empty.  If there is a selection in the text
editor, the first slurp will copy it.  Otherwise it will copy from the cursor to the end of the
current word.

Once a search has begun, slurping copies from the end of the current result to the next word
boundary.  If a search has begun and there are no results, slurping will do nothing.

## Search Options

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

At this time only 1 previous search is remembered and it is not stored between sessions.
In an update, more history will be stored and each history item will record the options used.
The history will also be stored between sessions.

## Overriding Styles

The default result styles are copied from Atom's find-and-replace package so it will look
familiar, but it uses custom classes which you can style.  To style the current result use
`.editor .isearch-current .region`.  To style other results `.editor .isearch-result .region`.

For example, to change the border around the current search result to red, you would add
the following to your ~/.atom/styles.less file:

```css
.editor .isearch-current .region {
  border: 1px solid red;
}
```

## Key Binding Summary

### OS X

To start an incremental search:

* `cmd-i` - start a forward incremental search
* `shift-cmd-i` - start a backward incremental search

Once you've started an incremental search:

* type text characters to search - the results are updated
* `cmd-i` - move cursor forward to next result
* `shift-cmd-i` - move cursor backward to previous result
* `cmd-e` - slurp
* `return` - stop the search and leave the cursor where it is
* `esc` - cancel the search and return the cursor to where it was before searching
* `cmd-r` - toggle regular expressions
* `cmd-c` - toggle case sensitivity
* `cmd-enter` - set focus to the text editor without canceling search

### Windows & Linux

To start an incremental search:

* `ctrl-i` - start a forward incremental search
* `shift-ctrl-i` - start a backward incremental search

Once you've started an incremental search:

* type text characters to search - the results are updated
* `ctrl-i` - move cursor forward to next result
* `shift-ctrl-i` - move cursor backward to previous result
* `ctrl-e` - slurp
* `return` - stop the search and leave the cursor where it is
* `esc` - cancel the search and return the cursor to where it was before searching
* `ctrl-r` - toggle regular expressions
* `ctrl-c` - toggle case sensitivity
* `ctrl-enter` - set focus to the text editor without canceling search

### emacs

There is no built in emacs compatibility, but you can get close by remapping three keys. You
will want to copy the keymap from this package into your private keymap.  Note the ".isearch"
class maps keys inside of the incremental-search pane so that `ctrl-w` does not override
mappings in your text editor.

```
'.platform-darwin .workspace .editor:not(.mini)':
  'ctrl-s': 'incremental-search:forward'
  'ctrl-r': 'incremental-search:backward'

'.platform-darwin .workspace .isearch .editor':
  'ctrl-s': 'incremental-search:forward'
  'ctrl-r': 'incremental-search:backward'
  'ctrl-w' : 'incremental-search:slurp'
```

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

Additionally, the key binding "footprint" is as small as possible.  Most keys only take effect
once a search has started.  Atom is in real danger of using up all of the keys which is not
good for a project designed for extensibility.
