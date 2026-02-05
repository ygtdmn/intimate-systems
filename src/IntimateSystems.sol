// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { ContractShow } from "./ContractShow.sol";
import { Sculpture } from "./Sculpture.sol";
import { SculptureERC721 } from "./SculptureERC721.sol";
import { Mod } from "./Mod.sol";
import { WebRenderer, KeyValue } from "./web/WebRenderer.sol";
import { LibString } from "solady/utils/LibString.sol";

contract IntimateSystems is ContractShow {
    Sculpture[] public sculptures;

    mapping(Sculpture => SculptureERC721) public sculptureERC721s;

    Mod public immutable data;

    WebRenderer public renderer;

    constructor(Sculpture[] memory _sculptures, SculptureERC721[] memory _sculptureERC721s, Mod _data) {
        sculptures = _sculptures;

        if (_sculptures.length != _sculptureERC721s.length) {
            revert("Sculptures and sculpture tokens must have the same length");
        }

        for (uint256 i = 0; i < _sculptures.length; i++) {
            sculptureERC721s[_sculptures[i]] = _sculptureERC721s[i];
        }

        data = _data;
    }

    function title() external pure returns (string memory) {
        return "Intimate Systems";
    }

    function authors() external view returns (string[] memory) {
        uint256 length = 1;
        for (uint256 i = 0; i < sculptures.length; i++) {
            try sculptures[i].authors() returns (string[] memory sculptureAuthors) {
                for (uint256 j = 0; j < sculptureAuthors.length; j++) {
                    length++;
                }
            } catch {}
        }
        string[] memory authors_ = new string[](length);
        uint256 index;
        for (uint256 i = 0; i < sculptures.length; i++) {
            try sculptures[i].authors() returns (string[] memory sculptureAuthors) {
                for (uint256 j = 0; j < sculptureAuthors.length; j++) {
                    authors_[index] = sculptureAuthors[j];
                    index++;
                }
            } catch {}
        }
        authors_[index] = data.curator();
        return authors_;
    }

    function addresses() external view returns (address[] memory) {
        uint256 length = 1;
        for (uint256 i = 0; i < sculptures.length; i++) {
            try sculptures[i].addresses() returns (address[] memory sculptureAddresses) {
                for (uint256 j = 0; j < sculptureAddresses.length; j++) {
                    length++;
                }
            } catch {}
        }
        address[] memory addresses_ = new address[](length);
        uint256 index = 1;
        addresses_[0] = address(this);
        for (uint256 i = 0; i < sculptures.length; i++) {
            try sculptures[i].addresses() returns (address[] memory sculptureAddresses) {
                for (uint256 j = 0; j < sculptureAddresses.length; j++) {
                    addresses_[index] = sculptureAddresses[j];
                    index++;
                }
            } catch {}
        }
        return addresses_;
    }

    function text() public view returns (string memory) {
        return data.text();
    }

    function urls() public view returns (string[] memory) {
        return data.urls();
    }

    function html() external view returns (string memory) {
        return renderer.html();
    }

    function resolveMode() external view returns (bytes32) {
        return renderer.resolveMode();
    }

    function request(
        string[] memory resource,
        KeyValue[] memory params
    ) external view returns (uint statusCode, string memory body, KeyValue[] memory headers) {
        return renderer.request(resource, params);
    }

    function getSculptures() public view returns (Sculpture[] memory) {
        return sculptures;
    }

    function getSculptureERC721(Sculpture sculpture) public view returns (SculptureERC721 memory) {
        return sculptureERC721s[sculpture];
    }

    function setSculptures(
        Sculpture[] calldata _sculptures,
        SculptureERC721[] calldata _sculptureERC721s
    ) public onlyOperator {
        if (_sculptures.length != _sculptureERC721s.length) {
            revert("Sculptures and sculpture tokens must have the same length");
        }

        sculptures = _sculptures;

        for (uint256 i = 0; i < _sculptures.length; i++) {
            sculptureERC721s[_sculptures[i]] = _sculptureERC721s[i];
        }
    }

    function setRenderer(WebRenderer _renderer) public onlyOperator {
        renderer = _renderer;
    }

    modifier onlyOperator() {
        if (msg.sender != data.operator()) {
            revert("No permission");
        }
        _;
    }

    fallback() external {
        revert(LibString.toHexString(abi.encodeWithSignature("html()")));
    }
}
