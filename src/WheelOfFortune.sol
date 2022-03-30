// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract WheelOfFortune {
    Game[] public games;

    struct Game {
        address player;
        uint256 id;
        uint256 bet;
        uint256 blockNumber;
    }

    function spin(uint256 _bet) public payable {
        require(msg.value >= 0.01 ether, "Insufficient $ETH");
        uint256 gameId = games.length;
        // games.length++;
        games[gameId].id = gameId;
        games[gameId].player = msg.sender;
        games[gameId].bet = _bet;
        games[gameId].blockNumber = block.number;
        if (gameId > 0) {
            uint256 lastGameId = gameId - 1;
            uint256 num = rand(blockhash(games[lastGameId].blockNumber), 100);
            if (num == games[lastGameId].bet) {
                SafeTransferLib.safeTransferETH(
                    games[lastGameId].player,
                    address(this).balance
                );
            }
        }
    }

    function rand(bytes32 hash, uint256 max)
        private
        pure
        returns (uint256 result)
    {
        // return uint256(keccak256(hash)) % max;
    }
}
