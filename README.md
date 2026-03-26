FlaviaPay Router

Minimal, non-custodial smart contract for processing native and ERC20 payments.

Built for real-world usage — simple, transparent, and event-driven.

Overview

FlaviaPayRouter enables direct payments from users to merchants without holding funds.

It acts purely as a stateless routing layer.

Key properties:

No custody
No stored balances
No protocol-level state
Event-based verification
Features
Native token payments (ETH, MATIC, etc.)
ERC20 token payments
Safe ERC20 transfers (low-level call protection)
Backend-friendly payment tracking via paymentId
Gas-efficient and minimal design
Contract Structure

FlaviaPayRouter
Main contract that routes payments.

SafeERC20 (internal library)
Handles safe ERC20 transfers using low-level calls.

Functions
payNative
function payNative(bytes32 paymentId, address payable recipient) external payable

Sends native currency directly to a recipient.

Requirements:

paymentId must not be zero
recipient must not be zero address
msg.value > 0
payERC20
function payERC20(
    bytes32 paymentId,
    address recipient,
    address token,
    uint256 amount
) external

Transfers ERC20 tokens from payer to recipient.

Requirements:

Token must be a valid contract
User must approve the contract beforehand
amount > 0
Events
PaymentProcessed
event PaymentProcessed(
    bytes32 indexed paymentId,
    address indexed payer,
    address indexed recipient,
    address token,
    uint256 amount
);

This event is the core integration point for backend systems.

How It Works
Backend generates a unique paymentId
User initiates payment from wallet
Contract transfers funds directly to merchant
Event is emitted
Backend listens and marks payment as complete
Important Design Notes
paymentId is not enforced on-chain

The contract does not prevent duplicate paymentIds.

This is intentional:

Keeps contract stateless
Reduces gas costs
Keeps logic off-chain

Backend must handle uniqueness.

Recommended paymentId strategy
keccak256(abi.encodePacked(orderId, userAddress, timestamp))
Replay behavior

If a paymentId is reused:

Multiple events can be emitted
Backend must ignore duplicates
Security Considerations
No custody of funds
No internal balances
No mutable payment state
Safe ERC20 transfer handling
Rejects:
zero address recipient
zero amount
invalid token contracts
Integration Example
Backend
Create order → generate paymentId
Send request to frontend
Listen to PaymentProcessed
Match paymentId
Mark order as paid
Frontend
User clicks "Pay"
Wallet opens
Call:
payNative or
payERC20
Transaction confirms
Philosophy

"You can build a payment processor without ever touching user funds."

No custody = lower risk
No balances = fewer attack vectors
Pure routing + verification
Roadmap
SDKs (JS / PHP / Python)
Webhooks / indexer service
Multi-chain deployments
UI components
