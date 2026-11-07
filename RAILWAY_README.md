# Quizzy Defense - Railway Deployment Setup

This directory contains all necessary files for deploying the Quizzy Defense application to Railway.

## 📋 Files Overview

### Core Deployment Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage Docker build for backend (NestJS) + frontend (React/Vite) |
| `docker-compose.yml` | Local development environment with PostgreSQL |
| `.dockerignore` | Optimizes Docker build by excluding unnecessary files |
| `start.sh` | Custom startup script with database health checks |

### Documentation

| File | Purpose |
|------|---------|
| `RAILWAY_DEPLOYMENT_GUIDE.md` | **READ THIS FIRST** - Complete step-by-step deployment guide |
| `DEPLOYMENT_CHECKLIST.md` | Quick reference checklist for deployment |
| `railway.env.example` | Environment variables template for Railway |

### Project Structure

```
quizzy-defense/
├── api/                          # NestJS Backend
│   ├── src/
│   │   ├── main.ts              # Entry point
│   │   ├── app.module.ts        # Main module
│   │   └── database/
│   │       ├── data-source.ts   # Database configuration
│   │       └── migrations/      # Database migrations
│   ├── dist/                    # Compiled output
│   ├── package.json
│   └── tsconfig.json
├── ui/                           # React + Vite Frontend
│   ├── src/
│   │   ├── main.jsx            # Entry point
│   │   └── App.jsx
│   ├── dist/                   # Built assets
│   ├── package.json
│   └── vite.config.js
├── Dockerfile                    # Multi-stage build
├── docker-compose.yml
├── .dockerignore
├── start.sh
└── RAILWAY_DEPLOYMENT_GUIDE.md
```

## 🚀 Quick Start

### Option 1: Fastest Setup (Recommended)

```bash
# 1. Ensure all code is pushed to GitHub
git add .
git commit -m "Add Railway deployment files"
git push origin main

# 2. Go to https://railway.app
# 3. Create new project
# 4. Select "GitHub Repo" → Your repository
# 5. Add PostgreSQL database service
# 6. Configure environment variables (see railway.env.example)
# 7. Deploy!
```

**Total time:** 10-15 minutes

### Option 2: Test Locally First

```bash
# Build Docker image
docker build -t quizzy-defense:latest .

# Start with PostgreSQL
docker-compose up -d

# Check logs
docker-compose logs -f app

# Access at http://localhost:3000

# Cleanup
docker-compose down
```

## 🔧 Technology Stack

### Backend
- **Framework:** NestJS (TypeScript)
- **Runtime:** Node.js 20
- **Database:** PostgreSQL 16
- **Real-time:** Socket.io (WebSockets)
- **ORM:** TypeORM

### Frontend
- **Framework:** React 19 + Vite
- **Build:** Vite (fast bundler)
- **Styling:** Mantine UI
- **HTTP:** Axios

### Deployment
- **Hosting:** Railway
- **Container:** Docker (multi-stage build)
- **Port:** 3000

## ⚙️ Configuration

### Environment Variables (Critical)

```env
# Copy from railway.env.example and update:

# API
NODE_ENV=production
PORT=3000
JWT_SECRET=<generate-strong-random-secret>

# URLs (update with your Railway domain)
CORS_ORIGIN=https://your-railway-domain.railway.app
FRONTEND_URL=https://your-railway-domain.railway.app

# Database (Railway provides DATABASE_URL automatically)
DATABASE_URL=postgresql://...
```

### Optional API Integrations

- **Google OAuth:** For login functionality
- **SendGrid:** For email notifications
- **OpenRouter:** For AI features
- **Cloudinary:** For image uploads

See `railway.env.example` for all options.

## 📚 Complete Deployment Guide

**For detailed step-by-step instructions, read:**

👉 **[RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md)**

This guide includes:
- Prerequisites and setup
- Environment variables configuration
- GitHub integration setup
- PostgreSQL database setup
- Verification and testing
- Troubleshooting common issues
- Scaling and monitoring
- Post-deployment checklist

## ✅ Quick Checklist

Before deploying:

- [ ] All code committed to GitHub
- [ ] `Dockerfile` is present in root
- [ ] `docker-compose.yml` is present
- [ ] Environment variables ready (see `railway.env.example`)
- [ ] Generate strong JWT_SECRET
- [ ] Gather API keys (Google, SendGrid, etc.)
- [ ] Tested locally with `docker-compose up`

After deploying:

- [ ] Application shows "Running" in Railway
- [ ] Check logs for successful startup
- [ ] Verify frontend loads
- [ ] Test API endpoints
- [ ] Check WebSocket connection
- [ ] All integrations working

