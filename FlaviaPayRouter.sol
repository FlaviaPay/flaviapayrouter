// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library SafeERC20 {
    error TransferFromFailed();

    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        if (!success) revert TransferFromFailed();
        if (data.length > 0 && !abi.decode(data, (bool))) revert TransferFromFailed();
    }
}

contract FlaviaPayRouter {
    error InvalidRecipient();
    error InvalidToken();
    error InvalidAmount();
    error InvalidPaymentId();
    error NativeTransferFailed();

    event PaymentProcessed(
        bytes32 indexed paymentId,
        address indexed payer,
        address indexed recipient,
        address token,   // address(0) for native
        uint256 amount
    );

    /// @notice Pay seller in native coin
    /// @param paymentId Unique backend-generated payment id
    /// @param recipient Seller wallet
    function payNative(
        bytes32 paymentId,
        address payable recipient
    ) external payable {
        if (paymentId == bytes32(0)) revert InvalidPaymentId();
        if (recipient == address(0)) revert InvalidRecipient();
        if (msg.value == 0) revert InvalidAmount();

        uint256 amount = msg.value;

        (bool sent, ) = recipient.call{value: amount}("");
        if (!sent) revert NativeTransferFailed();

        emit PaymentProcessed(
            paymentId,
            msg.sender,
            recipient,
            address(0),
            amount
        );
    }

    /// @notice Pay seller in ERC20
    /// @param paymentId Unique backend-generated payment id
    /// @param recipient Seller wallet
    /// @param token ERC20 token address
    /// @param amount Token amount
    function payERC20(
        bytes32 paymentId,
        address recipient,
        address token,
        uint256 amount
    ) external {
        if (paymentId == bytes32(0)) revert InvalidPaymentId();
        if (recipient == address(0)) revert InvalidRecipient();
        if (token == address(0)) revert InvalidToken();
        if (token.code.length == 0) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        SafeERC20.safeTransferFrom(token, msg.sender, recipient, amount);

        emit PaymentProcessed(
            paymentId,
            msg.sender,
            recipient,
            token,
            amount
        );
    }
}
