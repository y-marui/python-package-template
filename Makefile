.PHONY: install lint type test all update-charter

install:
	poetry install

lint:
	poetry run ruff check .

type:
	poetry run mypy src

test:
	poetry run pytest

all: lint type test

update-charter:
	git subtree pull --prefix=docs/dev-charter dev-charter main --squash
