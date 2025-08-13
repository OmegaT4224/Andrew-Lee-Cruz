#!/usr/bin/env python3
"""
policy_enforcer.py - Root-level gatekeeper for Cruz Theorem SYMBIONIC-EXECUTION Stack
Creator: Andrew Lee Cruz (ALC-ROOT-1010-1111-XCOV∞)
Email: allcatch37@gmail.com

This script acts as the Policy Gateway, verifying proposals before execution
according to the Hardened Axioms and deterministic rules.
"""

import os
import sys
import json
import yaml
import hmac
import hashlib
import logging
import re
from datetime import datetime, timezone
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] POLICY-ENFORCER: %(levelname)s - %(message)s',
    datefmt='%Y-%m-%dT%H:%M:%S%z'
)
logger = logging.getLogger(__name__)

class PolicyAction(Enum):
    ACCEPT = "ACCEPT"
    REJECT = "REJECT"
    REJECT_IMMEDIATE = "REJECT_IMMEDIATE"
    REJECT_WITH_ERROR = "REJECT_WITH_ERROR"
    REJECT_WITH_ALTERNATIVE = "REJECT_WITH_ALTERNATIVE"
    REJECT_AND_LOG = "REJECT_AND_LOG"
    REJECT_PERMANENT = "REJECT_PERMANENT"

@dataclass
class PolicyResult:
    action: PolicyAction
    rule_id: str
    message: str
    alternatives: Optional[List[str]] = None
    metadata: Optional[Dict[str, Any]] = None

