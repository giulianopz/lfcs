## git

## General

Initialize a directory as a git repository hosted on GitHub: 
```
touch README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/{user-name}/{repository-name}.git
git push -u origin main
```

Create a minimal configuration for git in your `~/.gitconfig`:
```
[user]
    name = [username]
    email = [email-address]

# choose a difftool
[diff]
    guitool = meld

[difftool "meld"]
    cmd = meld \"$REMOTE\" \"$LOCAL\" --label \"DIFF (ORIGINAL MY)\"

# choose a mergetool
[merge]
    tool = meld

[mergetool "meld"]
    cmd = meld \"$LOCAL\" \"$MERGED\" \"$REMOTE\" --output \"$MERGED\"

# store your credentials in a plain-text file
[credential]
        helper = store --file ~/.gitcredentials

# choose a default editor
[core]
        editor = vi
```

Show all configuration settings and their location: `git config --show-origin --list`

## Undo

Undo an already pushed commit recording a new commit: `git revert [<commit>]`

Note that it only reverts that specific commit and not commits after that. If you want to revert a range of commits, you can do it like this:
`git revert [<oldest_commit_hash>]..[<latest_commit_hash>]`

To undo a pushed merge: `git revert -m 1 [<merge-commit-hash>]`

The `-m 1` option tells Git that we want to keep the left side of the merge (which is the branch we had merged into). When you view a merge commit in the output of git log, you will see its parents listed on the line that begins with Merge:
```
commit 8f937c683929b08379097828c8a04350b9b8e183
Merge: 8989ee0 7c6b236
Author: Ben James <ben@example.com>
Date:   Wed Aug 17 22:49:41 2011 +0100

Merge branch 'gh-pages'
```
In this situation, `git revert 8f937c6 -m 1` will get you the tree as it was in `8989ee0`, and `git revert -m 2` will reinstate the tree as it was in `7c6b236`.

To throw away not yet pushed changes in your working directory, use instead:
`git reset [--soft | --mixed | --hard ] [<commit>]`

