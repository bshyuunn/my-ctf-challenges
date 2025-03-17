// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HyuunnToken} from "./HyuunnToken.sol";

contract Setup {
    HyuunnToken public hyuunnTokenContract;

    constructor() payable {
        hyuunnTokenContract = new HyuunnToken();
        hyuunnTokenContract.deposit{value: 10 ether}(10 ether);
        hyuunnTokenContract.transferOwnership(msg.sender);
    }

    function isSolved() public view returns (bool) {
        return address(hyuunnTokenContract).balance == 0;
    }

}