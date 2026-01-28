import docker
import os
import datetime

# 1. Connect to the Docker Socket (The "Eyes")
try:
    client = docker.from_env()
    print("✅ SUCCESS: Connected to Docker Socket.")
except Exception as e:
    print(f"❌ ERROR: Could not connect to Docker: {e}")
    exit(1)

# 2. List Containers (The "Vision Test")
print("\n--- CURRENT CONTAINERS ---")
containers = client.containers.list(all=True)
for c in containers:
    print(f"[{c.status.upper()}] {c.name}")

# 3. Modify Filesystem (The "Hands Test")
timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
log_message = f"Agent checked system at {timestamp}\n"

try:
    with open("/workspace/agent_log.txt", "a") as f:
        f.write(log_message)
    print(f"\n✅ SUCCESS: Wrote log to /workspace/agent_log.txt")
except Exception as e:
    print(f"❌ ERROR: Could not write to file: {e}")
