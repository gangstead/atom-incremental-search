# incremental-search package

An incremental search package for Atom designed for fast navigation.

## Using

Press cmd-i to start a search.  This opens an edit control at the bottom of the screen, similar
to Atom's normal find.  Search results are identified as you type and the cursor moves to the
nearest result called the "current result".  It is highlighted slightly more than others.
Press cmd-i again to move the cursor from the current result to the next one.  Press
shift-cmd-i to search in reverse.

To stop a search and leave the cursor on the current search result, press Enter.  To cancel
the search and return the cursor to where it was before the search, press Escape.

The case-sensitive button and use-regular-exprssion buttons can be toggled while in the
search control using cmd-c and cmd-r, respectively.  These are normally cleared when a
search is stopped or canceled so the next search starts without them.  The package setting
"Keep Options After Search" will cause the options to be kept for the next search.

## History

When you press cmd-i or shift-cmd-i to start a search, the search field is always empty.
Press cmd-i or shift-cmd-i again to populate it with the previous search.

At this time only 1 previous search is remembered and it is not stored between sessions.

In an update, more history will be stored and each history item will record the options used.
The history will also be stored between sessions.

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
