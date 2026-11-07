# Railway Deployment Architecture Diagrams

## 🏗️ Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Railway Platform                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────┐         ┌──────────────────┐     │
│  │   Docker Container   │◄────────│ GitHub Webhook   │     │
│  │   (Your App)         │         │   (Auto-deploy)  │     │
│  │                      │         └──────────────────┘     │
│  │  ┌────────────────┐  │                                   │
│  │  │   NestJS API   │  │                                   │
│  │  │  (Port 3000)   │  │                                   │
│  │  │                │  │                                   │
│  │  │ ├─ REST API    │  │                                   │
│  │  │ ├─ WebSocket   │  │                                   │
│  │  │ └─ Static CSS  │  │                                   │
│  │  │                │  │                                   │
│  │  │ React App      │  │                                   │
│  │  │ (Built as      │  │                                   │
│  │  │  static files) │  │                                   │
│  │  └────────────────┘  │                                   │
│  │                      │                                   │
│  └──────────────────────┘                                   │
│           │                                                 │
│           │ TCP Connection                                  │
│           ▼                                                 │
│  ┌──────────────────────┐                                   │
│  │  PostgreSQL Database │                                   │
│  │  (Auto-provisioned)  │                                   │
│  │                      │                                   │
│  │ ├─ TypeORM ORM       │                                   │
│  │ ├─ Migrations        │                                   │
│  │ └─ Automatic Backups │                                   │
│  └──────────────────────┘                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
		  ▲
		  │ HTTPS + WSS (Secure WebSocket)
		  │
	┌─────┴──────┐
	│   Browser  │
	│            │
	│ ├─ React   │
	│ ├─ Axios   │
	│ ├─ Socket. │
	│ │  io      │
	│ └─ Mantine │
	│   UI       │
	└────────────┘
```

---

## 📦 Docker Build Stages

```
┌──────────────────────────────────────────────────────────────┐
│         Your Source Code on GitHub                           │
│  (Frontend + Backend + Dockerfile + docker-compose)          │
└────────────────────┬─────────────────────────────────────────┘
					 │
					 ▼ Push to main
┌──────────────────────────────────────────────────────────────┐
│      Railway Receives GitHub Webhook                         │
│        (Automatic trigger)                                   │
└────────────────────┬─────────────────────────────────────────┘
					 │
					 ▼
┌──────────────────────────────────────────────────────────────┐
│      Docker Build Process (Multi-Stage)                      │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  STAGE 1: Frontend Builder                                   │
│  ────────────────────────                                    │
│  FROM node:20-alpine                                         │
│  COPY ui/package*.json                                       │
│  RUN npm ci                                                  │
│  COPY ui .                                                   │
│  RUN npm run build  ────────┐                                │
│                             │                                │
│                             ▼                                │
│                  ┌────────────────────┐                      │
│                  │  dist/index.html   │                      │
│                  │  dist/assets/*     │ (Static files)       │
│                  └────────────────────┘                      │
│                                                               │
│  STAGE 2: Backend Builder                                    │
│  ────────────────────────                                    │
│  FROM node:20-alpine                                         │
│  COPY api/package*.json                                      │
│  RUN npm ci                                                  │
│  COPY api .                                                  │
│  RUN npm run build  ────────┐                                │
│                             │                                │
│                             ▼                                │
│                  ┌────────────────────┐                      │
│                  │  dist/main.js      │                      │
│                  │  dist/**/*.js      │ (Compiled code)      │
│                  └────────────────────┘                      │
│                                                               │
│  STAGE 3: Production Runtime                                 │
│  ───────────────────────────                                 │
│  FROM node:20-alpine                                         │
│  WORKDIR /app                                                │
│  │                                                            │
│  ├─ COPY backend dist + node_modules                         │
│  │                                                            │
│  ├─ COPY frontend dist → /app/public                         │
│  │  (Backend serves frontend from /public)                   │
│  │                                                            │
│  └─ EXPOSE 3000                                              │
│     CMD ["node", "dist/main"]                                │
│                                                               │
└──────────────────────────────────────────────────────────────┘
					 │
					 ▼
