// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Rebase Token
 * @author 0xsyber88
 * @notice This is going to be a cross-chain rebase token that incentivises users to deposit into a vault
 *  and gain interset in rewards
 * @notice the interest rate in the smart contract can only decrease 
 * @notice Each user will have theri own interst rate that is the glonbal interest rate at the time of 
 * depositing
 */
contract RebaseToken is ERC20{
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 newinterestRate, uint256 s_interestRate);

    uint256 private s_interestRate = 5e10;

    event IntersteRateSet(uint256 indexed newInterestRate);

    constructor() ERC20 ("Rebase token", "RBT") {

    }

    function setInterestRate(uint256 _newInterestRate) external {
        if (_newInterestRate < s_interestRate) 
        revert 
        RebaseToken__InterestRateCanOnlyDecrease(_newInterestRate, s_interestRate);
        s_interestRate = _newInterestRate;

        emit IntersteRateSet(_newInterestRate);

    }

}