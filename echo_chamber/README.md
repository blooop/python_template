# Echo Chamber

An Android app for collecting and viewing reviews from your friends!

## Features

- **Review Feed**: View all reviews from your friends in one place
- **Add Reviews**: Record reviews from friends on various topics
- **Friend Management**: Add and manage your friend list
- **Local Storage**: All data stored locally on your device

## How It Works

1. **Add Friends**: Navigate to the Friends screen and add your friends
2. **Create Reviews**: Tap "New Review" to record feedback from a friend
3. **View Feed**: See all reviews on the home screen

## Running the App

### Desktop (for testing)

Install dependencies:
```bash
pixi add kivy
pixi run python echo_chamber/main.py
```

Or with pip:
```bash
pip install kivy
python echo_chamber/main.py
```

### Building for Android

1. Install Buildozer:
   ```bash
   pip install buildozer
   ```

2. Install Android build dependencies (Ubuntu/Debian):
   ```bash
   sudo apt update
   sudo apt install -y git zip unzip openjdk-17-jdk python3-pip autoconf libtool pkg-config zlib1g-dev libncurses5-dev libncursesw5-dev libtinfo5 cmake libffi-dev libssl-dev
   ```

3. Build the APK:
   ```bash
   buildozer android debug
   ```

4. The APK will be generated in `bin/` directory

5. Install on device:
   ```bash
   buildozer android deploy run
   ```

## Project Structure

```
echo_chamber/
├── __init__.py       # Package initialization
├── main.py           # Main app with UI screens
├── storage.py        # Data storage handling
└── README.md         # This file
```

## Data Storage

Reviews and friends are stored as JSON files:
- `reviews.json`: All review entries
- `friends.json`: Friend list

By default, data is stored in the current directory. On Android, it will be in the app's private storage.

## Development

The app uses Kivy framework for cross-platform UI. Key screens:
- `HomeScreen`: Main feed displaying all reviews
- `NewReviewScreen`: Form to add new reviews
- `FriendsScreen`: Manage friend list

## Future Enhancements

Potential features to add:
- Cloud sync between devices
- Share reviews with friends
- Review categories/tags
- Search and filter reviews
- Profile pictures for friends
- Rating system (stars, thumbs up/down)
- Comments on reviews
- Export reviews to PDF/text
