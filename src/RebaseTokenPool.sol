// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TokenPool} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RebaseTokenPool is TokenPool{
    constructor(IERC20 _token, address[] memory _allowList, address _rmnProxy, address _router) TokenPool(_token, _allowList, _rmnProxy, _router) {

    }

}