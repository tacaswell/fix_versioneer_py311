# Fix versioneer for py311

This is a (xonsh) script to apply a naive fix to versioneer to account for the
upcoming removal of SafeConfigParser in Python 3.11 which was deprecated in
Python 3.2 (released Feb 20, 2011), to all of your local checkouts and open up
PRs with the change.

Updating versioneer will also fix this, however I chose to patch versioneer.py
instead.  My main motivation was to avoid any risk of updating the version of
versioneer.py being used changing any behavior of the project because I was
looking at needing to touch ~130 projects and wanted to avoid being pulled into
debugging build systems.

There are two patches because there are at least 2 versions of versioneer.py out
in the wild that need to be updated.

## Use

The first step is identify which repos you have checked out need the patches.
I used ack + grep to find them:

```bash
cd your_toplevel_source
ack --python 'parser = configparser.SafeConfigParser()' -l | grep versio
```

From there, edit `fix_py311.xsh` to include this list in `target`, update the
`base_path` and set `YOUR_GH_USER`.  Once that is done:

```bash
xnosh fix_py311.xsh
```

Given that this script has significant external side-effects (opens PRs!), I
strongly suggest running it 10 or so repos at a time and keeping an eye on it.