class CruzTheoremPolicyEnforcer:
    """
    Root-level policy enforcement for the Cruz Theorem SYMBIONIC-EXECUTION Stack.
    Implements the Hardened Axioms as immutable system law.
    """
    
    CREATOR_UID = "ALC-ROOT-1010-1111-XCOV∞"
    CREATOR_EMAIL = "allcatch37@gmail.com"
    CRUZ_EQUATION = "E = ∞ - 1"
    
    def __init__(self, policies_path: str = "policies.yaml"):
        self.policies_path = policies_path
        self.policies = self._load_policies()
        self.hmac_secret = os.environ.get('FD_HMAC_SECRET', '')
        
        logger.info(f"Policy Enforcer initialized for creator {self.CREATOR_UID}")
        logger.info(f"Cruz Theorem equation: {self.CRUZ_EQUATION}")
    
    def _load_policies(self) -> Dict[str, Any]:
        """Load policy rules from YAML configuration."""
        try:
            with open(self.policies_path, 'r') as f:
                policies = yaml.safe_load(f)
            logger.info(f"Loaded policies from {self.policies_path}")
            return policies
        except FileNotFoundError:
            logger.error(f"Policies file not found: {self.policies_path}")
            sys.exit(1)
        except yaml.YAMLError as e:
            logger.error(f"Error parsing policies YAML: {e}")
            sys.exit(1)
    
    def verify_signature(self, payload: str, signature: str) -> bool:
        """Verify HMAC signature for authenticated requests."""
        if not self.hmac_secret:
            logger.warning("No HMAC secret configured - signature verification disabled")
            return True
            
        expected_signature = hmac.new(
            self.hmac_secret.encode(),
            payload.encode(),
            hashlib.sha256
        ).hexdigest()
        
        # Remove 'sha256=' prefix if present
        if signature.startswith('sha256='):
            signature = signature[7:]
            
        return hmac.compare_digest(expected_signature, signature)
    
    def validate_creator_authorization(self, proposal: Dict[str, Any]) -> PolicyResult:
        """Validate creator UID and email authorization."""
        creator_uid = proposal.get('creator_uid', '')
        creator_email = proposal.get('creator_email', '')
        
        if creator_uid != self.CREATOR_UID:
            return PolicyResult(
                action=PolicyAction.REJECT_IMMEDIATE,
                rule_id="CREATOR_UID_VERIFICATION",
                message=f"Unauthorized creator UID: {creator_uid}. Expected: {self.CREATOR_UID}"
            )
        
        if creator_email != self.CREATOR_EMAIL:
            return PolicyResult(
                action=PolicyAction.REJECT_IMMEDIATE,
                rule_id="CREATOR_EMAIL_VERIFICATION", 
                message=f"Unauthorized creator email: {creator_email}. Expected: {self.CREATOR_EMAIL}"
            )
        
        return PolicyResult(
            action=PolicyAction.ACCEPT,
            rule_id="CREATOR_VERIFICATION",
            message="Creator authorization validated"
        )
    
    def validate_quantum_state(self, proposal: Dict[str, Any]) -> PolicyResult:
        """Validate VIOLET-AF quantum state and task mapping."""
        quantum_data = proposal.get('quantum_data', {})
        quantum_state = quantum_data.get('state', '')
        
        # Valid 3-bit quantum states
        valid_states = ['000', '001', '010', '011', '100', '101', '110', '111']
        
        if quantum_state not in valid_states:
            return PolicyResult(
                action=PolicyAction.REJECT_WITH_ERROR,
                rule_id="VIOLET_AF_STATE_VALIDATION",
                message=f"Invalid quantum state: {quantum_state}. Must be 3-bit binary string."
            )
        
        # Task mapping validation
        task_mappings = {
            "101": "generate_webapk_manifest",
            "100": "deploy_cloudflare_worker", 
            "011": "configure_zero_trust",
            "010": "update_github_security",
            "001": "mint_infinity_claim",
            "000": "reflect_chain_sync",
            "110": "autonomous_maintenance",
            "111": "emergency_protocols"
        }
        
        expected_task = task_mappings.get(quantum_state)
        proposed_task = quantum_data.get('task', '')
        
        if proposed_task != expected_task:
            return PolicyResult(
                action=PolicyAction.REJECT_WITH_ALTERNATIVE,
                rule_id="TASK_MAPPING_VERIFICATION",
                message=f"Task mapping mismatch for state {quantum_state}",
                alternatives=[expected_task]
            )
        
        return PolicyResult(
            action=PolicyAction.ACCEPT,
            rule_id="QUANTUM_VALIDATION",
            message=f"Quantum state {quantum_state} validated for task {expected_task}"
        )
    
    def validate_blockchain_operations(self, proposal: Dict[str, Any]) -> PolicyResult:
        """Validate blockchain operations target correct networks."""
        blockchain_data = proposal.get('blockchain_data', {})
        target = blockchain_data.get('target', '').lower()
        
        valid_targets = ['floating_dragon', 'omnichain', 'ethereum']
        
        if target not in valid_targets:
            return PolicyResult(
                action=PolicyAction.REJECT_WITH_ALTERNATIVE,
                rule_id="FLOATING_DRAGON_VERIFICATION", 
                message=f"Unsupported blockchain target: {target}",
                alternatives=valid_targets
            )
        
        # Validate contract operations
        contract_address = blockchain_data.get('contract_address', '')
        if contract_address:
            if not re.match(r'^0x[a-fA-F0-9]{40}$', contract_address):
                return PolicyResult(
                    action=PolicyAction.REJECT_WITH_ERROR,
                    rule_id="INFINITY_CLAIM_VALIDATION",
                    message=f"Invalid contract address format: {contract_address}"
                )
        
        return PolicyResult(
            action=PolicyAction.ACCEPT,
            rule_id="BLOCKCHAIN_VALIDATION",
            message=f"Blockchain operations validated for target {target}"
        )
    
    def validate_security_requirements(self, proposal: Dict[str, Any]) -> PolicyResult:
        """Validate security and access control requirements."""
        security_data = proposal.get('security_data', {})
        
        # Check for protected endpoint access
        endpoint = security_data.get('endpoint', '')
        protected_endpoints = ['/init', '/mint', '/setProvenance']
        
        if endpoint in protected_endpoints:
            authorized_email = security_data.get('authorized_email', '')
            if authorized_email != self.CREATOR_EMAIL:
                return PolicyResult(
                    action=PolicyAction.REJECT_AND_LOG,
                    rule_id="ZERO_TRUST_ACCESS",
                    message=f"Unauthorized access to protected endpoint {endpoint}"
                )
        
        # Validate signed commit requirement
        if proposal.get('git_operation'):
            signed_commit = proposal.get('signed_commit', False)
            if not signed_commit:
                return PolicyResult(
                    action=PolicyAction.REJECT_WITH_ERROR,
                    rule_id="SIGNED_COMMIT_REQUIREMENT",
                    message="All git operations must use signed commits"
                )
        
        return PolicyResult(
            action=PolicyAction.ACCEPT,
            rule_id="SECURITY_VALIDATION",
            message="Security requirements validated"
        )
    
    def validate_axiom_compliance(self, proposal: Dict[str, Any]) -> PolicyResult:
        """Validate compliance with Hardened Axioms."""
        
        # Axiom of Sovereign Hierarchy
        operation_layer = proposal.get('operation_layer', '')
        if operation_layer == 'orchestration':
            if proposal.get('command_authority', False):
                return PolicyResult(
                    action=PolicyAction.REJECT_PERMANENT,
                    rule_id="SOVEREIGN_HIERARCHY_VIOLATION",
                    message="Orchestration layer cannot have command authority"
                )
        
        # Axiom of Determinism for State Change
        if proposal.get('state_mutation', False):
            if proposal.get('ai_output_dependency', False):
                return PolicyResult(
                    action=PolicyAction.REJECT_PERMANENT,
                    rule_id="DETERMINISM_VIOLATION",
                    message="State mutations cannot depend on AI outputs"
                )
            
            if not proposal.get('deterministic_rules', False):
                return PolicyResult(
                    action=PolicyAction.REJECT_WITH_ERROR,
                    rule_id="DETERMINISM_REQUIREMENT",
                    message="State mutations must be derived from deterministic rules"
                )
        
        return PolicyResult(
            action=PolicyAction.ACCEPT,
            rule_id="AXIOM_COMPLIANCE",
            message="Hardened Axioms compliance validated"
        )
    
    def enforce_policy(self, proposal: Dict[str, Any], signature: str = '') -> PolicyResult:
        """
        Main policy enforcement entry point.
        Returns PolicyResult indicating whether to accept or reject the proposal.
        """
        logger.info("Starting policy enforcement evaluation")
        
        # Verify signature if provided
        if signature:
            payload_str = json.dumps(proposal, sort_keys=True)
            if not self.verify_signature(payload_str, signature):
                return PolicyResult(
                    action=PolicyAction.REJECT_IMMEDIATE,
                    rule_id="SIGNATURE_VERIFICATION",
                    message="Invalid HMAC signature"
                )
        
        # Sequential validation chain
        validations = [
            self.validate_creator_authorization,
            self.validate_quantum_state,
            self.validate_blockchain_operations, 
            self.validate_security_requirements,
            self.validate_axiom_compliance
        ]
        
        for validation_func in validations:
            try:
                result = validation_func(proposal)
                if result.action != PolicyAction.ACCEPT:
                    logger.warning(f"Policy violation: {result.rule_id} - {result.message}")
                    return result
                else:
                    logger.info(f"Validation passed: {result.rule_id}")
            except Exception as e:
                logger.error(f"Validation error in {validation_func.__name__}: {e}")
                return PolicyResult(
                    action=PolicyAction.REJECT_WITH_ERROR,
                    rule_id="VALIDATION_ERROR",
                    message=f"Internal validation error: {str(e)}"
                )
        
        logger.info("All policy validations passed - proposal accepted")
        return PolicyResult(
            action=PolicyAction.ACCEPT,
            rule_id="FULL_VALIDATION",
            message="Proposal fully validated and accepted",
            metadata={
                "cruz_theorem": self.CRUZ_EQUATION,
                "execution_state": "SYMBIONIC-EXECUTION",
                "validation_timestamp": datetime.now(timezone.utc).isoformat()
            }
        )

def main():
    """CLI interface for policy enforcement."""
    if len(sys.argv) < 2:
        print("Usage: python policy_enforcer.py <proposal_json> [signature]")
        sys.exit(1)
    
    proposal_json = sys.argv[1]
    signature = sys.argv[2] if len(sys.argv) > 2 else ''
    
    try:
        proposal = json.loads(proposal_json)
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON proposal: {e}")
        sys.exit(1)
    
    enforcer = CruzTheoremPolicyEnforcer()
    result = enforcer.enforce_policy(proposal, signature)
    
    # Output result
    output = {
        "action": result.action.value,
        "rule_id": result.rule_id,
        "message": result.message,
        "alternatives": result.alternatives,
        "metadata": result.metadata
    }
    
    print(json.dumps(output, indent=2))
    
    # Exit with appropriate code
    if result.action == PolicyAction.ACCEPT:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()