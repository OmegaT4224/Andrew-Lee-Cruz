"""
VIOLET-AF CLI Interface
Command-line interface for quantum sequence execution
"""

import json
import argparse
import sys
from pathlib import Path

from .quantum_sequence_trigger import QuantumSequenceTrigger

def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description="VIOLET-AF Quantum Sequence Trigger",
        epilog=f"UID: ALC-ROOT-1010-1111-XCOV∞ | Domain: Kidhum"
    )
    
    parser.add_argument(
        "--execute", 
        action="store_true",
        help="Execute quantum sequence and generate task tree"
    )
    
    parser.add_argument(
        "--log-dir",
        default="./logs",
        help="Directory for ReflectChain logs (default: ./logs)"
    )
    
    parser.add_argument(
        "--output",
        help="Output file for VIOLET state JSON"
    )
    
    parser.add_argument(
        "--verify-logs",
        action="store_true", 
        help="Verify ReflectChain log signatures"
    )
    
    args = parser.parse_args()
    
    # Initialize quantum trigger
    trigger = QuantumSequenceTrigger(log_dir=args.log_dir)
    
    if args.execute:
        print("🌀 Executing VIOLET-AF Quantum Sequence...")
        print(f"   UID: {trigger.uid}")
        print(f"   Domain: Kidhum")
        print(f"   Log Directory: {args.log_dir}")
        print()
        
        # Execute quantum sequence
        violet_state = trigger.execute_violet_sequence()
        
        if violet_state.get("status") == "error":
            print(f"❌ Error: {violet_state.get('error')}")
            sys.exit(1)
            
        print("✅ Quantum sequence executed successfully!")
        print(f"   Sequence ID: {violet_state.get('violet_sequence_id')}")
        print(f"   Launch Command: {violet_state.get('launch_command')}")
        print(f"   Task Tree Children: {len(violet_state.get('task_tree', {}).get('root', {}).get('children', []))}")
        
        # Show quantum results summary
        qr = violet_state.get('quantum_result', {})
        if qr.get('success'):
            sv = qr.get('statevector', {})
            outcomes = sv.get('measurement_outcomes', {})
            print(f"   Quantum States: {list(outcomes.keys())}")
            print(f"   Backend: {qr.get('backend', 'unknown')}")
            
        # Output to file if specified
        if args.output:
            with open(args.output, 'w') as f:
                json.dump(violet_state, f, indent=2)
            print(f"   Output saved to: {args.output}")
            
        # Show ReflectChain info
        log_dir = Path(args.log_dir)
        if log_dir.exists():
            violet_state_file = log_dir / "VioletState.json"
            if violet_state_file.exists():
                print(f"   VioletState.json: {violet_state_file}")
                
    elif args.verify_logs:
        print("🔍 Verifying ReflectChain logs...")
        log_dir = Path(args.log_dir)
        
        if not log_dir.exists():
            print("❌ Log directory not found")
            sys.exit(1)
            
        # Verify VioletState.json
        violet_state_file = log_dir / "VioletState.json"
        if violet_state_file.exists():
            with open(violet_state_file) as f:
                violet_state = json.load(f)
                
            if trigger.reflect_logger.verify_entry(violet_state):
                print("✅ VioletState.json signature valid")
            else:
                print("❌ VioletState.json signature invalid")
        else:
            print("⚠️  VioletState.json not found")
            
        # Verify daily reflect logs
        reflect_logs = list(log_dir.glob("reflect_chain_*.json"))
        if reflect_logs:
            for log_file in reflect_logs:
                print(f"📋 Verifying {log_file.name}...")
                valid_entries = 0
                total_entries = 0
                
                with open(log_file) as f:
                    for line in f:
                        if line.strip():
                            total_entries += 1
                            try:
                                entry = json.loads(line.strip())
                                if trigger.reflect_logger.verify_entry(entry):
                                    valid_entries += 1
                            except json.JSONDecodeError:
                                continue
                                
                print(f"   Valid entries: {valid_entries}/{total_entries}")
        else:
            print("⚠️  No reflect chain logs found")
            
    else:
        parser.print_help()
        
if __name__ == "__main__":
    main()