┌──────────────────────────────────────────────────────────────┐
│      Final Docker Image (~400-500MB)                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Optimized Alpine Linux                              │   │
│  │  + Node.js 20 runtime                                │   │
│  │  + Backend compiled code (dist/)                     │   │
│  │  + Backend node_modules (prod only)                  │   │
│  │  + Frontend static files (/public)                   │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────┬───────────────────────────────────────────┘
				 │
				 ▼
┌──────────────────────────────────────────────────────────────┐
│   Railway Container Runtime                                  │
│                                                              │
│   Environment Variables Injected:                           │
│   ├─ NODE_ENV=production                                    │
│   ├─ DATABASE_URL=postgresql://...                          │
│   ├─ JWT_SECRET=...                                         │
│   ├─ CORS_ORIGIN=https://...railway.app                     │
│   └─ ... (other variables)                                  │
│                                                              │
│   Container Starts:                                         │
│   ├─ Connects to PostgreSQL                                 │
│   ├─ Initializes TypeORM                                    │
│   ├─ Starts NestJS server on port 3000                      │
│   └─ Ready to accept requests                               │
│                                                              │
└────────────────┬───────────────────────────────────────────┘
				 │
				 ▼
┌──────────────────────────────────────────────────────────────┐
│   Application Live! ✅                                       │
│   https://your-railway-domain.railway.app                   │
│   ✅ WebSockets working                                     │
│   ✅ API responding                                         │
│   ✅ Database connected                                     │
│   ✅ Frontend served                                        │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔄 Deployment Workflow

```
Developer
   │
   │ 1. Make changes
   │   (frontend/backend)
   ▼
Git Repository (GitHub)
   │
   │ 2. Push to main
   │    git push origin main
   ▼
GitHub Webhook
   │
   │ 3. Send notification
   │    to Railway
   ▼
Railway Platform
   │
   ├─ 4a. Read Dockerfile
   │
   ├─ 4b. Build Docker image
   │  ├─ Stage 1: npm run build (ui)
   │  ├─ Stage 2: npm run build (api)
   │  └─ Stage 3: Combine & optimize
   │
   ├─ 4c. Push to Railway registry
   │
   ├─ 4d. Provision PostgreSQL (if first deploy)
   │
   ├─ 4e. Pull image & run container
   │
   └─ 4f. Inject environment variables
	  └─ Restart container
   ▼
Application Running
   │
   ├─ Listen on port 3000
   ├─ Connect to PostgreSQL
   ├─ Accept WebSocket connections
   └─ Serve frontend (React app)
   ▼
User Access
   │
   └─ https://your-railway-domain.railway.app
```

---

## 🔐 Environment Variable Flow

```
┌─────────────────────────────────┐
│  railway.env.example (local)    │
│  - Serves as template           │
│  - Never committed to Git       │
│  - Shows all variables needed   │
└──────────────┬──────────────────┘
			   │
			   │ Developer fills in values
			   ▼
┌─────────────────────────────────┐
│  Railway Dashboard              │
│  Variables tab                  │
│                                 │
│  KEY        VALUE               │
│  ──────────────────────────────  │
│  JWT_SECRET  [encrypted]        │
│  DATABASE_URL [encrypted]       │
│  CORS_ORIGIN https://...        │
│  ... more variables ...         │
└──────────────┬──────────────────┘
			   │
			   │ On deployment:
			   │ Railway injects
			   │ into container
			   ▼
┌─────────────────────────────────┐
│  Inside Docker Container        │
│  process.env.JWT_SECRET = "..." │
│  process.env.DATABASE_URL = "...│
│  process.env.CORS_ORIGIN = "..."│
│  ... etc ...                    │
└──────────────┬──────────────────┘
			   │
			   │ Application reads
			   │ at runtime
			   ▼
┌─────────────────────────────────┐
│  Running Application            │
│  Uses variables:                │
│  - Database connection          │
│  - JWT signing                  │
│  - CORS validation              │
│  - API key initialization       │
│  - Email service setup          │
│  - OAuth configuration          │
│  - etc.                         │
└─────────────────────────────────┘
```

