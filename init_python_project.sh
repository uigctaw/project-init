#!/bin/bash

project=$(basename $PWD)

read -p 'Create project and test folders? [yes]' agreed
if [[ ${agreed:-yes} == yes ]]; then
    mkdir $project
    touch $project/__init__.py
    mkdir tests
    mkdir tests/unit
    touch tests/unit/__init__.py
    mkdir tests/integration
    touch tests/integration/__init__.py
fi

read -p 'Create Python virtual environment? [yes]' agreed
if [[ ${agreed:-yes} == yes ]]; then 
    read -p 'Please enter folder name [.venv]' venv_folder
    venv_folder=${venv_folder:-.venv}
    venv_full_path=$venv_folder/bin/python
    read -p 'Please enter python version [python3.8]' python_name
    eval ${python_name:-python3.8} -m venv $venv_folder
fi

read -p 'Initialize Poetry toml file? [yes]' agreed_poetry
if [[ ${agreed:-yes} == yes ]]; then
    poetry init

    if [[ -z $venv_folder ]]; then
        question="Change Poetry's virtual env to the one created before?"
        question="$question ($venv_full_path)"
        question="$question [yes]"
        read -p "$question" agreed 
        if [[ ${agreed:-yes} == yes ]]; then
            poetry env use $venv_full_path
        fi
    fi
fi

read -p 'Initialize git repository? [yes]' agreed
if [[ ${agreed:-yes} == yes ]]; then
    git init
fi

read -p 'Create .gitignore with some defaults? [yes]' agreed
if [[ ${agreed:-yes} == yes ]]; then
    cat > .gitignore << EOM
.*
!/.gitignore
dist
*.egg-info
**/__pycache__
res
EOM

cat .gitignore
fi

if [[ $venv_full_path ]]; then
    question='Create flake8, mypy and bandit exec scripts? [yes]'
    read -p "$question" agreed
    if [[ ${agreed:-yes} == yes ]]; then
        cat > flake8.sh << EOM
#!/bin/bash
$venv_full_path -m flake8 $project
$venv_full_path -m flake8 tests
EOM
        chmod u+x flake8.sh 

        cat > mypy.sh << EOM
#!/bin/bash
$venv_full_path -m mypy --strict $project
$venv_full_path -m mypy --strict tests
EOM
        chmod u+x mypy.sh 

        cat > bandit.sh << EOM
#!/bin/bash
$venv_full_path -m bandit -rq $project
$venv_full_path -m bandit -rq tests
EOM
        chmod u+x bandit.sh 

        if [[ ${agreed_poetry:-yes} == yes ]]; then
            poetry add flake8
            poetry add mypy
            poetry add bandit
        fi
    fi
fi
