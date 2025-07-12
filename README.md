# Scripts

Gathering some useful scripts and avoiding redoing them when \
necessary.


## Git Hooks

For now, two simples git hooks are available: 
- `pre-commit` for check to a PATTERN in the commit message. \
  Default `PATTERN=".*(#[0-9]+).*"`
- `pre-push` to apply full tests before push. The current script is for maven projects. 


To install the hooks just copy `git-hooks` folder to your project directory and run the following command from that
place.

```bash
./git-hooks/install-hooks.sh
```

## Git bash
Git keep asking about the ssh key on Windows, more or less like in this post from 
[StackOverflow](https://stackoverflow.com/questions/10032461/git-keeps-asking-me-for-my-ssh-key-passphrase)

What worked for me was to check for a running `ssh-agent` and export the corresponding variables for access it in the 
current git-bash terminal.

To use this just:

1. In a git-bash terminal clone this in your home folder
2. `cp ${HOME}/scripts/git-bash/.bash_profile ${HOME}`
3. Restart the git-bash terminal/

## Handling certificates
While working on restrict environments I need to manually setup certificates in order to be able
to access resources. The idea here is build scripts that help me to speed up this process.

### Extract Certificates
This script was made in collaboration with GPT-3.5, was an amazing experience guiding GPT in the creation process and 
helping him to fix the script issues in the intermediate versions.

Given a certain application domain exposed by https and an output directory the script should extract the certificates
available for that domain and save in the output dir.

```bash
./extract_certificates.sh example.com crts
```

### SK6: Simple k6 
A simple command-line interface to run k6 load tests with constant throughput.

Example usage:
```bash
# 1 Request per second for 5 seconds to http://httpbin.org/
sk6 -c 1 -d 5s -R 1 http://httpbin.org/
```

More details in the [sk6 readme](sk6/README.md).