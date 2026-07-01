#!/usr/bin/env python3
import sys
import json
import asyncio
import websockets
import argparse

async def consumer(topic: str):
    uri = "ws://localhost:8080/ws?token=admin_2024"
    uuid = f"demo-consumer-{int(asyncio.get_running_loop().time()*1000)}"
    
    print(f"🔌 Connecting to topic: {topic}")
    print(f"📋 UUID : {uuid}")
    print("Waiting for jobs... (Press Ctrl+C to stop)\n")

    try:
        async with websockets.connect(uri) as ws:
            # Send init
            await ws.send(json.dumps({
                "action": "init",
                "uuid": uuid,
                "topic": topic
            }))
            
            print("✅ Connected successfully!\n")
            
            while True:
                msg = await ws.recv()
                data = json.loads(msg)
                
                print(f"📥 {data}")
                
                if data.get("action") == "job":
                    await ws.send(json.dumps({
                        "action": "ack",
                        "lastID": data.get("seqId", 0),
                        "jobId": data.get("jobId"),
                        "topic": topic
                    }))
                    print(f"✅ ACK sent for job {data.get('jobId')}\n")
                    
    except websockets.exceptions.ConnectionClosed:
        print("\nConnection closed by server.")
    except asyncio.CancelledError:
        print("\nConsumer stopped.")
    except KeyboardInterrupt:
        print("\n\n👋 Consumer stopped by user.")
    except Exception as e:
        print(f"\nError: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Cue Proxy Simple Consumer")
    parser.add_argument("topic", nargs="?", default="orders", help="Topic to subscribe to")
    args = parser.parse_args()
    
    try:
        asyncio.run(consumer(args.topic))
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")
        sys.exit(0)