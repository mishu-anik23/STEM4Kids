# STEM Learning Game - Backend API

Backend server for the STEM Learning Game mobile application built with Node.js, Express, PostgreSQL, and Redis.

## 🚀 Features

- **Authentication**: JWT-based authentication with refresh tokens
- **User Management**: User profiles, progress tracking, achievements
- **Leaderboards**: Global, weekly, and grade-based rankings with Redis
- **Real-time Updates**: Socket.io for live leaderboard updates
- **Progress Tracking**: Detailed level completion and performance tracking
- **Achievements System**: Unlock badges and earn rewards
- **COPPA Compliance**: Parent email verification for users under 13

## 📋 Prerequisites

- Node.js (v16 or higher)
- PostgreSQL (v12 or higher)
- Redis (v6 or higher)
- npm or yarn

## 🛠️ Installation

### 1. Clone and Install Dependencies

```bash
cd stem-game-backend
npm install
```

### 2. Database Setup

Create a PostgreSQL database:

```sql
CREATE DATABASE stem_game_db;
```

### 3. Redis Setup

Start Redis server:

```bash
redis-server
```

Or using Docker:

```bash
docker run -d -p 6379:6379 redis:alpine
```

### 4. Environment Configuration

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
NODE_ENV=development
PORT=3000

DB_HOST=localhost
DB_PORT=5432
DB_NAME=stem_game_db
DB_USER=postgres
DB_PASSWORD=your_password

REDIS_HOST=localhost
REDIS_PORT=6379

JWT_SECRET=your_super_secret_key_here
JWT_EXPIRE=7d
```

### 5. Run Migrations

```bash
npm run migrate
```

### 6. Seed Database

```bash
node database/seeds/achievements.js
```

### 7. Start Server

Development mode with auto-reload:

```bash
npm run dev
```

Production mode:

```bash
npm start
```

## 📚 API Documentation

### Authentication Endpoints

#### Register User
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "player123",
  "password": "securepass",
  "parentEmail": "parent@example.com",
  "age": 8,
  "grade": 3
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "player123",
  "password": "securepass"
}
```

#### Get Current User
```
GET /api/auth/me
Authorization: Bearer {token}
```

### Progress Endpoints

#### Submit Level Completion
```
POST /api/progress/complete
Authorization: Bearer {token}
Content-Type: application/json

{
  "worldId": 1,
  "levelId": 5,
  "score": 95,
  "timeSpentSeconds": 120,
  "hintsUsed": 0
}
```

#### Get User Progress
```
GET /api/progress
Authorization: Bearer {token}
```

#### Get Specific Level Progress
```
GET /api/progress/:worldId/:levelId
Authorization: Bearer {token}
```

### Leaderboard Endpoints

#### Global Leaderboard
```
GET /api/leaderboard/global?limit=100&offset=0
```

#### Weekly Leaderboard
```
GET /api/leaderboard/weekly?limit=100
```

#### Grade Leaderboard
```
GET /api/leaderboard/grade/:grade
```

#### User Position
```
GET /api/leaderboard/me
Authorization: Bearer {token}
```

## 🔌 WebSocket Events

### Join Leaderboard
```javascript
socket.emit('join-leaderboard', { type: 'global' }); // or 'weekly'
```

### Leaderboard Update (received)
```javascript
socket.on('leaderboard-update', (data) => {
  console.log('New leaderboard data:', data);
});
```

## 🏗️ Project Structure

```
src/
├── config/           # Configuration files
│   ├── database.js   # Sequelize config
│   └── redis.js      # Redis config
├── controllers/      # Route controllers
│   ├── authController.js
│   ├── progressController.js
│   └── leaderboardController.js
├── middleware/       # Custom middleware
│   ├── auth.js       # JWT authentication
│   └── validation.js # Request validation
├── models/           # Database models
│   ├── User.js
│   ├── LevelProgress.js
│   ├── Achievement.js
│   └── index.js
├── routes/           # API routes
│   ├── authRoutes.js
│   ├── progressRoutes.js
│   └── leaderboardRoutes.js
└── server.js         # App entry point
```

## 🔒 Security Features

- Helmet.js for security headers
- Rate limiting on API endpoints
- JWT token expiration
- Password hashing with bcrypt
- Input validation with express-validator
- CORS configuration

## 📊 Database Schema

### Users Table
- id (UUID, PK)
- username (unique)
- password (hashed)
- parentEmail
- age, grade
- coins, totalStars
- currentWorld, currentLevel
- loginStreak
- timestamps

### Level Progress Table
- id (UUID, PK)
- userId (FK)
- worldId, levelId
- stars, score
- attempts, timeSpentSeconds
- hintsUsed, coinsEarned
- completed, completedAt
- timestamps

### Achievements Table
- id (UUID, PK)
- code (unique)
- name, description
- iconUrl, category
- coinReward
- requirement (JSONB)
- timestamps

### User Achievements Table
- id (UUID, PK)
- userId (FK)
- achievementId (FK)
- unlockedAt
- timestamps

## 🧪 Testing

Run tests:

```bash
npm test
```

## 📈 Performance

- Redis caching for leaderboards (O(log N) operations)
- Database indexing on frequently queried fields
- Connection pooling for PostgreSQL
- Compression middleware for responses

## 🚀 Deployment

### Docker Deployment

Create `Dockerfile`:

```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "src/server.js"]
```

Build and run:

```bash
docker build -t stem-game-api .
docker run -p 3000:3000 stem-game-api
```

### Environment Variables for Production

- Set `NODE_ENV=production`
- Use strong JWT secrets
- Configure proper CORS origins
- Set up SSL/TLS
- Use environment-specific database credentials

## 📝 License

MIT License

## 👥 Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## 🐛 Troubleshooting

### Database Connection Issues
- Verify PostgreSQL is running
- Check credentials in `.env`
- Ensure database exists

### Redis Connection Issues
- Verify Redis is running
- Check Redis host/port in `.env`

### Port Already in Use
- Change PORT in `.env`
- Kill process using the port: `lsof -ti:3000 | xargs kill`

## 📞 Support

For issues and questions, please create an issue in the repository.
