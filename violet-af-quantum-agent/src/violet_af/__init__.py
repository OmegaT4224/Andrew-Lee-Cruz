"""
VIOLET-AF Quantum Automation Engine
Creator UID: ALC-ROOT-1010-1111-XCOV∞
Sovereign Owner: allcatch37@gmail.com

Quantum-powered autonomous execution capabilities with ReflectChain memory state management
and AxiomDevCore automation integration for the Cruz Theorem sovereignty infrastructure.
"""

__version__ = "1.0.0"
__author__ = "allcatch37@gmail.com"
__creator_uid__ = "ALC-ROOT-1010-1111-XCOV∞"

from .quantum_sequence_trigger import (
    VioletAfQuantumTrigger, 
    QuantumState, 
    ReflectChainEntry
)

from .axiom_dev_core import (
    AxiomDevCore,
    AutomationScope,
    GitHubOperation
)

from .reflect_logger import (
    ReflectLogger,
    ReflectEntry,
    ChainState
)

__all__ = [
    "VioletAfQuantumTrigger",
    "QuantumState", 
    "ReflectChainEntry",
    "AxiomDevCore",
    "AutomationScope",
    "GitHubOperation", 
    "ReflectLogger",
    "ReflectEntry",
    "ChainState"
]