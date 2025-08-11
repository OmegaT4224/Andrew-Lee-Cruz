#!/usr/bin/env python3
"""
Test script for VIOLET-AF Quantum Automation Engine
Validates basic functionality and integration components
"""

import sys
import os
import json
import tempfile
from quantum_sequence_trigger import VioletAutomationEngine, create_violet_quantum_circuit, trigger_sequence

def test_violet_automation_engine():
    """Test VioletAutomationEngine basic functionality"""
    print("🧪 Testing VioletAutomationEngine...")
    
    engine = VioletAutomationEngine()
    
    # Test quantum state interpretation
    test_quantum_result = {
        '000': 200,
        '001': 150,
        '010': 100,
        '011': 120,
        '100': 140,
        '101': 90,
        '110': 80,
        '111': 144
    }
    
    task_tree = engine.interpret_quantum_state_as_task_tree(test_quantum_result)
    assert len(task_tree) == 8, f"Expected 8 tasks, got {len(task_tree)}"
    assert "initialize_system" in task_tree, "Missing initialize_system task"
    assert "genesis_block_mine" in task_tree, "Missing genesis_block_mine task"
    
    # Test symbolic links creation
    links = engine.create_symbolic_entanglement_links()
    assert len(links) == 4, f"Expected 4 links, got {len(links)}"
    
    # Test Z-gate stamps
    stamps = engine.apply_z_gate_log_stamps()
    assert len(stamps) == 3, f"Expected 3 stamps, got {len(stamps)}"
    
    # Test genesis block mining
    genesis_block = engine.mine_genesis_block(test_quantum_result)
    assert genesis_block["block_type"] == "GENESIS", "Invalid genesis block type"
    assert "block_hash" in genesis_block, "Missing block hash"
    assert "quantum_signature" in genesis_block, "Missing quantum signature"
    
    print("   ✅ VioletAutomationEngine tests passed")
    return True

def test_quantum_circuit_creation():
    """Test quantum circuit creation"""
    print("🧪 Testing quantum circuit creation...")
    
    circuit = create_violet_quantum_circuit()
    
    # Verify circuit has correct number of qubits
    assert circuit.num_qubits == 3, f"Expected 3 qubits, got {circuit.num_qubits}"
    # Note: measure_all() may add additional classical bits, so we check for at least 3
    assert circuit.num_clbits >= 3, f"Expected at least 3 classical bits, got {circuit.num_clbits}"
    
    # Verify circuit has reasonable depth (gates were added)
    assert circuit.depth() > 0, "Circuit should have non-zero depth"
    
    print("   ✅ Quantum circuit creation tests passed")
    return True

def test_full_sequence():
    """Test the complete VIOLET-AF sequence"""
    print("🧪 Testing full VIOLET-AF sequence...")
    
    # Use temporary directory for testing
    with tempfile.TemporaryDirectory() as temp_dir:
        # Change to temp directory
        original_dir = os.getcwd()
        os.chdir(temp_dir)
        
        try:
            # Run the full sequence
            result = trigger_sequence()
            
            # Verify result structure
            assert result["status"] == "completed", f"Expected completed status, got {result['status']}"
            assert "quantum_results" in result, "Missing quantum_results"
            assert "task_tree" in result, "Missing task_tree"
            assert "genesis_block" in result, "Missing genesis_block"
            assert "executed_tasks" in result, "Missing executed_tasks"
            
            # Verify ReflectChain file was created
            assert os.path.exists("VioletState.json"), "VioletState.json not created"
            
            # Verify ReflectChain content
            with open("VioletState.json", 'r') as f:
                reflect_chain = json.load(f)
            
            assert len(reflect_chain) > 0, "ReflectChain should not be empty"
            assert any(entry["type"] == "genesis_block" for entry in reflect_chain), "Missing genesis block in ReflectChain"
            assert any(entry["type"] == "z_gate_stamp" for entry in reflect_chain), "Missing Z-gate stamps in ReflectChain"
            
            print("   ✅ Full sequence tests passed")
            return True
            
        finally:
            os.chdir(original_dir)

def run_all_tests():
    """Run all tests for VIOLET-AF"""
    print("🚀 Running VIOLET-AF Test Suite...")
    print("=" * 60)
    
    tests = [
        test_violet_automation_engine,
        test_quantum_circuit_creation,
        test_full_sequence
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"   ❌ Test failed: {e}")
            import traceback
            traceback.print_exc()
    
    print("=" * 60)
    print(f"🏁 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! VIOLET-AF is working correctly.")
        return True
    else:
        print("⚠️ Some tests failed. Please review the implementation.")
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)