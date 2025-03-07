// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {Vault} from "../src/Vault.sol";

contract RebaseTokenTest is Test {
    RebaseToken private rebaseToken;
    Vault private vault;

    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        rebaseToken = new RebaseToken();
        vault = new Vault(IRebaseToken(address(rebaseToken)));
        rebaseToken.grantMintAndBurnRole(address(vault));
        (bool success,) = payable(address(vault)).call{value: 1e18}("");
        vm.stopPrank();
    }

    

    function testDepositLinear(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        // deposit
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        // check our rebase token balance
        uint256 startBalance = rebaseToken.balanceOf(user);
        console.log("starting balance: ", startBalance);
        assertEq(startBalance, amount);

        //warp time and check balances again
        vm.warp(block.timestamp + 1 hours);
        uint256 middleBalance = rebaseToken.balanceOf(user);
        assert(middleBalance > startBalance);

        //warp time and check balances again
        vm.warp(block.timestamp + 1 hours);
        uint256 endBalance = rebaseToken.balanceOf(user);
        assertGt(endBalance, middleBalance);

        assertApproxEqAbs((endBalance - middleBalance), (middleBalance - startBalance), 1);
        vm.stopPrank();
    }

    function testRedeemStraightAway(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        vm.startPrank(user);
        vm.deal(user, amount);
        //deposit
        vault.deposit{value: amount}();
        assertEq(rebaseToken.balanceOf(user), amount);
        //redeem
        vault.redeem(type(uint256).max);
        assertEq(rebaseToken.balanceOf(user), 0);
        assertEq(address(user).balance, amount);
        vm.stopPrank();
    }

    function testRedeenAfterSomeTimePassed(uint256 depositAmount, uint256 time) public {
        time = bound(time, 1000, type(uint256).max);
        depositAmount = bound(depositAmount, 1e5, type(uint256).max);
        //deposit
        vm.startPrank(user);
        vault.deposit{value: depositAmount}();
        //warp time
        vm.warp(block.timestamp + time);
        uint256 balance = rebaseToken.balanceOf(user);
        //redeem
        vault.redeem(type(uint256).max);
        vm.stopPrank();

        uint256 ethBalance = address(user).balance;

        assertEq(balance, ethBalance);

    }
}
