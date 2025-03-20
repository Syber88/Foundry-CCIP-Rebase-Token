// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24

import {Script} from "forge-std/Script.sol";
import {TokenPool} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";
import {RateLimiter} from "@ccip/contracts/src/v0.8/ccip/libraries/RateLimiter.sol";



contract ConfigurePoolScript is Script {
    function run(
        address localPool,
        uint256 remoteChainSelector,
        address remotePool,
        address remoteToken,
        bool outboundRateLimiterisEnabled,
        uint128 outboundRateLimiterCapacity,
        uint128 outboundRateLimiterRate,
        bool inboundRateLimiterCapacityisEnabled,
        uint128 inboundRateLimiterCapacity,
        uint128 inboundRateLimiterRate,
    ) public {
        vm.startBroadcast();
        bytes[] memory remotePoolAddresses = new bytes[](1);
        TokenPool.ChainUpdate[] memory chainsToAdd = new TokenPool.ChainUpdate[](1);
        chainsToAdd[0] = TokenPool.ChainUpdate({
            remoteChainSelector: remoteChainSelector,
            remotePoolAddresses: remotePoolAddresses,
            remoteTokenAddress: abi.encode(remoteToken),
            outboundRateLimiter: RateLimiter.Config({
                isEnabled: outboundRateLimiterisEnabled,
                rate: outboundRateLimiterRate,
                capacity: outboundRateLimiterCapacity
            }),
            inboundRateLimiter: RateLimiter.Config({
                isEnabled: inboundRateLimiterisEnabled,
                rate: inboundRateLimiterRate,
                capacity: inboundRateLimiterCapacity
            })
        });
        vm.stopBroadcast();

    }
}
