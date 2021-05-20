## git refresher (+ git-secret)

### Quick refresher

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

Get everything ready to commit: `git add .`

Get custom file ready to commit: `git add index.html`

Commit changes: `git commit -m "Message"`

Commit changes with title and description: `git commit -m "Title" -m "Description..."`

Add and commit in one step: `git commit -a -m "Message"`

Update most recent unpushed commit message: `git commit --amend -m "New Message"`

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

Fetch all changes from the remote and remove deleted branches: `git fetch -a -p`

Create and switch to a new branch:`git branch -b [branchname]`

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

Put in stash: `git stash save "Message"`

Show stash: `git stash list`

Show stash stats: `git stash show stash@{0}`

Show stash changes: `git stash show -p stash@{0}`

Use custom stash item and drop it: `git stash pop stash@{0}`

Use custom stash item and do not drop it: `git stash apply stash@{0}`

Use custom stash item and index: `git stash apply --index`

Create branch from stash: `git stash branch new_branch`

Delete custom stash item: `git stash drop stash@{0}`

Delete complete stash: `git stash clear`

## Gitignore & Gitkeep

About: https://help.github.com/articles/ignoring-files

Useful templates: https://github.com/github/gitignore

Add or edit gitignore: 
`nano .gitignore`

Track empty dir: 
`touch dir/.gitkeep`

## Log

Show commits:
`git log`

Show oneline-summary of commits:
`git log --oneline`

Show oneline-summary of commits with full SHA-1:
`git log --format=oneline`

Show oneline-summary of the last three commits:
`git log --oneline -3`

Show only custom commits:
`git log --author="Sven"`
`git log --grep="Message"`
`git log --until=2013-01-01`
`git log --since=2013-01-01`

Show only custom data of commit:
`git log --format=short`
`git log --format=full`
`git log --format=fuller`
`git log --format=email`
`git log --format=raw`

Show changes:
`git log -p`

Show every commit since special commit for custom file only:
`git log 6eb715d.. index.html`

Show changes of every commit since special commit for custom file only:
`git log -p 6eb715d.. index.html`

Show stats and summary of commits:
`git log --stat --summary`

Show history of commits as graph:
`git log --graph`

Show history of commits as graph-summary:
`git log --oneline --graph --all --decorate`

## Compare

Compare modified files:
`git diff`

Compare modified files and highlight changes only:
`git diff --color-words index.html`

Compare modified files within the staging area:
`git diff --staged`

Compare branches:
`git diff master..branchname`

Compare branches like above:
`git diff --color-words master..branchname^`

Compare commits:
`git diff 6eb715d`
`git diff 6eb715d..HEAD`
`git diff 6eb715d..537a09f`

Compare commits of file:
`git diff 6eb715d index.html`
`git diff 6eb715d..537a09f index.html`

Compare without caring about spaces:
`git diff -b 6eb715d..HEAD` or:
`git diff --ignore-space-change 6eb715d..HEAD`

Compare without caring about all spaces:
`git diff -w 6eb715d..HEAD` or:
`git diff --ignore-all-space 6eb715d..HEAD`

Useful comparings:
`git diff --stat --summary 6eb715d..HEAD`

Blame:
`git blame -L10,+1 index.html`

## Releases & Version Tags

Show all released versions:
`git tag`

Show all released versions with comments:
`git tag -l -n1`

Create release version:
`git tag v1.0.0`

Create release version with comment:
`git tag -a v1.0.0 -m 'Message'`

Checkout a specific release version:
`git checkout v1.0.0`

## Collaborate

Show remote:
`git remote`

Show remote details:
`git remote -v`

Add remote upstream from GitHub project:
`git remote add upstream https://github.com/user/project.git`

Add remote upstream from existing empty project on server:
`git remote add upstream ssh://root@123.123.123.123/path/to/repository/.git`

Fetch:
`git fetch upstream`

Fetch a custom branch:
`git fetch upstream branchname:local_branchname`

Merge fetched commits:
`git merge upstream/master`

Remove origin:
`git remote rm origin`

Show remote branches:
`git branch -r`

Show all branches (remote and local):
`git branch -a`

Create and checkout branch from a remote branch:
`git checkout -b local_branchname upstream/remote_branchname`

Compare:
`git diff origin/master..master`

Push (set default with `-u`):
`git push -u origin master`

Push:
`git push origin master`

Force-Push:
`git push origin master --force

Pull:
`git pull`

Pull specific branch:
`git pull origin branchname`

Fetch a pull request on GitHub by its ID and create a new branch:
`git fetch upstream pull/ID/head:new-pr-branch`

Clone to localhost:
`git clone https://github.com/user/project.git` or:
`git clone ssh://user@domain.com/~/dir/.git`

Clone to localhost folder:
`git clone https://github.com/user/project.git ~/dir/folder`

Clone specific branch to localhost:
`git clone -b branchname https://github.com/user/project.git`

Clone with token authentication (in CI environment):
`git clone https://oauth2:<token>@gitlab.com/username/repo.git`

Delete remote branch (push nothing):
`git push origin :branchname` or:
`git push origin --delete branchname`

## Archive
Create a zip-archive: `git archive --format zip --output filename.zip master`

Export/write custom log to a file: `git log --author=sven --all > log.txt`

## Troubleshooting
Ignore files that have already been committed to a Git repository: http://stackoverflow.com/a/1139797/1815847

## Security
Hide Git on the web via `.htaccess`: `RedirectMatch 404 /\.git` 
(more info here: http://stackoverflow.com/a/17916515/1815847)

## Large File Storage
Website: https://git-lfs.github.com/

Install: `brew install git-lfs`

Track `*.psd` files: `git lfs track "*.psd"` (init, add, commit and push as written above)

### Resources to learn more:

1. [Learn Git Branching](https://learngitbranching.js.org/)
2. [Pro Git](https://git-scm.com/book/en/v2)
3. [Oh Shit, Git!?!](https://ohshitgit.com/)
4. [Git Cheatsheet](https://gist.github.com/hofmannsven/6814451)