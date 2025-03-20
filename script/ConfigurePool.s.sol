// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24

import {Script} from "forge-std/Script.sol";

contract ConfigurePoolScript is Script {
    function run(
        address localPool,
        uint256 remoteChainSelector,
        address remotePool,
        address remoteToken,
        bool outboundRateLimiterCapacityisEnabled,
        uint128 outboundRateLimiterCapacity,
        uint128 outboundRateLimiterRate,
        bool inboundRateLimiterCapacityisEnabled,
        uint128 inboundRateLimiterCapacity,
        uint128 inboundRateLimiterRate,
    ) public {
        vm.startBroadcast();
        vm.stopBroadcast();

    }
}
