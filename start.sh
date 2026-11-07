#!/bin/sh
# Start script for Railway deployment
# Handles database migrations and starts the server

set -e

cd /app/api

echo "🚀 Starting Quizzy Defense Application..."

# Check if database is accessible
echo "📦 Waiting for database connection..."
MAX_RETRIES=30
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
  if node -e "require('pg').Client({connectionString: process.env.DATABASE_URL || 'postgresql://' + process.env.DB_USERNAME + ':' + process.env.DB_PASSWORD + '@' + process.env.DB_HOST + ':' + process.env.DB_PORT + '/' + process.env.DB_DATABASE}).connect().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); })" 2>/dev/null; then
	echo "✅ Database connection successful"
	break
  fi

  RETRY=$((RETRY + 1))
  echo "⏳ Retrying database connection... ($RETRY/$MAX_RETRIES)"
  sleep 2
done

if [ $RETRY -eq $MAX_RETRIES ]; then
  echo "❌ Failed to connect to database after $MAX_RETRIES attempts"
  exit 1
fi

# Run database migrations if migration runner exists
if [ -f "dist/database/migrations" ]; then
  echo "🔄 Running database migrations..."
  npm run migration:run || echo "⚠️  Migrations skipped or already run"
fi

echo "✅ Initialization complete. Starting server..."
# Start the application
exec node dist/main
