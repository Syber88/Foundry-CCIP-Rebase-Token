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
contract RebaseToken is ERC20 {
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 newinterestRate, uint256 s_interestRate);

    mapping(address user => uint256 amount) private s_userInterestRate;
    mapping(address user => uint256 amount) private s_userLastUpdatedTimestamp;

    uint256 private s_interestRate = 5e10;

    uint256 private constant PRECISION_FACTOR = 1e18;

    event InterestRateSet(uint256 indexed newInterestRate);

    constructor() ERC20("Rebase token", "RBT") {}

    /**
     *
     * @param _newInterestRate New interest rate to set
     * @dev the interest rate can only decrease
     */
    function setInterestRate(uint256 _newInterestRate) external {
        if (_newInterestRate < s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(_newInterestRate, s_interestRate);
        }
        s_interestRate = _newInterestRate;

        emit InterestRateSet(_newInterestRate);
    }
    /**
     *
     * @param _to User to mint tokens to
     * @param _amount amount of token to mint to the user
     */

    function mint(address _to, uint256 _amount) external {
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = s_interestRate;
        _mint(_to, _amount);
    }

    /**
     * @notice gets the interest rate of the user
     * @param user The user to get interest rate for
     */
    function getUserInterestRate(address user) external view returns (uint256) {
        return s_userInterestRate[user];
    }

    /**
     * @notice funtion to get the total balance of the user including all interest accumulated since the last update
     * Principle amount + accumulated amount
     * @param _user The user we are getting the balance of. Interest included
     */
    function balanceOf(address _user) public view override returns (uint256) {
        return (super.balanceOf(_user) * _calculateAccumulatedInterestSinceLastUpdate(_user) / PRECISION_FACTOR);
    }

    function _calculateAccumulatedInterestSinceLastUpdate(address _user) internal returns (uint256 linearInterest) {
        //will be linear growth
        // Principle amount + (1 + principle amount * user interest rate * time elapsed)
        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
        linearInterest = (PRECISION_FACTOR + (s_userInterestRate[_user] * timeElapsed));
    }

    function _mintAccruedInterest(address _user) internal {
        s_userLastUpdatedTimestamp[_user] = block.timestamp;
    }
}
