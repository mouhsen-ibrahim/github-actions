test:
	@echo "Running tests..."
	@python -m unittest discover -p "*_test.py"

coverage:
	@echo "Generating coverage report..."
	@coverage run -m unittest discover -p "*_test.py"
	@coverage report
	@coverage html
