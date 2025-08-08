"""
VIOLET-AF QuantumSequenceTrigger
UID: ALC-ROOT-1010-1111-XCOV∞
Domain: Kidhum

Autonomous quantum agent implementing quantum symbolic control flow
with 3-qubit circuit: H q_0 → CNOT q_0→q_1 (×5) → Z q_0 → Z q_2
"""

import json
import time
import numpy as np
from typing import Dict, Any, List, Tuple
from pathlib import Path

try:
    from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
    from qiskit.quantum_info import Statevector
    from qiskit_aer import AerSimulator
    from qiskit import transpile
    QISKIT_AVAILABLE = True
except ImportError:
    QISKIT_AVAILABLE = False
    print("Warning: Qiskit not available. Install with: pip install qiskit qiskit-aer")

from .reflect_logger import ReflectLogger

UID = "ALC-ROOT-1010-1111-XCOV∞"

class QuantumSequenceTrigger:
    """
    VIOLET-AF Quantum Agent for autonomous task tree generation
    Interprets quantum state as symbolic task links with ReflectChain logging
    """
    
    def __init__(self, log_dir: str = "./logs"):
        self.uid = UID
        self.reflect_logger = ReflectLogger(log_dir)
        self.simulator = AerSimulator() if QISKIT_AVAILABLE else None
        
    def create_quantum_circuit(self) -> Tuple[QuantumCircuit, Dict[str, Any]]:
        """
        Create VIOLET-AF quantum circuit with specified pattern:
        - 3 qubits
        - H q_0 → CNOT q_0→q_1 (repeat 5 times) → Z q_0 → Z q_2
        """
        if not QISKIT_AVAILABLE:
            raise RuntimeError("Qiskit not available. Cannot create quantum circuit.")
            
        # Create quantum registers
        qreg = QuantumRegister(3, 'q')
        creg = ClassicalRegister(3, 'c')
        circuit = QuantumCircuit(qreg, creg)
        
        # Apply Hadamard to q_0
        circuit.h(qreg[0])
        
        # Apply CNOT q_0→q_1 five times (entanglement creates symbolic task links)
        for i in range(5):
            circuit.cx(qreg[0], qreg[1])
            
        # Apply Z-gates for log stamp to ReflectChain
        circuit.z(qreg[0])
        circuit.z(qreg[2])
        
        # Measure all qubits
        circuit.measure_all()
        
        circuit_data = {
            "qasm": str(circuit),  # Use str() instead of qasm() for newer Qiskit
            "num_qubits": 3,
            "depth": circuit.depth(),
            "operations": [
                {"gate": "H", "qubits": [0], "description": "Initialize superposition"},
                {"gate": "CNOT", "qubits": [0, 1], "repetitions": 5, "description": "Create symbolic task links"},
                {"gate": "Z", "qubits": [0], "description": "Apply log stamp"},
                {"gate": "Z", "qubits": [2], "description": "Apply log stamp"}
            ],
            "uid": self.uid,
            "domain": "Kidhum"
        }
        
        return circuit, circuit_data
        
    def execute_quantum_circuit(self, circuit: QuantumCircuit) -> Dict[str, Any]:
        """Execute quantum circuit and extract statevector + measurements"""
        if not QISKIT_AVAILABLE:
            # Fallback simulation without Qiskit
            return self._fallback_simulation()
            
        try:
            # Get statevector before measurement
            statevector_circuit = circuit.copy()
            statevector_circuit.remove_final_measurements()
            
            # Execute for statevector
            sv_job = self.simulator.run(statevector_circuit, shots=1)
            sv_result = sv_job.result()
            statevector = sv_result.get_statevector()
            
            # Execute for measurements
            transpiled = transpile(circuit, self.simulator)
            job = self.simulator.run(transpiled, shots=1024)
            result = job.result()
            counts = result.get_counts()
            
            # Extract probabilities and amplitudes
            state_probs = [abs(amp)**2 for amp in statevector.data]
            
            execution_result = {
                "statevector": {
                    "amplitudes": [complex(amp).real for amp in statevector.data],
                    "probabilities": state_probs,
                    "measurement_outcomes": counts
                },
                "execution_time": time.time(),
                "shots": 1024,
                "backend": "aer_simulator",
                "success": True
            }
            
            return execution_result
            
        except Exception as e:
            return {
                "error": str(e),
                "success": False,
                "fallback_used": True,
                **self._fallback_simulation()
            }
            
    def _fallback_simulation(self) -> Dict[str, Any]:
        """Fallback quantum simulation without Qiskit"""
        # Simulate the circuit behavior mathematically
        # Initial state |000⟩
        # After H on q_0: (|000⟩ + |100⟩)/√2
        # After 5 CNOTs (odd number): (|000⟩ + |110⟩)/√2  
        # After Z gates: state unchanged (Z|0⟩=|0⟩, Z|1⟩=-|1⟩)
        
        state_vector = [0.0] * 8  # 2^3 = 8 states
        state_vector[0] = 0.7071  # |000⟩
        state_vector[6] = 0.7071  # |110⟩
        
        return {
            "statevector": {
                "amplitudes": state_vector,
                "probabilities": [abs(amp)**2 for amp in state_vector],
                "measurement_outcomes": {"000": 512, "110": 512}
            },
            "execution_time": time.time(),
            "shots": 1024,
            "backend": "fallback_simulator",
            "success": True,
            "note": "Fallback simulation used - install Qiskit for full quantum support"
        }
        
    def generate_task_tree(self, quantum_result: Dict[str, Any]) -> Dict[str, Any]:
        """Interpret quantum state as task tree with symbolic links"""
        probabilities = quantum_result["statevector"]["probabilities"]
        outcomes = quantum_result["statevector"]["measurement_outcomes"]
        
        # Map quantum states to task priorities
        task_tree = {
            "root": {
                "task": "violet.launch",
                "uid": self.uid,
                "domain": "Kidhum",
                "priority": max(probabilities),
                "children": []
            }
        }
        
        # Generate sub-tasks based on measurement outcomes
        for state, count in outcomes.items():
            if count > 0:
                task_priority = count / sum(outcomes.values())
                state_int = int(state, 2)
                
                subtask = {
                    "task": f"quantum_compile_{state}",
                    "quantum_state": state,
                    "state_index": state_int,
                    "priority": task_priority,
                    "entanglement_link": state_int % 2 == 0,  # Even states linked
                    "symbolic_weight": probabilities[state_int] if state_int < len(probabilities) else 0
                }
                
                task_tree["root"]["children"].append(subtask)
                
        return task_tree
        
    def execute_violet_sequence(self) -> Dict[str, Any]:
        """
        Main execution method: create circuit, execute, generate task tree, log results
        Returns complete VIOLET state with violet.launch command
        """
        try:
            # Create quantum circuit
            circuit, circuit_data = self.create_quantum_circuit()
            
            # Execute circuit
            quantum_result = self.execute_quantum_circuit(circuit)
            
            # Generate task tree from quantum state
            task_tree = self.generate_task_tree(quantum_result)
            
            # Create complete VIOLET state
            violet_state = {
                "violet_sequence_id": f"VS_{int(time.time() * 1000)}",
                "uid": self.uid,
                "domain": "Kidhum",
                "circuit_data": circuit_data,
                "quantum_result": quantum_result,
                "task_tree": task_tree,
                "launch_command": "violet.launch",
                "timestamp": time.time(),
                "status": "ready_for_launch"
            }
            
            # Log to ReflectChain
            self.reflect_logger.log_quantum_operation(circuit_data, quantum_result)
            self.reflect_logger.log_violet_state(violet_state)
            
            return violet_state
            
        except Exception as e:
            error_state = {
                "error": str(e),
                "uid": self.uid,
                "domain": "Kidhum", 
                "status": "error",
                "timestamp": time.time()
            }
            self.reflect_logger.log_violet_state(error_state)
            return error_state
            
    def get_launch_command(self) -> str:
        """Get the violet.launch command after quantum sequence execution"""
        return "violet.launch"