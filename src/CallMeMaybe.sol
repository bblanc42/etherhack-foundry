// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract CallMeMaybe {
    modifier CallMeMaybe() {
        uint32 size;
        address _addr = msg.sender;
        assembly {
            size := extcodesize(_addr)
        }
        if (size > 0) {
            revert();
        }
        _;
    }

    function HereIsMyNumber() public CallMeMaybe {
        if (tx.origin == msg.sender) {
            revert();
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
        }
    }

    receive() external payable {}
}
