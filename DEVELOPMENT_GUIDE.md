# STEM Learning Game - Complete Development Guide

## 🎮 Project Overview

A mobile educational game for children ages 6-10 teaching STEM concepts through story-based interactive levels.

### Tech Stack
- **Frontend**: Flutter 3.x + Flame game engine
- **Backend**: Node.js + Express
- **Database**: PostgreSQL 12+
- **Cache/Realtime**: Redis + Socket.io
- **State Management**: Flutter BLoC
- **Authentication**: JWT with refresh tokens

---

## 📁 Project Structure

```
STEM-LEARNING-GAME/
├── stem-game-backend/          # Node.js API
│   ├── src/
│   │   ├── config/             # DB, Redis config
│   │   ├── controllers/        # Business logic
│   │   ├── middleware/         # Auth, validation
│   │   ├── models/             # Database models
│   │   ├── routes/             # API endpoints
│   │   └── server.js           # Entry point
│   ├── database/
│   │   ├── migrations/
│   │   └── seeds/
│   └── package.json
│
├── stem-game-flutter/          # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart           # App entry
│   │   ├── core/               # Constants, themes, routes
│   │   ├── data/               # Models, repositories, API
│   │   ├── game/               # Flame game components
│   │   ├── features/           # Auth, profile, leaderboard
│   │   └── widgets/            # Reusable UI components
│   ├── assets/                 # Images, audio, fonts
│   └── pubspec.yaml
│
└── docs/                       # Documentation
    ├── LEVEL_DESIGN.md         # Complete level breakdown
    ├── API_DOCS.md             # API specifications
    └── DEPLOYMENT.md           # Production deployment
```

---

## 🚀 Quick Start Guide

### Prerequisites Installation

1. **Node.js and npm** (v16+)
   ```bash
   # macOS
   brew install node
   
   # Ubuntu/Debian
   curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Windows
   # Download from nodejs.org
   ```

2. **PostgreSQL** (v12+)
   ```bash
   # macOS
   brew install postgresql
   brew services start postgresql
   
   # Ubuntu/Debian
   sudo apt install postgresql postgresql-contrib
   sudo systemctl start postgresql
   
   # Windows
   # Download from postgresql.org
   ```

3. **Redis** (v6+)
   ```bash
   # macOS
   brew install redis
   brew services start redis
   
   # Ubuntu/Debian
   sudo apt install redis-server
   sudo systemctl start redis
   
   # Windows (WSL recommended)
   # Or use Docker: docker run -d -p 6379:6379 redis:alpine
   ```

4. **Flutter** (3.x+)
   ```bash
   # Follow official guide: https://docs.flutter.dev/get-started/install
   
   # Verify installation
   flutter doctor
   ```

---

## 🗄️ Backend Setup (15 minutes)

### Step 1: Database Setup

```bash
# Create PostgreSQL database
psql postgres
CREATE DATABASE stem_game_db;
CREATE USER stem_admin WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE stem_game_db TO stem_admin;
\q
```

### Step 2: Backend Configuration

```bash
cd stem-game-backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env with your credentials
nano .env
```

Required environment variables:
```env
NODE_ENV=development
PORT=3000

DB_HOST=localhost
DB_PORT=5432
DB_NAME=stem_game_db
DB_USER=stem_admin
DB_PASSWORD=your_secure_password

REDIS_HOST=localhost
REDIS_PORT=6379

JWT_SECRET=generate_random_string_here_min_32_chars
JWT_REFRESH_SECRET=generate_another_random_string_here
```

### Step 3: Run Migrations & Seeds

```bash
# Run database migrations
npm run migrate

# Seed achievements
node database/seeds/achievements.js
```

### Step 4: Start Backend Server

```bash
# Development mode (auto-reload)
npm run dev

# Production mode
npm start
```

Server should be running at `http://localhost:3000`

Test with:
```bash
curl http://localhost:3000/health
```

---

## 📱 Frontend Setup (10 minutes)

### Step 1: Flutter Dependencies

```bash
cd stem-game-flutter

# Get dependencies
flutter pub get
```

### Step 2: Configure API Endpoint

Create `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  
  // For Android emulator, use:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // For iOS simulator, use:
  // static const String baseUrl = 'http://localhost:3000/api';
  
  // For physical device, use your computer's local IP:
  // static const String baseUrl = 'http://192.168.1.X:3000/api';
}
```

### Step 3: Run the App

```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Or run on specific device
flutter run -d <device-id>

# For web (testing only)
flutter run -d chrome
```

---

## 🎨 Asset Preparation

### Image Assets Needed

Create placeholder images in `assets/images/`:

