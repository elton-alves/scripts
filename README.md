# Scripts

Gathering some useful scripts and avoiding redoing them when \
necessary.


## Git Hooks

For now two simple git hooks are available: 
- `pre-commit` for check to a PATTERN in the commit message. \
  Default `PATTERN=".*(#[0-9]+).*"`
- `pre-push` to apply full tests before push. Current used for \
  java maven projects. 


To install the hooks Just copy `git-hooks` folder to your git \
project directory and run the following command from your \
project root folder

```bash
./git-hooks/install-hooks.sh
```