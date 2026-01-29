// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import "forge-std/Script.sol";
import "../src/draft/APlaceFound.sol";
import "../src/draft/KOD.sol";

contract DeploySculptures is Script {
    function run() public returns (APlaceFound aPlaceFound, KOD kod) {
        vm.startBroadcast();
        aPlaceFound = new APlaceFound();
        kod = new KOD();
        vm.stopBroadcast();
    }
}
