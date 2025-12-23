"""Echo Chamber Android App - Main entry point."""

import os
from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.scrollview import ScrollView
from kivy.uix.gridlayout import GridLayout
from kivy.core.window import Window
from echo_chamber.storage import ReviewStorage


class HomeScreen(Screen):
    """Main screen showing review feed."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.storage = ReviewStorage()
        layout = BoxLayout(orientation='vertical', padding=10, spacing=10)

        # Header
        header = BoxLayout(size_hint_y=0.1, spacing=10)
        header.add_widget(Label(text='Echo Chamber', font_size='24sp', bold=True))
        layout.add_widget(header)

        # Reviews scroll view
        self.scroll_view = ScrollView(size_hint=(1, 0.75))
        self.reviews_layout = GridLayout(cols=1, spacing=10, size_hint_y=None)
        self.reviews_layout.bind(minimum_height=self.reviews_layout.setter('height'))
        self.scroll_view.add_widget(self.reviews_layout)
        layout.add_widget(self.scroll_view)

        # Navigation buttons
        nav_layout = BoxLayout(size_hint_y=0.15, spacing=10)

        new_review_btn = Button(text='New Review', font_size='18sp')
        new_review_btn.bind(on_press=self.go_to_new_review)
        nav_layout.add_widget(new_review_btn)

        friends_btn = Button(text='Friends', font_size='18sp')
        friends_btn.bind(on_press=self.go_to_friends)
        nav_layout.add_widget(friends_btn)

        layout.add_widget(nav_layout)
        self.add_widget(layout)

    def on_enter(self):
        """Refresh reviews when entering screen."""
        self.refresh_reviews()

    def refresh_reviews(self):
        """Load and display all reviews."""
        self.reviews_layout.clear_widgets()
        reviews = self.storage.get_all_reviews()

        if not reviews:
            self.reviews_layout.add_widget(
                Label(
                    text='No reviews yet!\nTap "New Review" to create one.',
                    size_hint_y=None,
                    height=100,
                    halign='center'
                )
            )
        else:
            for review in reversed(reviews):  # Show newest first
                review_widget = self.create_review_widget(review)
                self.reviews_layout.add_widget(review_widget)

    def create_review_widget(self, review):
        """Create a widget to display a single review."""
        layout = BoxLayout(
            orientation='vertical',
            size_hint_y=None,
            height=150,
            padding=10,
            spacing=5
        )

        # Friend name
        friend_label = Label(
            text=f"From: {review['friend']}",
            size_hint_y=0.3,
            bold=True,
            halign='left'
        )
        friend_label.bind(size=friend_label.setter('text_size'))
        layout.add_widget(friend_label)

        # Topic
        topic_label = Label(
            text=f"Topic: {review['topic']}",
            size_hint_y=0.3,
            halign='left'
        )
        topic_label.bind(size=topic_label.setter('text_size'))
        layout.add_widget(topic_label)

        # Review text
        review_label = Label(
            text=review['review'],
            size_hint_y=0.4,
            halign='left',
            valign='top'
        )
        review_label.bind(size=review_label.setter('text_size'))
        layout.add_widget(review_label)

        return layout

    def go_to_new_review(self, instance):
        """Navigate to new review screen."""
        self.manager.current = 'new_review'

    def go_to_friends(self, instance):
        """Navigate to friends screen."""
        self.manager.current = 'friends'


class NewReviewScreen(Screen):
    """Screen for creating a new review."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.storage = ReviewStorage()
        layout = BoxLayout(orientation='vertical', padding=10, spacing=10)

        # Header
        header = Label(text='New Review', font_size='24sp', bold=True, size_hint_y=0.1)
        layout.add_widget(header)

        # Form
        form_layout = BoxLayout(orientation='vertical', spacing=10, size_hint_y=0.75)

        # Friend selector
        form_layout.add_widget(Label(text='Friend:', size_hint_y=0.1))
        self.friend_input = TextInput(
            hint_text='Select or enter friend name',
            multiline=False,
            size_hint_y=0.1
        )
        form_layout.add_widget(self.friend_input)

        # Topic
        form_layout.add_widget(Label(text='Topic:', size_hint_y=0.1))
        self.topic_input = TextInput(
            hint_text='What do you want reviewed?',
            multiline=False,
            size_hint_y=0.1
        )
        form_layout.add_widget(self.topic_input)

        # Review text
        form_layout.add_widget(Label(text='Review:', size_hint_y=0.1))
        self.review_input = TextInput(
            hint_text='Enter the review from your friend...',
            multiline=True,
            size_hint_y=0.5
        )
        form_layout.add_widget(self.review_input)

        layout.add_widget(form_layout)

        # Action buttons
        button_layout = BoxLayout(size_hint_y=0.15, spacing=10)

        cancel_btn = Button(text='Cancel', font_size='18sp')
        cancel_btn.bind(on_press=self.go_back)
        button_layout.add_widget(cancel_btn)

        save_btn = Button(text='Save Review', font_size='18sp')
        save_btn.bind(on_press=self.save_review)
        button_layout.add_widget(save_btn)

        layout.add_widget(button_layout)
        self.add_widget(layout)

    def save_review(self, instance):
        """Save the review and return to home."""
        friend = self.friend_input.text.strip()
        topic = self.topic_input.text.strip()
        review = self.review_input.text.strip()

        if friend and topic and review:
            self.storage.add_review(friend, topic, review)

            # Clear inputs
            self.friend_input.text = ''
            self.topic_input.text = ''
            self.review_input.text = ''

            # Go back to home
            self.manager.current = 'home'

    def go_back(self, instance):
        """Return to home screen."""
        self.manager.current = 'home'


