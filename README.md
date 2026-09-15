# Git Quick Reference (temporary)

Delete this file once the team doesn't need it anymore.

## First-time setup (per machine)
```
git clone <repo-url>
cd 24-1444AdoteRonAdrian_Portfolio
```

## Check status before doing anything
```
git status
```

## Staging changes
```
git add <file>          # stage a specific file
git add .                # stage everything in the current folder (respects .gitignore)
```
> Note: `.vs/`, `bin/`, `obj/`, and `packages/` are excluded via `.gitignore`.
> If Visual Studio is open, some files there can be locked and cause
> "permission denied" errors during `git add` — close VS or wait for it
> to release the file, then retry.

## Committing
```
git commit -m "Short description of the change"
```

## Pulling latest changes
```
git pull
```
If you get merge conflicts, resolve them in the affected files, then:
```
git add <resolved-file>
git commit
```

## Pushing your changes
```
git push
```
If this is the first push on a new branch:
```
git push -u origin <branch-name>
```

## Typical daily workflow
```
git pull                 # get latest changes first
# ... make your edits ...
git status                # review what changed
git add .
git commit -m "Describe your change"
git push
```

## Branching (optional, recommended for features)
```
git checkout -b feature/my-change
# ... work, commit ...
git push -u origin feature/my-change
```
Then open a pull request to merge into `main`.
