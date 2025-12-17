import os
import sys
from dotenv import load_dotenv, find_dotenv

print(f"Current CWD: {os.getcwd()}")
print(f"Files in CWD: {os.listdir('.')}")

env_path = os.path.join(os.getcwd(), '.env')
print(f"Expected .env path: {env_path}")
print(f"Exists: {os.path.exists(env_path)}")

if os.path.exists(env_path):
    with open(env_path, 'r', encoding='utf-8') as f:
        content = f.read()
        print(f"Raw content length: {len(content)}")
        print("First 50 chars of content:", content[:50])
        print("GEMINI in content:", "GEMINI_API_KEY" in content)

print("\n--- Loading dotenv ---")
success = load_dotenv(env_path, verbose=True, override=True)
print(f"load_dotenv returned: {success}")

print(f"GEMINI_API_KEY: {'SET' if os.getenv('GEMINI_API_KEY') else 'NOT SET'}")
print(f"OPENAI_API_KEY: {'SET' if os.getenv('OPENAI_API_KEY') else 'NOT SET'}")
