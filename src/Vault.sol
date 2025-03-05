// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract Vault {
    error Vault__RedeemFailed();

    IRebaseToken private immutable i_rebaseToken;

    event Deposit(address indexed sender, uint256 amount);
    event Redeem(address indexed sender, uint256 amount);

    constructor(IRebaseToken _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

    /**
     * @notice Gets the address of the rebase token
     */
    function getRebaseTokenAddress() external view returns(address) {
        return address(i_rebaseToken);
    }

    receive() external payable {

    }

    /**
     * @notice allows users to deposit ETH into the vault and mint rebase tokens in return
     */
    function deposit () external payable {
        i_rebaseToken.mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Allows users to redeem their tokens for eth
     * @param _amount Amount of deposited eth that the user wants to redeem for their rebse tokens
     */
    function redeem(uint256 _amount) external {
        i_rebaseToken.burn(msg.sender, _amount);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
        emit Redeem(msg.sender, _amount);
    }
}