// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AtomicSwapHTLC
 * @dev Implementation of a Hashed Timelock Contract for atomic swaps.
 */
contract AtomicSwapHTLC {
    struct Swap {
        address sender;
        address receiver;
        uint256 amount;
        bytes32 hashlock;
        uint256 timelock;
        bool withdrawn;
        bool refunded;
        bytes32 preimage;
    }

    mapping(bytes32 => Swap) public swaps;

    event SwapInitiated(bytes32 indexed id, address sender, address receiver, uint256 amount, bytes32 hashlock, uint256 timelock);
    event SwapWithdrawn(bytes32 indexed id, bytes32 preimage);
    event SwapRefunded(bytes32 indexed id);

    /**
     * @dev Initiate a swap by locking tokens.
     */
    function initiate(
        bytes32 _id,
        address _receiver,
        bytes32 _hashlock,
        uint256 _timelock,
        address _token,
        uint256 _amount
    ) external {
        require(swaps[_id].sender == address(0), "Swap ID already exists");
        require(_timelock > block.timestamp, "Timelock must be in the future");

        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        swaps[_id] = Swap({
            sender: msg.sender,
            receiver: _receiver,
            amount: _amount,
            hashlock: _hashlock,
            timelock: _timelock,
            withdrawn: false,
            refunded: false,
            preimage: 0x0
        });

        emit SwapInitiated(_id, msg.sender, _receiver, _amount, _hashlock, _timelock);
    }

    /**
     * @dev Receiver claims funds by providing the secret preimage.
     */
    function withdraw(bytes32 _id, bytes32 _preimage, address _token) external {
        Swap storage swap = swaps[_id];
        require(keccak256(abi.encodePacked(_preimage)) == swap.hashlock, "Invalid preimage");
        require(!swap.withdrawn, "Already withdrawn");
        require(!swap.refunded, "Already refunded");

        swap.withdrawn = true;
        swap.preimage = _preimage;
        IERC20(_token).transfer(swap.receiver, swap.amount);

        emit SwapWithdrawn(_id, _preimage);
    }

    /**
     * @dev Sender reclaims funds if the timelock expires.
     */
    function refund(bytes32 _id, address _token) external {
        Swap storage swap = swaps[_id];
        require(msg.sender == swap.sender, "Not the sender");
        require(block.timestamp >= swap.timelock, "Timelock not expired");
        require(!swap.withdrawn, "Already withdrawn");
        require(!swap.refunded, "Already refunded");

        swap.refunded = true;
        IERC20(_token).transfer(swap.sender, swap.amount);

        emit SwapRefunded(_id);
    }
}
