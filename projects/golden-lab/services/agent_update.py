import subprocess
import os

def create_override():
    print("🤖 Agent: Generating configuration overrides...")
    override_content = """
services:
  caddy:
    restart: always
  gluetun:
    restart: always
"""
    with open("docker-compose.override.yml", "w") as f:
        f.write(override_content.strip())
    print("✅ Agent: docker-compose.override.yml created.")

def apply_updates():
    print("🚀 Agent: Deploying stack updates...")
    # FIX: Uses 'homelab' project name to manage EXISTING stack
    cmd = ["docker-compose", "-p", "homelab", "up", "-d", "--remove-orphans"]
    
    try:
        subprocess.run(cmd, check=True)
        print("✨ Success: Stack updated successfully.")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: Update failed with exit code {e.returncode}")

if __name__ == "__main__":
    create_override()
    apply_updates()