```
assets/images/
├── worlds/
│   ├── world_1_math.png        (1024x1024)
│   ├── world_2_physics.png
│   ├── world_3_chemistry.png
│   └── world_4_nature.png
├── characters/
│   ├── player_default.png      (512x512)
│   └── ...
├── backgrounds/
│   ├── math_island_bg.png      (1920x1080)
│   └── ...
├── ui/
│   ├── button_primary.png
│   ├── star_empty.png
│   ├── star_filled.png
│   ├── coin.png
│   └── ...
└── achievements/
    ├── quick_thinker.png       (256x256)
    └── ...
```

### Audio Assets Needed

```
assets/audio/
├── music/
│   ├── menu_theme.mp3
│   ├── world_1_theme.mp3
│   └── ...
└── sfx/
    ├── button_click.mp3
    ├── correct_answer.mp3
    ├── wrong_answer.mp3
    ├── level_complete.mp3
    ├── star_collect.mp3
    └── coin_collect.mp3
```

**Temporary Solution**: Use free assets from:
- Images: OpenGameArt.org, Kenney.nl
- Audio: FreeSound.org, OpenGameArt.org

---

## 🧪 Testing the Complete System

### 1. Test Backend API

```bash
# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testplayer",
    "password": "password123",
    "parentEmail": "parent@test.com",
    "age": 8,
    "grade": 3
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testplayer",
    "password": "password123"
  }'

# Copy the token from response
TOKEN="<paste_token_here>"

# Submit level completion
curl -X POST http://localhost:3000/api/progress/complete \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "worldId": 1,
    "levelId": 1,
    "score": 95,
    "timeSpentSeconds": 120,
    "hintsUsed": 0
  }'
```

### 2. Test Flutter App

1. Launch app on emulator
2. Register new account
3. Navigate through worlds
4. Complete a level
5. Check leaderboard
6. View profile and achievements

---

## 🎯 Development Workflow

### Daily Development Flow

```bash
# Terminal 1: Backend
cd stem-game-backend
npm run dev

# Terminal 2: Redis (if not running as service)
redis-server

# Terminal 3: PostgreSQL monitoring
psql -U stem_admin -d stem_game_db

# Terminal 4: Flutter
cd stem-game-flutter
flutter run
```

### Code Organization Best Practices

#### Flutter File Naming
```
# Screens: *_screen.dart
login_screen.dart, world_map_screen.dart

# Widgets: *_widget.dart  
star_rating_widget.dart, level_card_widget.dart

# BLoC: *_bloc.dart, *_event.dart, *_state.dart
auth_bloc.dart, auth_event.dart, auth_state.dart

# Models: *.dart
user.dart, level_progress.dart

# Services: *_service.dart
api_service.dart, audio_service.dart
```

#### Backend File Naming
```
# Controllers: *Controller.js
authController.js, progressController.js

# Models: Capitalized
User.js, LevelProgress.js

# Routes: *Routes.js
authRoutes.js, progressRoutes.js

# Services: *Service.js
emailService.js, achievementService.js
```

---

## 🎮 Implementing Game Levels

### Example: Math Level Implementation

Create `lib/game/levels/math/counting_stars_level.dart`:

```dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class CountingStarsLevel extends FlameGame with TapDetector {
  int targetCount = 0;
  int currentCount = 0;
  List<SpriteComponent> stars = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Generate random target (1-10)
    targetCount = 5 + (DateTime.now().millisecond % 6);
    
    // Create stars
    for (int i = 0; i < targetCount; i++) {
      final star = await SpriteComponent()
        ..sprite = await loadSprite('ui/star_empty.png')
        ..size = Vector2(64, 64)
        ..position = Vector2(
          100 + (i % 5) * 100.0,
          100 + (i ~/ 5) * 100.0,
        );
      add(star);
      stars.add(star);
    }
  }

  @override
  void onTapUp(TapUpInfo info) {
    // Check if tapped on a star
    for (var star in stars) {
      if (star.containsPoint(info.eventPosition.global)) {
        currentCount++;
        star.sprite = Sprite(images.fromCache('ui/star_filled.png'));
        
        if (currentCount == targetCount) {
          // Level complete!
          onLevelComplete(100); // 100% score
        }
      }
    }
  }

  void onLevelComplete(int score) {
    // Submit score to backend
    // Navigate to level complete screen
  }
}
```

---

## 🔒 Security Checklist

### Before Production

- [ ] Change all default passwords
- [ ] Use strong JWT secrets (min 32 characters)
- [ ] Enable HTTPS/SSL
- [ ] Configure proper CORS origins
- [ ] Set up rate limiting (already included)
- [ ] Implement parent email verification
- [ ] Add input sanitization
- [ ] Set up error logging (Sentry)
- [ ] Configure database backups
- [ ] Use environment variables for secrets
- [ ] Implement API versioning
- [ ] Add request logging
- [ ] Set up monitoring (health checks)

