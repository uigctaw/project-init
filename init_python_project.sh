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

read -p 'Initialize Poetry toml file? [yes]' agreed_poetry
if [[ ${agreed:-yes} == yes ]]; then
    poetry init
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
EOM

cat .gitignore

fi

if [[ $venv_full_path ]]; then
    question='Create flake8, mypy and bandit exec scripts? [yes]'
    read -p "$question" agreed
    if [[ ${agreed:-yes} == yes ]]; then
        cat > flake8.sh << EOM
#!/bin/bash
poetry run python -m flake8 $project
poetry run python -m flake8 tests
EOM
        chmod u+x flake8.sh 

        cat > mypy.sh << EOM
#!/bin/bash
poetry run python -m mypy $project
poetry run python -m mypy tests
EOM
        chmod u+x mypy.sh 

        cat > bandit.sh << EOM
#!/bin/bash
poetry run python -m bandit -rq $project
EOM
        chmod u+x bandit.sh 

        if [[ ${agreed_poetry:-yes} == yes ]]; then
            poetry add --dev flake8
            poetry add --dev mypy
            poetry add --dev bandit
        fi
    fi
fi
