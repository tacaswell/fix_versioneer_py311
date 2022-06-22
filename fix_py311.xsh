from pathlib import Path


script_dir = Path($(pwd).strip())

def fix_one(fname, gh_account):
    p = Path(fname)
    work_dir = p.parent

    print(work_dir)
    cd @(work_dir)
    git remote update --prune
    hub fork

    if gh_account in $(git remote get-url origin):
        push_target = 'origin'
    else:
        push_target = gh_account

    if $(git ls-remote --heads @(gh_account) fix_py312) != '':
        git checkout fix_py312
        print('already done')
        return
    if $(git branch --list main) != '':
        git switch main
    elif $(git branch --list master) != '':
        git switch master
    else:
        raise Exception("can not guess default branch")
    if $(git ls-remote --heads origin master) != '':
        with ${...}.swap(RAISE_SUBPROC_ERROR=True):
            git branch -u origin/master
    elif $(git ls-remote --heads origin main) != '':
        with ${...}.swap(RAISE_SUBPROC_ERROR=True):
            git branch -u origin/main
    git pull

    if not !(test -f versioneer.py):
        print('no file!')
        return

    if not !(git switch -c fix_py312):
        print(f"FAILED {work_dir}")
        return

    if !(grep '# Version: 0.19' versioneer.py):
        return
    if !(grep 'with open(setup_cfg) as f:' versioneer.py):
        patch -p 1 < @(script_dir / 'patch1.patch')
    elif !(grep 'with open(setup_cfg, "r") as f:' versioneer.py):
        patch -p 1 <  @(script_dir / 'patch2.patch')


    with ${...}.swap(RAISE_SUBPROC_ERROR=True):
        git add versioneer.py
        git commit -m """MNT: change from using SafeConfigParser to ConfigParser

SafeConfigParser has been deprecated since Python 3.2 and will
be removed in py312.

https://github.com/python/cpython/pull/28292
https://bugs.python.org/issue45173
https://github.com/python/cpython/issues/89336
"""
        git push @(push_target) fix_py312
    hub pull-request -m """Fix versioneer compat with py312

SafeConfigParser has been deprecated since Python 3.2 and will be removed in py312.

https://github.com/python/cpython/pull/28292
https://bugs.python.org/issue45173
https://github.com/python/cpython/issues/89336
"""

base_path = '/path/to/your/source'

targets = ['some_repo/versioneer.py', 'some_other_repo/versioneer.py']

for target in targets:
    if not len(target):
        continue
    fix_one(f'{base_path}/{target}', 'YOUR_GH_USER')
