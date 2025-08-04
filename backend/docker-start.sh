#!/bin/bash

# Docker start script for FastAPI backend with PostgreSQL

echo "🐳 Starting FastAPI Backend with PostgreSQL..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Determine the correct compose command
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "❌ Neither 'docker compose' nor 'docker-compose' found. Please install Docker Compose."
    exit 1
fi

# Build and start the services
echo "📦 Building and starting services..."
$COMPOSE_CMD up --build -d

echo "✅ Services started! Your API should be available at http://localhost:8000"
echo "📊 PostgreSQL is available at localhost:5432"
echo "📚 API docs available at http://localhost:8000/docs"
