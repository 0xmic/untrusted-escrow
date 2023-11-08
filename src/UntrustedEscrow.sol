// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title UntrustedEscrow
 * @dev This contract allows a buyer to deposit an arbitrary ERC20 token, which the seller can withdraw after 3 days.
 */
contract UntrustedEscrow {
    using SafeERC20 for IERC20; // Using SafeERC20 library for IERC20

    /// @notice The duration for which the seller has to wait to withdraw tokens.
    uint256 public constant WAIT_DURATION = 3 days;

    /// @notice Address of the buyer.
    address public immutable buyer;

    /// @notice Address of the seller.
    address public immutable seller;

    /// @notice The ERC20 token which the buyer will deposit.
    IERC20 public immutable token;

    /// @notice The timestamp when the buyer deposited the tokens.
    uint256 public depositTimestamp;

    /// @notice Event emitted when tokens are deposited.
    event TokensDeposited(address indexed buyer, uint256 amount, uint256 timestamp);

    /// @notice Event emitted when tokens are withdrawn by the seller.
    event TokensWithdrawn(address indexed seller, uint256 amount);

    /**
     * @dev Creates an escrow contract.
     * @param tokenAddress Address of the ERC20 token to be used.
     * @param sellerAddress Address of the seller.
     */
    constructor(address tokenAddress, address sellerAddress) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        require(sellerAddress != address(0), "Seller address cannot be zero");

        token = IERC20(tokenAddress);
        seller = sellerAddress;
        buyer = msg.sender;
    }

    /**
     * @dev Allows the buyer to deposit a specified amount of tokens into the escrow.
     * The buyer must approve the contract to spend tokens beforehand.
     * @param amount Amount of tokens to deposit.
     */
    function deposit(uint256 amount) external {
        require(msg.sender == buyer, "Only the buyer can deposit");
        require(amount > 0, "Amount must be greater than 0");

        depositTimestamp = block.timestamp;
        emit TokensDeposited(buyer, amount, depositTimestamp);

        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev Allows the seller to withdraw the tokens after the waiting duration.
     */
    function withdraw() external {
        require(msg.sender == seller, "Only the seller can withdraw");
        require(block.timestamp >= depositTimestamp + WAIT_DURATION, "Withdrawal time has not been reached yet");

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "No tokens to withdraw");
        emit TokensWithdrawn(seller, amount);

        token.safeTransfer(seller, amount);
    }
}
