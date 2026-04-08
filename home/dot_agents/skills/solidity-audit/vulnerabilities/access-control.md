---
title: Access Control Vulnerabilities
impact: CRITICAL
impactDescription: Missing authorization, tx.origin phishing, delegatecall context confusion, and unprotected privileged operations
tags: solidity, access-control, authorization, delegatecall, tx.origin
---

# Access Control Vulnerabilities

## Missing access control

Any external/public function without access control can be called by anyone.

INCORRECT:

```solidity
function setPrice(uint256 newPrice) external {
    // Anyone can call this!
    price = newPrice;
}

function mint(address to, uint256 amount) external {
    _mint(to, amount);
}
```

CORRECT:

```solidity
function setPrice(uint256 newPrice) external onlyOwner {
    price = newPrice;
    emit PriceUpdated(newPrice);
}

function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
    _mint(to, amount);
}
```

## tx.origin for authentication

`tx.origin` is the EOA that initiated the transaction chain. It can be
exploited via phishing contracts that trick users into calling them.

INCORRECT:

```solidity
function withdraw() external {
    // Phishing: attacker deploys a contract that calls this
    // tx.origin is the victim who called the attacker's contract
    require(tx.origin == owner, "not owner");
    payable(owner).transfer(address(this).balance);
}
```

CORRECT:

```solidity
function withdraw() external {
    // msg.sender is the direct caller -- can't be spoofed
    if (msg.sender != owner) revert NotOwner();
    payable(owner).transfer(address(this).balance);
}
```

## Delegatecall context confusion

`delegatecall` executes foreign code in the caller's storage context.
The called contract's `msg.sender` and `msg.value` are preserved from
the original call.

INCORRECT:

```solidity
// Implementation contract
contract Logic {
    address public owner;

    function initialize(address _owner) external {
        // When called via delegatecall, this sets the PROXY's owner
        // But the implementation can also be initialized directly
        owner = _owner;
    }
}
```

CORRECT:

```solidity
contract Logic is Initializable {
    address public owner;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();  // prevent direct initialization
    }

    function initialize(address _owner) external initializer {
        owner = _owner;
    }
}
```

## Unprotected selfdestruct / delegatecall to implementation

If the implementation contract behind a proxy can be destroyed or
its logic hijacked, the proxy becomes unusable.

INCORRECT:

```solidity
contract Implementation {
    // Anyone can delegatecall arbitrary code through this
    function execute(address target, bytes calldata data) external {
        (bool success,) = target.delegatecall(data);
        require(success);
    }
}
```

CORRECT:

```solidity
contract Implementation {
    function execute(address target, bytes calldata data) external onlyOwner {
        // Restrict both who can call and what can be called
        if (!allowedTargets[target]) revert TargetNotAllowed(target);
        (bool success, bytes memory result) = target.delegatecall(data);
        if (!success) revert ExecutionFailed(result);
    }
}
```

## Role-based access control

For contracts with multiple privileged operations, use role-based access
instead of a single owner.

```solidity
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract Vault is AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function rebalance(bytes calldata params) external onlyRole(OPERATOR_ROLE) {
        // ...
    }

    function pause() external onlyRole(GUARDIAN_ROLE) {
        // ...
    }
}
```
