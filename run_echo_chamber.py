#!/usr/bin/env python3
"""Quick start script for Echo Chamber app."""

import sys
import os

# Add the project root to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from echo_chamber.main import EchoChamberApp

if __name__ == '__main__':
    EchoChamberApp().run()