class FriendsScreen(Screen):
    """Screen for managing friends."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.storage = ReviewStorage()
        layout = BoxLayout(orientation='vertical', padding=10, spacing=10)

        # Header
        header = Label(text='Friends', font_size='24sp', bold=True, size_hint_y=0.1)
        layout.add_widget(header)

        # Friends list
        self.scroll_view = ScrollView(size_hint=(1, 0.6))
        self.friends_layout = GridLayout(cols=1, spacing=10, size_hint_y=None)
        self.friends_layout.bind(minimum_height=self.friends_layout.setter('height'))
        self.scroll_view.add_widget(self.friends_layout)
        layout.add_widget(self.scroll_view)

        # Add friend section
        add_layout = BoxLayout(orientation='vertical', size_hint_y=0.2, spacing=5)
        add_layout.add_widget(Label(text='Add Friend:', size_hint_y=0.3))

        input_layout = BoxLayout(size_hint_y=0.7, spacing=5)
        self.friend_name_input = TextInput(
            hint_text='Friend name',
            multiline=False,
            size_hint_x=0.7
        )
        input_layout.add_widget(self.friend_name_input)

        add_btn = Button(text='Add', size_hint_x=0.3)
        add_btn.bind(on_press=self.add_friend)
        input_layout.add_widget(add_btn)

        add_layout.add_widget(input_layout)
        layout.add_widget(add_layout)

        # Back button
        back_btn = Button(text='Back to Home', font_size='18sp', size_hint_y=0.1)
        back_btn.bind(on_press=self.go_back)
        layout.add_widget(back_btn)

        self.add_widget(layout)

    def on_enter(self):
        """Refresh friends when entering screen."""
        self.refresh_friends()

    def refresh_friends(self):
        """Load and display all friends."""
        self.friends_layout.clear_widgets()
        friends = self.storage.get_all_friends()

        if not friends:
            self.friends_layout.add_widget(
                Label(
                    text='No friends added yet!',
                    size_hint_y=None,
                    height=50
                )
            )
        else:
            for friend in sorted(friends):
                friend_widget = self.create_friend_widget(friend)
                self.friends_layout.add_widget(friend_widget)

    def create_friend_widget(self, friend_name):
        """Create a widget to display a single friend."""
        layout = BoxLayout(size_hint_y=None, height=50, spacing=10)

        name_label = Label(
            text=friend_name,
            halign='left',
            size_hint_x=0.7
        )
        name_label.bind(size=name_label.setter('text_size'))
        layout.add_widget(name_label)

        delete_btn = Button(text='Remove', size_hint_x=0.3)
        delete_btn.bind(on_press=lambda x: self.remove_friend(friend_name))
        layout.add_widget(delete_btn)

        return layout

    def add_friend(self, instance):
        """Add a new friend."""
        name = self.friend_name_input.text.strip()
        if name:
            self.storage.add_friend(name)
            self.friend_name_input.text = ''
            self.refresh_friends()

    def remove_friend(self, friend_name):
        """Remove a friend."""
        self.storage.remove_friend(friend_name)
        self.refresh_friends()

    def go_back(self, instance):
        """Return to home screen."""
        self.manager.current = 'home'


class EchoChamberApp(App):
    """Main application class."""

    def build(self):
        """Build the application."""
        Window.clearcolor = (0.95, 0.95, 0.95, 1)

        sm = ScreenManager()
        sm.add_widget(HomeScreen(name='home'))
        sm.add_widget(NewReviewScreen(name='new_review'))
        sm.add_widget(FriendsScreen(name='friends'))

        return sm


if __name__ == '__main__':
    EchoChamberApp().run()
