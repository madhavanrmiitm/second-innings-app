#!/bin/bash

# Test Runner Script for Second Innings Backend
# This script helps you run tests in different ways

set -e

echo "🧪 Second Innings Backend Test Runner"
echo "======================================"

# Set up test environment variables
export DATABASE_URL="postgresql://testuser:testpass@localhost:5432/testdb"
export FIREBASE_PROJECT_ID="test-project"
export GEMINI_API_KEY="test-key"

# Function to check if pytest is installed
check_pytest() {
    if ! python -m pytest --version > /dev/null 2>&1; then
        echo "❌ pytest not found. Installing dependencies..."
        pip install -r requirements.txt
    fi
}

# Function to run all tests
run_all_tests() {
    echo "🔍 Running all tests..."
    python -m pytest app/tests/ -v
}

# Function to run specific test file
run_specific_test() {
    if [ -z "$1" ]; then
        echo "❌ Please provide a test file name"
        echo "Example: ./run_tests.sh auth"
        exit 1
    fi
    
    echo "🔍 Running tests for: $1"
    python -m pytest "app/tests/test_${1}_controller.py" -v
}

# Function to run tests with coverage
run_with_coverage() {
    echo "🔍 Running tests with coverage..."
    python -m pytest app/tests/ --cov=app --cov-report=html --cov-report=term
}

# Function to run only unit tests
run_unit_tests() {
    echo "🔍 Running unit tests only..."
    python -m pytest app/tests/ -m unit -v
}

# Function to run integration tests
run_integration_tests() {
    echo "🔍 Running integration tests..."
    python -m pytest app/tests/ -m integration -v
}

# Function to run tests in parallel
run_parallel_tests() {
    echo "🔍 Running tests in parallel..."
    python -m pytest app/tests/ -n auto -v
}

# Main script logic
case "${1:-all}" in
    "all")
        check_pytest
        run_all_tests
        ;;
    "auth")
        check_pytest
        run_specific_test "auth"
        ;;
    "admin")
        check_pytest
        run_specific_test "admin"
        ;;
    "user")
        check_pytest
        run_specific_test "user"
        ;;
    "tickets")
        check_pytest
        run_specific_test "tickets"
        ;;
    "coverage")
        check_pytest
        pip install pytest-cov > /dev/null 2>&1 || true
        run_with_coverage
        ;;
    "unit")
        check_pytest
        run_unit_tests
        ;;
    "integration")
        check_pytest
        run_integration_tests
        ;;
    "parallel")
        check_pytest
        pip install pytest-xdist > /dev/null 2>&1 || true
        run_parallel_tests
        ;;
    "help")
        echo "Available commands:"
        echo "  all          - Run all tests (default)"
        echo "  auth         - Run authentication tests"
        echo "  admin        - Run admin controller tests"
        echo "  user         - Run user controller tests"
        echo "  tickets      - Run tickets controller tests"
        echo "  coverage     - Run tests with coverage report"
        echo "  unit         - Run unit tests only"
        echo "  integration  - Run integration tests only"
        echo "  parallel     - Run tests in parallel"
        echo "  help         - Show this help message"
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run './run_tests.sh help' for available commands"
        exit 1
        ;;
esac

echo "✅ Test execution completed!"
