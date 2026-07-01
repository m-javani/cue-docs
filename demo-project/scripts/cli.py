#!/usr/bin/env python3
import sys
import json
import requests
import argparse

BASE_URL = "http://localhost:8080"
TOKEN = "admin_2024"

def main():
    parser = argparse.ArgumentParser(description="Cue Proxy CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Topic command
    topic_parser = subparsers.add_parser("topic", help="Create a topic")
    topic_parser.add_argument("name", help="Topic name")

    # Job command
    job_parser = subparsers.add_parser("job", help="Send a job")
    job_parser.add_argument("topic", help="Topic name")
    job_parser.add_argument("payload", help="JSON payload")

    args = parser.parse_args()

    headers = {
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json"
    }

    try:
        if args.command == "topic":
            print(f"📝 Creating topic: {args.name}")
            response = requests.post(
                f"{BASE_URL}/producer/topic",
                headers=headers,
                json={"topic": args.name},
                timeout=5
            )
            
            if response.status_code == 200:
                print("✅ Topic created successfully")
            elif response.status_code == 409:
                print("⚠️  Topic already exists")
            else:
                print(f"❌ Failed: HTTP {response.status_code}")
                print(response.text)

        elif args.command == "job":
            print(f"📤 Sending job to topic: {args.topic}")
            job_id = f"cli-job-{int(__import__('time').time())}"
            
            payload = {
                "job": {
                    "id": job_id,
                    "topic": args.topic,
                    "data": __import__('base64').b64encode(args.payload.encode()).decode()
                }
            }
            
            response = requests.post(
                f"{BASE_URL}/producer/job",
                headers=headers,
                json=payload,
                timeout=5
            )
            
            if response.status_code == 200:
                print(f"✅ Job sent successfully (ID: {job_id})")
            else:
                print(f"❌ Failed: HTTP {response.status_code}")
                print(response.text)

    except requests.exceptions.ConnectionError:
        print("❌ Error: Cannot connect to proxy. Is 'make start' running?")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()