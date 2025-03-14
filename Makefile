DIST ?= dist/
PIP ?= $(VENV_BIN)/pip
PYTHON ?= $(VENV_BIN)/python
PYTHON_VERSION ?= python3.10
VENV ?= .venv
VENV_BIN ?= $(VENV)/bin
# .PHONY: dev-requirements.txt requirements.txt release bdist_wheel clean-dist clean-pyc

clean-venv:
	rm -rf $(VENV)
clean-dist: ## remove dist artifacts
	rm -rf $(DIST)

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean: clean-dist clean-pyc clean-venv

sdist: ## builds source package
	$(PYTHON) setup.py sdist && ls -l dist

bdist_wheel: ## builds wheel package
	$(PYTHON) setup.py bdist_wheel && ls -l dist

dist: clean-dist sdist bdist_wheel

release: dist
	twine upload dist/*

pip-sync:
	$(VENV_BIN)/pip-sync

.venv:
	$(PYTHON_VERSION) -m venv $(VENV)
	$(PIP) install pip-tools
	$(PIP) install -r requirements.txt
	$(PIP) install -r dev-requirements.txt

requirements.txt: requirements.in
	$(VENV_BIN)/pip-compile --generate-hashes

dev-requirements.txt: dev-requirements.in
	$(VENV_BIN)/pip-compile --generate-hashes dev-requirements.in --output-file dev-requirements.txt

test:
	$(VENV_BIN)/pytest

tox:
	python3 -m pip install --upgrade pip
	pip install tox tox-gh-actions

lint:
	black chef