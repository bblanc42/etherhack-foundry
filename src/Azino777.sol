// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract Azino777 {
    using Address for address payable;

    function spin(uint256 bet) public payable {
        require(msg.value >= 0.01 ether, "Insufficient $ETH");
        uint256 num = rand(100);
        if (num == bet) {
            SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
        }
    }

    //Generate random number between 0 & max
    uint256 private constant FACTOR =
        1157920892373161954235709850086879078532699846656405640394575840079131296399;

    function rand(uint256 max) private view returns (uint256) {
        uint256 factor = (FACTOR * 100) / max;
        uint256 lastBlockNumber = block.number - 1;
        uint256 hashVal = uint256(blockhash(lastBlockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }

    receive() external payable {}
}
