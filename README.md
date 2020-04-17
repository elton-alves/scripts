# Scripts

Gathering some useful scripts and avoiding redoing them when \
necessary.


## Git Hooks

For now, two simples git hooks are available: 
- `pre-commit` for check to a PATTERN in the commit message. \
  Default `PATTERN=".*(#[0-9]+).*"`
- `pre-push` to apply full tests before push. The current \
  script is for maven projects. 


To install the hooks just copy `git-hooks` folder to your project\
directory and run the following command from that place.

```bash
./git-hooks/install-hooks.sh
```

## Git bash
Git keep asking about the ssh key on Windows, more or less like in this post from [StackOverflow](https://stackoverflow.com/questions/10032461/git-keeps-asking-me-for-my-ssh-key-passphrase)

What worked for me was check for a running `ssh-agent` and
export the corresponding variables for access it in the current
git-bash terminal.

To use this just:

1. In a git-bash terminal
2. `cp git-bash/.bash_profile`
3. Restart the git-bash terminal

