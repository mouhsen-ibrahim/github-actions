test:
	@echo "Running tests..."
	@python -m unittest discover -p "*_test.py"

coverage:
	@echo "Generating coverage report..."
	@coverage run --branch --source=services -m unittest discover -p "*_test.py"
	@coverage report -m --omit "*/site-packages/*,*/dist-packages/*,*/.venv/*,*_test.py"
	@coverage html