---

## 🗄️ Database Architecture

```
┌──────────────────────────────────────────────────┐
│   Your Application (NestJS + TypeORM)            │
│                                                  │
│   const connection = await dataSource.initialize()
│   const user = await userRepository.findById(1)  │
│   await userRepository.save(newUser)             │
└────────────────┬─────────────────────────────────┘
				 │
				 │ SQL Queries via TypeORM
				 ▼
┌──────────────────────────────────────────────────┐
│   PostgreSQL Database (Railway Managed)          │
│                                                  │
│   Tables:                                        │
│   ├─ users                                       │
│   │  ├─ id (primary key)                         │
│   │  ├─ email                                    │
│   │  ├─ password (hashed)                        │
│   │  └─ ...                                      │
│   │                                              │
│   ├─ quizzes                                     │
│   │  ├─ id                                       │
│   │  ├─ title                                    │
│   │  ├─ questions (relation)                     │
│   │  └─ ...                                      │
│   │                                              │
│   ├─ game_sessions                               │
│   │  ├─ id                                       │
│   │  ├─ players (many-to-many)                   │
│   │  ├─ teams (one-to-many)                      │
│   │  └─ ...                                      │
│   │                                              │
│   └─ ... (more tables)                           │
│                                                  │
│   Migrations:                                    │
│   ├─ 1234567890-create-users.ts                 │
│   ├─ 1234567891-create-quizzes.ts               │
│   └─ ... (applied in order)                      │
│                                                  │
│   Features:                                      │
│   ├─ Automatic backups (Railway)                 │
│   ├─ Point-in-time recovery                      │
│   ├─ Connection pooling                          │
│   └─ Automatic scaling                           │
└──────────────────────────────────────────────────┘
```

---

## 🔌 Request Flow

```
Browser (User)
	│
	│ 1. User opens: https://your-domain.railway.app
	│
	▼
HTTPS Connection
	│
	│ 2. Railway loads balancer
	│
	▼
Docker Container (Your App)
	│
	├─ Route 1: GET / (frontend request)
	│  └─ NestJS serves React dist/index.html (static)
	│     ├─ React app loads
	│     ├─ axios initialized with API_URL
	│     └─ Socket.io connects to backend
	│
	├─ Route 2: GET /api/users (API request)
	│  └─ NestJS REST endpoint
	│     ├─ Validates JWT token
	│     ├─ Queries database via TypeORM
	│     └─ Returns JSON response
	│
	└─ Route 3: WS /socket.io (WebSocket)
	   └─ NestJS Gateway
		  ├─ Establishes WebSocket connection
		  ├─ Listens for real-time events
		  ├─ Emits game state changes
		  └─ Maintains connection until close
	│
	▼
Response to Browser
	│
	├─ HTML + CSS + JS (React app)
	├─ JSON data (API)
	└─ Real-time updates (WebSocket)
	│
	▼
User sees application
	├─ Can interact with UI
	├─ API calls work
	└─ Real-time updates show instantly
```

---

## 🚀 Scaling Architecture (Future)

