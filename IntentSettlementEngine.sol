// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IntentSettlementEngine
 * @dev Settles multi-hop or direct Coincidence of Wants (CoW) trade intents verified by Solvers.
 */
contract IntentSettlementEngine is Ownable {

    struct UserIntent {
        address swapper;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 nonce;
        uint256 deadline;
    }

    mapping(address => uint256) public nonces;

    event IntentExecuted(bytes32 indexed intentHash, address indexed swapper, address indexed solver);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Settles a pair of opposing intents directly (Coincidence of Wants) minimizing on-chain AMM gas.
     */
    function settleCoincidenceOfWants(
        UserIntent calldata intentA,
        UserIntent calldata intentB,
        bytes calldata sigA,
        bytes calldata sigB
    ) external onlyOwner {
        require(block.timestamp <= intentA.deadline && block.timestamp <= intentB.deadline, "Intent expired");
        require(intentA.tokenIn == intentB.tokenOut && intentA.tokenOut == intentB.tokenIn, "Tokens mismatch for CoW match");
        require(intentA.amountIn >= intentB.minAmountOut && intentB.amountIn >= intentA.minAmountOut, "Price constraints not met");

        bytes32 hashA = keccak256(abi.encode(intentA));
        bytes32 hashB = keccak256(abi.encode(intentB));

        // In production, verify the EIP-712 signatures (sigA and sigB) match intentA.swapper and intentB.swapper
        
        nonces[intentA.swapper]++;
        nonces[intentB.swapper]++;

        // Execute direct atomic swaps between user accounts
        IERC20(intentA.tokenIn).transferFrom(intentA.swapper, intentB.swapper, intentA.amountIn);
        IERC20(intentB.tokenIn).transferFrom(intentB.swapper, intentA.swapper, intentB.amountIn);

        emit IntentExecuted(hashA, intentA.swapper, msg.sender);
        emit IntentExecuted(hashB, intentB.swapper, msg.sender);
    }
}
