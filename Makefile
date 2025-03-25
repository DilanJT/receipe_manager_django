.PHONY: setup install init-project run migrations makemigrations superuser clean test lint shell help

# Variables
PYTHON_VERSION := 3.10.12
PROJECT_NAME := myproject

help:
	@echo "Django REST Framework project with Poetry"
	@echo ""
	@echo "Usage:"
	@echo "  make setup              Setup Python version with pyenv"
	@echo "  make install            Install dependencies with Poetry"
	@echo "  make init-project       Initialize Django REST Framework project"
	@echo "  make run                Run development server"
	@echo "  make migrations         Run Django migrations"
	@echo "  make makemigrations     Create new migrations"
	@echo "  make superuser          Create superuser"
	@echo "  make clean              Remove Python artifacts"
	@echo "  make test               Run tests"
	@echo "  make lint               Run linting"
	@echo "  make shell              Run Django shell"
	@echo ""

setup:
	@echo "Setting up Python $(PYTHON_VERSION) with pyenv..."
	pyenv install $(PYTHON_VERSION) --skip-existing
	pyenv local $(PYTHON_VERSION)
	pip install --upgrade pip
	pip install poetry
	@echo "Python setup complete."

install:
	@echo "Installing dependencies with Poetry..."
	poetry config virtualenvs.in-project true
	poetry install
	@echo "Dependencies installed."

init-project:
	@echo "Initializing Poetry project..."
	@if [ ! -f "pyproject.toml" ]; then \
		poetry init --name $(PROJECT_NAME) --description "Django REST Framework project" --author "Your Name <your.email@example.com>" --python "^$(PYTHON_VERSION)" --no-interaction; \
		poetry add django djangorestframework django-cors-headers djangorestframework-simplejwt python-dotenv; \
		poetry add --group dev black isort flake8 pytest pytest-django; \
		echo "Poetry project initialized."; \
	else \
		echo "pyproject.toml already exists. Skipping initialization."; \
	fi
	@echo "Creating Django project..."
	@if [ ! -d "$(PROJECT_NAME)" ]; then \
		poetry run django-admin startproject $(PROJECT_NAME) .; \
		mkdir -p $(PROJECT_NAME)/apps; \
		touch $(PROJECT_NAME)/apps/__init__.py; \
		echo "Django project created."; \
	else \
		echo "Django project already exists. Skipping creation."; \
	fi
	@echo "Creating .env file..."
	@if [ ! -f ".env" ]; then \
		echo "DEBUG=True" > .env; \
		echo "SECRET_KEY=$(shell poetry run python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" >> .env; \
		echo "ALLOWED_HOSTS=localhost,127.0.0.1" >> .env; \
		echo ".env file created."; \
	else \
		echo ".env file already exists. Skipping creation."; \
	fi

run:
	poetry run python manage.py runserver

migrations:
	poetry run python manage.py migrate

makemigrations:
	poetry run python manage.py makemigrations

superuser:
	poetry run python manage.py createsuperuser

clean:
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
	find . -name "*.egg-info" -delete
	find . -name "*.egg" -delete
	rm -rf .coverage htmlcov/ .pytest_cache/ dist/ build/

test:
	poetry run pytest

lint:
	poetry run black .
	poetry run isort .
	poetry run flake8 .

shell:
	poetry shell