```
Current Setup (Single Container):
┌─────────────────────┐
│  Docker Container   │
│  - NestJS API       │
│  - React Frontend   │
│  Port: 3000         │
└──────┬──────────────┘
	   │
	   ▼
   PostgreSQL
   (Single Database)


Scaled Setup (Optional):
┌─────────────────────────────────────────┐
│        Railway Load Balancer             │
├─────────────────────────────────────────┤
│                                          │
├─ Container 1  Container 2  Container 3  │
│   (Port 3000)   (Port 3001)  (Port 3002)│
│                                          │
│   Each runs:                             │
│   - NestJS API                           │
│   - React Frontend                       │
│   - Shares PostgreSQL connection         │
│                                          │
└─────────────────────────────────────────┘
		   │
		   ▼
	PostgreSQL
	(Managed replication available)


How to Enable:
1. Go to Railway Settings
2. Enable "Auto Scaling"
3. Set min/max replicas
4. Railway handles:
   - Load distribution
   - Automatic failover
   - Resource optimization
   - Health checks
```

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                  Frontend (React)                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │ User Actions                                      │  │
│  │ ├─ Login/Signup                                   │  │
│  │ ├─ Start Quiz                                     │  │
│  │ ├─ Answer Question                                │  │
│  │ ├─ Join Game                                      │  │
│  │ └─ Real-time Chat                                 │  │
│  └────────┬────────────────────────────────────────┘  │
│           │                                            │
│           ├─ HTTP POST/GET (Axios)                     │
│           │  └─ /api/auth/login                        │
│           │  └─ /api/quizzes                           │
│           │  └─ /api/answers                           │
│           │                                            │
│           └─ WebSocket Events (Socket.io)              │
│              └─ game:started                           │
│              └─ player:joined                          │
│              └─ question:updated                       │
│                                                         │
└────────────────┬────────────────────────────────────────┘
				 │
				 ▼
		 ┌─────────────────┐
		 │   HTTPS/WSS     │
		 │   Encryption    │
		 └────────┬────────┘
				  │
				  ▼
		┌─────────────────────┐
		│  NestJS Backend     │
		│  (api/src/main.ts)  │
		└────────┬────────────┘
				 │
	┌────────────┼────────────┐
	│            │            │
	▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌─────────────┐
│REST      │ │Websocket │ │Middleware   │
│API       │ │Gateway   │ │             │
│Routes   │ │Events    │ │├─ Auth      │
│         │ │          │ │├─ Validation│
│GET /api │ │@SubscribeM │─ CORS      │
│POST/PUT │ │essage()  │ │└─ Errors   │
│DELETE   │ │          │ │             │
└────┬────┘ └────┬─────┘ └──────────────┘
	 │           │
	 └─────┬─────┘
		   │
		   ▼
	┌─────────────────┐
	│  Services       │
	│  Modules        │
	│  Controllers    │
	└────────┬────────┘
			 │
			 ├─ User Service
			 ├─ Quiz Service
			 ├─ Game Service
			 ├─ Auth Service
			 └─ ... more services
			 │
			 ▼
	┌──────────────────────┐
	│  TypeORM             │
	│  (Database Layer)    │
	└────────┬─────────────┘
			 │
			 ▼
	┌──────────────────────┐
	│ PostgreSQL Database  │
	│                      │
	│ ├─ users table       │
	│ ├─ quizzes table     │
	│ ├─ games table       │
	│ ├─ players table     │
	│ ├─ answers table     │
	│ └─ ... more tables   │
	│                      │
	│ Transactions:        │
	│ ├─ ACID compliant    │
	│ ├─ Indexed queries   │
	│ └─ Connection pool   │
	└──────────────────────┘
```

---

## 🔐 Security Flow

```
User Request
	│
	▼
HTTPS (Automatic with Railway)
	│ Encrypted transmission
	▼
Reverse Proxy (Railway Load Balancer)
	│ SSL/TLS termination
	▼
NestJS Application
	│
	├─ CORS Check
	│  └─ Verify origin matches CORS_ORIGIN
	│
	├─ Rate Limiting (optional)
	│  └─ Prevent abuse
	│
	├─ Input Validation
	│  └─ Sanitize inputs
	│
	├─ Authentication (if required)
	│  └─ Check JWT token
	│     ├─ Verify signature with JWT_SECRET
	│     ├─ Check expiration
	│     └─ Extract user info
	│
	├─ Authorization
	│  └─ Check user permissions
	│
	└─ Database Operation
	   └─ TypeORM prepared statements
		  └─ Protection against SQL injection
	│
	▼
PostgreSQL Database
	│
	├─ User authentication
	├─ Data validation
	├─ Transaction isolation
	└─ Connection encryption (optional)
	│
	▼
Response to Client
	│
	└─ Encrypted via HTTPS
```

---

**All diagrams show how your application will work in production on Railway! 🚀**
