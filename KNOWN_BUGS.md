# List of known bugs

- Subprocesses spawned as a result of calling `run` which won't shut down
  properly and keep occupying the chroot filesystem will trigger errors.
  - We have code to specifically look for `gpg-agent` to shut it down to avoid
    `pacman`/`yay`/`git` calls to cause this error. Will be fixed with a more
    generic solution in the long term.
