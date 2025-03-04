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

    function _calculateAccumulatedInterestSinceLastUpdate(address _user) internal view returns (uint256 linearInterest) {
        //will be linear growth
        // Principle amount + (1 + principle amount * user interest rate * time elapsed)
        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
        linearInterest = (PRECISION_FACTOR + (s_userInterestRate[_user] * timeElapsed));
    }

    /**
     * @notice Mint the accrued interest to user since the last time they interacted with the protocol
     * @param _user The user to mint the interest to 
     */
    function _mintAccruedInterest(address _user) internal {
        uint256 previousPrincipleBalance = super.balanceOf(_user);
        uint256 currentBalance = balanceOf(_user);
        uint256 balanceIncreaseMargin = currentBalance - previousPrincipleBalance;

        s_userLastUpdatedTimestamp[_user] = block.timestamp;
        _mint(_user, balanceIncreaseMargin);
    }

    /**
     * @notice Transfer tokens from one user to another with interest included if any
     * @param _recipient User to tranfer the tokens to 
     * @param _amount The amount of tokens to transfer
     * @return True if the transfer was successful
     */
    function transfer (address _recipient, uint256 _amount) public override returns(bool){
        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(_recipient);
        if (_amount == type(uint256).max) {
            _amount = balanceOf(msg.sender);
        }
        if (balanceOf(_recipient) == 0){
            s_userInterestRate[_recipient] = s_userInterestRate[msg.sender];
        }
        return super.transfer(_recipient, _amount);
    }

    /**
     * @notice Transfer tokens from one user to another with interest included if any
     * @param _sender User to transfer tokens from 
     * @param _recipient User to tranfer the tokens to 
     * @param _amount The amount of tokens to transfer
     * @return True if the transfer was successful
     */
    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns(bool){
        _mintAccruedInterest(_sender);
        _mintAccruedInterest(_recipient);
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_sender);
        }
        if (balanceOf(_recipient) == 0){
            s_userInterestRate[_recipient] = s_userInterestRate[_sender];
        }
        return super.transferFrom(_sender, _recipient, _amount);
    }

    /**
     * @notice Get the token balance of the user. This is the number of tokens that have currently been minted to the 
     * user. excluding interest afer the last time they interacted with protocol
     * @param _user User that we will be returning balance of 
     */
    function principleBalanceOf(address _user) external view returns(uint256) {
        return balanceOf(_user);
    }

    /**
     * @notice Get the interest rate of for the contract currently for future depositors
     */
    function getInterestRate () public view returns(uint256){
        return s_interestRate;
    }
 
    /**
     * @notice Burns the user tokens when they withdraw from the vault
     * @param _from The user to burn the tokens from 
     * @param _amount Amount of tokens to burn
     */
    function burn(address _from, uint256 _amount) external {
        if (_amount == type(uint256).max ) {
            _amount = balanceOf(_from);
        }
        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }
}
