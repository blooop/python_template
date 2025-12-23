"""Tests for Echo Chamber app."""

import tempfile
from pathlib import Path
import pytest
from echo_chamber.storage import ReviewStorage


class TestReviewStorage:
    """Test the ReviewStorage class."""

    @pytest.fixture
    def temp_storage(self):
        """Create a temporary storage instance."""
        with tempfile.TemporaryDirectory() as tmpdir:
            storage = ReviewStorage(data_dir=tmpdir)
            yield storage

    def test_add_review(self, temp_storage):
        """Test adding a review."""
        review = temp_storage.add_review(
            friend="Alice",
            topic="My App",
            review_text="Great app! Really useful."
        )

        assert review['friend'] == "Alice"
        assert review['topic'] == "My App"
        assert review['review'] == "Great app! Really useful."
        assert 'timestamp' in review
        assert 'id' in review

    def test_get_all_reviews(self, temp_storage):
        """Test getting all reviews."""
        temp_storage.add_review("Alice", "App", "Good")
        temp_storage.add_review("Bob", "Feature", "Needs work")

        reviews = temp_storage.get_all_reviews()
        assert len(reviews) == 2
        assert reviews[0]['friend'] == "Alice"
        assert reviews[1]['friend'] == "Bob"

    def test_get_reviews_by_friend(self, temp_storage):
        """Test filtering reviews by friend."""
        temp_storage.add_review("Alice", "App", "Good")
        temp_storage.add_review("Bob", "Feature", "Nice")
        temp_storage.add_review("Alice", "Design", "Beautiful")

        alice_reviews = temp_storage.get_reviews_by_friend("Alice")
        assert len(alice_reviews) == 2
        assert all(r['friend'] == "Alice" for r in alice_reviews)

    def test_get_reviews_by_topic(self, temp_storage):
        """Test filtering reviews by topic."""
        temp_storage.add_review("Alice", "App", "Good")
        temp_storage.add_review("Bob", "App", "Great")
        temp_storage.add_review("Charlie", "Design", "Nice")

        app_reviews = temp_storage.get_reviews_by_topic("App")
        assert len(app_reviews) == 2
        assert all(r['topic'] == "App" for r in app_reviews)

    def test_add_friend(self, temp_storage):
        """Test adding a friend."""
        temp_storage.add_friend("Alice")
        temp_storage.add_friend("Bob")

        friends = temp_storage.get_all_friends()
        assert len(friends) == 2
        assert "Alice" in friends
        assert "Bob" in friends

    def test_add_duplicate_friend(self, temp_storage):
        """Test adding a duplicate friend doesn't create duplicates."""
        temp_storage.add_friend("Alice")
        temp_storage.add_friend("Alice")

        friends = temp_storage.get_all_friends()
        assert len(friends) == 1
        assert friends[0] == "Alice"

    def test_remove_friend(self, temp_storage):
        """Test removing a friend."""
        temp_storage.add_friend("Alice")
        temp_storage.add_friend("Bob")
        temp_storage.remove_friend("Alice")

        friends = temp_storage.get_all_friends()
        assert len(friends) == 1
        assert "Alice" not in friends
        assert "Bob" in friends

    def test_auto_add_friend_on_review(self, temp_storage):
        """Test that adding a review automatically adds the friend."""
        temp_storage.add_review("Charlie", "Topic", "Review")

        friends = temp_storage.get_all_friends()
        assert "Charlie" in friends

    def test_clear_all_data(self, temp_storage):
        """Test clearing all data."""
        temp_storage.add_review("Alice", "Topic", "Review")
        temp_storage.add_friend("Bob")

        temp_storage.clear_all_data()

        assert len(temp_storage.get_all_reviews()) == 0
        assert len(temp_storage.get_all_friends()) == 0

    def test_persistence(self):
        """Test that data persists across storage instances."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create first storage instance and add data
            storage1 = ReviewStorage(data_dir=tmpdir)
            storage1.add_review("Alice", "Topic", "Review")
            storage1.add_friend("Bob")

            # Create second storage instance and verify data
            storage2 = ReviewStorage(data_dir=tmpdir)
            reviews = storage2.get_all_reviews()
            friends = storage2.get_all_friends()

            assert len(reviews) == 1
            assert reviews[0]['friend'] == "Alice"
            assert "Alice" in friends  # Auto-added from review
            assert "Bob" in friends

    def test_empty_storage(self, temp_storage):
        """Test that empty storage returns empty lists."""
        assert temp_storage.get_all_reviews() == []
        assert temp_storage.get_all_friends() == []
