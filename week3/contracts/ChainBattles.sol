// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    struct Warrior {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // mapping(uint256 => uint256) public tokenIdToLevels;
    mapping(uint256 => Warrior) public tokenIdToWarrior;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function random(uint256 number) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % number;
    }

    function generateCharacter(uint256 tokenId) public returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getLevels(tokenId),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            tokenIdToWarrior[tokenId].speed.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength:",
            tokenIdToWarrior[tokenId].strength.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life:",
            tokenIdToWarrior[tokenId].life.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToWarrior[tokenId].level;
        return levels.toString();
    }

    function getTokenURI(uint256 tokenId) public returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '",',
            '"attributes": [',
            "{",
            '"trait_type": "Level",',
            '"value":"',
            getLevels(tokenId),
            '"',
            "},",
            "{",
            '"trait_type": "Speed",',
            '"value":"',
            tokenIdToWarrior[tokenId].speed.toString(),
            '"',
            "},",
            "{",
            '"trait_type": "Strength",',
            '"value":"',
            tokenIdToWarrior[tokenId].strength.toString(),
            '"',
            "},",
            "{",
            '"trait_type": "Life",',
            '"value":"',
            tokenIdToWarrior[tokenId].life.toString(),
            '"',
            "}",
            "]",
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToWarrior[newItemId] = Warrior(
            0,
            random(10),
            random(10),
            random(10)
        );
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );
        Warrior memory w = tokenIdToWarrior[tokenId];
        tokenIdToWarrior[tokenId] = Warrior(
            w.level + 1,
            w.speed + 3,
            w.strength + 3,
            w.life + 3
        );
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
