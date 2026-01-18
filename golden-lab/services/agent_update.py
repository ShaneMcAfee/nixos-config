import docker
import shutil
import subprocess
import time
import os

COMPOSE_FILE = "/workspace/docker-compose.yml"
BACKUP_FILE = "/workspace/docker-compose.yml.bak"
TEST_SERVICE_NAME = "agent-test-runner"

# 1. Setup Docker Client
try:
    client = docker.from_env()
    print("✅ [INIT] Connected to Docker.")
except Exception as e:
    print(f"❌ [FATAL] Docker connection failed: {e}")
    exit(1)

def run_compose_up():
    print("   >>> Running 'docker-compose up -d'...")
    # Using --remove-orphans to ensure cleanups happen
    result = subprocess.run(
        ["docker-compose", "up", "-d", "--remove-orphans"], 
        cwd="/workspace",
        capture_output=True,
        text=True
    )
    if result.returncode == 0:
        print("   ✅ Docker Compose Success")
    else:
        print(f"   ❌ Docker Compose Failed:\n{result.stderr}")
        raise Exception("Compose failed")

# 2. Backup
print(f"\n📦 [BACKUP] Saving {COMPOSE_FILE} to {BACKUP_FILE}...")
shutil.copyfile(COMPOSE_FILE, BACKUP_FILE)

try:
    # 3. Modify (Inject a Test Service)
    print("✏️  [MODIFY] Injecting test container definition...")
    injection = f"""
  
  # --- AGENT TEST INJECTION ---
  {TEST_SERVICE_NAME}:
    image: alpine:latest
    container_name: {TEST_SERVICE_NAME}
    command: sh -c "echo 'Agent Test Running' && sleep 60"
    networks:
      - caddy
"""
    with open(COMPOSE_FILE, "a") as f:
        f.write(injection)

    # 4. Apply
    print("🚀 [APPLY] Deploying changes to live stack...")
    run_compose_up()

    # 5. Verify
    print("Pd [VERIFY] Checking container health...")
    time.sleep(3) # Give it a moment to spin up
    
    container = client.containers.get(TEST_SERVICE_NAME)
    if container.status == "running":
        print(f"   ✅ SUCCESS: Container '{TEST_SERVICE_NAME}' is {container.status}")
    else:
        print(f"   ⚠️  WARNING: Container status is {container.status}")

except Exception as e:
    print(f"❌ [ERROR] Pipeline failed: {e}")

finally:
    # 6. Rollback / Cleanup
    print("\naa [ROLLBACK] Restoring configuration and cleaning up...")
    if os.path.exists(BACKUP_FILE):
        shutil.copyfile(BACKUP_FILE, COMPOSE_FILE)
        run_compose_up() # Apply the 'clean' file (removes the test container)
        print("   ✅ System Restored to Original State")
    else:
        print("   ❌ CRITICAL: Backup file missing! Cannot rollback.")
