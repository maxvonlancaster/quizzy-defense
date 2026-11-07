# Railway Deployment Guide for Quizzy Defense

This guide provides step-by-step instructions to deploy your full-stack application (Frontend, Backend, and Database) to Railway.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Setup Railway Account](#setup-railway-account)
4. [Environment Variables Setup](#environment-variables-setup)
5. [Deploy to Railway](#deploy-to-railway)
6. [Verify Deployment](#verify-deployment)
7. [Troubleshooting](#troubleshooting)
8. [Scaling and Monitoring](#scaling-and-monitoring)

---

## Prerequisites

Before starting, ensure you have:

- A Railway account (free tier available at https://railway.app)
- Git installed on your machine
- Docker installed (for local testing)
- Your project repository pushed to GitHub
- All necessary API keys and secrets documented

Required API Keys (if using):
- OpenRouter API Key (for AI features)
- Google OAuth credentials (Client ID, Client Secret)
- SendGrid API Key (for email notifications)
- Cloudinary credentials (for image uploads)

---

## Project Structure

Your project consists of:

```
quizzy-defense/
├── api/                    # NestJS backend (Node.js)
│   ├── src/
│   ├── package.json
│   └── tsconfig.json
├── ui/                     # React + Vite frontend
│   ├── src/
│   ├── package.json
│   └── vite.config.js
├── Dockerfile             # Multi-stage build (backend + frontend)
├── docker-compose.yml     # Local development setup
└── .env.example          # Environment variables template
```

**Key Technologies:**
- Backend: NestJS (TypeScript)
- Frontend: React 19 + Vite
- Database: PostgreSQL 16
- Real-time: Socket.io (WebSockets)

---

## Setup Railway Account

### 1. Create Railway Account

1. Go to https://railway.app
2. Click "Login" → "Sign up"
3. Choose your preferred authentication method (GitHub recommended)
4. Complete the signup process

### 2. Create a New Project

1. Click "New Project" in your Railway dashboard
2. Select "Empty Project"
3. Give your project a name: `quizzy-defense`

---

## Environment Variables Setup

### 1. Create Environment Variables Document

Before deploying, gather all required environment variables:

**Critical Variables:**

```env
# API Configuration
NODE_ENV=production
PORT=3000
CORS_ORIGIN=https://your-railway-domain.railway.app
FRONTEND_URL=https://your-railway-domain.railway.app

# Database (Railway will provide PostgreSQL connection)
DATABASE_URL=postgresql://user:password@host:port/database
DB_HOST=your-railway-postgres-host
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your-secure-password
DB_DATABASE=railway

# JWT Configuration (Generate a strong random string)
JWT_SECRET=your_very_long_random_secret_key_here_minimum_32_characters

# Optional API Integrations
OPENROUTER_API_KEY=your_openrouter_key
OPENROUTER_MODEL=openai/gpt-4o
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=https://your-railway-domain.railway.app/auth/google/callback
SENDGRID_API_KEY=your_sendgrid_key
SENDGRID_SENDER=noreply@yourdomain.com
EMAIL_RESET_PASSWORD_URL=https://your-railway-domain.railway.app/reset-password
EMAIL_RESET_TEMPLATE_ID=your_sendgrid_template_id

# Cloudinary (for image uploads)
VITE_CLOUDINARY_CLOUD_NAME=your_cloud_name
VITE_CLOUDINARY_UPLOAD_PRESET=your_preset
VITE_CLOUDINARY_API_FOLDER=quizzy
```

### 2. Generate Secure JWT Secret

Run this command to generate a strong JWT secret:

**On macOS/Linux:**
```bash
openssl rand -base64 32
```

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String((1..32 | ForEach-Object { [byte](Get-Random -Maximum 256) }))
```

---

## Deploy to Railway

### Option 1: Deploy from GitHub (Recommended)

#### Step 1: Connect Repository

1. In Railway dashboard, click "New"
2. Select "GitHub Repo"
3. Authorize Railway to access your GitHub account
4. Select your `quizzy-defense` repository
5. Click "Deploy Now"

#### Step 2: Add PostgreSQL Database

1. In your Railway project, click "New"
2. Select "PostgreSQL"
3. Railway will automatically provision a PostgreSQL instance
4. The database connection will be available as an environment variable

#### Step 3: Configure Environment Variables

1. Go to your Railway project dashboard
2. Click on the "Variables" tab (or click the service and go to Variables)
3. Add all environment variables from the document above:
   - For each variable, click "Add Variable"
   - Enter the key and value
   - Save changes

**Important:** Railway automatically detects the PostgreSQL service and injects `DATABASE_URL`.

#### Step 4: Configure Build Settings

1. Click on your application service (named after your GitHub repo)
2. Go to the "Settings" tab
3. Set the following:
   - **Start Command:** Leave empty (uses Dockerfile CMD)
   - **Dockerfile Path:** `Dockerfile` (or leave default)
   - **Build Command:** Leave empty (uses Dockerfile)

### Option 2: Deploy Using Railway CLI

#### Step 1: Install Railway CLI

```bash
npm i -g @railway/cli
```

#### Step 2: Login to Railway

```bash
railway login
```

#### Step 3: Initialize Project

```bash
railway init
```

#### Step 4: Set Environment Variables

```bash
# Set variables one by one
railway variables set NODE_ENV production
railway variables set PORT 3000
railway variables set JWT_SECRET "your_generated_secret"
railway variables set DATABASE_URL "postgresql://..."
# ... add other variables
```

Or create a `.env` file and use:

```bash
railway variables load .env
```

#### Step 5: Deploy

```bash
railway up
```

---

## Verify Deployment

### 1. Check Build Status

1. Go to Railway dashboard
2. Click on your project
3. Click the application service
4. Go to the "Deployments" tab
5. Check the latest deployment status

**Expected Status:** ✅ Running (green)

### 2. View Logs

1. Click on the application service
2. Go to the "Logs" tab
3. Look for:
   - Database connection successful
   - Server listening on port 3000
   - No TypeORM migration errors

**Expected Log Output:**
```
[NestFactory] Instantiating NestApplication
[TypeOrmModule] TypeORM connected successfully
[NestApplication] Nest application successfully started
```

### 3. Test the Application

```bash
# Get your Railway domain
# Dashboard → Project → Application → Settings → Domain

curl https://your-railway-domain.railway.app/api/health
# Expected response: Success or health check data
```

### 4. Test Frontend Access

1. Open https://your-railway-domain.railway.app in your browser
2. You should see your React application
3. Check browser console (F12) for any API connection errors

### 5. Test WebSocket Connection (Real-time Features)

```bash
# Check if Socket.io is working
# Use browser DevTools → Network → WS tab
# Should see WebSocket connection to your domain
```

---

## Troubleshooting

### Issue 1: Database Connection Error

**Error Message:**
```
Error: connect ECONNREFUSED
```

**Solution:**
1. Verify `DATABASE_URL` is set correctly in Railway Variables
2. Check PostgreSQL service is running in your project
3. Restart the application service

```bash
railway variables set DATABASE_URL "postgresql://user:pass@host:5432/dbname"
railway redeploy
```

### Issue 2: Port Already in Use

**Error Message:**
```
Port 3000 already in use
```

**Solution:**
1. Railway automatically handles this
2. If issue persists, change PORT variable to 3001 or 5000
3. Redeploy

### Issue 3: TypeORM Migrations Not Running

**Error Message:**
```
No migrations found
```

**Solution:**
1. Migrations run automatically on startup
2. Ensure migrations folder exists: `api/src/database/migrations/`
3. Check migrations are compiled in `dist/` folder
4. Manually run migrations via SSH or add to startup script:

Add to `api/src/main.ts`:
```typescript
import { DataSource } from 'typeorm';
import dataSource from './database/data-source';

async function bootstrap() {
	// ... existing code ...

	// Run migrations
	if (!dataSource.isInitialized) {
		await dataSource.initialize();
	}
	if (!dataSource.migrations.length) {
		await dataSource.runMigrations();
	}

	// ... rest of code ...
}
```

### Issue 4: CORS Errors in Browser

**Error Message:**
```
Access to XMLHttpRequest at 'https://...' from origin 'https://...' 
has been blocked by CORS policy
```

**Solution:**
1. Update `CORS_ORIGIN` environment variable to match your Railway domain
2. Ensure it includes the protocol: `https://your-railway-domain.railway.app`
3. Restart the application

```bash
railway variables set CORS_ORIGIN "https://your-railway-domain.railway.app"
railway redeploy
```

### Issue 5: Frontend Blank Page or 404

**Error Message:**
- Blank white page
- 404 on index.html

**Solution:**
1. Verify frontend build was successful
2. Check Dockerfile properly copies frontend dist
3. Confirm NestJS serves static files from `public/` directory
4. Add to `api/src/app.module.ts`:

```typescript
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

@Module({
  imports: [
	ServeStaticModule.forRoot({
	  rootPath: join(__dirname, '..', 'public'),
	  exclude: ['/api*'],
	}),
	// ... other imports
  ],
})
export class AppModule {}
```

### Issue 6: WebSocket Connection Failed

**Error Message:**
```
WebSocket connection failed
```

**Solution:**
1. WebSockets should work with Railway automatically
2. If not connecting, check CORS settings
3. Update frontend to use correct WebSocket URL:

```javascript
// In your frontend Socket.io connection
const socket = io(process.env.VITE_API_URL || window.location.origin, {
	transports: ['websocket', 'polling'],
});
```

3. Add to backend main.ts:

```typescript
const app = await NestFactory.create(AppModule);
app.enableCors({
	origin: process.env.CORS_ORIGIN,
	credentials: true,
	methods: ['GET', 'POST'],
	allowedHeaders: ['Content-Type'],
});
```

---

## Scaling and Monitoring

### 1. View Resource Usage

1. Dashboard → Project → Application → "Metrics" tab
2. Monitor:
   - CPU usage
   - Memory usage
   - Network I/O
   - Request count

### 2. Scale Up Resources

1. Click application service
2. Go to "Settings" tab
3. Adjust resource allocation:
   - Memory: Start with 512MB, scale to 1GB+ as needed
   - CPU: Auto-scaled based on load

### 3. Enable Auto-Scaling

1. In Settings, check "Auto Scaling"
2. Set min/max replicas based on expected traffic

### 4. View Logs in Production

```bash
# Using Railway CLI
railway logs -f

# Or via dashboard
# Dashboard → Project → Application → Logs tab
```

### 5. Monitor Database

1. Click PostgreSQL service
2. Go to "Metrics" tab
3. Monitor connections, active queries, disk usage

### 6. Setup Error Tracking (Optional)

Add Sentry for error monitoring:

```bash
npm install @sentry/node --save
```

Then add to `api/src/main.ts`:

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});
```

---

## Local Testing Before Deployment

### Test Locally with Docker Compose

```bash
# Build the Docker image
docker build -t quizzy-defense:latest .

# Run with Docker Compose (includes PostgreSQL)
docker-compose up -d

# Check logs
docker-compose logs -f app

# Stop services
docker-compose down
```

### Test Environment Variables Locally

1. Create `.env.local` in root directory
2. Add your test environment variables
3. Update docker-compose.yml to use them:

```yaml
services:
  app:
	env_file: .env.local
```

4. Run: `docker-compose up`

---

## Post-Deployment Checklist

- [ ] Application is running (green status in Railway)
- [ ] PostgreSQL database is initialized
- [ ] Frontend loads without errors
- [ ] API endpoints respond correctly
- [ ] WebSocket connection works
- [ ] All API keys are set (Google, SendGrid, etc.)
- [ ] CORS_ORIGIN matches your Railway domain
- [ ] JWT_SECRET is strong and random
- [ ] Database backups are enabled
- [ ] Monitoring/alerts are configured
- [ ] SSL certificate is active (automatic with Railway)
- [ ] All environment variables are secured

---

## Useful Commands

### Update Application

```bash
# Using Git push (automatic with GitHub integration)
git push origin main

# Using Railway CLI
railway redeploy
```

### Access Database

```bash
# Using Railway CLI
railway postgres exec psql -U postgres -d railway
```

### View Network Metrics

```bash
# Real-time logs
railway logs -f

# Filter by service
railway logs -f --service app
```

### Restart Application

```bash
railway restart
```

---

## Additional Resources

- Railway Docs: https://docs.railway.app
- NestJS Deployment: https://docs.nestjs.com/deployment
- Docker Best Practices: https://docs.docker.com/develop/dev-best-practices/
- PostgreSQL on Railway: https://docs.railway.app/databases/postgresql
- Environment Variables: https://docs.railway.app/develop/variables

---

## Support & Help

If you encounter issues:

1. Check Railway logs: Dashboard → Logs tab
2. Review this troubleshooting guide
3. Check application health: `https://your-domain.railway.app/api/health`
4. Contact Railway support: https://railway.app/support
5. Review NestJS docs: https://docs.nestjs.com

---

**Last Updated:** 2024
**Version:** 1.0
