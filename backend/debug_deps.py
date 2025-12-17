import os
from dotenv import load_dotenv, find_dotenv

print(f"CWD: {os.getcwd()}")
print(f"Finding .env: {find_dotenv()}")
success = load_dotenv()
print(f"load_dotenv result: {success}")

# Check if keys are in os.environ at all (maybe different names?)
print("Keys in environ that contain 'KEY':")
for k in os.environ:
    if 'KEY' in k:
        print(f"  {k}")

print(f"GEMINI_API_KEY: {bool(os.getenv('GEMINI_API_KEY'))}")
print(f"OPENAI_API_KEY: {bool(os.getenv('OPENAI_API_KEY'))}")
