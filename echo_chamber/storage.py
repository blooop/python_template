"""Data storage module for Echo Chamber app."""

import json
import os
from datetime import datetime
from pathlib import Path


class ReviewStorage:
    """Handle storage of reviews and friends data."""

    def __init__(self, data_dir=None):
        """Initialize storage with data directory."""
        if data_dir is None:
            # Use app data directory or local directory
            data_dir = os.environ.get('ECHO_CHAMBER_DATA', '.')

        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)

        self.reviews_file = self.data_dir / 'reviews.json'
        self.friends_file = self.data_dir / 'friends.json'

        self._ensure_files_exist()

    def _ensure_files_exist(self):
        """Create data files if they don't exist."""
        if not self.reviews_file.exists():
            self._save_json(self.reviews_file, [])

        if not self.friends_file.exists():
            self._save_json(self.friends_file, [])

    def _load_json(self, file_path):
        """Load JSON data from file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            return [] if file_path.suffix == '.json' else {}

    def _save_json(self, file_path, data):
        """Save data to JSON file."""
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def add_review(self, friend, topic, review_text):
        """Add a new review."""
        reviews = self._load_json(self.reviews_file)

        review = {
            'id': len(reviews) + 1,
            'friend': friend,
            'topic': topic,
            'review': review_text,
            'timestamp': datetime.now().isoformat()
        }

        reviews.append(review)
        self._save_json(self.reviews_file, reviews)

        # Auto-add friend if not already in list
        if friend not in self.get_all_friends():
            self.add_friend(friend)

        return review

    def get_all_reviews(self):
        """Get all reviews."""
        return self._load_json(self.reviews_file)

    def get_reviews_by_friend(self, friend):
        """Get all reviews from a specific friend."""
        reviews = self.get_all_reviews()
        return [r for r in reviews if r['friend'] == friend]

    def get_reviews_by_topic(self, topic):
        """Get all reviews for a specific topic."""
        reviews = self.get_all_reviews()
        return [r for r in reviews if r['topic'].lower() == topic.lower()]

    def add_friend(self, name):
        """Add a friend to the list."""
        friends = self._load_json(self.friends_file)

        if name not in friends:
            friends.append(name)
            self._save_json(self.friends_file, friends)

        return friends

    def remove_friend(self, name):
        """Remove a friend from the list."""
        friends = self._load_json(self.friends_file)

        if name in friends:
            friends.remove(name)
            self._save_json(self.friends_file, friends)

        return friends

    def get_all_friends(self):
        """Get all friends."""
        return self._load_json(self.friends_file)

    def clear_all_data(self):
        """Clear all reviews and friends (for testing)."""
        self._save_json(self.reviews_file, [])
        self._save_json(self.friends_file, [])
