// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Sculpture } from "./Sculpture.sol";
import { SculptureERC721 } from "./SculptureERC721.sol";

interface ContractShow is Sculpture {
    function getSculptures() external view returns (Sculpture[] memory);

    function getSculptureERC721(Sculpture sculpture) external view returns (SculptureERC721 memory);
}
