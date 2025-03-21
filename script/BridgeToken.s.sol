// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {IRouterClient} from "@ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@ccip/contracts/src/v0.8/ccip/libraries/Client.sol";


contract BridgeTokenScript is Script {
    function run(uint64 destinationChainSelector, address routerAddress) public {
        vm.startBroadcast();
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            
        });
        IRouterClient(routerAddress).ccipSend(destinationChainSelector, message);


        vm.stopBroadcast();
    }
}