---

## 📊 Performance Optimization

### Backend Optimizations
```javascript
// Add database indexes (already included in models)
// Example in User model:
{
  indexes: [
    { fields: ['username'] },
    { fields: ['totalStars'] },
    { fields: ['grade'] }
  ]
}

// Use Redis for caching
const cachedData = await redisClient.get('key');
if (cachedData) return JSON.parse(cachedData);

// Compress responses (already enabled)
app.use(compression());
```

### Flutter Optimizations
```dart
// Use const constructors
const Text('Hello');

// Lazy load images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
);

// Dispose controllers
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---

## 🚀 Deployment Guide

### Backend Deployment (Heroku Example)

```bash
# Install Heroku CLI
# Login
heroku login

# Create app
heroku create stem-game-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Add Redis
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=<generate-strong-secret>
heroku config:set JWT_REFRESH_SECRET=<generate-strong-secret>

# Deploy
git push heroku main

# Run migrations
heroku run npm run migrate

# Seed database
heroku run node database/seeds/achievements.js
```

### Flutter Deployment

#### Android APK
```bash
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS (requires Mac)
```bash
flutter build ios --release

# Submit to App Store via Xcode
```

#### Google Play Store
1. Create app in Google Play Console
2. Upload APK/AAB
3. Complete store listing
4. Submit for review

---

## 📞 Troubleshooting

### Backend Issues

**Problem**: Database connection failed
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check credentials
psql -U stem_admin -d stem_game_db

# Reset password if needed
ALTER USER stem_admin WITH PASSWORD 'new_password';
```

**Problem**: Redis connection failed
```bash
# Check Redis is running
redis-cli ping
# Should return: PONG

# Restart Redis
sudo systemctl restart redis
```

### Flutter Issues

**Problem**: Dependencies won't install
```bash
flutter clean
flutter pub get
```

**Problem**: Hot reload not working
```bash
# Restart in debug mode
flutter run --debug
```

**Problem**: App won't connect to backend
```dart
// For Android emulator, use 10.0.2.2 instead of localhost
// For physical device, use your computer's IP address
// Check your computer's IP: ipconfig (Windows) or ifconfig (Mac/Linux)
```

---

## 🎓 Next Steps for Development

### Priority 1: Core Gameplay (Week 1-2)
1. Implement first 5 Math levels
2. Create level progression system
3. Add star rating calculation
4. Implement coin rewards

### Priority 2: User Experience (Week 3-4)
1. Add animations and sound effects
2. Create tutorial system
3. Implement hint system
4. Add achievements unlock notifications

### Priority 3: Social Features (Week 5-6)
1. Complete leaderboard UI
2. Add friend system
3. Implement daily challenges
4. Create parent dashboard

### Priority 4: Content (Week 7-12)
1. Complete all 80 levels
2. Add story cutscenes
3. Create achievement system
4. Implement avatar customization

### Priority 5: Polish & Testing (Week 13-16)
1. User testing with kids
2. Performance optimization
3. Bug fixes
4. Prepare for launch

---

## 📚 Additional Resources

### Learning Resources
- Flutter: https://flutter.dev/docs
- Flame: https://docs.flame-engine.org
- Node.js: https://nodejs.org/docs
- PostgreSQL: https://www.postgresql.org/docs
- Express: https://expressjs.com

### Design Resources
- Game Design: https://www.gamasutra.com
- Educational Games: https://gamesandlearning.umich.edu
- UI/UX: https://www.nngroup.com

### Asset Resources
- Freesound: https://freesound.org
- OpenGameArt: https://opengameart.org
- Kenney: https://kenney.nl

---

## 🤝 Team Collaboration

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/level-design

# Make changes and commit
git add .
git commit -m "Add counting stars level"

# Push and create PR
git push origin feature/level-design
```

### Code Review Checklist
- [ ] Code follows naming conventions
- [ ] No console.log or print statements
- [ ] Error handling implemented
- [ ] Comments for complex logic
- [ ] No hardcoded values
- [ ] Tests added/updated

---

## 📄 License

MIT License - See LICENSE file for details

---

## ✨ You're Ready to Build!

You now have:
✅ Complete backend API with authentication and leaderboards
✅ Flutter project structure with Flame game engine
✅ Database schema and models
✅ 80 levels designed across 4 worlds
✅ Development and deployment guides

Start with the backend, get it running, then move to Flutter!

Good luck building your STEM learning game! 🚀🎮📚