## 🐛 Troubleshooting

### Build Fails
```bash
# Test build locally
docker build -t test:latest .
```

### Database Connection Error
- Ensure `DATABASE_URL` is set in Railway
- Check PostgreSQL service is running
- Verify DB credentials match

### CORS Errors
- Update `CORS_ORIGIN` to your Railway domain
- Ensure it matches your actual deployment URL
- Include protocol: `https://`

### Frontend Shows 404
- Check `Dockerfile` copies frontend dist correctly
- Verify `dist/` folder exists after build
- Ensure NestJS serves static files

**For more solutions, see RAILWAY_DEPLOYMENT_GUIDE.md → Troubleshooting**

## 🔐 Security

### Best Practices

✅ **Do:**
- Use environment variables for all secrets
- Generate strong JWT_SECRET (32+ characters)
- Use HTTPS (automatic with Railway)
- Enable CORS only for your domain
- Keep dependencies updated
- Use PostgreSQL with strong password

❌ **Don't:**
- Commit `.env` files to Git
- Hardcode secrets in code
- Use `*` for CORS origin
- Share API keys
- Use weak passwords

## 📊 Monitoring & Logs

### View Logs in Production

**Via Railway Dashboard:**
1. Go to your project
2. Click application service
3. Select "Logs" tab
4. Filter by date/time

**Via Railway CLI:**
```bash
railway login
railway logs -f
```

### Monitor Metrics

- CPU usage
- Memory usage
- Network I/O
- Request count
- Response time

**Access via:** Dashboard → Metrics tab

## 🔄 Deployment Updates

### After Making Code Changes

**Option 1: Automatic (GitHub Integration)**
```bash
# Just push your changes
git push origin main
# Railway automatically redeploys
```

**Option 2: Manual (Railway CLI)**
```bash
railway redeploy
```

**Option 3: Rollback to Previous Deploy**
```bash
# List deployments
railway deployments

# Rollback to specific deployment
railway rollback <DEPLOYMENT_ID>
```

## 📦 Local Development

### Setup Local Environment

```bash
# Install dependencies
cd api && npm install && cd ..
cd ui && npm install && cd ..

# Create .env files
cp api/.env.example api/.env
cp ui/.env.example ui/.env

# Update .env files with local values
```

### Run Locally

```bash
# Terminal 1: PostgreSQL + API
docker-compose up

# Terminal 2: Frontend dev server
cd ui && npm run dev

# Access at:
# Frontend: http://localhost:5173
# API: http://localhost:3000
```

### Build Docker Image

```bash
# Build image
docker build -t quizzy-defense:latest .

# Run image
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  -e JWT_SECRET=test \
  -e DATABASE_URL=postgresql://... \
  quizzy-defense:latest
```

## 📖 Resources

### Railway
- [Railway Docs](https://docs.railway.app)
- [Railway CLI](https://github.com/railwayapp/cli)
- [Railway Status](https://status.railway.app)

### NestJS
- [NestJS Docs](https://docs.nestjs.com)
- [NestJS Deployment](https://docs.nestjs.com/deployment)
- [TypeORM Guide](https://typeorm.io)

### Docker
- [Docker Docs](https://docs.docker.com)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node)

### Frontend
- [React Docs](https://react.dev)
- [Vite Guide](https://vitejs.dev)
- [Mantine UI](https://mantine.dev)

## ❓ FAQ

**Q: How much does Railway cost?**
A: Free tier available with generous limits. Paid plans start at $5/month. See https://railway.app/pricing

**Q: Can I use my own domain?**
A: Yes! Railway supports custom domains. Configure in Project Settings → Domain.

**Q: How do I backup my database?**
A: Railway provides automatic backups. Access in PostgreSQL service → Backups tab.

**Q: Can I scale the application?**
A: Yes! Adjust memory in Settings. Use auto-scaling for automatic resource management.

**Q: How do I monitor application errors?**
A: Railway provides logs. For advanced monitoring, integrate Sentry.io or similar services.

**Q: Can I have multiple environments?**
A: Yes! Create separate Railway projects for staging/production.

## 🤝 Support

- **Railway Support:** https://railway.app/support
- **Documentation:** RAILWAY_DEPLOYMENT_GUIDE.md
- **Checklist:** DEPLOYMENT_CHECKLIST.md
- **GitHub Issues:** Check your repository

---

**Version:** 1.0  
**Last Updated:** 2024  
**Status:** Ready for Production  

**Next Step:** Read [RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md) for complete deployment instructions! 🚀