![reset-ops-visually-exaplained](https://i.stack.imgur.com/qRAte.jpg)

Typically, to discard all recent changes resetting the HEAD to the previous commit: `git reset --hard HEAD^`

Remove a file from the staging area: `git restore --staged [<filepath>]` 

Undo modifications on the working tree (restore files from latest commited version): `git checkout -- index.html`

Restore file from a custom commit (in current branch): `git checkout 6eb715d -- index.html`

Remove files from the working tree and the index: `git rm index.html`

Remove file only from the index: `git rm --cached index.html`

## Branch

Show all branches (including the remote ones): `git branch -l -a`

Create and switch to a new branch:`git checkout -b [branchname]`

Move to branch: `git checkout [branchname]`

Checkout to new branch tracking a remote one: `git checkout --track origin/[branchname]`

Rename branch: `git branch -m [branchname] [new-branchname]`

Delete merged branch (only possible if not HEAD): `git branch -d [branch-to-delete]`

Delete not merged branch: `git branch -D [branch-to-delete]`

Delete remote branch: `git push origin --delete [branch-to-delete]`

## Merge

Merge `branchname` into the cuurent branch: `git merge [branchname]`

Stop merge (in case of conflicts): `git merge --abort`

Merge only one specific commit: `git cherry-pick [073791e7]`

Review the recent history interactively choosing if deleting some of the latest commits: `git rebase -i HEAD~[N]`

## Stash

Show stash history: `git stash list`

Put a specific file into the stash: `git stash push -m ["welcome_cart"] [app/views/cart/welcome.html]`

View the content of the most recent stash commit: `git stash show -p`

View the content of an arbitrary stash: `git stash show -p stash@{1}`

Extract a single file from a stash commit:
```
git show stash@{0}:[full filename]  >  [newfile]
git show stash@{0}:[./relative filename] > [newfile]
```

Apply this stash commit on top of the working tree and remove it from the stash: `git stash pop stash@{0}`

Apply this stash commit on top of the working tree but do not remove it: `git stash apply stash@{0}`

Delete custom stash item: `git stash drop stash@{0}`

Delete complete stash: `git stash clear`

## Log

Show commit logs: `git log`

> Note: git log shows the current `HEAD` and its ancestry. That is, it prints the commit `HEAD` points to, then its parent, its parent, and so on. It traverses back through the repo's ancestry, by recursively looking up each commit's parent. `git reflog `doesn't traverse `HEAD`'s ancestry at all. The `reflog` is an ordered list of the commits that `HEAD` has pointed to: it's undo history for your repo. The reflog isn't part of the repo itself (it's stored separately to the commits themselves) and isn't included in pushes, fetches or clones: it's purely local. Aside: understanding `reflog` means you can't really lose data from your repo once it's been committed. If you accidentally reset to an older commit, or rebase wrongly, or any other operation that visually "removes" commits, you can use `reflog` to see where you were before and `git reset --hard` back to that ref to restore your previous state. Remember, refs imply not just the commit but the entire history behind it. ([source](https://stackoverflow.com/a/17860179/9109880))


Show only custom commits:
```
git log --author="Sven"
git log --grep="Message"
git log --until=2013-01-01
git log --since=2013-01-01
```

Show stats and summary of commits: `git log --stat --summary`

Show history of commits as graph-summary: `git log --oneline --graph --all --decorate`

A nice [trick](https://stackoverflow.com/a/9074343/9109880) is to add some aliases in your `~/.gitconfig` for using `git log` with a good combination of options, like:
```
[alias]
lg1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
lg2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
lg = !"git lg1"
```

## Compare

See lastest changes in a file: `git diff [filename]`

Compare modified files and highlight changes only: `git diff --color-words [filename]`

Compare modified files within the staging area: `git diff --staged [filename]`

Compare branches: `git diff [branch1]..[branch2]`

> Note: This command combined with the two-dot operator will show you all the commits that “branch2” has that are not in “branch1”. While if used with three dots it will compare the top of the right branch with the common ancestor of the two branches (see [here](https://devconnected.com/how-to-compare-two-git-branches/)).

To see the commit differences between two branches, use `git log` and specify the branches that you want to compare.
`git log [branch1]..[branch2]`

> Note: This won’t show you the actual file differences between the two branches but only the commits.

Compare commits:
```
git diff 6eb715d
git diff 6eb715d..HEAD
git diff 6eb715d..537a09f
```

Compare commits of file:
```
git diff 6eb715d [filename]
git diff 6eb715d..537a09f [filename]
```

Compare without caring about whitespaces:
```
git diff -b 6eb715d..HEAD
git diff --ignore-space-change 6eb715d..HEAD
```

This ignores differences even if one line has whitespace where the other line has none:
```
git diff -w 6eb715d..HEAD
git diff --ignore-all-space 6eb715d..HEAD
```

Show what revision and author last modified each line of a file: `git blame -L10,+1 [filename]`

## Collaborate

Get everything ready to commit: `git add .`

Get custom file ready to commit: `git add index.html`

Commit changes: `git commit -m "Message"`

Commit changes with title and description: `git commit -m "Title" -m "Description..."`

Add and commit in one step: `git commit -a -m "Message"`

Update most recent unpushed commit message: `git commit --amend -m "New Message"`

Fetch all changes from the remote and remove deleted branches: `git fetch -a -p`

Push to a branch and set it as the default upstream: `git push -u origin [master]`

Pull a specific branch: `git pull origin [branchname]`

Clone: `git clone https://github.com/user/project.git`

Clone to local folder:
`git clone https://github.com/user/project.git ~/dir/folder`

Resolve conflicts after attempted merge by means of a mergetool (see the config file above in the 'General' section): `git mergetool`

## Ignore 

Add a `.gitignore` file at the root of the repository to instruct git to not track specific file types or filepaths: `vi .gitignore`

You can create your own file from an online template generator: https://www.toptal.com/developers/gitignore

## Archive

Create a zip-archive: `git archive --format zip --output filename.zip master`

## Security

To encrypt your private data inside a git repo: https://git-secret.io/

## Large File Storage

To version large files (.wav, .pdf, etc) in a git repository: https://git-lfs.github.com/ (it's not free)

### Resources to learn more:

1. [Learn Git Branching](https://learngitbranching.js.org/)
2. [Pro Git](https://git-scm.com/book/en/v2)
3. [Oh Shit, Git!?!](https://ohshitgit.com/)
4. [Git Cheatsheet](https://gist.github.com/hofmannsven/6814451)