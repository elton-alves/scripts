# Scripts

Gathering some useful scripts and avoiding redoing them when \
necessary.


## Git Hooks

For now, two simples git hooks are available: 
- `pre-commit` for check to a PATTERN in the commit message. \
  Default `PATTERN=".*(#[0-9]+).*"`
- `pre-push` to apply full tests before push. Applied for \
  maven projects. 


To install the hooks just copy `git-hooks` folder to your project\
directory and run the following command from that place.

```bash
./git-hooks/install-hooks.sh
```