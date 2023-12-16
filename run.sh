#!/bin/bash

set -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

function try-load-dotenv {

    if [ ! -f "$THIS_DIR/.env" ]; then
        echo "no .env file found"
        return 1
    fi

    while read -r line; do
        export "$line"
    done < <(grep -v '^#' "$THIS_DIR/.env" | grep -v '^$')
}

function clean {
    rm -rf dist build test-reports

    find . \
      -type d \
      \( \
        -name "*cache*" \
        -o -name "*.dist-info" \
        -o -name "*.egg-info" \
        -o -name "*htmlcov" \
      \) \
      -not -path "*env/*" \
      -exec rm -r {} + || true

    find . \
      -type f \
      -name "*.pyc" \
      -not -path "*env/*" \
      -exec rm {} +
}

function lint {
    pre-commit run --all-files
}

function lint:ci {
    SKIP=no-commit-on-branch pre-commit run --all-files
}

function install {
    pip install --upgrade pip
    pip install -e "${THIS_DIR}/[dev]"
}

function build {
    python -m build --sdist --wheel "${THIS_DIR}/"
}

function publish:test {
    try-load-dotenv || true
    twine upload dist/* \
    --repository testpypi \
    --username=__token__ \
    --password="$TEST_PYPI_TOKEN"
}

function release:test {
    lint
    clean
    build
    publish:test
}

function publish:prod {
    try-load-dotenv || true
    twine upload dist/* \
    --repository pypi \
    --username=__token__ \
    --password="$PROD_PYPI_TOKEN"
}

function release:prod {
    release:test
    publish:prod
}

function test:quick {
    pytest -m "not slow" "$THIS_DIR/tests"
}

function test {

    PYTEST_EXIT_STATUS=0
    pytest "${@:-$THIS_DIR/tests}" \
    --cov="$THIS_DIR/src/packaging_demo" \
    --cov-report html \
    --cov-report term \
    --cov-report xml \
    --junit-xml "$THIS_DIR/test-reports/report.xml" \
    --cov-fail-under 80 || ((PYTEST_EXIT_STATUS+=$?))

    mv coverage.xml "$THIS_DIR/test-reports"
    mv htmlcov "$THIS_DIR/test-reports"

    return $PYTEST_EXIT_STATUS
}

function test:ci {

    PYTEST_EXIT_STATUS=0
    INSTALLED_PKG_DIR="$(python -c 'import packaging_demo; print(packaging_demo.__path__[0])')"
    pytest "$THIS_DIR/tests/" \
    --cov="$INSTALLED_PKG_DIR" \
    --cov-report html \
    --cov-report term \
    --cov-report xml \
    --junit-xml "$THIS_DIR/test-reports/report.xml" \
    --cov-fail-under 80 || ((PYTEST_EXIT_STATUS+=$?))

    mv coverage.xml "$THIS_DIR/test-reports/"
    mv htmlcov "$THIS_DIR/test-reports/"

    return $PYTEST_EXIT_STATUS
}

function serve-coverage-report {
    python -m http.server --directory "$THIS_DIR/htmlcov"
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}
