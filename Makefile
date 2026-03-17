.PHONY: install lint type test all setup-charter update-charter

install:
	poetry install

lint:
	poetry run ruff check .

type:
	poetry run mypy src

test:
	poetry run pytest

all: lint type test

## dev-charter helpers
setup-charter:
	git remote add dev-charter https://github.com/y-marui/dev-charter
	git fetch dev-charter
	git subtree add --prefix=docs/dev-charter dev-charter main --squash

update-charter:
	git subtree pull --prefix=docs/dev-charter dev-charter main --squash
